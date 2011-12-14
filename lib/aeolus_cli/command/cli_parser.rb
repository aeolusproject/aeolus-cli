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

require 'optparse'

module Aeolus
  module CLI
    class CLIParser
      COMMANDS = %w(image)
      attr_accessor :options, :command, :args

      def initialize(argv=[], out=STDOUT )
        @args = argv
        @out = out
        @options = {}
      end

      def process
        # Check for command, then call appropriate Optionparser and initiate
        # call to that class.
        @command = @args.shift
        if COMMANDS.include?(@command)
          parse() unless @args.include?('-h')
          self.send(@command.to_sym)
        else
          @args << "-h" unless @args.include?('-h')
          parse()
        end
      end

      private
      def parse()
        @optparse ||= OptionParser.new do|opts|
          opts.banner = "Usage: aeolus-cli [#{COMMANDS.join('|')}] [subcommand] [general options] [command options]"
          opts.separator ""
          opts.on( '-h', '--help', 'Get usage information for this tool') do
            @out.puts opts
          end
          opts.separator ""
          opts.separator "URL with credentials to Conductor are set in ~/.aeolus-cli"
          opts.separator "Conductor URL should point to https://<host_where_conductor_runs>/conductor/api"
        end

        begin
          @optparse.parse(@args)
        rescue OptionParser::InvalidOption => e
          #This is just a wrapper, let the actual commands handle bad options later
          return true
        rescue OptionParser::MissingArgument => e
          @out.puts "Warning, #{e.message}"
          exit(1)
        end
      end

      def image
        parser = Aeolus::CLI::ConfigParser.new(@args)
        parser.process
      end
    end
  end
end
