# IRIS-FHIR-to-OMOP
InterSystems IRIS for Health を用いてFHIRリポジトリのデータをOMOP CDM形式に変換するプログラムの試行版です。

## ディレクトリ構成
```
root/  
  ├ file/  
  │  ├ FHIR/  ・・・・・・テスト用FHIRリソースデータ  
  │  ├ OMOP/  ・・・・・・OMOPボキャブラリファイル（サイズ制限のためファイルは配置せず）  
  │  └ Utils/ ・・・・・・データ変換設定に使用するデータ  
  └ src/  
      ├ cls/ ・・・・・・・OMOPDTLパッケージ内クラス定義  
      ├ ddl/ ・・・・・・・テーブル、インデックス作成用DDL  
      └ fsb_transform/ ・・FHIR SQL Builderでの変換定義  
```

## インストール手順

1. IRIS for Health 設定
  - バージョンは2023.3以降のものを使用する
  - Pythonライブラリについて、pandas, pyodbc, openpyxl をインストールする必要がある  
  インストール方法はオンラインドキュメントを参照
  https://docs.intersystems.com/iris20231/csp/docbookj/DocBook.UI.Page.cls?KEY=AEPYTHON#AEPYTHON_callpython
  - ODBCドライバをインストールする必要がある  
  インストール方法はオンラインドキュメントを参照
  https://docs.intersystems.com/iris20231/csp/docbookj/DocBook.UI.Page.cls?KEY=BNETODBC_intro
  - ネームスペース名は任意だが、「相互運用プロダクション用にネームスペースを有効化」を ON にして作成する

2. FHIRリポジトリ作成
  - 1.で作成したネームスペースにリポジトリを作成する
  - Core FHIR package はバージョン4.0.1(hl7.fhir.r4.core@4.0.1)で作成する
  - 作成後に、FHIR SQL Builderでサンプリングするためのテストデータをロードする必要がある  
    コマンド例：
    ```
    Set status = ##class(HS.FHIRServer.Tools.DataLoader).SubmitResourceFiles("/home/irisowner/file/FHIR","FHIRServer","/csp/healthshare/omop/fhir/r4")
    ```  
    1番目の引数にテストデータのディレクトリを、3番目の引数にFHIRリポジトリのURLを指定する

3. FHIR SQL Builder設定
    1. Repository Configuration
    - SuperUserなど管理者権限を持つアカウントを用いて、Credentials設定を作成する
    - FHIR Repository Configuration設定を作成する
      - Name = OmopRepo
      - Host = FHIRリポジトリのホスト名
      - Port = FHIRリポジトリのWebサーバポート番号
      - Credentials = 作成したCredentials名
      - FHIR Repository URL = FHIRリポジトリのURL
      
    2. Analyses
    - Analysis設定を作成する
      - FHIR Repository = OmopRepo
      - Selectivity Percentage = 100 (データ量に応じて適宜変更)
      
    3. Transformation Specification
    - ファイルからインポートして設定
      - Name = インポートされた名前のままとする
      - Analysis = 作成したAnalysis設定を指定
      
    4. Projections
    - 個別にProjection設定を作成する
      - FHIR Repository = OmopRepo
      - Transformation Specification と Package Name は下表の通り

      | Transformation Specification | Package Name |  
      | -- | -- |  
      | OmopTransform_Condition | OMOPSBCND |  
      | OmopTransform_Encounter | OMOPSBENC |  
      | OmopTransform_MedicationAdministration | OMOPSBMED |  
      | OmopTransform_Observation | OMOPSBOBS |  
      | OmopTransform_Organization | OMOPSBORG |  
      | OmopTransform_Patient | OMOPSBPAT |  
      | OmopTransform_Practitioner | OMOPSBPRC |  
      | OmopTransform_Procedure | OMOPSBPCD |  

