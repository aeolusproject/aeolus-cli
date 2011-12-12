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

module Aeolus
  module CLI
    class ImportCommand < BaseCommand
      def initialize(opts={}, logger=nil)
        super(opts, logger)
        default = {
          :image => '',
          :build => '', # TODO - Is this used anywhere?
          :id => '',
          :description => '<image><name>' + @options[:id] + '</name></image>',
          :provider_account => ''
        }
        @options = default.merge(@options)
      end

      def import_image
        begin
          description = read_file(@options[:description])
          if !description.nil?
            @options[:description] = description
          end
          # TODO: Validate Description XML
          image = Aeolus::CLI::Image.new({:target_identifier => @options[:id],
                                          :image_descriptor => @options[:description],
                                          :provider_account_name => @options[:provider_account].first})
          image.save!
          puts ""
          puts "Image: " + image.id
          puts "Build: " + image.build.id
          puts "Target Image: " + image.build.target_images.target_image.id
          puts "Provider Image: " + image.build.target_images.target_image.provider_images.provider_image.id
          puts "Status: " + image.build.target_images.target_image.provider_images.provider_image.status
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end
    end
  end
end
