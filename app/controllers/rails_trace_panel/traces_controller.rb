module RailsTracePanel
  class TracesController < ActionController::Base
    def index
      Datadog::Tracing.reject!
      filters = {
        id: params[:id],
        service: params[:service],
        error: params[:error] == "true",
        min_duration: (params[:min_duration] || RailsTracePanel.configuration.min_span_duration_threshold)&.to_f,
        query: params[:query].presence
      }

      @traces = RailsTracePanel::Store.filtered_traces(100, filters)
    end

    def show
      Datadog::Tracing.reject!
      @traces = RailsTracePanel::Store.recent_traces(100, id: params[:id])
    end

    def destroy_all
      Datadog::Tracing.reject!
      RailsTracePanel::Store.clear
      redirect_to traces_path, notice: "All traces cleared"
    end
  end
end
