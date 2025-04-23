# RailsTracePanel::Store.clear

module RailsTracePanel
  class Span
    attr_accessor :name, :service, :resource, :duration, :parent_id, :span_id, :status, :tags, :trace
    attr_accessor :start, :trace_id, :type, :meta, :metrics, :error

    def initialize(data, trace:)
      @error = data["error"]
      @metrics = data["metrics"]
      @meta = data["meta"]
      @start = data["start"]
      @type = data["type"]
      @name = data["name"]
      @service = data["service"]
      @resource = data["resource"]
      @duration = data["duration"]
      @parent_id = data["parent_id"]
      @span_id = data["span_id"]
      @status = data["status"]
      @tags = data["tags"] || {}
      @trace_id = data["trace_id"]
      @start = data["start"]
      @type = data["type"]
      @meta = data["meta"] || {}
      @metrics = data["metrics"] || {}
      # @error = data["error"] || 0
      @trace = trace
    end

    def to_s
      extras = []
      extras << "(s:#{service})"
      extras << "(r:#{resource.split("\n").first})"
      extras << "(n:#{name})"
      # extras << "(e:#{error})"
      extras << "(u: #{meta["http.url"]})" if meta["http.url"]
      ["[#{type}] #{extras.join(" ")}", *children.map { padded_text(_1) }].join("\n")
    end

    def children
      trace.by_parent_id[span_id] || []
      # trace.spans.select { _1.parent_id == span_id }
    end

    # def start_time
    #   Time.at(start / 1000000000.0)
    # end

    # def end_time
    #   Time.at((start + duration) / 1000000000.0)
    # end
    #
    # def to_s_tree(label = 150, bar = nil)
    #   bar ||= [IO.console.winsize[1] - label - 20, 10].max

    #   [
    #     "#{start_time} - #{end_time} : #{humanized_time}",
    #     _to_s_tree(label, bar, start_time, end_time)
    #   ].join("\n")
    # end


    # def _to_s_tree(label, bar, starts, ends)
    #   z = percentage(starts, starts, ends, bar).to_i
    #   s = percentage(start_time, starts, ends, bar).floor
    #   e = percentage(end_time, starts, ends, bar).ceil
    #   t = percentage(ends, starts, ends, bar).to_i

    #   zs = segment(" ", z, s)
    #   se = segment("-", s, e)
    #   et = segment(" ", e, t)

    #   [
    #     "#{fixed(banner, label)} [#{zs}#{se}#{et}] #{humanized_time}",
    #     *children.map { padded_text(_1._to_s_tree(label - 2, bar, starts, ends)) },
    #     ""
    #   ].join("\n")
    # end
    #
    #

    # def fixed(text, width)
    #   text.ljust(width)[0...width]
    # end

    # def banner
    #   "[#{service}] #{name} #{resource.split("\n").first}"
    # end

    # def percentage(x, starts, ends, total)
    #   (x - starts) / (ends - starts) * total
    # end

    # def segment(char, starts, ends)
    #   char * (ends - starts)
    # end

    def padded_text(text)
      text.to_s.split("\n").map { "  #{_1}" }.join("\n")
    end
    # https://github.com/fcm-digital/bff/blob/e7a8683bcf1348679a8fafc6b29b3db4592bc1ff/lib/zirconium/app/models/zirconium/datadog_debug.rb
  end
end
