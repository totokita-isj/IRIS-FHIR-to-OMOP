Class OMOPDTL.TableList Extends %Persistent
{

Property TableName As %String(MAXLEN = 100) [ SqlColumnNumber = 2 ];

Property TableAbbr As %String(MAXLEN = 10) [ SqlColumnNumber = 3 ];

Property SchemaName As %String(MAXLEN = 100) [ SqlColumnNumber = 4 ];

Property KeyColumns As %String(MAXLEN = 255) [ SqlColumnNumber = 5 ];

Property TableType As %String(MAXLEN = 100) [ SqlColumnNumber = 6 ];

Property SourceTableName As %String(MAXLEN = 100) [ SqlColumnNumber = 7 ];

Property SourceSchemaName As %String(MAXLEN = 100) [ SqlColumnNumber = 8 ];

Property LoadSeq As %Integer [ SqlColumnNumber = 9 ];

Index "PK_TableList" On (TableName, SchemaName) [ IdKey ];


}
