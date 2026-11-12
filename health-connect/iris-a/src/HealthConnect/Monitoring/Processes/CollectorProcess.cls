Class HealthConnect.Monitoring.Processes.CollectorProcess Extends Ens.BusinessProcess
{

Property TargetConfigName As %String(MAXLEN = 1000) [ InitialExpression = "To_InfluxDB_Metrics" ];

///Property Categories As %String(MAXLEN = 10000);
 
/// Update SelectedMetrics Property Value
Property SelectedMetrics As %String(MAXLEN = 1000) [ InitialExpression = "DatabaseLatency,DatabaseFreeSpace,SystemAlerts,SystemInfo,SystemState,CacheEfficiency,IrisProcessCount,DatabaseSize" ];

Property HostName As %String(MAXLEN = 255) [ InitialExpression = "iris-a" ];

Property InstanceName As %String(MAXLEN = 255) [ InitialExpression = "HEALTHMONITOR" ];

Property Environment As %String(MAXLEN = 100) [ InitialExpression = "development" ];

/// Udate the SETTINGS Parameter for easy management
Parameter SETTINGS = "TargetConfigName:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}, Categories:Basic:selector?multiSelect=0&context={Ens.ContextSearch/ProductionCategories?productionName=@productionId}, SelectedMetrics:Basic";
/// Main orchestration method.




Method OnRequest(
    pRequest As HealthConnect.Monitoring.Messages.CollectorTriggerRequest,
    Output pResponse As Ens.Response
) As %Status
{
    $$$TRACE("DataCollectionProcess started")

    // 1. Retrieve Prometheus metrics.
    Set tRequest = ##class(Ens.StringRequest).%New()
    Set tRequest.StringValue = ""

    Set tSC = ..SendRequestSync("MetricsRetriever", tRequest, .tResponse)

    If $$$ISERR(tSC) {
        $$$TRACE("MetricsRetriever failed")
        Do ..NotifyFailure("MetricsRetriever failed with status: "_tSC)
        Quit tSC
    }

    Set tMetrics = tResponse.StringValue

    If tMetrics = "" {
        $$$TRACE("No metrics returned")
        Quit $$$OK
    }

    // 2. Generate one UTC timestamp for this collection cycle.
    Set tHorolog = $Horolog
    Set tTimestamp = ($Piece(tHorolog, ",", 1) - 47117) * 86400
    Set tTimestamp = tTimestamp + $Piece(tHorolog, ",", 2)

    // 3. Process each selected metric separately.
    Set tFinalSC = $$$OK

    For i = 1:1:$Length(..SelectedMetrics, ",") {

        Set tMetricName = $ZStrip($Piece(..SelectedMetrics, ",", i), "<>W")

        If tMetricName = "" {
            Continue
        }

        $$$TRACE("Processing metric: "_tMetricName)

        Set tPayload = ..ParseMetric(tMetricName, tMetrics, tTimestamp)
        $$$TRACE("Metric: "_tMetricName)
        $$$TRACE("Parsed payload length: "_$LENGTH(tPayload))

        If tPayload = "" {
            $$$TRACE("No data found for metric: "_tMetricName)
            Continue
        }


        // 4. Send one custom request per selected metric.
        Set tInfluxRequest = ..CreateRequest(tPayload)
        $$$TRACE("Request payload length: "_$LENGTH(tInfluxRequest.Payload))
        Set tInfluxResponse = ""

        Set tSC = ..SendRequestSync(
            ..TargetConfigName,
            tInfluxRequest,
            .tInfluxResponse
        )

        $$$TRACE("Influx target: "_..TargetConfigName)
        $$$TRACE("Influx request class: "_$CLASSNAME(tInfluxRequest))
        $$$TRACE("Influx SendRequestSync status: "_tSC)
        $$$TRACE("Influx SendRequestSync error: "_$SYSTEM.Status.GetErrorText(tSC))
        $$$TRACE("Influx response object exists: "_$ISOBJECT(tInfluxResponse))

        // Check whether a valid response was returned.
        If '$ISOBJECT(tInfluxResponse) {

            $$$TRACE("InfluxDB returned no response object")

            Set tFailureMessage = "InfluxDB returned no response for metric "_tMetricName

            Do ..NotifyFailure(tFailureMessage)

            Set tFinalSC = $$$ERROR($$$GeneralError, tFailureMessage)

            Quit
        }

        // Check transport status and the operation's acknowledgement.
        If $$$ISERR(tSC) || (tInfluxResponse.Success '= 1) {

            Set tFailureMessage = "InfluxDB write failed for metric "_tMetricName

            Set tFailureMessage = tFailureMessage_" | HTTP status: "_tInfluxResponse.HTTPStatus
            Set tFailureMessage = tFailureMessage_" | Error code: "_tInfluxResponse.ErrorCode
            Set tFailureMessage = tFailureMessage_" | Response: "_tInfluxResponse.ResponseBody

            $$$TRACE(tFailureMessage)

            Do ..NotifyFailure(tFailureMessage)

            If $$$ISERR(tSC) {
                Set tFinalSC = tSC
            }
            Else {
                Set tFinalSC = $$$ERROR($$$GeneralError, tFailureMessage)
            }

            Quit
        }

        // Successful acknowledgement.
        $$$TRACE("InfluxDB accepted metric "_tMetricName_" with HTTP status "_tInfluxResponse.HTTPStatus)

    }

    // 5. Return the actual processing status.
    If $$$ISERR(tFinalSC) {
        Quit tFinalSC
    }

    Quit $$$OK
}

 

