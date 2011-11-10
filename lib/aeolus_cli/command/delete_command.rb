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
        begin
          if pi = ProviderImage.find(@options[:providerimage])
            if pi.destroy
              puts "Provider Image: " + @options[:providerimage] + " Deleted Successfully"
              exit(0)
            end
            puts "ERROR: Unable to Delete Provider Image: " + @options[:providerimage]
            exit(1)
          else
            puts "ERROR: Provider Image: " + @options[:providerimage] + " does not exist"
            exit(1)
          end
        rescue => e
          handle_exception(e)
        end
      end

      def target_image
        begin
          if ti = TargetImage.find(@options[:targetimage])
            if ti.destroy
              puts "Target Image: " + @options[:targetimage] + " Deleted Successfully"
              exit(0)
            end
            puts "ERROR: Unable to Delete Target Image: " + @options[:targetimage]
            exit(1)
          else
            puts "ERROR: Target Image: " + @options[:targetimage] + " does not exist"
            exit(1)
          end
        rescue => e
          handle_exception(e)
        end
      end

      def build
        begin
          if b = Build.find(@options[:build])
            if b.destroy
              puts "Build: " + @options[:build] + " Deleted Successfully"
              exit(0)
            end
            puts "ERROR: Unable to Delete Build: " + @options[:build]
            exit(1)
          else
            puts "ERROR: Build: " + @options[:build] + " does not exist"
            exit(1)
          end
        rescue => e
          handle_exception(e)
        end
      end

      def image
        begin
          if i = Image.find(@options[:image])
            if i.destroy
              puts "Image: " + @options[:image] + " Deleted Successfully"
              exit(0)
            end
            puts "ERROR: Unable to Delete Image: " + @options[:image]
          else
            puts "ERROR: Image: " + @options[:image] + " does not exist"
          end
        rescue => e
          exit(1)
        end
      end
    end
  end
end
