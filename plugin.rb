# frozen_string_literal: true

# name: discourse-checkin-plugin
# about: A comprehensive check-in plugin with points system, consecutive rewards, and make-up functionality
# meta_topic_id: TODO
# version: 1.0.0
# authors: Pandacc
# url: https://github.com/pandacc/discourse-checkin-plugin
# required_version: 2.7.0

enabled_site_setting :checkin_plugin_enabled

module ::CheckinPlugin
  PLUGIN_NAME = "discourse-checkin-plugin"
end

require_relative "lib/checkin_plugin/engine"

after_initialize do
  # Load models
  load File.expand_path("app/models/user_point.rb", __dir__)
  load File.expand_path("app/models/checkin_record.rb", __dir__)

  # Load controllers
  load File.expand_path("app/controllers/checkin_plugin/checkin_controller.rb", __dir__)
  load File.expand_path("app/controllers/checkin_plugin/points_controller.rb", __dir__)

  # Add user associations
  add_to_class(:user, :user_point_association) do
    has_one :user_point, dependent: :destroy
    has_many :checkin_records, dependent: :destroy

    def ensure_user_point
      self.user_point || UserPoint.create!(user_id: self.id)
    end
  end
end
