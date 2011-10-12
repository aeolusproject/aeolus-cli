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
    class DeleteCommand < BaseCommand
      def initialize(opts={}, logger=nil)
        super(opts, logger)
      end

      def provider_image
        if pi = ProviderImage.find(@options[:providerimage])
          if pi.delete!
            puts "b: " + @options[:providerimage] + " Deleted Successfully"
            exit(0)
          end
          puts "ERROR: Unable to Delete Provider Image: " + @options[:providerimage]
        else
          puts "Provider Image: " + @options[:providerimage] + " does not exist"
        end
        exit(1)
      end

      def target_image
        if ti = TargetImage.find(@options[:targetimage])
          if ti.delete!
            puts "Target Image: " + @options[:targetimage] + " Deleted Successfully"
            exit(0)
          end
          puts "ERROR: Unable to Delete Target Image: " + @options[:targetimage]
        else
          puts "Target Image: " + @options[:targetimage] + " does not exist"
        end
        exit(1)
      end

      def build
        if b = ImageBuild.find(@options[:build])
          if b.delete!
            puts "Build: " + @options[:build] + " Deleted Successfully"
            exit(0)
          end
          puts "ERROR: Unable to Delete Build: " + @options[:build]
        else
          puts "Build: " + @options[:build] + " does not exist"
        end
        exit(1)
      end

      def image
        if i = Image.find(@options[:image])
          if i.delete!
            puts "Image: " + @options[:image] + " Deleted Successfully"
            exit(0)
          end
          puts "ERROR: Unable to Delete Image: " + @options[:image]
        else
          puts "Image: " + @options[:image] + " does not exist"
        end
        exit(1)
      end

      # Deletes all Images,Builds,TargetImages,ProviderImages
      def iwhd
        Image.all.each do |image|
          Image.delete(image.uuid)
        end

        ImageBuild.all.each do |build|
          ImageBuild.delete(build.uuid)
        end

        TargetImage.all.each do |target_image|
          TargetImage.delete(target_image.uuid)
        end

        ProviderImage.all.each do |provider_image|
          ProviderImage.delete(provider_image.uuid)
        end
        puts "Deleted all objects in IWHD"
        exit(0)
      end
    end
  end
end
