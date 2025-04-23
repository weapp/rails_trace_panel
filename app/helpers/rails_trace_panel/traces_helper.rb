module RailsTracePanel::TracesHelper

  def to_ms(s)
    ms = (s * 1000).round(1)
    if ms > 1000
      "#{(ms / 1000).round(1)}s"
    else
      "#{ms}ms"
    end
  end

  def render_span_summary(span, trace)
    color = service_color(span.service)

    content_tag(:div, class: "span-header") do
      safe_join([
        content_tag(:span, "#{span_type_emoji(span.type)}", alt: span.type),
        content_tag(:span, "#{span.service}", class: "service-tag", style: "color: #{color}"),
        content_tag(:span, "#{span.name}", class: "name-tag"),
        content_tag(:span, "#{span.resource.truncate(100)}", class: "bold"),
        content_tag(:span, to_ms(span.duration), class: "muted"),
        content_tag(:span, "start: #{span == trace.root ? span.start : to_ms(Time.parse(span.start) - Time.parse(trace.root&.start)) }"),
        (content_tag(:span, "route: #{span.meta["http.route"]}") if span.meta["http.route"] && span.meta["http.route"] != span.meta["http.url"]),
        (content_tag(:span, "url: #{span.meta["http.url"]}", class: "bold") if span.meta["http.url"]),
        (content_tag(:span, "error.type: #{span.meta["error.type"]}", class: "bold") if span.meta["error.type"]),
        (content_tag(:span, "error.message: #{span.meta["error.message"]}") if span.meta["error.message"]),
        (content_tag(:span, "error.stack: #{span.meta["error.stack"][0..300]}") if span.meta["error.stack"]),
        (content_tag(:span, "active_record.instantiation.class_name: #{span.meta["active_record.instantiation.class_name"]}", class: "bold") if span.meta["active_record.instantiation.class_name"]),
        # content_tag(:pre, "META: #{JSON.pretty_generate(span.meta)}"),
        (content_tag(:span, "⚠️ error", class: "error") if span.status == 1),
        (content_tag(:pre, span.resource, class: "sql", "x-show": "sql") if span.resource.length > 100 || span.resource.include?("\n") || span.type == "sql"),
      ].compact, " ")
    end
  end

  def render_span_bar(span, trace)
    color = service_color(span.service)
    width_percent = duration_percent(span, trace)
    offset = duration_offset(span, trace)

    content_tag(:div, "", class: "bar", style: "left: #{offset}%;width: #{width_percent}%; background-color: #{color};")
  end

  def render_span_tree(span, trace)
    content_tag(:li) do
      content_tag(:details, open: span.children.any?) do
        safe_join([
          content_tag(:summary) do
            render_span_summary(span, trace) +
            render_span_bar(span, trace)
          end,
          content_tag(:ul) do
            safe_join(span.children.map { |child| render_span_tree(child, trace) })
          end
        ])
      end
    end
  end

  def span_type_emoji(type)
    {
      "http" => "🌐",
      "web" => "🧭",
      "custom" => "🛠️",
      "browser" => "🧪",
      "worker" => "🧵",
      "db" => "🗄️",
      "sql" => "🗄️",
    }[type.to_s] || "❓"
  end

  def duration_offset(span, trace)
    offset =
      if trace.is_a?(Numeric)
        nil
      else
        trace&.root&.start
      end

    return 0 unless offset

    offset = Time.parse(span.start) - Time.parse(offset)
    offset = offset
    offset = (offset.to_f / trace.root.duration.to_f) * 100
    offset.round(1)
  end

  def duration_percent(span, trace)
    duration =
      if trace.is_a?(Numeric)
        trace
      else
        trace&.root&.duration
      end

    return 100 unless duration
    ((span.duration.to_f / duration.to_f) * 100).round(1)
  end

  def service_color(service)
    @service_colors ||= {}
    @service_colors[service] ||= begin
      hash = Zlib.crc32(service.to_s)
      h = (hash % 360)
      "hsl(#{h}, 60%, 60%)"
    end
  end


  def draw_span_tree(span)
    return draw_span_header(span) if span.children.empty?
    tag.details do
      safe_join([
        tag.summary { draw_span_header(span) },
        draw_span_list(span.children)
      ], "\n")
    end
  end

  def draw_span_list(list)
    tag.div(style: "margin-left: 1rem") do
      tag.ul do
        safe_join(
          list.map do |span|
            tag.li { draw_span_tree(span) }
          end,
          "\n"
        )
      end
    end
  end

  def draw_span_header(span)
    tag.div(class: "span-header") do
      safe_join([
        header_1(span),
        header_2(span)
      ], "\n")
    end
  end

  def header_1(span)
    tag.div(style: "display: inline-flex; gap: 1rem") do
      safe_join([
        tag.strong("#{span.type}"),
        tag.span("s: #{span.service}"),
        tag.span("r: #{span.resource.to_s.split("\n").first}"),
        tag.span("n: #{span.name}"),
        (tag.span("u: #{span.meta["http.url"]}") if span.meta["http.url"]),
        tag.span("#{(span.duration*1000).round(2)}ms"),
        tag.span("from #{span.start}"),
        tag.span("status: #{span.status}"),
        (tag.span("error: #{span.error}") if span.error),
      ].compact, " ")
    end
  end

  def header_2(span)
    # tag.span(style: "opacity: 0.2", "x-show": "debug", "x-cloak": true) { span.tags.to_s }
      # .gsub(",", ", ").gsub("=>", ": ").gsub("\"", "")
  end
  # tag.span("(e:#{span.error})"),


  # def c(*args)
  #   return concat(*args) if args.present?
  #   return capture { yield } if block_given?
  #   CTag.new(self)
  # end
end
