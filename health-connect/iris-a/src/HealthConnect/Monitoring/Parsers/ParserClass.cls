
Class HealthConnect.Monitoring.Parsers.ParserClass Extends %RegisteredObject
{

/// Convert CacheEfficiency from Prometheus format to InfluxDB Line Protocol.
ClassMethod CacheEfficiency(
    pMetrics As %String,
    pHost As %String,
    pInstance As %String,
    pEnvironment As %String,
    pTimestamp As %String
) As %String
{
    Set tPayload = ""
    Set tLineCount = $Length(pMetrics, $Char(10))

    For i = 1:1:tLineCount {

        Set tLine = $ZStrip($Piece(pMetrics, $Char(10), i), "<>W")

        // Skip empty lines and Prometheus comments.
        If (tLine = "") || ($Extract(tLine, 1) = "#") {
            Continue
        }

        Set tMetricName = $Piece(tLine, " ", 1)

        // Find CacheEfficiency.
        If tMetricName '= "iris_cache_efficiency" {
            Continue
        }

        Set tValue = $Piece(tLine, " ", 2)

        If tValue = "" {
            Continue
        }

        // Escape tag values.
        Set tHost = ..EscapeTagValue(pHost)
        Set tInstance = ..EscapeTagValue(pInstance)
        Set tEnvironment = ..EscapeTagValue(pEnvironment)

        // Build InfluxDB Line Protocol.
        Set tPayload = "healthconnect_metrics"
        Set tPayload = tPayload_",host="_tHost
        Set tPayload = tPayload_",instance="_tInstance
        Set tPayload = tPayload_",environment="_tEnvironment
        Set tPayload = tPayload_",metric=CacheEfficiency"
        Set tPayload = tPayload_" value="_tValue
        Set tPayload = tPayload_" "_pTimestamp

        // Stop searching after finding the metric.
        Quit
    }

    Quit tPayload
}

/// Convert IrisProcessCount from Prometheus format to InfluxDB Line Protocol.
ClassMethod IrisProcessCount(
    pMetrics As %String,
    pHost As %String,
    pInstance As %String,
    pEnvironment As %String,
    pTimestamp As %String
) As %String
{
    Set tPayload = ""
    Set tLineCount = $Length(pMetrics, $Char(10))

    For i = 1:1:tLineCount {

        Set tLine = $ZStrip($Piece(pMetrics, $Char(10), i), "<>W")

        // Skip empty lines and comments.
        If (tLine = "") || ($Extract(tLine, 1) = "#") {
            Continue
        }

        Set tMetricName = $Piece(tLine, " ", 1)

        // Find iris_process_count.
        If tMetricName '= "iris_process_count" {
            Continue
        }

        Set tValue = $Piece(tLine, " ", 2)

        If tValue = "" {
            Continue
        }

        Set tHost = ..EscapeTagValue(pHost)
        Set tInstance = ..EscapeTagValue(pInstance)
        Set tEnvironment = ..EscapeTagValue(pEnvironment)

        // Build InfluxDB Line Protocol.
        Set tPayload = "healthconnect_metrics"
        Set tPayload = tPayload_",host="_tHost
        Set tPayload = tPayload_",instance="_tInstance
        Set tPayload = tPayload_",environment="_tEnvironment
        Set tPayload = tPayload_",metric=IrisProcessCount"
        Set tPayload = tPayload_" value="_tValue
        Set tPayload = tPayload_" "_pTimestamp

        Quit
    }

    Quit tPayload
}


