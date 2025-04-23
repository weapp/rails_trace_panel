module RailsTracePanel
  class TracesController < ActionController::Base
    def index
      filters = {
        id: params[:id],
        service: params[:service],
        error: params[:error] == "true",
        min_duration: params[:min_duration]&.to_f,
        query: params[:query].presence
      }

      @traces = RailsTracePanel::Store.filtered_traces(50, filters)
    end
  end
end
