Class HealthConnect.Monitoring.Messages.MetricsRetrieveRequest Extends Ens.Request
{
    Property SelectedMetricIdentifiers As %String(MAXLEN = 4000);
    Property RequestingInstance As %String(MAXLEN = 255);
    Property CorrelationIdentifier As %String(MAXLEN = 255);
Storage Default
{
<Data name="MetricsRetrieveRequestDefaultData">
<Subscript>"MetricsRetrieveRequest"</Subscript>
<Value name="1">
<Value>SelectedMetricIdentifiers</Value>
</Value>
<Value name="2">
<Value>RequestingInstance</Value>
</Value>
<Value name="3">
<Value>CorrelationIdentifier</Value>
</Value>
</Data>
<DefaultData>MetricsRetrieveRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}