# RailsTracePanel::Store.clear

module RailsTracePanel
  class Trace
    attr_accessor :id, :spans, :by_id, :by_parent_id
    def initialize(data)
      @id = data[:id]
      @spans = data[:spans].map { |span_data| Span.new(span_data, trace: self) }
      @by_id = @spans.index_by(&:span_id)
      @by_parent_id = @spans.group_by(&:parent_id)
    end

    def root_spans
      spans.reject { @by_id.include?(_1.parent_id) }
    end

    # def print!
    #   puts "-" * 80
    #   puts self
    #   puts "-" * 80
    #   root_spans.each do |span|
    #     puts span.to_s_tree
    #   end
    #   puts "-" * 80
    # end
  end
end
