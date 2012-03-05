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
      end

      def run
        begin
          pi = Aeolus::CLI::ProviderImage.new(request_parameters)
          pi.save!

          headers = ActiveSupport::OrderedHash.new
          # Add Image/Build or TargetImage to output (Depending on what is defined on command line)
          pi_array = Array(pi.provider_image)
          {:image_id => "Image", :build_id => "Build", :target_image_id => "Target Image"}.each_pair do |method, label|
            if pi.respond_to?(method)
              headers[method] = label
              pi_array.each do |provider_image|
                provider_image.attributes[method] = pi.send(method)
              end
            end
          end
          headers[:id] = "Provider Image"
          headers[:provider] = "Provider"
          headers[:account] = "Account"
          headers[:status] = "Status"

          print_collection(pi_array, headers)
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end

      def request_parameters
        if @options[:account]
          request_map = {:provider_account => @options[:account].join(",")}
        else
          puts "Error: You must specify an account to push to"
          quit(1)
        end

        if @options[:image]
          request_map[:image_id] = @options[:image]
        elsif @options[:build]
          request_map[:build_id] = @options[:build]
        elsif @options[:targetimage]
          request_map[:target_image_id] = @options[:targetimage]
        else
          puts "Error: You must specify either an image, build or target image to push"
          quit(1)
        end
        request_map
      end

    end
  end
end