# frozen_string_literal: true

# name: fuck-you
# about: pandacc
# meta_topic_id: TODO
# version: 6.6.6
# authors: Pandacc
# url: facker
# required_version: 2.7.0

enabled_site_setting :plugin_name_enabled

module ::MyPluginModule
  PLUGIN_NAME = "fuck-you"
end

require_relative "lib/my_plugin_module/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
