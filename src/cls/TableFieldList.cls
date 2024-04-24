Class OMOPDTL.TableFieldList Extends %Persistent
{

Property TableName As %String(MAXLEN = 200) [ SqlColumnNumber = 2 ];

Property FieldName As %String(MAXLEN = 200) [ SqlColumnNumber = 3 ];

Property IsTextToDate As %Boolean [ SqlColumnNumber = 4 ];

Index IdxFileTypeField On (TableName, FieldName) [ IdKey ];


}
