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

require 'open-uri'

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
            image = Aeolus::CLI::Image.new({
                :targets => @options[:target] * ",",
                :tdl => "#{template}",
                :environment => @options[:environment]})
            image.save!

            headers = ActiveSupport::OrderedHash.new
            headers[:image] = "Image"
            headers[:build] = "Build"
            headers[:id] = "Target Image"
            headers[:target] = "Target"
            headers[:status] = "Status"

            ti_array = Array(image.build.target_images.target_image)
            ti_array.each do |target_image|
              target_image.image = image.id
              target_image.build = image.build.id
            end

            print_collection(ti_array, headers)
            quit(0)
          rescue => e
            handle_exception(e)
          end
        end
      end

      def validate_xml_schema(xml)
        errors = validate_xml_document(File.dirname(__FILE__) + "/../../../examples/tdl.rng", xml)
        if errors.length > 0
          errors.each do |error|
            puts "- Line: " + error.line.to_s + " => " + error.message
          end
          quit(1)
        end
      end

      def read_template
        begin
          f = open(@options[:template])
          return f.read
        rescue Errno::ENOENT => e
          puts "Error: Cannot open '#{e}'"
          exit(1)
        end
     end

      def combo_implemented?
        if @options[:template].empty? || @options[:target].empty? || @options[:environment].nil?
          raise ArgumentError, "Error: This combination of parameters is not currently supported"
        end
        true
      end
    end
  end
end
