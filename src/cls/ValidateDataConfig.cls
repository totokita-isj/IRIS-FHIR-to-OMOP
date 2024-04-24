Class OMOPDTL.ValidateDataConfig Extends %Persistent
{

Property StepOrder As %Integer [ SqlColumnNumber = 2 ];

Property StepOrderSeq As %Integer [ SqlColumnNumber = 3 ];

Property ValidateType As %Integer [ SqlColumnNumber = 4 ];

Property ValidateTable As %String(MAXLEN = 255) [ SqlColumnNumber = 5 ];

Property ValidateColumn As %String(MAXLEN = 255) [ SqlColumnNumber = 6 ];

Property CrossCheckTable As %String(MAXLEN = 255) [ SqlColumnNumber = 7 ];

Property Description As %String(MAXLEN = 255) [ SqlColumnNumber = 8 ];

Index "PK_ValidateDataConfig" On (StepOrder, StepOrderSeq) [ IdKey ];


}
