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
    describe ListCommand do
      it "should list all account" do
        VCR.use_cassette('command/list_command/list_all_accounts') do
          lc = ListCommand.new
          begin
            lc.accounts
          rescue SystemExit => e
            e.status.should == 0
          end
          headers = ["Name", "Provider", "Provider Type"]
          content = ["ec2-acc", "ec2-us-east-1", "ec2"]
          (headers + content).each do |expected_text|
            $stdout.string.should include(expected_text)
          end
        end
      end

      it "should list all targets" do
        VCR.use_cassette('command/list_command/list_all_targets') do
          lc = ListCommand.new
          begin
            lc.targets
          rescue SystemExit => e
            e.status.should == 0
          end
          headers = ["Name", "Reference"]
          content = ["Mock", "mock", "Amazon EC2", "ec2", "VMware vSphere", "vsphere"]
          (headers + content).each do |expected_text|
            $stdout.string.should include(expected_text)
          end
        end
      end

      it "should list all providers" do
        VCR.use_cassette('command/list_command/list_all_providers') do
          lc = ListCommand.new
          begin
            lc.providers
          rescue SystemExit => e
            e.status.should == 0
          end
          headers = ["Name", "Type", "Target Reference"]
          content = ["ec2-us-east-1", "ec2", "us-east-1"]
          (headers + content).each do |expected_text|
            $stdout.string.should include(expected_text)
          end
        end
      end

      it "should list all images" do
        VCR.use_cassette('command/list_command/list_all_images') do
          lc = ListCommand.new
          begin
            lc.images
          rescue SystemExit => e
            e.status.should == 0
          end
          headers = ["ID", "Name", "OS", "OS Version", "Arch", "Description"]
          content = ["7e6d409b-11d5-446d-99e8-656deb4f28ca", "a2da41eb-4bec-410c-b59d-afca5ea94c21", "Fedora", "14", "x86_64", "foo"]
          (headers + content).each do |expected_text|
            $stdout.string.should include(expected_text)
          end
        end
      end

      it "should list all build for a particular images" do
        VCR.use_cassette('command/list_command/list_all_builds_for_image') do
          lc = ListCommand.new({:id => "7e6d409b-11d5-446d-99e8-656deb4f28ca"})
          begin
            lc.builds
          rescue SystemExit => e
            e.status.should == 0
          end
          headers = ["ID", "Image"]
          content = ["7e6d409b-11d5-446d-99e8-656deb4f28ca", "98632297-1d3b-4493-8643-e37beb29204c"]
          (headers + content).each do |expected_text|
            $stdout.string.should include(expected_text)
          end
        end
      end

      it "should list all target images for a particular build" do
        VCR.use_cassette('command/list_command/list_all_target_images_for_build') do
          lc = ListCommand.new({:id => "3eeb6c8f-9dd0-4a5b-bd13-e96daef435f9"})
          begin
            lc.targetimages
          rescue SystemExit => e
            e.status.should == 0
          end
          headers = ["ID", "Status", "Build"]
          content = ["3a548835-3008-473b-a4c6-6618f82e026f", "COMPLETE", "3eeb6c8f-9dd0-4a5b-bd13-e96daef435f9"]
          (headers + content).each do |expected_text|
            $stdout.string.should include(expected_text)
          end
        end
      end

      it "should list all provider images for a particular target image" do
        VCR.use_cassette('command/list_command/list_all_provider_images_for_target_image') do
          lc = ListCommand.new({:id => "d7cab2b2-eeb8-459e-b739-a1844a5d5a62"})
          begin
            lc.providerimages
          rescue SystemExit => e
            e.status.should == 0
          end
          headers = ["ID", "Target Identifier", "Provider", "Status", "Target Image",
                     "Account", "Provider", "Provider Type"]
          content = ["9ac21235-81f4-4140-ac25-18a19ebcb2f8", "ami-test", "ec2-us-east-1",
                     "COMPLETE", "d7cab2b2-eeb8-459e-b739-a1844a5d5a62", "ec2-acc",
                     "ec2-us-east-1", "ec2"]
          (headers + content).each do |expected_text|
            $stdout.string.should include(expected_text)
          end
        end
      end
    end
  end
end