/// Dispatches a selected metric to its corresponding ParserClass method.
Method ParseMetric(
    pMetricName As %String,
    pMetrics As %String,
    pTimestamp As %String
) As %String
{
    If pMetricName = "CacheEfficiency" {
        Quit ##class(HealthConnect.Monitoring.Parsers.ParserClass).CacheEfficiency(
            pMetrics,
            ..HostName,
            ..InstanceName,
            ..Environment,
            pTimestamp
        )
    }

    If pMetricName = "IrisProcessCount" {
        Quit ##class(HealthConnect.Monitoring.Parsers.ParserClass).IrisProcessCount(
            pMetrics,
            ..HostName,
            ..InstanceName,
            ..Environment,
            pTimestamp
        )
    }

    If pMetricName = "DatabaseSize" {
        Quit ##class(HealthConnect.Monitoring.Parsers.ParserClass).DatabaseSize(
            pMetrics,
            ..HostName,
            ..InstanceName,
            ..Environment,
            pTimestamp
        )
    }

    If pMetricName = "DatabaseLatency" {
        Quit ##class(HealthConnect.Monitoring.Parsers.ParserClass).DatabaseLatency(
            pMetrics,
            ..HostName,
            ..InstanceName,
            ..Environment,
            pTimestamp
        )
    }

    If pMetricName = "DatabaseFreeSpace" {
        Quit ##class(HealthConnect.Monitoring.Parsers.ParserClass).DatabaseFreeSpace(
            pMetrics,
            ..HostName,
            ..InstanceName,
            ..Environment,
            pTimestamp
        )
    }

    If pMetricName = "SystemAlerts" {
        Quit ##class(HealthConnect.Monitoring.Parsers.ParserClass).SystemAlerts(
            pMetrics,
            ..HostName,
            ..InstanceName,
            ..Environment,
            pTimestamp
        )
    }

    If pMetricName = "SystemInfo" {
        Quit ##class(HealthConnect.Monitoring.Parsers.ParserClass).SystemInfo(
            pMetrics,
            ..HostName,
            ..InstanceName,
            ..Environment,
            pTimestamp
        )
    }

    If pMetricName = "SystemState" {
        Quit ##class(HealthConnect.Monitoring.Parsers.ParserClass).SystemState(
            pMetrics,
            ..HostName,
            ..InstanceName,
            ..Environment,
            pTimestamp
        )
    }

    Quit ""
}



