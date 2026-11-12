Class HealthConnect.Monitoring.Operations.EmailAlert Extends Ens.BusinessOperation
{


Parameter ADAPTER = "Ens.OutboundAdapter";

Parameter SETTINGS = "";

Method OnMessage(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
    Set pResponse = ##class(Ens.StringResponse).%New()
    
    // Log the alert content to the IRIS system trace since SMTP is out of scope
    $$$TRACE("EmailAlert received error message: "_pRequest.StringValue)
    
    Set pResponse.StringValue = "Alert logged locally (SMTP out of scope)"
    Quit $$$OK
}

}
