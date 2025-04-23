module RailsTracePanel
  class TracesController < ActionController::Base
    def index
      filters = {
        id: params[:id],
        service: params[:service],
        error: params[:error] == "true",
        min_duration: (params[:min_duration] || 1)&.to_f,
        query: params[:query].presence
      }

      @traces = RailsTracePanel::Store.filtered_traces(100, filters)
    end

    def show
      @traces = RailsTracePanel::Store.recent_traces(1, id: params[:id])
    end

    def destroy_all
      RailsTracePanel::Store.clear
      redirect_to traces_path, notice: "All traces cleared"
    end
  end
end
