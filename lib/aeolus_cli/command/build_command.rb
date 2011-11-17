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
    class BuildCommand < BaseCommand
      attr_accessor :console
      def initialize(opts={}, logger=nil)
        super(opts, logger)
        default = {
          :template_str => '',
          :template => '',
          :target => [],
          :image => '',
          :build => '',
          :validation => true
        }
        @options = default.merge(@options)
      end

      def run
        if combo_implemented?
          begin
            template = read_template
            validate_xml_schema(template)

            image = Aeolus::CLI::Image.new({:targets => @options[:target] * ",", :tdl => template})
            image.save!
            puts "Image: " + image.id
            puts "Build: " + image.build.id
            Array(image.build.target_images.target_image).each do |target_image|
              puts "Target Image: " + target_image.id.to_s + "\t :Status " + target_image.status
            end
            quit(0)
          rescue => e
            handle_exception(e)
          end
        end
      end

      def validate_xml_schema(xml)
        if @options[:validation]
          errors = validate_xml_document(File.dirname(__FILE__) + "/../../../examples/tdl.rng", xml)
          if errors.length > 0
            puts "ERROR: The given Template does not conform to the TDL Schema, see below for specific details:"
            errors.each do |error|
              puts "- " + error.message
            end
            quit(1)
          end
        end
      end

      def read_template
        template = read_file(@options[:template])
        if template.nil?
          puts "Error: Cannot find specified file"
          quit(1)
        end
        template
      end

      def combo_implemented?
        if @options[:template].empty? || @options[:target].empty?
          puts "Error: This combination of parameters is not currently supported"
          quit(1)
        end
        true
      end
    end
  end
end
