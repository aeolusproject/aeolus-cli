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
require 'logger'

module Aeolus
  module CLI
    class ConfigParser
      COMMANDS = %w(list build push import delete status)
      attr_accessor :options, :command, :args

      def initialize(argv)
        @args = argv
        # Default options
        @options = {}
      end

      def process
        # Check for command, then call appropriate Optionparser and initiate
        # call to that class.
        @command = @args.shift
        # Eventually get the config file from user dir if it exists.
        # File.expand_path("~")
        if COMMANDS.include?(@command)
          parse(@command)
          self.send(@command.to_sym)
        else
          @args << "-h"
          puts "Valid command required: \n\n"
          parse
        end
      end

      private
      def parse(subcommand = nil)
        subcommand = subcommand.to_sym if subcommand

        @optparse ||= OptionParser.new do|opts|
          opts.banner = "Usage: aeolus-cli [#{COMMANDS.join('|')}] [general options] [command options]"

          opts.separator ""
          opts.separator "General options:"
          opts.on('-d', '--id ID', 'id for a given object') do |id|
            @options[:id] = id
          end
          opts.on('-r', '--description NAME', 'description (e.g. "<image><name>MyImage</name></image>" or "/home/user/myImage.xml")') do |description|
            @options[:description] = description
          end
          opts.on('-r', '--provider NAME1,NAME2',  Array,'name of specific provider (ie ec2-us-east1)') do |name|
            @options[:provider] = name
          end
          opts.on('-I', '--image ID', 'ID of the base image, can be used in build and push commands, see examples') do |id|
            @options[:image] = id
          end
          opts.on('-T', '--target TARGET1,TARGET2', Array, 'provider type (ec2, rackspace, rhevm, etc)') do |name|
            @options[:target] = name
          end
          opts.on( '-h', '--help', 'Get usage information for this tool') do
            puts opts
            exit(0)
          end

          if !subcommand || subcommand == :list
            opts.separator ""
            opts.separator "List options:"
            opts.on('-i', '--images', 'Retrieve a list of images') do
              @options[:subcommand] = :images
            end
            opts.on('-b', '--builds ID', 'Retrieve the builds of an image') do |id|
              @options[:subcommand] = :builds
              @options[:id] = id
            end
            opts.on('-t', '--targetimages ID', 'Retrieve the target images from a build') do |id|
              @options[:subcommand] = :targetimages
              @options[:id] = id
            end
            opts.on('-P', '--providerimages ID', 'Retrieve the provider images from a target image') do |id|
              @options[:subcommand] = :providerimages
              @options[:id] = id
            end
            opts.on('-g', '--targets', 'Retrieve the values available for the --target parameter') do
              @options[:subcommand] = :targets
            end
            opts.on('-p', '--providers', 'Retrieve the values available for the --provider parameter') do
              @options[:subcommand] = :providers
            end
            opts.on('-a', '--accounts', 'Retrieve the values available for the --account parameter') do
              @options[:subcommand] = :accounts
            end
          end

          if !subcommand || subcommand == :build
            opts.separator ""
            opts.separator "Build options:"
            opts.on('-e', '--template FILE', 'path to file that contains template xml') do |file|
              @options[:template] = file
            end
            opts.on('-z', '--no-validation', 'Do not validation the template against the TDL XML Schema') do |description|
              @options[:validation] = false
            end
          end

          if !subcommand || subcommand == :push
            opts.separator ""
            opts.separator "Push options:"
            opts.on('-B', '--build ID', 'push all target images for a build, to same providers as previously') do |id|
              @options[:build] = id
            end
            opts.on('-t', '--targetimages ID', 'Retrieve the target images from a build') do |id|
              @options[:targetimage] = id
            end
            opts.on('-A', '--account NAME', 'name of specific provider account to use for push') do |name|
              @options[:account] = name
            end
          end

          if !subcommand || subcommand == :delete
            opts.separator ""
            opts.separator "Delete options:"
            opts.on('-I', '--image ID', 'delete build image and associated objects') do |id|
              @options[:subcommand] = :image
              @options[:image] = id
            end
            opts.on('-B', '--build ID', 'delete build and associated objects') do |id|
              @options[:subcommand] = :build
              @options[:build] = id
            end
            opts.on('-m', '--targetimage ID', 'delete target image and its provider images') do |id|
              @options[:subcommand] = :target_image
              @options[:targetimage] = id
            end
            opts.on('-D', '--providerimage ID', 'delete provider image') do |id|
              @options[:subcommand] = :provider_image
              @options[:providerimage] = id
            end
          end

          opts.separator ""
          opts.separator "Status options:"
          opts.on('-t', '--targetimage ID', 'target image status') do |id|
            @options[:subcommand] = :target_image
            @options[:targetimage] = id
          end
          opts.on('-P', '--providerimage ID', 'provider image status') do |id|
            @options[:subcommand] = :provider_image
            @options[:providerimage] = id
          end

          opts.separator ""
          opts.separator "URL with credentials to Conductor are set in ~/.aeolus-cli"
          opts.separator "Conductor URL should point to https://<host_where_conductor_runs>/conductor/api"

          if !subcommand || subcommand == :list
            opts.separator ""
            opts.separator "List Examples:"
            opts.separator "aeolus-cli list --images                    # list available images"
            opts.separator "aeolus-cli list --builds $image_id          # list the builds of an image"
            opts.separator "aeolus-cli list --targetimages $build_id    # list the target images from a build"
            opts.separator "aeolus-cli list --providerimages $target_id # list the provider images from a target image"
            opts.separator "aeolus-cli list --targets                   # list the values available for the --target parameter"
            opts.separator "aeolus-cli list --providers                 # list the values available for the --provider parameter"
            opts.separator "aeolus-cli list --accounts                  # list the values available for the --account parameter"
          end

          if !subcommand || subcommand == :build
            opts.separator ""
            opts.separator "Build examples:"
            opts.separator "aeolus-cli build --target ec2 --template my.tmpl        # build a new image for ec2 from based on the given template"
            opts.separator "aeolus-cli build --target ec2,rhevm --template my.tmpl  # build a new image for ec2 and for rhevm based on the given template"
            #opts.separator "aeolus-cli build --image $image_id                # (NOT IMPLEMENTED) rebuild the image template and targets from latest build"
            #opts.separator %q{aeolus-cli build --target ec2,rackspace \         # rebuild the image with a new template and set of targets
            #         --image $image_i \
            #         --template my.tmpl}
          end

          if !subcommand || subcommand == :push
            opts.separator ""
            opts.separator "Push examples:"
            opts.separator "aeolus-cli push --account ec2-account,ec2-account2 --targetimage $target_image_id   # Push target images to each of the specified account"
            opts.separator "aeolus-cli push --account ec2-account,rhevm-account --build $build_id               # Push target images attached to a particular build to each of the specified accounts"
            opts.separator "aeolus-cli push --account ec2-account,rhevm-account --image $image_id               # Push target images attached to a particular image to each of the specified accounts"
          end

          if !subcommand || subcommand == :import
            opts.separator ""
            opts.separator "Import examples:"
            opts.separator "aeolus-cli import --provider ec2-us-east-1 --target ec2 --id $ami_id # import an AMI from the specified provider"
            opts.separator "aeolus-cli import --provider ec2-us-east-1 --target ec2 --id $ami_id --description '<image><name>My Image</name></image>' # import an AMI from the specified provider"
            opts.separator "aeolus-cli import --provider ec2-us-east-1 --target ec2 --id $ami_id --description <path_to_xml_file> # import an AMI from the specified provider"
          end

          if !subcommand || subcommand == :status
            opts.separator "Status examples:"
            opts.separator "aeolus-cli status --targetimage $target_image     # status of target image build"
            opts.separator "aeolus-cli status --providerimage $provider_image # status of provider image push"
          end

          if !subcommand || subcommand == :delete
            opts.separator ""
            opts.separator "Delete examples: (DELETE CURRENTLY NOT IMPLEMENTED) "
            opts.separator "aeolus-cli delete --image $image_id               # deletes a image and all associated builds"
            opts.separator "aeolus-cli delete --build $build_id               # deletes a build and all associated targetimages"
            opts.separator "aeolus-cli delete --targetimage $target_image     # deletes a target image and all associated provider images"
            opts.separator "aeolus-cli delete --providerimage $provider_image # deletes a provider image"
          end
        end

        begin
          @optparse.parse!(@args)
        rescue OptionParser::InvalidOption
          puts "Warning: Invalid option"
          exit(1)
        rescue OptionParser::MissingArgument => e
          puts "Warning, #{e.message}"
          exit(1)
        end
      end

      # TODO: Remove all this boilerplate and replace with some metaprogramming,
      # perhaps method_missing
      def list
        # TODO: Instantiate and call object matching command type, for example:
        # l = ListCommand.new(@options)
        # Each Command will call it's own internal method depending on the contents of the hash.
        # For the list example above, that object would call a method 'images' based on the item
        # @options[:subcommand] being :images, so internally that class may do something like:
        # self.send(@options[:subcommand])
        if @options[:subcommand].nil?
          # TODO: Pull out Print Usage into seporate method, and print
          puts "Could not find subcommand for list, run `./aeolus-cli --help` for usage instructions"
          exit(1)
        else
          list_command = ListCommand.new(@options)
          list_command.send(@options[:subcommand])
        end
      end

      def build
        b = BuildCommand.new(@options)
        b.run
      end

      def push
        b = PushCommand.new(@options)
        b.run
      end

      def import
        import_command = ImportCommand.new(@options)
        import_command.import_image
      end

      def delete
        if @options[:subcommand].nil?
          # TODO: Pull out Print Usage into seporate method, and print
          puts "Could not find subcommand for delete, run `./aeolus-cli --help` for usage instructions"
          exit(1)
        else
          delete_command = DeleteCommand.new(@options)
          delete_command.send(@options[:subcommand])
        end
      end

      def status
        status_command = StatusCommand.new(@options)
        status_command.run
      end
    end
  end
end
