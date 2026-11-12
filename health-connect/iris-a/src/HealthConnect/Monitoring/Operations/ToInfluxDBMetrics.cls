
Class HealthConnect.Monitoring.Operations.ToInfluxDBMetrics Extends Ens.BusinessOperation
{
    Parameter ADAPTER = "Ens.OutboundAdapter";

Method OnMessage(
    pRequest As HealthConnect.Monitoring.Messages.InfluxMetricRequest,
    Output pResponse As HealthConnect.Monitoring.Messages.InfluxMetricResponse
) As %Status
{
    Set pResponse = ##class(HealthConnect.Monitoring.Messages.InfluxMetricResponse).%New()
    Set pResponse.Success = 0
    Set pResponse.HTTPStatus = 0
    Set pResponse.ResponseBody = ""
    Set pResponse.ErrorCode = ""
    Set pResponse.SessionID = ""

    // Read configuration from IRIS container environment
    Set tServer = $SYSTEM.Util.GetEnviron("INFLUXDB_SERVER")
    Set tPort = $SYSTEM.Util.GetEnviron("INFLUXDB_PORT")
    Set tBucket = $SYSTEM.Util.GetEnviron("INFLUXDB_BUCKET")
    Set tOrg = $SYSTEM.Util.GetEnviron("INFLUXDB_ORG")
    Set tToken = $SYSTEM.Util.GetEnviron("INFLUXDB_TOKEN")
    $$$TRACE("INFLUXDB_SERVER configured: "_(tServer'=""))
    $$$TRACE("INFLUXDB_PORT configured: "_(tPort'=""))
    $$$TRACE("INFLUXDB_BUCKET configured: "_(tBucket'=""))
    $$$TRACE("INFLUXDB_ORG configured: "_(tOrg'=""))
    $$$TRACE("INFLUXDB_TOKEN configured: "_(tToken'=""))

    // Optional settings with defaults
    Set tWritePath = $SYSTEM.Util.GetEnviron("INFLUXDB_WRITE_PATH")
    If tWritePath = "" {
        Set tWritePath = "/api/v2/write"
    }

    Set tPrecision = $SYSTEM.Util.GetEnviron("INFLUXDB_PRECISION")
    If tPrecision = "" {
        Set tPrecision = "s"
    }

    Set tTimeout = $SYSTEM.Util.GetEnviron("INFLUXDB_TIMEOUT")
    If tTimeout = "" {
        Set tTimeout = 30
    }

    // Validate configuration
    If tServer = "" {
        Set pResponse.ErrorCode = "CONFIG_SERVER_MISSING"
        Set pResponse.ResponseBody = "INFLUXDB_SERVER is not configured"
        Quit $$$ERROR($$$GeneralError, pResponse.ResponseBody)
    }

    If tPort = "" {
        Set pResponse.ErrorCode = "CONFIG_PORT_MISSING"
        Set pResponse.ResponseBody = "INFLUXDB_PORT is not configured"
        Quit $$$ERROR($$$GeneralError, pResponse.ResponseBody)
    }

    If tBucket = "" {
        Set pResponse.ErrorCode = "CONFIG_BUCKET_MISSING"
        Set pResponse.ResponseBody = "INFLUXDB_BUCKET is not configured"
        Quit $$$ERROR($$$GeneralError, pResponse.ResponseBody)
    }

    If tOrg = "" {
        Set pResponse.ErrorCode = "CONFIG_ORG_MISSING"
        Set pResponse.ResponseBody = "INFLUXDB_ORG is not configured"
        Quit $$$ERROR($$$GeneralError, pResponse.ResponseBody)
    }

    If tToken = "" {
        Set pResponse.ErrorCode = "CONFIG_TOKEN_MISSING"
        Set pResponse.ResponseBody = "INFLUXDB_TOKEN is not configured"
        Quit $$$ERROR($$$GeneralError, pResponse.ResponseBody)
    }

    // Validate request payload
    Set tPayload = pRequest.Payload

    If tPayload = "" {
        Set pResponse.ErrorCode = "EMPTY_PAYLOAD"
        Set pResponse.ResponseBody = "InfluxDB payload is empty"
        Quit $$$ERROR($$$GeneralError, pResponse.ResponseBody)
    }

    // Build InfluxDB write URL
    Set tPath = tWritePath_"?org="_tOrg_"&bucket="_tBucket_"&precision="_tPrecision

    // Create HTTP request
    Set tHTTP = ##class(%Net.HttpRequest).%New()
    Set tHTTP.Server = tServer
    Set tHTTP.Port = +tPort
    Set tHTTP.Timeout = +tTimeout

    // Authentication and content type
    Do tHTTP.SetHeader("Authorization", "Token "_tToken)
    Do tHTTP.SetHeader("Content-Type", "text/plain; charset=utf-8")

    // Write Line Protocol payload
    Do tHTTP.EntityBody.Write(tPayload)

    // Send POST request
    Set tSC = tHTTP.Post(tPath)

    If $$$ISERR(tSC) {
        Set pResponse.ErrorCode = "HTTP_TRANSPORT_ERROR"
        Set pResponse.ResponseBody = $SYSTEM.Status.GetErrorText(tSC)
        Quit tSC
    }

    // Capture HTTP status
    Set pResponse.HTTPStatus = tHTTP.HttpResponse.StatusCode

    // InfluxDB returns HTTP 204 when the write succeeds
    If pResponse.HTTPStatus '= 204 {
        Set pResponse.ErrorCode = "HTTP_"_pResponse.HTTPStatus
        Set pResponse.ResponseBody = "InfluxDB HTTP error: "_pResponse.HTTPStatus
        Quit $$$ERROR($$$GeneralError, pResponse.ResponseBody)
    }

    // Successful write
    Set pResponse.Success = 1
    Set pResponse.ResponseBody = "InfluxDB write successful"
    Set pResponse.ErrorCode = ""

    Quit $$$OK
}
}




    

 


