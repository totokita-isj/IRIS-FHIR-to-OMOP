Class OMOPDTL.JobStepList Extends %Persistent
{

Property StepOrder As %Integer [ SqlColumnNumber = 2 ];

Property StepOrderSeq As %Integer [ SqlColumnNumber = 3 ];

Property StepName As %String(MAXLEN = 255) [ SqlColumnNumber = 4 ];

Property ExecutionClassMethod As %String(MAXLEN = 255) [ SqlColumnNumber = 5 ];

Property ExecutionParameter As %String(MAXLEN = 100) [ SqlColumnNumber = 6 ];

Property Description As %String(MAXLEN = 255) [ SqlColumnNumber = 7 ];

Index "PK_JobStepList" On (StepOrder, StepOrderSeq) [ IdKey ];


}
