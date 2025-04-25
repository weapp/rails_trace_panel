require "rails_trace_panel/version"
require "rails_trace_panel/engine"
require "rails_trace_panel/store"
require "rails_trace_panel/span"
require "rails_trace_panel/trace"
require "rails_trace_panel/configuration"

module RailsTracePanel
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
