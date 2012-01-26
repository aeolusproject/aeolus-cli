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
          opts = self.send((@command + "Options").to_sym)
          if @args.include?('-h') || @args.include?('--help')
            puts opts
          else
            parse(opts)
            self.send(@command.to_sym)
          end
        else
          puts generalOptions
          exit(1)
        end
      end

      def parse(opts)
        begin
          opts.parse(@args)
        rescue OptionParser::ParseError => e
          puts "Warning, " + e.message + "\n\tSee `aeolus-image " + @command + " -h` for usage information."
          exit(1)
        rescue
          puts "An error occurred: See `aeolus-image " + @command + " -h` for usage information."
          exit(1)
        end
      end

      def generalOptions
        subtext = "Aeolus Image Commands:"
        subtext += "\n    list   : Lists Aeolus Image Resources"
        subtext += "\n    build  : Builds a new Image"
        subtext += "\n    push   : Pushes an Image to a particular Provider Account"
        subtext += "\n    import : Imports an existing image"
        subtext += "\n    delete : Delete an Aeolus Image Resource"
        subtext += "\n    status : Check the status of a push or build"
        subtext += "\nSee `aeolus-image <command> -h` for more information on each command"

        general = OptionParser.new do |opts|
          opts.banner = "Usage: aeolus-image [#{COMMANDS.join('|')}] [command options]"
          opts.on( '-h', '--help', 'Get usage information for this tool') do
            puts opts
            exit(0)
          end
          opts.separator(subtext)
        end
        general
      end

      def listOptions
        OptionParser.new do |opts|
          opts.banner = "Usage: aeolus-image list [command options]"
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
          opts.on( '-h', '--help', 'Get usage information for this command')

          opts.separator ""
          opts.separator "Examples:"
          opts.separator "aeolus-image list --images                     # list available images"
          opts.separator "aeolus-image list --builds $image_id           # list the builds of an image"
          opts.separator "aeolus-image list --targetimages $build_id     # list the target images from a build"
          opts.separator "aeolus-image list --providerimages $target_id  # list the provider images from a target image"
          opts.separator "aeolus-image list --targets                    # list the values available for the --target parameter"
          opts.separator "aeolus-image list --providers                  # list the values available for the --provider parameter"
          opts.separator "aeolus-image list --accounts                   # list the values available for the --account parameter"
          opts.separator ""
          opts.separator "N.B. Aeolus Credentials should be defined in the configuration file ~/.aeolus-cli"
        end
      end

      def buildOptions
        OptionParser.new do |opts|
          opts.banner = "Usage: aeolus-image build [command options]"
          opts.separator ""
          opts.separator "Options:"
          opts.on('-e', '--template FILE', 'path to file that contains template xml') do |file|
            @options[:template] = file
          end
          opts.on('-z', '--no-validation', 'Do not validation the template against the TDL XML Schema') do |description|
            @options[:validation] = false
          end
          opts.on('-T', '--target TARGET1,TARGET2', Array, 'provider type (ec2, rackspace, rhevm, etc)') do |name|
            @options[:target] = name
          end
          opts.on( '-h', '--help', 'Get usage information for this command')

          opts.separator ""
          opts.separator "Examples:"
          opts.separator "aeolus-image build --target ec2 --template my.tmpl        # build a new image for ec2 from based on the given template"
          opts.separator "aeolus-image build --target ec2,rhevm --template my.tmpl  # build a new image for ec2 and for rhevm based on the given template"
          #opts.separator "aeolus-image build --image $image_id                # (NOT IMPLEMENTED) rebuild the image template and targets from latest build"
          #opts.separator %q{aeolus-image build --target ec2,rackspace \         # rebuild the image with a new template and set of targets
          #         --image $image_i \
          #         --template my.tmpl}
        end
      end

      def pushOptions
        OptionParser.new do |opts|
          opts.banner = "Usage: aeolus-image push [command options]"
          opts.separator ""
          opts.separator "Options:"
          opts.on('-I', '--image ID', 'ID of the base image, can be used in build and push commands, see examples') do |id|
            @options[:image] = id
          end
          opts.on('-B', '--build ID', 'push all target images for a build, to same providers as previously') do |id|
            @options[:build] = id
          end
          opts.on('-t', '--targetimages ID', 'Retrieve the target images from a build') do |id|
            @options[:targetimage] = id
          end
          opts.on('-A', '--account NAME,NAME', Array, 'name of specific provider account to use for push') do |name|
            @options[:account] = name
          end
          opts.on( '-h', '--help', 'Get usage information for this command')

          opts.separator ""
          opts.separator "Examples:"
          opts.separator "aeolus-image push --account ec2-account,ec2-account2 --targetimage $target_image_id   # Push target images to each of the specified account"
          opts.separator "aeolus-image push --account ec2-account,rhevm-account --build $build_id               # Push target images attached to a particular build to each of the specified accounts"
          opts.separator "aeolus-image push --account ec2-account,rhevm-account --image $image_id               # Push target images attached to a particular image to each of the specified accounts"
          opts.separator ""
          opts.separator "N.B. Aeolus Credentials should be defined in the configuration file ~/.aeolus-cli"
        end
      end

      def statusOptions
        OptionParser.new do |opts|
          opts.banner = "Usage: aeolus-image status [command options]"
          opts.separator ""
          opts.separator "Options:"
          opts.on('-t', '--targetimage ID', 'target image status') do |id|
            @options[:subcommand] = :target_image
            @options[:targetimage] = id
          end
          opts.on('-P', '--providerimage ID', 'provider image status') do |id|
            @options[:subcommand] = :provider_image
            @options[:providerimage] = id
          end
          opts.on( '-h', '--help', 'Get usage information for this command')

          opts.separator "Examples:"
          opts.separator "aeolus-image status --targetimage $target_image     # status of target image build"
          opts.separator "aeolus-image status --providerimage $provider_image # status of provider image push"
          opts.separator ""
          opts.separator "N.B. Aeolus Credentials should be defined in the configuration file ~/.aeolus-cli"
        end
      end

      def importOptions
        OptionParser.new do |opts|
          opts.banner = "Usage: aeolus-image import [command options]"
          opts.separator ""
          opts.separator "Options:"
          opts.on('-d', '--id ID', 'id for a given object') do |id|
            @options[:id] = id
          end
          opts.on('-r', '--description NAME', 'description (e.g. "<image><name>MyImage</name></image>" or "/home/user/myImage.xml")') do |description|
            @options[:description] = description
          end
          opts.on('-A', '--account NAME,NAME', Array, 'name of specific account to import to') do |name|
            @options[:provider_account] = name
          end
          opts.on( '-h', '--help', 'Get usage information for this command')

          opts.separator ""
          opts.separator "Examples:"
          opts.separator "aeolus-image import --account my-ec2 --id $ami_id # import an AMI from the specified provider"
          opts.separator "aeolus-image import --account my-ec2 --id $ami_id --description '<image><name>My Image</name></image>' # import an AMI from the specified provider"
          opts.separator "aeolus-image import --account my-ec2 --id $ami_id --description <path_to_xml_file> # import an AMI from the specified provider"
          opts.separator ""
          opts.separator "RHEV:"
          opts.separator "Enter the template id for the provider image id. The template id can be found through the RHEV REST API."
          opts.separator "For example: curl https://rhevm.example.org:8443/api/templates --user user@rhevm_domain:password"
          opts.separator ""
          opts.separator "N.B. Aeolus Credentials should be defined in the configuration file ~/.aeolus-cli"
        end
      end

      def deleteOptions
        OptionParser.new do |opts|
          opts.banner = "Usage: aeolus-image delete [command options]"
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
          opts.on( '-h', '--help', 'Get usage information for this command')

          opts.separator ""
          opts.separator "Delete examples:"
          opts.separator "aeolus-image delete --image $image_id               # deletes a image and all associated builds"
          opts.separator "aeolus-image delete --build $build_id               # deletes a build and all associated targetimages"
          opts.separator "aeolus-image delete --targetimage $target_image     # deletes a target image and all associated provider images"
          opts.separator "aeolus-image delete --providerimage $provider_image # deletes a provider image"
          opts.separator ""
          opts.separator "N.B. Aeolus Credentials should be defined in the configuration file ~/.aeolus-cli"
        end
      end

      def list
        # TODO: Instantiate and call object matching command type, for example:
        # l = ListCommand.new(@options)
        # Each Command will call it's own internal method depending on the contents of the hash.
        # For the list example above, that object would call a method 'images' based on the item
        # @options[:subcommand] being :images, so internally that class may do something like:
        # self.send(@options[:subcommand])
        if @options[:subcommand].nil?
          # TODO: Pull out Print Usage into seporate method, and print
          puts "Could not find options for list, run `./aeolus-image list --help` for usage instructions"
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
          puts "Could not find subcommand for delete, run `./aeolus-image --help` for usage instructions"
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
