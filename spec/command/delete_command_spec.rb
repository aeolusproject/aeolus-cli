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

require 'spec_helper'

module Aeolus
  module CLI
    describe DeleteCommand do
      it "should delete a provider image of a given id" do
        @options = {:providerimage => "8f8bc89c-f86b-4366-8b28-f632ad7ce711"}
        VCR.use_cassette('command/delete_command/delete_provider_image') do
          dc = DeleteCommand.new(@options)
          begin
            dc.provider_image
          rescue SystemExit => e
            e.status.should == 0
          end
          $stdout.string.should include("Provider Image: 8f8bc89c-f86b-4366-8b28-f632ad7ce711 Deleted Successfully")
        end
      end

      it "should delete an target image of a given id" do
        VCR.use_cassette('command/delete_command/delete_target_image') do
          @options = {:targetimage => "e626cadf-5901-4db4-95c5-d53a696e00dd"}
          dc = DeleteCommand.new(@options)
          begin
            dc.target_image
          rescue SystemExit => e
            e.status.should == 0
          end
          $stdout.string.should include("Target Image: e626cadf-5901-4db4-95c5-d53a696e00dd Deleted Successfully")
        end
      end

      it "should delete a build of a given id" do
        @options = {:build => "a5b23c06-8d63-4173-be49-fb15975065da"}
        VCR.use_cassette('command/delete_command/delete_build') do
          dc = DeleteCommand.new(@options)
          begin
            dc.build
          rescue SystemExit => e
            e.status.should == 0
          end
          $stdout.string.should include("Build: a5b23c06-8d63-4173-be49-fb15975065da Deleted Successfully")
        end
      end

      it "should delete an image of a given id" do
        VCR.use_cassette('command/delete_command/delete_image') do
          @options = {:image => "3d0ee4e4-901f-415d-be3a-f8da80e74d03"}
          dc = DeleteCommand.new(@options)
          begin
            dc.image
          rescue SystemExit => e
            e.status.should == 0
          end
          $stdout.string.should include("Image: 3d0ee4e4-901f-415d-be3a-f8da80e74d03 Deleted Successfully")
        end
      end
    end
  end
end