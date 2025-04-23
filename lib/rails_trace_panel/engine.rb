require "rails/engine"

module RailsTracePanel
  class Engine < ::Rails::Engine
    isolate_namespace RailsTracePanel
  end
end
