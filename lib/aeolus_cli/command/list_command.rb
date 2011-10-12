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
  module Image
    class ListCommand < BaseCommand
      def initialize(opts={}, logger=nil)
        super(opts, logger)
      end

      def images
        check_bucket_exists("images")
        images = [["IMAGE ID", "LASTEST PUSHED BUILD", "NAME", "OS", "OS VERSION", "ARCH", "DESCRIPTION"]]
        Image.all.each do |i|
          images << [i.uuid, (i.latest_pushed_build.nil? ? "" : i.latest_pushed_build.uuid), i.name, i.os.name, i.os.version, i.os.arch, i.description]
        end
        format_print(images)
        quit(0)
      end

      def builds
        builds = [["Build ID"]]
        image = Image.find(@options[:id])
        if image
          image.image_builds.each do |b|
            builds << [b.uuid]
          end
          format_print(builds)
        else
          puts "ERROR: could not find Image with ID: " + options[:id]
        end
        quit(0)
      end

      def targetimages
        targetimages = [["Target Image Id"]]
        build = ImageBuild.find(@options[:id])
        if build
          build.target_images.each do |ti|
            targetimages << [ti.uuid]
          end
          format_print(targetimages)
        else
          puts "ERROR: could not find Build with ID: " + options[:id]
        end
        quit(0)
      end

      def providerimages
        providerimages = [["PROVIDER IMAGE", "PROVIDER", "TARGET IMAGE", "TARGET IDENTIFIER"]]
        target_image = TargetImage.find(@options[:id])
        if target_image
          target_image.provider_images.each do |pi|
            providerimages << [pi.uuid, pi.provider_name, target_image.uuid, target_image.target]
          end
          format_print(providerimages)
        else
          puts "ERROR: could not find Target Image with ID: " + options[:id]
        end
        quit(0)
      end

      def targets
        targets = [["NAME", "TARGET CODE"]]
        targets << ["Mock", "mock"]
        targets << ["Amazon EC2", "ec2"]
        targets << ["RHEV-M", "rhevm"]
        targets << ["VMware vSphere", "vsphere"]
        targets << ["Condor Cloud", "condor_cloud"]
        format_print(targets)
        quit(0)
      end

      def providers
        print_values = [["NAME", "TYPE", "URL"]]

        doc = Nokogiri::XML conductor['/providers'].get
        doc.xpath("/providers/provider").each do |provider|
          print_values << [provider.xpath("name").text, provider.xpath("provider_type").text, provider.xpath("url").text]
        end

        format_print(print_values)
        quit(0)
      end

      def accounts
        print_values = [["NAME", "PROVIDER", "PROVIDER TYPE"]]
        doc = Nokogiri::XML conductor['/provider_accounts/'].get
        doc.xpath("/provider_accounts/provider_account").each do |account|
          print_values << [account.xpath("name").text, account.xpath("provider").text, account.xpath("provider_type").text]
        end

        format_print(print_values)
        quit(0)
      end

      private
      # Takes a 2D array of strings and neatly prints them to STDOUT
      def format_print(print_values)
        widths =  Array.new(print_values[0].size, 0)
        print_values.each do |print_value|
          widths = widths.zip(print_value).map! {|width, value| value.length > width ? value.length : width }
        end

        print_values.each do |print_value|
          widths.zip(print_value) do |width, value|
            printf("%-#{width + 5}s", value)
          end
          puts ""
        end
      end

      def get_template_info(image, targetimage)
        begin
          template = Nokogiri::XML iwhd["/templates/" + iwhd["/target_images/" + targetimage + "/template"].get].get
          [template.xpath("/template/name").text,
            iwhd["/target_images/" + targetimage + "/target"].get,
            template.xpath("/template/os/name").text,
            template.xpath("/template/os/version").text,
            template.xpath("/template/os/arch").text,
            template.xpath("/template/description").text]
        rescue
        end
      end

      def get_image_name(image)
        begin
          template_xml = Nokogiri::XML iwhd["images/" + image].get
          template_xml.xpath("/image/name").text
        rescue
          ""
        end
      end

      def lastest_pushed(image)
        begin
          build = iwhd["/images/" + image + "/latest_build"].get
          build.nil? ? "" : build
        rescue
          ""
        end
      end

      def check_bucket_exists(bucket)
        begin
          iwhd["/" + bucket].get
        rescue
          nil
        end
      end
    end
  end
end
