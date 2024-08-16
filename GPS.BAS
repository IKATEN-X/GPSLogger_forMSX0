10 'SAVE"GPS.BAS",A:SAVE"AUTOEXEC.BAS"
20 'Initialize
30   SCREEN 0:WIDTH 40:CLEAR 1000
40   MAXFILES=3:DIM DA$(20)
50   DQ$=CHR$(&H22):NL$=CHR$(13)+CHR$(10)
60 'user setting
70   CH$="xxxxx"            'channel ID
80   WK$="yyyyyyyyyyyyyyyy" 'write key
90   PA$="msx/me/if/NET0/"  'path
100   CALL COMINI("0:8N1NH",9600)
110   OPEN "COM:" AS #1
120   PRINT #1,"$PCAS03,9,0,0,0,0,0,0,0*0B" 'Set data kinds
130   C=LOC(1):IF C>0 THEN INPUT$(C,#1)
140   CLOSE #1
150   OPEN "COM:" AS #1
160   OPEN "GPS_LOG.TXT" FOR APPEND AS #2
170 C=LOC(1):IF C=0 THEN 170
180 INPUT #1,A$:IF A$="$GNGGA" THEN DA$(0)=">>"+A$:J=1 ELSE DA$(J)=A$:J=J+1
190 IF INSTR(A$,"*") THEN GOSUB 210:J=0
200 GOTO 170
210 'Print Time and Location
220   '?"D$:";D$:
230   'IF LEFT$(D$,6)<>"$GNGGA" THEN RETURN
240   'GOSUB 1380 ' Split string by ,
250   GOSUB 460 ' Upload to Ambient
260   GOSUB 290 ' Write LOG to File
270   FOR I=0 TO J-1:PRINT DA$(I):DA$(I)="":NEXT
280   RETURN
290   'PRINT #2, D$
300   PRINT #2, "UTC ";MID$(DA$(1),1,2);":";MID$(DA$(1),3,2);":";MID$(DA$(1),5,2);" ";
310   PRINT #2, DA$(3);
320   D$=DA$(2):GOSUB 410:PRINT #2, USING " ###.###### ";R;
330   PRINT #2, DA$(5);
340   D$=DA$(4):GOSUB 410:PRINT #2, USING " ###.###### ";R
350   RETURN
360 'Split string by ,
370   FOR J=0 TO 19
380   A=INSTR(D$,","):IF A<>0 THEN DA$(J)=LEFT$(D$,A-1):D$=MID$(D$,A+1) ELSE J=20
390   NEXT
400   RETURN
410 'Convert
420   V0=VAL(D$):V1=INT(V0/100)
430   V2=(V0-V1*100)/60
440   R=V1+V2
450   RETURN
460 'PRINT #FI, D$
470  D$=DA$(2):IF D$<>"" THEN GOSUB 410:LT$=MID$(STR$(R),2) ELSE PRINT"No Position":RETURN
480  D$=DA$(4):IF D$<>"" THEN GOSUB 410:LG$=MID$(STR$(R),2) ELSE PRINT"No Position":RETURN
490   _IOTPUT(PA$+ "conf/addr","54.65.206.59")
500   _IOTPUT(PA$+ "conf/port",80)
510   _IOTPUT(PA$+ "connect",1)
520 'check connect status
530   FOR I=0 TO 100:NEXT
540   _IOTGET(PA$+ "connect",S)
550   IF S<>1 THEN PRINT "connect fail":GOTO 860
560 'get sensor value
570   _IOTGET("host/battery/level", D1)
580 'create message
590   CN$="{"+DQ$+"writeKey"+DQ$+":"+DQ$+WK$+DQ$+","
600   CN$=CN$+DQ$+"d1"+DQ$+":"+DQ$+STR$(D1)+DQ$+","
610   CN$=CN$+DQ$+"lat"+DQ$+":"+DQ$+LEFT$(LT$,8)+DQ$+","
620   CN$=CN$+DQ$+"lng"+DQ$+":"+DQ$+LEFT$(LG$,9)+DQ$+","
630   CN$=CN$+DQ$+"d2"+DQ$+":"+DQ$+LT$+DQ$+","
640   CN$=CN$+DQ$+"d3"+DQ$+":"+DQ$+LG$+DQ$
650  CN$=CN$+"}"+NL$
660  SM$(0)="POST /api/v2/channels/"+CH$+"/data HTTP/1.1"+NL$
670  SM$(1)="Host: 54.65.206.59"+NL$
680  SM$(2)="Content-Length:"+STR$(LEN(CN$))+NL$
690  SM$(3)="Content-Type: application/json"+NL$
700  SM$(4)=""+NL$
710  SM$(5)=CN$
720  SM$(6)=""
730 'send message
740 PRINT NL$+"---- Send Message ----"
750 PRINT "Bat:";D1;"Lat:";LT$;"/Lng:";LG$
760 I=0
770 IF SM$(I)<>"" THEN _IOTPUT(PA$+ "msg",SM$(I)):I=I+1:GOTO 770
780 'FOR I=0 TO 1000:NEXT
790 'receive message
800 '  PRINT NL$+"---- Receive Message ----"
810   FOR J=0 TO 10
820 _IOTGET(PA$+ "msg",RM$)
830 'PRINTRM$;
840 'FOR I=0 TO 100:NEXT
850   NEXT
860 'disconnet
870 _IOTPUT(PA$+ "connect",0)
880 RETURN
