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
    describe BaseCommand do
      let( :base_command ) { BaseCommand.new }

      describe "configure_active_resource" do
        it "should setup ActiveResource with endpoint and authentication" do
          base_command
          Aeolus::CLI::Base.site.to_s.should == "https://localhost/conductor/api"
          Aeolus::CLI::Base.user.to_s.should == "admin"
          Aeolus::CLI::Base.password.to_s.should == "password"
        end
      end

      describe "#read_file" do
        it "should return nil when it cannot find file" do
          base_command.send(:read_file, "foo.fake").should be_nil
        end

        it "should read file content into string variable" do
          template_str = base_command.send(:read_file, "#{File.dirname(__FILE__)}" + "/../../examples/custom_repo.tdl")
          template_str.should include("<template>")
        end
      end

      describe "#is_file?" do
        it "should return false if no file found" do
          base_command.send(:is_file?, "foo.fake").should be_false
        end
        it "should return true if file found" do
          valid_file = "#{File.dirname(__FILE__)}" + "/../../examples/aeolus-cli"
          base_command.instance_eval {@config_location = valid_file}
          base_command.send(:is_file?, valid_file).should be_true
        end
      end

      describe "#write_file" do
        it "should write a new file" do
          new_file = "/tmp/foo.fake"
          base_command.instance_eval {@config_location = new_file}
          base_command.send(:write_file)
          conf = YAML::load(File.open(File.expand_path(new_file)))
          conf.has_key?(:conductor).should be_true
          File.delete(new_file)
        end
      end

      describe "#validate_xml_document?" do
        it "should return errors given non compliant xml" do
          errors = base_command.send(:validate_xml_document, "examples/tdl.rng", File.read("spec/fixtures/invalid_template.tdl"))
          errors.length.should > 0
        end

        it "should return no errors" do
          errors = base_command.send(:validate_xml_document, "examples/tdl.rng", File.read("spec/fixtures/valid_template.tdl"))
          errors.length.should == 0
        end
      end

      describe "#handle_exception" do
        it "should display a user message when an authorised response is returned from Conductor" do
          VCR.use_cassette('command/base_command/invalid_credentials') do
            lc = ListCommand.new
            Aeolus::CLI::Base.password = "wrong_password"
            begin
              lc.accounts
            rescue SystemExit => e
              e.status.should == 1
            end
            $stdout.string.should include("Invalid Credentials, please check ~/.aeolus-cli")
          end
        end

        it "should display message when Found response is returned from Conductor" do
          resp = mock(:header => {'Location' => 'site'})
          e = ActiveResource::Redirection.new(resp)
          lambda {base_command.send(:handle_exception, e)}.should raise_error(SystemExit)

          $stdout.string.should include("Server tried to redirect to #{e.response.header['location']}, please check ~/.aeolus-cli")
        end

        it "should display message when Conductor is not running" do
          resp = mock(:header => {'Location' => 'site'})
          e = ActiveResource::ServerError.new(resp)
          lambda {base_command.send(:handle_exception, e)}.should raise_error(SystemExit)

          $stdout.string.should include("Please check that Conductor is running.")
        end

        it "should display message when there is incorrect hostname in .aeolus-cli" do
          e = SocketError.new
          lambda {base_command.send(:handle_exception, e)}.should raise_error(SystemExit)

          $stdout.string.should include("Please check your ~/.aeolus-cli")
        end
      end

    end
  end
end