4. IRISオブジェクト作成
    1. OMOPDTLパッケージ クラス作成
    - `%SYSTEM.OBJ` クラスの `LoadDir` メソッドを実行して、クラスファイル(cls)から作成する  
    1つ目の引数はクラスファイルのパス、3つ目の引数は実行ログのパスを指定するよう適宜変更
    ```
    do $SYSTEM.OBJ.LoadDir("/mnt/omop/src/cls","ck","/tmp/OMOPDTL.log",1)
    ```
    
    2. OMOPパッケージ OMOPテーブル作成
    - `%SYSTEM.SQL.Schema` クラスの `ImportDDL` メソッドを実行して、DDLスクリプトから作成する  
    1つ目の引数はDDLスクリプトのパス、2つ目の引数は実行ログのパスを指定するよう適宜変更
    ```
    do $SYSTEM.SQL.Schema.ImportDDL("/home/irisowner/IRIS-FHIR-to-OMOP/src/ddl/OMOP_Vocabulary_Tables_DDL.sql","/tmp/OMOP_Vocabulary_Tables_DDL.log","IRIS")
    do $SYSTEM.SQL.Schema.ImportDDL("/home/irisowner/IRIS-FHIR-to-OMOP/src/ddl/OMOP_Clinical_Tables_DDL.sql","/tmp/OMOP_Clinical_Tables_DDL.log","IRIS")
    ```
    
    3. OMOPFTパッケージ 外部テーブル作成
    - `%SYSTEM.SQL.Schema` クラスの `ImportDDL` メソッドを実行して、DDLスクリプトから作成する  
    1つ目の引数はDDLスクリプトのパス、2つ目の引数は実行ログのパスを指定するよう適宜変更
    - コマンド実行前に、FOREIGN SERVERのファイルパス(スクリプト2行目)を OMOP OSVファイルを配置したパスに変更する  
    ```
    do $SYSTEM.SQL.Schema.ImportDDL("/home/irisowner/IRIS-FHIR-to-OMOP/src/ddl/OMOPFT_Foreign_Tables_DDL.sql","/tmp/OMOPFT_Foreign_Tables_DDL.log","IRIS")
    ```
    
    4. OMOPSTGパッケージ ビュー作成
    - `%SYSTEM.SQL.Schema` クラスの `ImportDDL` メソッドを実行して、DDLスクリプトから作成する  
    1つ目の引数はDDLスクリプトのパス、2つ目の引数は実行ログのパスを指定するよう適宜変更
    ```
    do $SYSTEM.SQL.Schema.ImportDDL("/home/irisowner/IRIS-FHIR-to-OMOP/src/ddl/OMOPSTG_Views_DDL.sql","/tmp/OMOPSTG_Views_DDL.log","IRIS")
    ```

5. 管理テーブルに値を投入
  - いずれも管理ポータル画面、SQLページの ウィザード から データ・インポート で実行
    1. OMOPDTL.JobStepList
    - CSVファイル (./file/Utils/JobStepList.csv) をロード
    
    2. OMOPDTL.TableList
    - CSVファイル (./file/Utils/TableList.csv) をロード
    
    3. OMOPDTL.TableFieldList
    - CSVファイル (./file/Utils/TableFieldList.csv) をロード
    
    4. OMOPDTL.ValidateDataConfig
    - CSVファイル (./file/Utils/ValidationDataConfig.csv) をロード

## ETL処理実行方法
  - ターミナルから OMOPDTL.Utils 内 EtlMain クラスメソッドを実行  
    パラメータは開始ステップ番号(1～5) と 終了ステップ番号(1～5)を指定  
      例： `DO ##class(OMOPDTL.Utils).EtlMain(1,5)`  
    ジョブステップ番号と処理内容は以下の通り  
    | 番号 | 処理内容 |
    | ---- | -------- |
    | 1 | マッピングテーブル(Excel)をロード |
    | 2 | OSVテーブルを外部テーブルからロード |
    | 3 | 品質チェック - 必須入力項目のNULLチェック |
    | 4 | 品質チェック - テーブル間の整合性チェック |
    | 5 | ClinicalDataテーブルをロード |

