RailsTracePanel::Engine.routes.draw do
  root to: "traces#index"
  get "traces", to: "traces#index"
  get "traces/:id", to: "traces#show", as: :trace
  delete "traces", to: "traces#destroy_all"
end
