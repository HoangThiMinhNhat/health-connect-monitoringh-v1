
Class HealthConnect.Monitoring.Services.CollectorTestService Extends Ens.BusinessService
{
    Parameter ADAPTER = "";

    Method OnProcessInput(
        pInput As HealthConnect.Monitoring.Messages.CollectorTriggerRequest,
        Output pOutput As %RegisteredObject
    ) As %Status
    {
        Set pOutput = ""

        Set tSC = ..SendRequestSync(
            "CollectorProcess",
            pInput,
            .pOutput
        )

        Quit tSC
    }
}
