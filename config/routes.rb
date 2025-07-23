# frozen_string_literal: true

CheckinPlugin::Engine.routes.draw do
  # Checkin routes
  get "/checkin" => "checkin#index"
  post "/checkin" => "checkin#checkin"
  post "/checkin/makeup" => "checkin#makeup"
  get "/checkin/calendar" => "checkin#calendar"

  # Points routes
  get "/points" => "points#index"
  get "/points/history" => "points#history"
  get "/points/leaderboard" => "points#leaderboard"
end

Discourse::Application.routes.draw { mount ::CheckinPlugin::Engine, at: "checkin-plugin" }
