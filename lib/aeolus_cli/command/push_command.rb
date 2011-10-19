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
    class PushCommand < BaseCommand
      attr_accessor :console
      def initialize(opts={}, logger=nil)
        super(opts, logger)
        default = {
          :provider => [],
          :id => '',
          :build => ''
        }
        @options = default.merge(@options)
      end

      def run
        begin
          if combo_implemented?
            if !@options[:id].empty? && pushed?(@options[:id])
              puts "ERROR: This image has already been pushed, to push to another provider please push via build-id rather than image-id"
              puts "e.g. aeolus-image push --provider <provider> --build <build-id>"
              quit(1)
            end

            pi = Aeolus::CLI::ProviderImage.new({:provider_name => @options[:provider].to_s,
                                                 :provider_account => @options[:account],
                                                 :image_id => @options[:image],
                                                 :build_id => @options[:build],
                                                 :target_image_id => @options[:targetimage]})
            pi.save!
            puts ""
            puts "Image: " + pi.image_id
            puts "Build: " + pi.build_id
            puts "Target Image: " + pi.target_image_id
            puts "Provider Image: " + pi.id
            puts "Status: " + pi.status
            quit(0)
          end
        rescue => e
          handle_exception(e)
        end
      end

      def get_creds
        conductor['provider_accounts'].get
      end

      def combo_implemented?
        if (@options[:provider].empty? || @options[:build].empty? || @options[:image].empty? || @options[:account].empty? || @options[:targetimage].empty?)
          puts "This combination of parameters is not currently supported"
          quit(1)
        end
        true
      end

      private
      def pushed?(image)
        begin
          uuid = Regexp.new('[\w]{8}[-][\w]{4}[-][\w]{4}[-][\w]{4}[-][\w]{12}')
          uuid.match(iwhd["/images/" + image + "/latest_unpushed"].get).nil? ? true : false
        rescue
          true
        end
      end
    end
  end
end