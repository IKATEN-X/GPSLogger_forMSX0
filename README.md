# GPSLogger_forMSX0
--GPSユニット「AT6558」を使っていた場所をロギングするBASICプログラム--  
MSX0のファームウェア　Ver.0.11.08が公開され、UART（シリアル通信）が使えるようになり、サンプルでGPSの使い方が公開されたので、それを流用してIoTデータの可視化サービス「Ambient」にアップできるようにしたものです。  

本プログラムを、利用するためには、以下の環境を整える必要があります。  
* GPSユニット「AT6558」  
https://docs.m5stack.com/ja/unit/gps  
これが無いと始まりません(^^;  
これを、Port Bに接続してください。  

* インターネット接続
スマホのテザリングやモバイルルーターでインターネット接続できるようにする必要があります。  
MSX0のLTEユニットがあれば、単体で通信が行えるかもしれませんが、持っていないの詳細は分かりません。  
  
* Ambientアカウントとチャネル  
  ロギングした位置情報を保存し、可視化するために利用します。  
  https://ambidata.io/  
  このURLにアクセスして、アカウントを開設してください。無料でチャネル（データを保存する枠）を8個まで持つことができます。  
  （アカウント開設方法はサイトに従って行ってください。ここでは割愛します）  
  <img src="https://github.com/IKATEN-X/GPSLogger_forMSX0/blob/main/image1.jpg?raw=true" width="500">  
  Ambientにログインすると、ページ上部にメニューが表示されていますので、その中から「チャネル・ボード」を選び、「チャネル一覧」をクリック。  
  チャネル一覧ページに入ると「チャネルを作る」ボタンを押すと、チャネルが１つ作成されます。  
  この際。ページに表示されている「チャネルID」と「ライトキー」が必要です。  
  作成したチャネルの行にある「設定」でチャネル名や8個まで持てる項目に管理しやすい名前を付けてください。
  この部分はプログラムには影響しません。  
  
上記３つがそろっていれば使えますが、オフラインでも元々のサンプルにあったファイルにログを書き出す処理は残しています。    
    
Ambientにアップロードしたログを地図にプロットするには、別途ボードの作成が必要です。  
ページ上部にメニューが表示されていますので、その中から「チャネル・ボード」を選び、「ボード一覧」をクリック。  
ボード一覧ページに入ると「ボードを作る」ボタンを押すと、ボードが１つ作成されます。  
作成されたボード名をクリックすると、真っ白な画面が表示されますので、どのデータをどのように表示するかの設定をここで行います。  
ページ上部にチャート追加のボタン  <img src="https://github.com/IKATEN-X/GPSLogger_forMSX0/blob/main/image2.jpg?raw=true"> が表示されていますので、それをクリック。  
チャート作成中の表示が追加されるので、その中の「チャネル/データ設定」をクリック。
(m
チャート名を設定し、チャネルを選んでください。  
チャート種類は「地図」を選択してください。  
表示件数は、ひと塊で表示する件数なので適当に設定してください。10秒に1個のログを残すので360ぐらいが1時間ぐらいの目安です。  

Ambientでの設定は以上です。  
次にプログラムの変更です。  

チャネル作成時に必要と書いていた「チャネルID」と「ライトキー」をプログラムに設定する必要があります。  
1060行目が「チャネルID」、1070行目が「ライトキー」の設定箇所です。  
  
■最後に...  
サンプルにAmbientへのアップロード処理を追加するだけで楽勝！…と思っていましたが、サンプルのままだと、シリアル通信のバッファからデータを取り出すところでうまく歩調をあわせられなくなり難儀しました。カンマ・改行区切りのデータは「INPUT #1､文字列$」の方が便利ですね。
