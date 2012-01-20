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
    describe PushCommand do

      before(:each) do
        @options[:provider] = ['mock']
        @options[:user] = 'admin'
        @options[:password] = 'password'
      end

      describe "#run" do
        it "should allow multple push for an image with 2 target images based on image id" do
          VCR.use_cassette('command/push_command/multiple_push_image_id') do
            @options = ({ :image => "b4b340dc-0efc-4830-8c59-411c9a3e0aba",
                          :account => ["mock-acc","mock-acc"] })
            p = PushCommand.new(@options, @output)
            begin
              p.run
            rescue SystemExit => e
              e.status.should == 0
            end

            # Headers
            $stdout.string.should include("Provider Image")
            $stdout.string.should include("Provider")
            $stdout.string.should include("Account")
            $stdout.string.should include("Image")

            # Provider Images
            $stdout.string.should include("daf6f1b3-d4b9-4ab1-81d3-11adf84d3a6a")
            $stdout.string.should include("07bf7f85-cf4f-4d26-862e-8795f0431f07")

            # Image
            $stdout.string.should include("b4b340dc-0efc-4830-8c59-411c9a3e0aba")

            $stdout.string.should include("mock")
            $stdout.string.should include("mock-acc")
            $stdout.string.should include("COMPLETED")
          end
        end

        it "should allow multple push for an image with 2 target images based on build id" do
          VCR.use_cassette('command/push_command/multiple_push_build_id') do
            @options = ({ :build => "661ee541-6db3-4d36-9b3c-8972d6e63c94",
                          :account => ["mock-acc","mock-acc"] })
            p = PushCommand.new(@options, @output)
            begin
              p.run
            rescue SystemExit => e
              e.status.should == 0
            end

            # Headers
            $stdout.string.should include("Provider Image")
            $stdout.string.should include("Provider")
            $stdout.string.should include("Account")
            $stdout.string.should include("Build")

            # Provider Images
            $stdout.string.should include("4f060b14-d627-4d20-a653-12307b6c0ea2")
            $stdout.string.should include("421bf284-2f51-4156-b068-79d86d8b3d27")

            # Build
            $stdout.string.should include("661ee541-6db3-4d36-9b3c-8972d6e63c94")

            $stdout.string.should include("mock")
            $stdout.string.should include("mock-acc")
            $stdout.string.should include("COMPLETED")
          end
        end

        it "should allow single push for an image on target image id" do
          VCR.use_cassette('command/push_command/multiple_push_target_image_id') do
            @options = ({ :targetimage => "e6176811-49e0-4dba-8b76-06b552a4b3a4",
                          :account => ["mock-acc"] })
            p = PushCommand.new(@options, @output)
            begin
              p.run
            rescue SystemExit => e
              e.status.should == 0
            end

            # Headers
            $stdout.string.should include("Provider Image")
            $stdout.string.should include("Provider")
            $stdout.string.should include("Account")
            $stdout.string.should include("Target Image")

            # Provider Image
            $stdout.string.should include("e4b94bf2-7bfc-4633-b6a1-2f888587417e")

            # Build
            $stdout.string.should include("e6176811-49e0-4dba-8b76-06b552a4b3a4")

            $stdout.string.should include("mock")
            $stdout.string.should include("mock-acc")
            $stdout.string.should include("PENDING")
          end
        end
      end


      describe "#request_parameters" do
        it "should give useful feedback if no account is specified" do
          b = PushCommand.new(@options, @output)
          begin
            b.request_parameters
          rescue SystemExit => e
            e.status.should == 1
          end
          $stdout.string.should  include("Error: You must specifcy an account to push to")
        end

        it "should give useful feedback if no image, build or targetimage is specified" do
          @options[:account] = ["mock_account"]
          b = PushCommand.new(@options, @output)
          begin
            b.request_parameters
          rescue SystemExit => e
            e.status.should == 1
          end
          $stdout.string.should  include("Error: You must specify either an image, build or target image to push")
        end
      end
    end
  end
end
