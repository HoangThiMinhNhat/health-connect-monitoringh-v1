Class HealthConnect.Monitoring.Messages.InfluxMetricRequest Extends Ens.Request
{
    Property Payload As %String;
Storage Default
{
<Data name="InfluxMetricRequestDefaultData">
<Subscript>"InfluxMetricRequest"</Subscript>
<Value name="1">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>InfluxMetricRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}