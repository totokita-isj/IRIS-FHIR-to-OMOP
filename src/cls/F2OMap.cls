/// Code mapping table from FHIR to OMOP
Class OMOPDTL.F2OMap Extends %Persistent
{

Property Key As %String(MAXLEN = 100) [ SqlColumnNumber = 2 ];

Property "Source_Code" As %String(MAXLEN = 100) [ SqlColumnNumber = 3 ];

Property "Source_Name" As %String(MAXLEN = 255) [ SqlColumnNumber = 4 ];

Property "OMOP_Concept_Id" As %Integer [ InitialExpression = 0, SqlColumnNumber = 5 ];

Index "PK_F2OMap" On ("Key", "Source_Code") [ IdKey ];


}
