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

require 'imagefactory'

module Aeolus
  module Image
    class BuildCommand < BaseCommand
      attr_accessor :console
      def initialize(opts={}, logger=nil)
        super(opts, logger)
        default = {
          :template_str => '',
          :template => '',
          :target => [],
          :image => '',
          :build => ''
        }
        @options = default.merge(@options)
        @console = ImageFactoryConsole.new()
        @console.start
      end

      def run
        if combo_implemented?
          @options[:template_str] = read_file(@options[:template])
          if @options[:template_str].nil?
            puts "Cannot find specified file"
            quit(1)
          end

          # Validate XML against TDL Schema
          errors = validate_xml_document(File.dirname(__FILE__) + "/../../../examples/tdl.rng", @options[:template_str])
          if errors.length > 0
            puts "ERROR: The given Template does not conform to the TDL Schema, see below for specific details:"
            errors.each do |error|
              puts "- " + error.message
            end
            quit(1)
          end

          #This is a temporary hack in case the agent doesn't show up on bus immediately
          sleep(5)
          @console.build(@options[:template_str], @options[:target], @options[:image], @options[:build]).each do |adaptor|
            puts ""
            puts "Target Image: #{adaptor.image_id}"
            puts "Image: #{adaptor.image}"
            puts "Build: #{adaptor.build}"
            puts "Status: #{adaptor.status}"
            puts "Percent Complete: #{adaptor.percent_complete}"
          end
          quit(0)
        end
      end

      def combo_implemented?
        if @options[:template].empty? || @options[:target].empty?
          puts "This combination of parameters is not currently supported"
          quit(1)
        end
        true
      end

      def quit(code)
        @console.shutdown
        super
      end

    end
  end
end
