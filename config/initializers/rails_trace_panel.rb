Datadog::Tracing.before_flush do |trace|
  RailsTracePanel::Store.save_trace(trace)
  trace
end
