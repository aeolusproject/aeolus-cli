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
    describe ImportCommand do
      before(:each) do
        @options = { :id => "ami-5592553c",
                     :target => ["ec2"],
                     :provider_account => ["ec2-us-east-1"],
                     :description => "<image><name>MyImage</name></image>"}
      end

      describe "#import_image" do
        it "should import an image with default description values" do
          VCR.use_cassette('command/import_command/import_image_default') do
            importc = ImportCommand.new(@options)
            begin
              importc.import_image
            rescue SystemExit => e
              e.status.should == 0
            end
            $stdout.string.should include("Image:")
            $stdout.string.should include("Target Image:")
            $stdout.string.should include("Build:")
            $stdout.string.should include("Provider Image:")
          end
        end

        it "should import an image with file description" do
          VCR.use_cassette('command/import_command/import_image_description_file') do
            @options[:description]  = 'spec/sample_data/image_description.xml'
            importc = ImportCommand.new(@options)
            begin
              importc.import_image
            rescue SystemExit => e
              e.status.should == 0
            end
            $stdout.string.should include("Image:")
            $stdout.string.should include("Target Image:")
            $stdout.string.should include("Build:")
            $stdout.string.should include("Provider Image:")
          end
        end
      end
    end
  end
end
