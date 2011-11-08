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
            @options = ({ :image => "04b509a2-274b-468d-84b0-e4190e4457cb",
                          :account => "ec2-acc,mock-acc" })
            p = PushCommand.new(@options, @output)
            begin
              p.run
            rescue SystemExit => e
              e.status.should == 0
            end
            $stdout.string.should include("Image: 04b509a2-274b-468d-84b0-e4190e4457cb")
            $stdout.string.should include("Provider Image: 139f9822-8228-4d25-a038-21a5d9e6888d")
            $stdout.string.should include("Provider Image: b7460080-2156-4d38-9945-f4edd052d87b")
            $stdout.string.should include("Status: New")
            $stdout.string.should include("Status: COMPLETE")
          end
        end

        it "should allow multple push for an image with 2 target images based on build id" do
          VCR.use_cassette('command/push_command/multiple_push_build_id') do
            @options = ({ :build => "5d81e1a4-911a-4934-bb50-b46881343f6d",
                          :account => "ec2-acc,mock-acc" })
            p = PushCommand.new(@options, @output)
            begin
              p.run
            rescue SystemExit => e
              e.status.should == 0
            end
            $stdout.string.should include("Build: 5d81e1a4-911a-4934-bb50-b46881343f6d")
            $stdout.string.should include("Provider Image: bd04dc3d-0e88-4175-987f-f448c009ea90")
            $stdout.string.should include("Provider Image: 3597b77b-0a0e-4d0c-8916-a071a6e8ec30")
            $stdout.string.should include("Status: New")
            $stdout.string.should include("Status: COMPLETE")
          end
        end

        it "should allow single push for an image on target image id" do
          VCR.use_cassette('command/push_command/multiple_push_target_image_id') do
            @options = ({ :targetimage => "e650a5cc-61e1-466e-83e1-8f8cfe5ac9b8",
                          :account => "mock-acc" })
            p = PushCommand.new(@options, @output)
            begin
              p.run
            rescue SystemExit => e
              e.status.should == 0
            end
            $stdout.string.should include("Target Image: e650a5cc-61e1-466e-83e1-8f8cfe5ac9b8")
            $stdout.string.should include("Provider Image: 2adccda4-d7eb-48eb-888e-54bd863f4130")
            $stdout.string.should include("Status: COMPLETE")
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
          @options[:account] = "mock_account"
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
