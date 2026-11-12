
Class HealthConnect.Monitoring.Messages.MetricsRetrieveResponse Extends Ens.Response
{
    Property MetricsPayload As %String(MAXLEN = 1000000);
    Property Success As %Boolean;
    Property ErrorMessage As %String(MAXLEN = 4000);
    Property CorrelationIdentifier As %String(MAXLEN = 255);
Storage Default
{
<Data name="MetricsRetrieveResponseDefaultData">
<Subscript>"MetricsRetrieveResponse"</Subscript>
<Value name="1">
<Value>MetricsPayload</Value>
</Value>
<Value name="2">
<Value>Success</Value>
</Value>
<Value name="3">
<Value>ErrorMessage</Value>
</Value>
<Value name="4">
<Value>CorrelationIdentifier</Value>
</Value>
</Data>
<DefaultData>MetricsRetrieveResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