/// Convert DatabaseSize from Prometheus format to InfluxDB Line Protocol.
ClassMethod DatabaseSize(
    pMetrics As %String,
    pHost As %String,
    pInstance As %String,
    pEnvironment As %String,
    pTimestamp As %String
) As %String
{
    Set tPayload = ""
    Set tLineCount = $Length(pMetrics, $Char(10))

    For i = 1:1:tLineCount {

        Set tLine = $ZStrip($Piece(pMetrics, $Char(10), i), "<>W")

        If (tLine = "") || ($Extract(tLine, 1) = "#") {
            Continue
        }

        Set tMetricName = $Piece(tLine, " ", 1)

        If $Piece(tMetricName, "{", 1) '= "iris_db_size_mb" {
            Continue
        }

        Set tValue = $Piece(tLine, " ", 2)

        If tValue = "" {
            Continue
        }

        // Extract database ID from the Prometheus labels.
        Set tDatabase = $Piece($Piece(tMetricName, "id=""", 2), """", 1)

        If tDatabase = "" {
            Continue
        }

        Set tHost = ..EscapeTagValue(pHost)
        Set tInstance = ..EscapeTagValue(pInstance)
        Set tEnvironment = ..EscapeTagValue(pEnvironment)
        Set tDatabase = ..EscapeTagValue(tDatabase)

        // Build InfluxDB Line Protocol.
        Set tLinePayload = "healthconnect_metrics"
        Set tLinePayload = tLinePayload_",host="_tHost
        Set tLinePayload = tLinePayload_",instance="_tInstance
        Set tLinePayload = tLinePayload_",environment="_tEnvironment
        Set tLinePayload = tLinePayload_",database="_tDatabase
        Set tLinePayload = tLinePayload_",metric=DatabaseSize"
        Set tLinePayload = tLinePayload_" value="_tValue
        Set tLinePayload = tLinePayload_" "_pTimestamp

        If tPayload '= "" {
            Set tPayload = tPayload_$CHAR(10)
        }

        Set tPayload = tPayload_tLinePayload
    }

    Quit tPayload
}


/// Convert DatabaseLatency from Prometheus format to InfluxDB Line Protocol.
ClassMethod DatabaseLatency(
    pMetrics As %String,
    pHost As %String,
    pInstance As %String,
    pEnvironment As %String,
    pTimestamp As %String
) As %String
{
    Set tPayload = ""
    Set tLineCount = $Length(pMetrics, $Char(10))

    For i = 1:1:tLineCount {

        Set tLine = $ZStrip($Piece(pMetrics, $Char(10), i), "<>W")

        If (tLine = "") || ($Extract(tLine, 1) = "#") {
            Continue
        }

        Set tMetricName = $Piece(tLine, " ", 1)

        If $Piece(tMetricName, "{", 1) '= "iris_db_latency" {
            Continue
        }

        Set tValue = $Piece(tLine, " ", 2)

        If tValue = "" {
            Continue
        }

        // Extract database ID.
        Set tDatabase = $Piece($Piece(tMetricName, "id=""", 2), """", 1)

        If tDatabase = "" {
            Continue
        }

        Set tHost = ..EscapeTagValue(pHost)
        Set tInstance = ..EscapeTagValue(pInstance)
        Set tEnvironment = ..EscapeTagValue(pEnvironment)
        Set tDatabase = ..EscapeTagValue(tDatabase)

        // Build InfluxDB Line Protocol.
        Set tLinePayload = "healthconnect_metrics"
        Set tLinePayload = tLinePayload_",host="_tHost
        Set tLinePayload = tLinePayload_",instance="_tInstance
        Set tLinePayload = tLinePayload_",environment="_tEnvironment
        Set tLinePayload = tLinePayload_",database="_tDatabase
        Set tLinePayload = tLinePayload_",metric=DatabaseLatency"
        Set tLinePayload = tLinePayload_" value="_tValue
        Set tLinePayload = tLinePayload_" "_pTimestamp

        If tPayload '= "" {
            Set tPayload = tPayload_$CHAR(10)
        }

        Set tPayload = tPayload_tLinePayload
    }

    Quit tPayload
}


/// Convert DatabaseFreeSpace from Prometheus format to InfluxDB Line Protocol.
ClassMethod DatabaseFreeSpace(
    pMetrics As %String,
    pHost As %String,
    pInstance As %String,
    pEnvironment As %String,
    pTimestamp As %String
) As %String
{
    Set tPayload = ""
    Set tLineCount = $Length(pMetrics, $Char(10))

    For i = 1:1:tLineCount {

        Set tLine = $ZStrip($Piece(pMetrics, $Char(10), i), "<>W")

        If (tLine = "") || ($Extract(tLine, 1) = "#") {
            Continue
        }

        Set tMetricName = $Piece(tLine, " ", 1)

        If $Piece(tMetricName, "{", 1) '= "iris_db_free_space" {
            Continue
        }

        Set tValue = $Piece(tLine, " ", 2)

        If tValue = "" {
            Continue
        }

        // Extract database ID.
        Set tDatabase = $Piece($Piece(tMetricName, "id=""", 2), """", 1)

        If tDatabase = "" {
            Continue
        }

        Set tHost = ..EscapeTagValue(pHost)
        Set tInstance = ..EscapeTagValue(pInstance)
        Set tEnvironment = ..EscapeTagValue(pEnvironment)
        Set tDatabase = ..EscapeTagValue(tDatabase)

        // Build InfluxDB Line Protocol.
        Set tLinePayload = "healthconnect_metrics"
        Set tLinePayload = tLinePayload_",host="_tHost
        Set tLinePayload = tLinePayload_",instance="_tInstance
        Set tLinePayload = tLinePayload_",environment="_tEnvironment
        Set tLinePayload = tLinePayload_",database="_tDatabase
        Set tLinePayload = tLinePayload_",metric=DatabaseFreeSpace"
        Set tLinePayload = tLinePayload_" value="_tValue
        Set tLinePayload = tLinePayload_" "_pTimestamp

        If tPayload '= "" {
            Set tPayload = tPayload_$CHAR(10)
        }

        Set tPayload = tPayload_tLinePayload
    }

    Quit tPayload
}


/// Convert SystemAlerts from Prometheus format to InfluxDB Line Protocol.
ClassMethod SystemAlerts(
    pMetrics As %String,
    pHost As %String,
    pInstance As %String,
    pEnvironment As %String,
    pTimestamp As %String
) As %String
{
    Set tPayload = ""
    Set tLineCount = $Length(pMetrics, $Char(10))

    For i = 1:1:tLineCount {

        Set tLine = $ZStrip($Piece(pMetrics, $Char(10), i), "<>W")

        If (tLine = "") || ($Extract(tLine, 1) = "#") {
            Continue
        }

        Set tMetricName = $Piece(tLine, " ", 1)

        If $Piece(tMetricName, "{", 1) '= "iris_system_alerts" {
            Continue
        }

        Set tValue = $Piece(tLine, " ", 2)

        If tValue = "" {
            Continue
        }

        Set tHost = ..EscapeTagValue(pHost)
        Set tInstance = ..EscapeTagValue(pInstance)
        Set tEnvironment = ..EscapeTagValue(pEnvironment)

        Set tPayload = "healthconnect_metrics"
        Set tPayload = tPayload_",host="_tHost
        Set tPayload = tPayload_",instance="_tInstance
        Set tPayload = tPayload_",environment="_tEnvironment
        Set tPayload = tPayload_",metric=SystemAlerts"
        Set tPayload = tPayload_" value="_tValue
        Set tPayload = tPayload_" "_pTimestamp

        Quit
    }

    Quit tPayload
}


ClassMethod SystemInfo(
    pMetrics As %String,
    pHost As %String,
    pInstance As %String,
    pEnvironment As %String,
    pTimestamp As %String
) As %String
{
    Set tPayload = ""
    Set tLineCount = $Length(pMetrics, $Char(10))

    For i = 1:1:tLineCount {
        Set tLine = $ZStrip($Piece(pMetrics, $Char(10), i), "<>W")

        If (tLine = "") || ($Extract(tLine, 1) = "#") {
            Continue
        }

        Set tMetricName = $Piece(tLine, " ", 1)

        If $Piece(tMetricName, "{", 1) '= "iris_system_info" {
            Continue
        }

        // SystemInfo is absent if no matching metric exists.
        // Do not generate fabricated monitoring data.
    }

    Quit tPayload
}


/// Convert SystemState from Prometheus format to InfluxDB Line Protocol.
ClassMethod SystemState(
    pMetrics As %String,
    pHost As %String,
    pInstance As %String,
    pEnvironment As %String,
    pTimestamp As %String
) As %String
{
    Set tPayload = ""
    Set tLineCount = $Length(pMetrics, $Char(10))

    For i = 1:1:tLineCount {
        Set tLine = $ZStrip($Piece(pMetrics, $Char(10), i), "<>W")

        If (tLine = "") || ($Extract(tLine, 1) = "#") {
            Continue
        }

        Set tMetricName = $Piece(tLine, " ", 1)

        If $Piece(tMetricName, "{", 1) '= "iris_system_state" {
            Continue
        }

        Set tValue = $Piece(tLine, " ", 2)

        If tValue = "" {
            Continue
        }

        Set tHost = ..EscapeTagValue(pHost)
        Set tInstance = ..EscapeTagValue(pInstance)
        Set tEnvironment = ..EscapeTagValue(pEnvironment)

        Set tPayload = "healthconnect_metrics"
        Set tPayload = tPayload_",host="_tHost
        Set tPayload = tPayload_",instance="_tInstance
        Set tPayload = tPayload_",environment="_tEnvironment
        Set tPayload = tPayload_",metric=SystemState"
        Set tPayload = tPayload_" value="_tValue
        Set tPayload = tPayload_" "_pTimestamp

        Quit
    }

    Quit tPayload
}

/// Escape spaces, commas, equals signs and backslashes in tag values.
ClassMethod EscapeTagValue(pValue As %String) As %String
{
    Set tValue = $Replace(pValue, "\", "\\")
    Set tValue = $Replace(tValue, " ", "\ ")
    Set tValue = $Replace(tValue, ",", "\,")
    Set tValue = $Replace(tValue, "=", "\=")

    Quit tValue
}

}
