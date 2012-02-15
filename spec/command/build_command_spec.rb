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
    describe BuildCommand do
      before(:each) do
        @options[:target] = ['ec2']
        @options[:template] = "#{File.dirname(__FILE__)}" + "../../fixtures/valid_template.tdl"
        @options[:environment] = ['default']
      end

      describe "#run" do
        it "should kick off a build with valid options" do
          VCR.use_cassette('command/build_command/build') do
            b = BuildCommand.new(@options, @output)
            begin
              b.run
            rescue SystemExit => e
              e.status.should == 0
            end
            $stdout.string.should include("Image")
            $stdout.string.should include("Target Image")
            $stdout.string.should include("Build")
            $stdout.string.should include("Target")
            $stdout.string.should include("Status")

            $stdout.string.should include("6affc8f5-a560-4b7e-88da-2e993cf9ebce")
            $stdout.string.should include("e0412885-28a6-4c3f-898a-886680ffadd0")
            $stdout.string.should include("0079b860-e601-4705-8729-d7624f160786")
            $stdout.string.should include("COMPLETED")
            $stdout.string.should include("ec2")

          end
        end

        it "should build for multiple targets" do
          VCR.use_cassette('command/build_command/multiple_build') do
            @options[:target] = ['ec2,mock']
            b = BuildCommand.new(@options, @output)
            begin
              b.run
            rescue SystemExit => e
              e.status.should == 0
            end
            $stdout.string.should include("Image")
            $stdout.string.should include("Build")
            $stdout.string.should include("Target Image")
            $stdout.string.should include("Target")
            $stdout.string.should include("Status")

            $stdout.string.should include("48b91462-9715-4a06-be21-4090972a7f5f")
            $stdout.string.should include("59643fd4-12d2-4e67-8394-2183341d9ec1")
            $stdout.string.should include("e33e3358-663a-4e81-9259-cff0ce6aa3b1")
            $stdout.string.should include("ec2")
            $stdout.string.should include("New")

            $stdout.string.should include("c74124e7-8777-4ec1-beea-d896bec80b22")
            $stdout.string.should include("mock")
            $stdout.string.should include("COMPLETED")
          end
        end

        it "should exit with a message if only image id is provided" do
          @options.delete(:template)
          @options.delete(:target)
          @options[:image] = '825c94d1-1353-48ca-87b9-36f02e069a8d'
          b = BuildCommand.new(@options, @output)
          begin
            b.run
          rescue SystemExit => e
            e.status.should == 1
          end
          $stdout.string.should include("This combination of parameters is not currently supported")
        end

        it "should exit with appropriate message when a non compliant template is given" do
          @options[:template] = "#{File.dirname(__FILE__)}" + "../../fixtures/invalid_template.tdl"
          @options[:image] = '825c94d1-1353-48ca-87b9-36f02e069a8d'
          b = BuildCommand.new(@options, @output)
          begin
            b.run
          rescue SystemExit => e
            e.status.should == 1
          end
          $stdout.string.should include("ERROR: The given Template does not conform to the TDL Schema")
        end
      end

      describe "#combo_implemented?" do
        it "should give useful feedback if no template or target is specified" do
          @options[:template] = ''
          @options[:target] = []
          b = BuildCommand.new(@options, @output)
          begin
            b.combo_implemented?
          rescue SystemExit => e
            e.status.should == 1
          end
          $stdout.string.should include("This combination of parameters is not currently supported")
        end
      end
    end
  end
end
