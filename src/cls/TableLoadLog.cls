Class OMOPDTL.TableLoadLog Extends %Persistent
{

Property TableName As %String(MAXLEN = 100) [ SqlColumnNumber = 2 ];

Property StartTime As %DateTime [ SqlColumnNumber = 3 ];

Property EndTime As %DateTime [ SqlColumnNumber = 4 ];


}
