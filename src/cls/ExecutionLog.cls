Class OMOPDTL.ExecutionLog Extends %Persistent
{

Property StepOrder As %BigInt [ SqlColumnNumber = 2 ];

Property StepName As %String(MAXLEN = 100) [ SqlColumnNumber = 3 ];

Property StartTime As %DateTime [ SqlColumnNumber = 4 ];

Property EndTime As %DateTime [ SqlColumnNumber = 5 ];


}
