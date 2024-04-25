Class OMOPDTL.Utils Extends %Base [ Language = objectscript ]
{

/* ETLメイン処理 */
ClassMethod EtlMain(pStart As %Integer, pEnd As %Integer) As %Status [ Language = objectscript ]
{
  try {

	/// JobStepListテーブルから実行するステップの一覧を抽出
	SET script1 = "SELECT StepOrder, StepOrderSeq, StepName, ExecutionClassMethod, ExecutionParameter FROM OMOPDTL.JobStepList "_
			  "WHERE StepOrder BETWEEN ? AND ? "_
			  "ORDER BY StepOrder, StepOrderSeq"
    	SET stmt1=##class(%SQL.Statement).%New()
    	SET status1=stmt1.%Prepare(script1)
    	IF status1'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(status1) QUIT}
    	SET rset1=stmt1.%Execute(pStart,pEnd)

    	WHILE rset1.%Next()
  			{
	  			SET order = rset1.StepOrder
	  			SET orderseq = rset1.StepOrderSeq
	  			SET stepname = rset1.StepName
	  			SET classmethod = rset1.ExecutionClassMethod
	  			SET parameter = rset1.ExecutionParameter
	  			/// 開始時刻をセット
				SET starttime = $SYSTEM.Util.UTCtoLocalWithZTIMEZONE($ZTIMESTAMP)

	  			/// ExecutionClassMethodの値を基に、クラスメソッドを実行
	  			SET exec=$CLASSMETHOD("OMOPDTL.Utils", classmethod, parameter)
	  			
				/// 終了時刻をセット
    				SET endtime = $SYSTEM.Util.UTCtoLocalWithZTIMEZONE($ZTIMESTAMP)
    
   				/// 実行ログを OMOPDTL.ExecutionLog に書き込み
				SET starttimelt = $ZDATETIME(starttime, 3, 1, 3)
				SET endtimelt = $ZDATETIME(endtime, 3, 1, 3)
	
    				SET logstmt=##class(%SQL.Statement).%New()
    
    				SET status=logstmt.%Prepare("INSERT INTO OMOPDTL.ExecutionLog VALUES (?, ?, ?, ?)")
    				IF status'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(status) QUIT}
    				SET logrset=logstmt.%Execute(order, stepname, starttimelt, endtimelt)
				
	  		}

  }

  Catch e {
	do e.OutputToDevice()
	zwrite   
  }

  QUIT status1
}

/* マッピングテーブルデータをExcelファイルからOMOPDTL.F2OMapへロード */
ClassMethod LoadMappingTable(pFilePath As %String) [ Language = python ]
{

	# ライブラリのインポート
	import iris
	import pandas as pd
	import pyodbc
	
	input_file = pd.ExcelFile(pFilePath)
	sheet_names = input_file.sheet_names

	sheet_df = input_file.parse(sheet_names)
	
	# ODBC接続定義
	server = 'localhost'
	database = 'OMOP'
	username = '_SYSTEM'
	password = 'SYS'
	cnxn = pyodbc.connect('DRIVER={InterSystems IRIS ODBC35};SERVER='+server +
                      ';DATABASE='+database+';UID='+username+';PWD=' + password)
	cursor = cnxn.cursor()

	for i, name in enumerate(sheet_names):
		sheet_df[i] = input_file.parse(name)

		# シート名が"List"以外のシートを読み込み
		if name != 'List':
			for index, row in sheet_df[i].iterrows():
				cursor.execute("INSERT OR UPDATE OMOPDTL.F2OMap (Key, Source_Code, Source_Name, OMOP_Concept_Id) values(?,?,?,?)", name, row.Source_Code, row.Source_Name, row.OMOP_Concept_Id)

	cnxn.commit()
	cursor.close()
}

/* 項目バリデーション (入力必須カラムのNULLチェック、参照先テーブルのレコード存在チェック) */
ClassMethod ValidateData(pValidateType As %Integer) As %Status [ Language = objectscript ]
{
  try {
		
	  	/// JobStepListテーブルから実行するステップの一覧を抽出
		SET script1 = "SELECT "_
		          "vdc.StepOrder as StepOrder, "_
		          "vdc.StepOrderSeq as StepOrderSeq, "_
		          "vdc.ValidateType as ValidateType, "_
		          "tl1.SchemaName as ValidateSchema, "_
		          "vdc.ValidateTable as ValidateTable, "_
		          "tl1.TableAbbr as ValidateTableAbbr, "_
		          "vdc.ValidateColumn as ValidateColumn, "_
		          "tl1.KeyColumns as ValidateTableKeys, "_
		          "tl2.SchemaName as CrossCheckSchema, "_
		          "tl2.TableName as CrossCheckTable,"_
		          "tl2.TableAbbr as CrossCheckTableAbbr, "_
		          "tl2.KeyColumns as CrossCheckKeys "_
		          "FROM OMOPDTL.ValidateDataConfig vdc "_
		          "LEFT OUTER JOIN OMOPDTL.TableList tl1 ON vdc.ValidateTable = tl1.TableName "_
		          "LEFT OUTER JOIN OMOPDTL.TableList tl2 ON vdc.CrossCheckTable  = tl2.TableName  "_
			  "WHERE vdc.ValidateType = ? "_
			  "ORDER BY vdc.StepOrder, vdc.StepOrderSeq"

    		SET stmt1=##class(%SQL.Statement).%New()
    		SET status=stmt1.%Prepare(script1)
    		IF status'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(status) QUIT}
    		SET rset1=stmt1.%Execute(pValidateType)

		/// 読み込んだ行ごとにエラーチェックのSQL実行
    		WHILE rset1.%Next()
  			{
	  			SET order = rset1.StepOrder
	  			SET seq = rset1.StepOrderSeq
	  			SET type = rset1.ValidateType
	  			SET schema = rset1.ValidateSchema
	  			SET table = rset1.ValidateTable
	  			SET column = rset1.ValidateColumn
	  			SET abbr = rset1.ValidateTableAbbr
	  			SET key = rset1.ValidateTableKeys
	  			
	  			SET ccschema = rset1.CrossCheckSchema
	  			SET cctable = rset1.CrossCheckTable
	  			SET ccabbr = rset1.CrossCheckTableAbbr
	  			SET cckey = rset1.CrossCheckKeys

				IF type = 1 {
		  			SET script2 = "INSERT INTO OMOPDTL.ValidationError "_
		  						  "(TableName, TableId, ColumnName, ErrorReason, ExecutionDateTime) "_
	  							  "SELECT '"_table_"', "_key_", '"_column_"','必須項目値がNULL', NOW()"_
	  							  " FROM "_schema_"."_table_
	  							  " WHERE "_column_" IS NULL"
				}
				ELSEIF type = 2 {
		  			SET script2 = "INSERT INTO OMOPDTL.ValidationError "_
		  						  "(TableName, TableId, ColumnName, ErrorReason, ExecutionDateTime) "_
	  							  "SELECT '"_table_"', "_key_", '"_column_"','参照先に存在しない (参照先: "_cctable_")', NOW()"_
		  						  " FROM "_schema_"."_table_" "_abbr_
	  							  " LEFT OUTER JOIN "_ccschema_"."_cctable_" "_ccabbr_
	  							  " ON "_abbr_"."_column_" = "_ccabbr_"."_cckey_
	  							  " WHERE "_abbr_"."_column_" IS NULL"_
	  							  " OR "_abbr_"."_column_" < 0"
				}
				/// write order, seq, table & column for debug purpose
				/// WRITE order_" | "_seq_" | "_table_" | "_column, !, script2, !, !
				
		    		SET stmt2=##class(%SQL.Statement).%New()
    				SET status=stmt2.%Prepare(script2)
    				IF status'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(status) QUIT}
    				SET rset2=stmt2.%Execute()

	  		}

  }

  Catch e {
	do e.OutputToDevice()
	zwrite   
  }

  QUIT status
}

/* ソースデータをOMOPテーブルにロード */
ClassMethod LoadOmopTable(pTableType As %String) As %Status [ Language = objectscript ]
{
	
	try {

		/// 対象テーブルのリストを取得
		SET tabletype = pTableType
		SET script1 = "SELECT t.TableType, t.SourceSchemaName, t.SourceTableName, t.SchemaName, t.TableName, "_
				  "LIST(CASE WHEN tf.IsTextToDate = 1 THEN 'TO_DATE(' || tf.FieldName || ', ''YYYYMMDD'')' ELSE tf.FieldName END) AS SourceFieldList, "_
				  "LIST(tf.FieldName) AS TargetFieldList "_
				  "FROM OMOPDTL.TableList t "_
				  "INNER JOIN OMOPDTL.TableFieldList tf ON t.TableName = tf.TableName "_
				  "WHERE t.TableType = ? "_
				  "GROUP BY t.TableType, t.SourceSchemaName, t.SourceTableName, t.SchemaName, t.TableName "_
				  "ORDER BY t.LoadSeq"
    		SET stmt=##class(%SQL.Statement).%New()
    		SET status=stmt.%Prepare(script1)
    		IF status'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(status) QUIT}
    		SET rset=stmt.%Execute(tabletype)
    
    		/// Vocabularyテーブルのロードの場合は、先にターゲットテーブルをTRUNCATEする
    		IF tabletype="Vocabulary"  {
	    		do ..TruncateOmopTable(tabletype)
	    	}
    
    		WHILE rset.%Next()
  			{
	  		
			/// SQL文(INSERT OR UPDATE)の生成
			SET sourceschema = rset.SourceSchemaName
			SET sourcetable = rset.SourceTableName
			SET sourcefieldlist = rset.SourceFieldList
			SET targetschema = rset.SchemaName
			SET targettable = rset.TableName
			SET targetfieldlist = rset.TargetFieldList

			SET script2 = "INSERT OR UPDATE %NOCHECK %NOJOURN %NOLOCK "_targetschema_"."_targettable_
					 " ("_targetfieldlist_") "_
					 "SELECT "_sourcefieldlist_" "_
					 "FROM "_sourceschema_"."_sourcetable
			
			/// INSERT OR UPDATE文の実行
			do ..ExecLoadSql(targettable, script2)

  			}
  	}
  	
	Catch e {
		do e.OutputToDevice()
		zwrite   
 	}

 	QUIT status
}

/* OMOPテーブルロード用SQL文の実行 */
ClassMethod ExecLoadSql(pTable As %String, pScript As %String) As %Status [ Language = objectscript ]
{
	
  try {

    	SET status = $$$OK 
	SET tablename = pTable
	/// 開始時刻をセット
    	SET starttime = $SYSTEM.Util.UTCtoLocalWithZTIMEZONE($ZTIMESTAMP)

    	SET statemt=##class(%SQL.Statement).%New()
    
    	SET status=statemt.%Prepare(pScript) 
    	IF status'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(status) QUIT}
    	SET rset=statemt.%Execute()
    
	/// 終了時刻をセット
    	SET endtime = $SYSTEM.Util.UTCtoLocalWithZTIMEZONE($ZTIMESTAMP)
    
    	/// 実行ログを OMOPDTL.TableLoadLog に書き込み
	SET starttimelt = $ZDATETIME(starttime, 3, 1, 3)
	SET endtimelt = $ZDATETIME(endtime, 3, 1, 3)
	
    	SET logstmt=##class(%SQL.Statement).%New()
    
    	SET status=logstmt.%Prepare("INSERT INTO OMOPDTL.TableLoadLog VALUES (?, ?, ?)")
    	IF status'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(status) QUIT}
    	SET logrset=logstmt.%Execute(tablename, starttimelt, endtimelt)
    
  }
  Catch e {
	do e.OutputToDevice()
	zwrite   
  }

  QUIT status
}

/* OMOPテーブルのTRUNCATE */
ClassMethod TruncateOmopTable(pTableType As %String) As %Status [ Language = objectscript ]
{
	
  try {

	/// 対象テーブルのリストを取得
	SET tabletype = pTableType
	SET script1 = "SELECT t.TableType, t.SchemaName, t.TableName "_
				  "FROM OMOPDTL.TableList t "_
				  "WHERE t.TableType = ? "_
				  "ORDER BY t.LoadSeq DESC"
    	SET stmt=##class(%SQL.Statement).%New()
    	SET status=stmt.%Prepare(script1)
    	IF status'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(status) QUIT}
    	SET rset=stmt.%Execute(tabletype)
    
    
   	WHILE rset.%Next()
  		{
	  		
		/// SQL文(TRUNCATE TABLE)の生成
		SET targetschema = rset.SchemaName
		SET targettable = rset.TableName

		SET script2 = "TRUNCATE TABLE %NOCHECK %NOLOCK %NOJOURN "_targetschema_"."_targettable
			
		/// TRUNCATE TABLE文の実行
	    	SET stmt2=##class(%SQL.Statement).%New()
    		SET status=stmt2.%Prepare(script2)
    		IF status'=1 {WRITE "%Prepare failed:" DO $System.Status.DisplayError(status) QUIT}
    		SET rset2=stmt2.%Execute()

  		}
  	}
  	
	Catch e {
		do e.OutputToDevice()
		zwrite   
 	}

 	QUIT status
}

}
