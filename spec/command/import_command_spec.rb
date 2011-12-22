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
      let( :description ) { "<image><name>MyImage</name></image>" }
      let( :options ) { { :id => "ami-5592553c",
        :target => ["ec2"],
        :provider_account => ["ec2-us-east-1"],
        :description => description } }
      let( :importc ) { ImportCommand.new( options ) }

      describe "#import_image" do
        context "without description parameter" do
          let( :options ) { { :id => "ami-5592553c",
            :target => ["ec2"],
            :provider_account => ["ec2-us-east-1"] } }

          it "should import an image with default description value" do
            VCR.use_cassette('command/import_command/import_image_default') do
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

        context "with description parameter" do
          context "as a string" do
            context "in correct format" do
              let( :description ) { "<image><name>MyImage</name></image>" }
              it "should import an image with provided description value" do
                VCR.use_cassette('command/import_command/import_image_default') do
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

            context "in incorrect format" do
              let( :description ) { "<badimage><name>MyImage</name></badimage>" }
              it "should not import an image at all" do
                VCR.use_cassette('command/import_command/import_image_default') do
                  begin
                    importc.import_image
                  rescue SystemExit => e
                    e.status.should == 1
                  end
                  $stdout.string.should include("ERROR")
                  $stdout.string.should include("Invalid description")
                end
              end
            end
          end

          context "as a file" do
            context "which exists" do
              context "and contains correct xml" do

                let( :description ) { 'examples/image_description.xml' }

                it "should import an image with file description" do
                  VCR.use_cassette('command/import_command/import_image_description_file') do
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

              context "and does not contain correct xml" do

                let( :description ) { 'examples/bad_image_description.xml' }

                it "should not import an image at all" do
                  VCR.use_cassette('command/import_command/import_image_description_file') do
                    begin
                      importc.import_image
                    rescue SystemExit => e
                      e.status.should == 1
                    end
                    $stdout.string.should include("ERROR")
                    $stdout.string.should include("Invalid description")
                  end
                end

              end
            end

            context "which does not exists" do

              let( :description ) { 'examples/no_file_image_description.xml' }

              it "should not import an image at all" do
                VCR.use_cassette('command/import_command/import_image_description_file') do
                  begin
                    importc.import_image
                  rescue SystemExit => e
                    e.status.should == 1
                  end
                  $stdout.string.should include("ERROR")
                  $stdout.string.should include("Invalid description")
                end
              end

            end
          end
        end
      end

      describe "#import_params_valid!" do
        subject { lambda { importc.send( :import_params_valid!, params ) } }
        context "correct params" do
          let( :params ) { { :id => "ami-5592553c",
            :target => ["ec2"],
            :provider_account => ["ec2-us-east-1"],
            :description => description } }
          it { subject.call.should be_true }
        end

        context "missing parameter" do
          let( :params ) { { :id => "ami-5592553c",
            :provider_account => ["ec2-us-east-1"],
            :description => description } }
          it { should raise_error(ArgumentError, /missing/) }
        end

        context "unexpected parameter" do
          let( :params ) { { :id => "ami-5592553c",
            :target => ["ec2"],
            :provider_account => ["ec2-us-east-1"],
            :other_parameter => "other_value",
            :description => description } }
          it { should raise_error(ArgumentError, /unexpected/) }
        end

        context "any parameter is nil" do
          let( :params ) { { :id => "ami-5592553c",
            :target => nil,
            :provider_account => ["ec2-us-east-1"],
            :other_parameter => "other_value",
            :description => description } }
          it { should raise_error(ArgumentError, /params should not contain nil/) }
        end

        context "parameters is not a Hash" do
          let( :params ) { "ami-5592553c" }
          it { should raise_error(TypeError, /params should be Hash instead/) }
        end
      end

      describe "validate_description_xml!" do
        subject { lambda { importc.send( :validate_description_xml!, xml ) } }
        context "with correct xml" do
          let( :xml ) { "<image><name>XML-NAME</name></image>" }
          it { subject.call.should be_true }
        end

        context "with incorrect xml" do
          let( :xml ) { "<badimage><name>XML-NAME</name></badimage>" }
          it { should raise_error( ArgumentError, /Invalid description/ ) }
        end
      end
    end
  end
end
