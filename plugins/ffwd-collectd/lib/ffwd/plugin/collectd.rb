# $LICENSE
# Copyright 2013-2014 Spotify AB. All rights reserved.
#
# The contents of this file are licensed under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

require 'ffwd/plugin'
require 'ffwd/protocol'
require 'ffwd/logging'

require_relative 'collectd/connection'
require_relative 'collectd/types_db'

module FFWD::Plugin::Collectd
  include FFWD::Plugin
  include FFWD::Logging

  DEFAULT_HOST = "localhost"
  DEFAULT_PORT = 25826
  DEFAULT_TYPES_DB = "/usr/share/collectd/types.db"

  register_plugin "collectd",
    :description => "A plugin for the collectd binary protocol.",
    :options => [
      FFWD::Plugin.option(
        :host, :default => DEFAULT_HOST, :modes => [:input],
        :help => ["Host to bind to."]
      ),
      FFWD::Plugin.option(
        :port, :default => DEFAULT_PORT,
        :help => ["Port to bind to."]
      ),
      FFWD::Plugin.option(
        :types_db, :default => DEFAULT_TYPES_DB,
        :help => [
          "TypesDB to load containing collectd type definitions."
        ]
      ),
    ]

  def self.setup_input config
    config[:host] ||= DEFAULT_HOST
    config[:port] ||= DEFAULT_PORT
    config[:types_db] ||= DEFAULT_TYPES_DB
    config[:protocol] ||= "udp"
    types_db = TypesDB.open config[:types_db]
    protocol = FFWD.parse_protocol config[:protocol]
    protocol.bind config, log, Connection, types_db
  end
end
