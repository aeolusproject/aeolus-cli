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
          :description => '<image><name>' + @options[:id] + '</name></image>',
        }
        @options = default.merge(@options)
      end

      def import_image
        begin
          description = read_file(@options[:description])
          if !description.nil?
            @options[:description] = description
          end

          import_params_valid!(@options)

          image = Aeolus::CLI::Image.new({:target_identifier => @options[:id],
                                          :image_descriptor => @options[:description],
                                          :provider_account_name => @options[:provider_account].first,
                                          :environment => @options[:environment]})
          image.save!

          headers = ActiveSupport::OrderedHash.new
          headers[:image] = "Image"
          headers[:build] = "Build"
          headers[:target_image] = "Target Image"
          headers[:id] = "Provider Image"
          headers[:status] = "Status"

          pi  = image.build.target_images.target_image.provider_images.provider_image
          pi.image = image.id
          pi.build = image.build.id
          pi.target_image = image.build.target_images.target_image.id
          pi_array = Array(pi)

          print_collection(pi_array, headers)
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end

      private

      def import_params_valid!(params)
        if not params.is_a? Hash
          raise TypeError, "params should be Hash instead of #{params.class}"
        end

        if not params.values.all?
          raise ArgumentError, "params should not contain nil"
        end

        required_keys = [:id, :provider_account, :environment]
        optional_keys = [:description]

        isect = params.keys & required_keys
        diff  = params.keys - required_keys - optional_keys

        missing = required_keys - isect

        if not missing == []
          raise ArgumentError, "missing #{missing*', '}"
        end

        if not diff == []
          raise ArgumentError, "unexpected #{diff*', '}"
        end

        validate_description_xml!(params[:description])
      end

      def validate_description_xml!(xml)
        errors = validate_xml_document(File.dirname(__FILE__) + "/../../../examples/image_desc.rng", xml)
        if errors.length > 0
          puts "ERROR: The given image description does not conform to the xml schema, see below for specific details:"
          errors.each do |error|
            puts "- " + error.message
          end
          raise ArgumentError, "Invalid description"
        end
        true
      end

    end
  end
end
