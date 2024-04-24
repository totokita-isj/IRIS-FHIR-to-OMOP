Class OMOPDTL.ValidationError Extends %Persistent
{

Property TableName As %String(MAXLEN = 100) [ SqlColumnNumber = 2 ];

Property TableId As %BigInt [ SqlColumnNumber = 3 ];

Property ColumnName As %String(MAXLEN = 100) [ SqlColumnNumber = 4 ];

Property ErrorReason As %String(MAXLEN = 255) [ SqlColumnNumber = 5 ];

Property ExecutionDateTime As %DateTime [ SqlColumnNumber = 6 ];


}
