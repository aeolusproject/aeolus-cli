#   Copyright 2011 Red Hat, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require 'rest_client'

module Aeolus
  module CLI
    class StatusCommand < BaseCommand
      attr_accessor :console
      def initialize(opts={}, logger=nil)
        super(opts, logger)
      end

      def run
        begin
          if @options[:targetimage]
            ti = Aeolus::CLI::TargetImage.find(@options[:targetimage])
            puts "Build Status: " + ti.status
          elsif @options[:providerimage]
            pi = Aeolus::CLI::ProviderImage.find(@options[:providerimage])
            puts "Push Status: " + pi.status
          else
            puts "Error: You must specify either a target or provider image to check their status"
            quit(1)
          end

          quit(0)
        rescue => e
          handle_exception(e)
        end
      end
    end
  end
end
