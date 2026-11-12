
Class HealthConnect.Monitoring.Messages.InfluxMetricResponse Extends Ens.Response
{
    Property HTTPStatus As %Integer;
    Property Success As %Boolean;
    Property ResponseBody As %String(MAXLEN = 1000000);
    Property ErrorCode As %String(MAXLEN = 255);
    Property SessionID As %String(MAXLEN = 255);

    Storage Default
    {
        <Data name="InfluxMetricResponseDefaultData">
<Subscript>"InfluxMetricResponse"</Subscript>
<Value name="1">
<Value>HTTPStatus</Value>
</Value>
<Value name="2">
<Value>Success</Value>
</Value>
<Value name="3">
<Value>ResponseBody</Value>
</Value>
<Value name="4">
<Value>ErrorCode</Value>
</Value>
<Value name="5">
<Value>SessionID</Value>
</Value>
</Data>
<DefaultData>InfluxMetricResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
    }
}
