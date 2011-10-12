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

require 'yaml'
require 'rest_client'
require 'nokogiri'

module Aeolus
  module Image
    #This will house some methods that multiple Command classes need to use.
    class BaseCommand
      attr_accessor :options

      def initialize(opts={}, logger=nil)
        logger(logger)
        @options = opts
        @config_location = "~/.aeolus-cli"
        @config = load_config
        configure_active_resource
      end

      protected
      def not_implemented
        "This option or combination is not yet implemented"
      end

      def logger(logger=nil)
        @logger ||= logger
        unless @logger
          @logger = Logger.new(STDOUT)
          @logger.level = Logger::INFO
          @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        end
        return @logger
      end

      def read_file(path)
        begin
          full_path = File.expand_path(path)
          if is_file?(path)
            File.read(full_path)
          else
            return nil
          end
        rescue
          nil
        end
      end

      # TODO: Consider ripping all this file-related stuff into a module or
      # class for better encapsulation and testability
      def is_file?(path)
        full_path = File.expand_path(path)
        if File.exist?(full_path) && !File.directory?(full_path)
          return true
        end
        false
      end

      def quit(code)
        exit(code)
      end

      def validate_xml_document(schema_path, xml_string)
        schema = Nokogiri::XML::RelaxNG(File.read(schema_path))
        doc = Nokogiri::XML xml_string
        schema.validate(doc)
      end

      def is_uuid?(id)
        uuid = Regexp.new('[\w]{8}[-][\w]{4}[-][\w]{4}[-][\w]{4}[-][\w]{12}')
        uuid.match(id).nil? ? false : true
      end

      private
      def configure_active_resource
        Aeolus::CLI::Base.site = @config[:conductor][:url]
        Aeolus::CLI::Base.user = @config[:conductor][:username]
        Aeolus::CLI::Base.password = @config[:conductor][:password]
      end

      def load_config
        begin
          file_str = read_file(@config_location)
          if is_file?(@config_location) && !file_str.include?(":url")
            lines = File.readlines(File.expand_path(@config_location)).map do |line|
              "#" + line
            end
            File.open(File.expand_path(@config_location), 'w') do |file|
              file.puts lines
            end
            write_file
          end
          write_file unless is_file?(@config_location)
          YAML::load(File.open(File.expand_path(@config_location)))
        rescue Errno::ENOENT
          #TODO: Create a custom exception to wrap CLI Exceptions
          raise "Unable to locate or write configuration file: \"" + @config_location + "\""
        end
      end

      def write_file
        example = File.read(File.expand_path(File.dirname(__FILE__) + "/../../../examples/aeolus-cli"))
        File.open(File.expand_path(@config_location), 'a+') do |f|
          f.write(example)
        end
      end
    end
  end
end
