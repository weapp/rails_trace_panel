# RailsTracePanel::Store.clear

module RailsTracePanel
  class Store
    DB_PATH = Rails.root.join("tmp", "rails_trace_panel.sqlite3").to_s
    TABLE_NAME = "traces"

    def self.db
      @db ||= begin
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        db.execute <<~SQL
          CREATE TABLE IF NOT EXISTS #{TABLE_NAME} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trace_id TEXT,
            spans_json TEXT,
            created_at TEXT
          );
        SQL
        db
      end
    end

    def self.save_trace(trace)
      return if trace.spans.count <= 2

      spans = trace.respond_to?(:spans) ? trace.spans : Array(trace)
      trace_id = spans.first&.trace_id || SecureRandom.uuid
      spans_array = spans.map { |s| span_to_h(s) }
      json = JSON.dump(spans_array)
      db.execute("INSERT INTO #{TABLE_NAME} (trace_id, spans_json, created_at) VALUES (?, ?, ?)",
                 [trace_id, json, Time.now.utc.iso8601])
    rescue => e
      Rails.logger.error("[rails_trace_panel] Error saving trace: #{e&.message || "no error"}")
    end

    def self.recent_traces(limit = 120, id: nil)
      if id
        db.execute("SELECT id, spans_json FROM #{TABLE_NAME} WHERE id = ?", [id]).map do |row|
          Trace.new({id: row["id"], spans: JSON.parse(row["spans_json"])})
        end
      else
        db.execute("SELECT id, spans_json FROM #{TABLE_NAME} ORDER BY id DESC LIMIT ?", [limit]).map do |row|
          Trace.new({id: row["id"], spans: JSON.parse(row["spans_json"])})
        end
      end
    end

    def self.filtered_traces(limit = 100, filters = {})
      recent_traces(limit, id: filters[:id]).map do |trace|
        filtered_spans = trace.spans.select do |span|
          next false if filters[:service] && span.service != filters[:service]
          next false if filters[:error] && span.status != 1
          next false if filters[:min_duration] && (span.duration * 1000) < filters[:min_duration]
          if filters[:query]
            q = filters[:query].downcase
            hit = [span.name, span.resource, span.meta["http.url"]].compact.any? { _1.downcase.include?(q) rescue false }
            next false unless hit
          end
          true
        end

        next nil if filtered_spans.empty?

        trace.tap { |t| t.spans = filtered_spans }
      end.compact
    end

    def self.span_to_h(span)
      {
        name: span.name,
        service: span.service,
        resource: span.resource,
        duration: span.duration,
        parent_id: span.parent_id,
        span_id: span.id,
        status: span.respond_to?(:status) ? span.status : nil,
        tags: span.respond_to?(:tags) ? span.tags : {},
        trace_id: span.trace_id,
        start: span.start_time,
        type: span.type,
        meta: span.meta || {},
        metrics: span.metrics || {},
        # error: span.status == 1
      }
    rescue => e
      debugger
    end

    def self.clear
      db.execute("DELETE FROM #{TABLE_NAME}")
    end
  end
end
