module RailsTracePanel::TracesHelper
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
