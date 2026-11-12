Class HealthConnect.Monitoring.Operations.MetricsRetriever Extends Ens.BusinessOperation
{
 
Parameter ADAPTER = "Ens.OutboundAdapter";
 
Property Server As %String [ InitialExpression = "localhost" ];
 
Property Port As %Integer [ InitialExpression = 52773 ];
 
Property MetricsPath As %String [ InitialExpression = "/api/monitor/metrics" ];
 
Parameter SETTINGS = "Server:Basic,Port:Basic,MetricsPath:Basic";
 
Method OnMessage(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
    Set pResponse = ##class(Ens.StringResponse).%New()
 
    // Create HTTP request.
    Set tHTTP = ##class(%Net.HttpRequest).%New()
    Set tHTTP.Server = ..Server
    Set tHTTP.Port = ..Port
    Set tHTTP.Timeout = 30
 
    // Retrieve all metrics from the API.
    Set tSC = tHTTP.Get(..MetricsPath)
 
    If $$$ISERR(tSC) {
        Quit tSC
    }
 
    // Check HTTP status.
    If tHTTP.HttpResponse.StatusCode '= 200 {
        Quit $$$ERROR($$$GeneralError, "Metrics endpoint returned HTTP status "_tHTTP.HttpResponse.StatusCode)
    }
 
    // Read the complete API response.
    Set tBody = tHTTP.HttpResponse.Data.Read()
 
    // Return all metrics without filtering.
    Set pResponse.StringValue = tBody
 
    Quit $$$OK
}
 
}
