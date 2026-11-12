Class HealthConnect.Monitoring.Services.CollectorService Extends Ens.BusinessService
{

 
/// Specifies the inbound adapter used for timer-based polling.
Parameter ADAPTER = "Ens.InboundAdapter";

///Exposes TargetConfigNames in the Management Portal setting UI.

Parameter SETTINGS = "TargetConfigNames:Basic:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";
 
/// Setting the call interval
Property CallInterval As %Numeric [ InitialExpression = 360 ];

/// 
Property TargetConfigNames As %String(MAXLEN = 1000)[InitialExpression = "CollectorProcess"];
 
/// Description
Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
    Set request = ##class(Ens.Request).%New()
    Set tSC = ..SendRequestSync(..TargetConfigNames, request, .pOutput)
 
    Quit tSC
}
 
}