/// Converts Prometheus metric samples to InfluxDB Line Protocol.
Method ConvertMetrics(pMetrics As %String) As %String
{
    Set tPayload = ""

    Set tLineCount = $Length(pMetrics, $Char(10))

    // Build allowed metric list from SelectedMetrics.
    Set tAllowed = ..SelectedMetrics


    For i = 1:1:tLineCount {

        Set tLine = $ZStrip($Piece(pMetrics, $Char(10), i), "<>W")

        // Skip empty lines and Prometheus comments.
        If (tLine = "") || ($Extract(tLine, 1) = "#") {
            Continue
        }

        // Extract metric name and value.
        Set tMetricName = $Piece(tLine, " ", 1)
        Set tValue = $Piece(tLine, " ", 2)

        // Remove labels temporarily to identify the base metric name.
        Set tBaseName = $Piece(tMetricName, "{", 1)
        
        // Map selected metric names to Prometheus metric names.
        Set tSelected = 0

        For j = 1:1:$Length(tAllowed, ",") {
            Set tSelectedName = $ZStrip($Piece(tAllowed, ",", j), "<>W")

            If tSelectedName = "DatabaseLatency", tBaseName = "iris_db_latency" {
                Set tSelected = 1
            }
            If tSelectedName = "DatabaseFreeSpace", tBaseName = "iris_db_free_space" {
                Set tSelected = 1
            }
            If tSelectedName = "SystemAlerts", tBaseName = "iris_system_alerts" {
                Set tSelected = 1
            }
            If tSelectedName = "SystemInfo", tBaseName = "iris_system_info" {
                Set tSelected = 1
            }
            If tSelectedName = "SystemState", tBaseName = "iris_system_state" {
                Set tSelected = 1
            }
            If tSelectedName = "CacheEfficiency", tBaseName = "iris_cache_efficiency" {
                Set tSelected = 1
            }
            If tSelectedName = "IrisProcessCount", tBaseName = "iris_process_count" {
                Set tSelected = 1
            }
            If tSelectedName = "DatabaseSize", tBaseName = "iris_db_size_mb" {
                Set tSelected = 1
            }
        }

        If 'tSelected {
            Continue
        }


        // Skip missing values.
        If tValue = "" {
            Continue
        }

        // Build basic InfluxDB Line Protocol.
        Set tPayload = tPayload_tBaseName_" value="_tValue_$Char(10)
    }

    Quit tPayload
}

 
/// Creates the outbound request message that is sent
/// to the target operation.
///
/// The payload is expected to contain one or more
/// InfluxDB Line Protocol rows generated by collector classes.

Method CreateRequest(pPayload As %String) As HealthConnect.Monitoring.Messages.InfluxMetricRequest
{
    $$$TRACE("CreateRequest started")

    Set tRequest = ##class(HealthConnect.Monitoring.Messages.InfluxMetricRequest).%New()

    Set tRequest.Payload = pPayload

    $$$TRACE("Payload assigned to custom request")

    Quit tRequest
}

/// SendAlert HELPER METHOD 
Method NotifyFailure(pErrorMessage As %String) As %Status
{
    Set tAlertReq = ##class(Ens.StringRequest).%New()
    Set tAlertReq.StringValue = pErrorMessage

    Set tSC = ..SendRequestSync("EmailAlert", tAlertReq, .tAlertResp)

    If $$$ISERR(tSC) {
        $$$TRACE("Failed to route message to EmailAlert operation")
    }

    Quit tSC
}
 
Storage Default
{
<Data name="CollectorProcessDefaultData">
<Subscript>"CollectorProcess"</Subscript>
<Value name="1">
<Value>TargetConfigName</Value>
</Value>
<Value name="2">
<Value>SelectedMetrics</Value>
</Value>
<Value name="3">
<Value>HostName</Value>
</Value>
<Value name="4">
<Value>InstanceName</Value>
</Value>
<Value name="5">
<Value>Environment</Value>
</Value>
</Data>
<DefaultData>CollectorProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
 
 
