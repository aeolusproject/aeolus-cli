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
    class DeleteCommand < BaseCommand
      def initialize(opts={}, logger=nil)
        super(opts, logger)
      end

      def provider_image
        if pi = ProviderImage.find(@options[:providerimage])
          if pi.destroy
            puts "Provider Image: " + @options[:providerimage] + " Deleted Successfully"
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
          if ti.destroy
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
        if b = Build.find(@options[:build])
          if b.destroy
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
          if i.destroy
            puts "Image: " + @options[:image] + " Deleted Successfully"
            exit(0)
          end
          puts "ERROR: Unable to Delete Image: " + @options[:image]
        else
          puts "Image: " + @options[:image] + " does not exist"
        end
        exit(1)
      end
    end
  end
end
