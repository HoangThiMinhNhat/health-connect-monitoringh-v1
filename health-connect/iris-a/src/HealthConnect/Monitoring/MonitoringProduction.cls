
Class HealthConnect.Monitoring.MonitoringProduction Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="HealthConnect.Monitoring.MonitoringProduction"
            TestingEnabled="true"
            LogGeneralTraceEvents="true">

  <Description>Production for monitoring system metrics and sending them to InfluxDB.</Description>

  <ActorPoolSize>2</ActorPoolSize>

  <!-- 1. Business Service: Timer-based collection -->
  <Item Name="CollectorService"
        ClassName="HealthConnect.Monitoring.Services.CollectorService"
        PoolSize="1"
        Enabled="false"
        Foreground="false"
        LogTraceEvents="true">

    <Setting Target="Adapter" Name="CallInterval">360</Setting>
    <Setting Target="Host" Name="TargetConfigNames">CollectorProcess</Setting>

  </Item>

  <!-- 2. Business Process: Orchestrates metric collection -->
  <Item Name="CollectorProcess"
        ClassName="HealthConnect.Monitoring.Processes.CollectorProcess"
        PoolSize="1"
        Enabled="true"
        Foreground="false"
        LogTraceEvents="true">

    <Setting Target="Host" Name="SelectedMetrics">DatabaseLatency,DatabaseFreeSpace,SystemAlerts,SystemInfo,SystemState,CacheEfficiency,IrisProcessCount,DatabaseSize</Setting>

  </Item>

  <!-- 3. Business Operation: Retrieves metrics -->
  <Item Name="MetricsRetriever"
        ClassName="HealthConnect.Monitoring.Operations.MetricsRetriever"
        PoolSize="1"
        Enabled="true"
        Foreground="false"
        LogTraceEvents="true">

    <Setting Target="Host" Name="Server">localhost</Setting>
    <Setting Target="Host" Name="Port">52773</Setting>
    <Setting Target="Host" Name="MetricsPath">/api/monitor/metrics</Setting>

  </Item>

  <!-- 4. Business Operation: Sends metrics to InfluxDB -->
  <Item Name="To_InfluxDB_Metrics"
        ClassName="HealthConnect.Monitoring.Operations.ToInfluxDBMetrics"
        PoolSize="1"
        Enabled="true"
        Foreground="false"
        LogTraceEvents="true">

    <!-- Configure InfluxDB settings according to the operation class -->

  </Item>

  <!-- 5. Business Operation: Handles notifications -->
  <Item Name="EmailAlert"
        ClassName="HealthConnect.Monitoring.Operations.EmailAlert"
        PoolSize="1"
        Enabled="true"
        Foreground="false"
        LogTraceEvents="true">

    <!-- Configure SMTP settings according to the operation class -->

  </Item>

  <!-- 6. Temporary Business Service for manual testing -->
  <Item Name="CollectorTestService"
        ClassName="HealthConnect.Monitoring.Services.CollectorTestService"
        PoolSize="0"
        Enabled="true"
        Foreground="false"
        LogTraceEvents="true">
  </Item>

</Production>
}

}
