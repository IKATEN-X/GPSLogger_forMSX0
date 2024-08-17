1000 'SAVE"GPS.BAS",A:SAVE"AUTOEXEC.BAS"
1010 'Initialize
1020   SCREEN 0:WIDTH 40:CLEAR 1000
1030   MAXFILES=3:DIM DA$(20)
1040   DQ$=CHR$(&H22):NL$=CHR$(13)+CHR$(10)
1050 'User Setting
1060   CH$="81779"            'channel ID
1070   WK$="af3f3bb1cdf7a821" 'write key
1080   PA$="msx/me/if/NET0/"  'path
1090   CALL COMINI("0:8N1NH",9600)
1100   OPEN "COM:" AS #1
1110   PRINT #1,"$PCAS03,9,0,0,0,0,0,0,0*0B" 'Set data kinds
1120   C=LOC(1):IF C>0 THEN INPUT$(C,#1)
1130   CLOSE #1
1140   OPEN "COM:" AS #1
1150   OPEN "GPS_LOG.TXT" FOR APPEND AS #2
1160 'Main Loop
1170   C=LOC(1):IF C=0 THEN 1170
1180   INPUT #1,A$:IF A$="$GNGGA" THEN DA$(0)=">>"+A$:JZ=1 ELSE DA$(JZ)=A$:JZ=JZ+1
1190   IF INSTR(A$,"*") THEN GOSUB 1210:JZ=0
1200   GOTO 1170
1210 'Print Time and Location
1220   GOSUB 1380 ' Upload to Ambient
1230   GOSUB 1260 ' Write LOG to File
1240   FOR I=0 TO JZ-1:DA$(I)="":NEXT
1250   RETURN
1260   '
1270   PRINT #2, "UTC ";MID$(DA$(1),1,2);":";MID$(DA$(1),3,2);":";MID$(DA$(1),5,2);" ";
1280   PRINT #2, DA$(3);
1290   D$=DA$(2):GOSUB 1330:PRINT #2, USING " ###.###### ";R;
1300   PRINT #2, DA$(5);
1310   D$=DA$(4):GOSUB 1330:PRINT #2, USING " ###.###### ";R
1320   RETURN
1330 'Convert
1340   V0=VAL(D$):V1=INT(V0/100)
1350   V2=(V0-V1*100)/60
1360   R=V1+V2
1370   RETURN
1380 'Upload to Ambient
1390   D$=DA$(2):IF D$<>"" THEN GOSUB 1330:LT$=MID$(STR$(R),2) ELSE PRINT"No Position":RETURN
1400   D$=DA$(4):IF D$<>"" THEN GOSUB 1330:LG$=MID$(STR$(R),2) ELSE PRINT"No Position":RETURN
1410   _IOTPUT(PA$+ "conf/addr","54.65.206.59")
1420   _IOTPUT(PA$+ "conf/port",80)
1430   _IOTPUT(PA$+ "connect",1)
1440 'check connect status
1450   FOR I=0 TO 100:NEXT
1460   _IOTGET(PA$+ "connect",S)
1470   IF S<>1 THEN PRINT "connect fail":GOTO 1770
1480 'get sensor value
1490   _IOTGET("host/battery/level", D1)
1500 'create message
1510   CN$="{"+DQ$+"writeKey"+DQ$+":"+DQ$+WK$+DQ$+","
1520   CN$=CN$+DQ$+"d1"+DQ$+":"+DQ$+STR$(D1)+DQ$+","
1530   CN$=CN$+DQ$+"lat"+DQ$+":"+DQ$+LEFT$(LT$,8)+DQ$+","
1540   CN$=CN$+DQ$+"lng"+DQ$+":"+DQ$+LEFT$(LG$,9)+DQ$+","
1550   CN$=CN$+DQ$+"d2"+DQ$+":"+DQ$+LT$+DQ$+","
1560   CN$=CN$+DQ$+"d3"+DQ$+":"+DQ$+LG$+DQ$
1570   CN$=CN$+"}"+NL$
1580   SM$(0)="POST /api/v2/channels/"+CH$+"/data HTTP/1.1"+NL$
1590   SM$(1)="Host: 54.65.206.59"+NL$
1600   SM$(2)="Content-Length:"+STR$(LEN(CN$))+NL$
1610   SM$(3)="Content-Type: application/json"+NL$
1620   SM$(4)=""+NL$
1630   SM$(5)=CN$
1640   SM$(6)=""
1650 'send message
1660   PRINT NL$+"---- Send Message ----"
1670   PRINT "Bat:";D1;"Lat:";LT$;"/Lng:";LG$
1680   I=0
1690   IF SM$(I)<>"" THEN _IOTPUT(PA$+ "msg",SM$(I)):I=I+1:GOTO 1690
1700 'receive message
1710 '  PRINT NL$+"---- Receive Message ----"
1720   FOR J=0 TO 10
1730  _IOTGET(PA$+ "msg",RM$)
1740 'PRINTRM$;
1750 'FOR I=0 TO 100:NEXT
1760   NEXT
1770 'disconnet
1780 _IOTPUT(PA$+ "connect",0)
1790  RETURN
