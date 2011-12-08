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
    class ListCommand < BaseCommand
      def initialize(opts={}, logger=nil)
        super(opts, logger)
      end

      def images
        begin
          headers = ActiveSupport::OrderedHash.new
          headers[:id] = "ID"
          headers[:name] = "Name"
          headers[:os] = "OS"
          headers[:os_version] = "OS Version"
          headers[:arch] = "Arch"
          headers[:description] = "Description"
          print_collection(Aeolus::CLI::Image.all, headers)
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end

      def builds
        begin
          headers = ActiveSupport::OrderedHash.new
          headers[:id] = "ID"
          headers[:image] = "Image"
          collection = @options[:id].nil? ? Aeolus::CLI::Build.all : Aeolus::CLI::Build.find(:all, :from => Aeolus::CLI::Base.site.path + "/images/" + @options[:id] + "/builds.xml")
          print_collection(collection, headers)
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end

      def targetimages
        begin
          headers = ActiveSupport::OrderedHash.new
          headers[:id] = "ID"
          headers[:status] = "Status"
          headers[:build] = "Build"
          collection = @options[:id].nil? ? Aeolus::CLI::TargetImage.all : Aeolus::CLI::TargetImage.find(:all, :from => Aeolus::CLI::Base.site.path + "/builds/" + @options[:id] + "/target_images.xml")
          print_collection(collection, headers)
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end

      def providerimages
        begin
          headers = ActiveSupport::OrderedHash.new
          headers[:id] = "ID"
          headers[:target_identifier] = "Target Identifier"
          headers[:status] = "Status"
          headers[:target_image] = "Target Image"
          headers[:account_name] = "Account"
          headers[:provider] = "Provider"
          headers[:account_type] = "Provider Type"
          collection = @options[:id].nil? ? Aeolus::CLI::ProviderImage.all : Aeolus::CLI::ProviderImage.find(:all, :from => Aeolus::CLI::Base.site.path + "/target_images/" + @options[:id] + "/provider_images.xml")

          paccs = Aeolus::CLI::ProviderAccount.all.group_by(&:provider)

          collection.map! do |item|
            prov = item.attributes[:provider]
            item.attributes[:account_name] = paccs[prov].first.name
            item.attributes[:account_type] = paccs[prov].first.provider_type
            item
          end

          print_collection(collection, headers)
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end

      def targets
        begin
          headers = ActiveSupport::OrderedHash.new
          headers[:name] = "Name"
          headers[:deltacloud_driver] = "Reference"
          print_collection(Aeolus::CLI::ProviderType.all, headers)
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end

      def providers
        begin
          headers = ActiveSupport::OrderedHash.new
          headers[:name] = "Name"
          headers[:provider_type] = "Type"
          headers[:deltacloud_provider] = "Target Reference"
          print_collection(Aeolus::CLI::Provider.all, headers)
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end

      def accounts
        begin
          headers = ActiveSupport::OrderedHash.new
          headers[:name] = "Name"
          headers[:provider] = "Provider"
          headers[:provider_type] = "Provider Type"
          print_collection(Aeolus::CLI::ProviderAccount.all, headers)
          quit(0)
        rescue => e
          handle_exception(e)
        end
      end
    end
  end
end
