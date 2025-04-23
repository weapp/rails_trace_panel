RailsTracePanel::Store::DB_PATH = Rails.root.join("tmp", "rails_trace_panel.sqlite3").to_s

Datadog::Tracing.before_flush do |trace|
  RailsTracePanel::Store.save_trace(trace)
  trace
end
