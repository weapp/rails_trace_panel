module RailsTracePanel
  class Configuration
    attr_accessor :min_trace_count, :db_path, :min_span_duration_threshold, :min_trace_duration_threshold

    def initialize
      @min_trace_count = 2
      @min_trace_count = 2
      @db_path = Rails.root.join("tmp", "rails_trace_panel.sqlite3").to_s
      @min_span_duration_threshold = 0.0005
      @min_trace_duration_threshold = 1
    end
  end
end
