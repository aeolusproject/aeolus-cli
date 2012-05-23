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
    describe ConfigParser do
      it "should parse the specified command" do
        VCR.use_cassette('command/list_command/list_all_images') do
          begin
            config_parser = ConfigParser.new(%w(list  --images))
            config_parser.process
          rescue SystemExit => e
            e.status.should == 0
          end
          config_parser.command.should == 'list'
        end
      end

      it "should exit gracefully when a required subcommand is not provided" do
        begin
          silence_stream(STDOUT) do
            config_parser = ConfigParser.new(%w(list))
            config_parser.process
            config_parser.should_receive(:exit).with(1)
          end
        rescue SystemExit => e
          e.status.should == 1
        end
      end

      it "should notify the user of an invalid command" do
        config_parser = ConfigParser.new(%w(sparkle))
        config_parser.should_receive(:exit).with(1)
        silence_stream(STDOUT) do
          config_parser.process
        end
      end

      it "should exit gracefully with bad params" do
        begin
          silence_stream(STDOUT) do
            config_parser = ConfigParser.new(%w(delete --fred))
            config_parser.process
            config_parser.should_receive(:exit).with(1)
          end
        rescue SystemExit => e
          e.status.should == 1
        end
      end

      context "setting options hash" do
        subject { config_parser }
        let ( :parameters ) { %w{} }
        let ( :config_parser ) { ConfigParser.new( parameters ) }

        before(:each) do
          Aeolus::CLI::ConfigParser::COMMANDS.each do |command|
            subject.stub!( command.to_sym )
          end
          subject.process
        end

        context "for list command" do
          context "with --images" do
            let ( :parameters ) { %w(list --images) }
            let ( :options_hash ) { { :subcommand => :images } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --builds ID" do
            let ( :parameters ) { %w(list --builds 12345) }
            let ( :options_hash ) { { :subcommand => :builds, :id => '12345' } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --targetimages ID" do
            let ( :parameters ) { %w(list --targetimages 12345) }
            let ( :options_hash ) { { :subcommand => :targetimages, :id => '12345' } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --providerimages ID" do
            let ( :parameters ) { %w(list --providerimages 12345) }
            let ( :options_hash ) { { :subcommand => :providerimages, :id => '12345' } }
          its ( :options ) { should include( options_hash ) }
          end
          context "with --targets" do
            let ( :parameters ) { %w(list --targets) }
            let ( :options_hash ) { { :subcommand => :targets } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --providers" do
            let ( :parameters ) { %w(list --providers) }
            let ( :options_hash ) { { :subcommand => :providers } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --accounts" do
            let ( :parameters ) { %w(list --accounts) }
            let ( :options_hash ) { { :subcommand => :accounts } }

            its ( :options ) { should include( options_hash ) }
          end
        end

        context "for delete command" do
          context "with --image ID" do
            let ( :parameters ) { %w(delete --image 12345) }
            let ( :options_hash ) { { :image => '12345', :subcommand => :image } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --build ID" do
            let ( :parameters ) { %w(delete --build 12345) }
            let ( :options_hash ) { { :build => '12345', :subcommand => :build } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --targetimage ID" do
            let ( :parameters ) { %w(delete --targetimage 12345) }
            let ( :options_hash ) { { :targetimage => '12345', :subcommand => :target_image } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --providerimage ID" do
            let ( :parameters ) { %w(delete --providerimage 12345) }
            let ( :options_hash ) { { :providerimage => '12345', :subcommand => :provider_image } }

            its ( :options ) { should include( options_hash ) }
          end
        end

        context "for import command" do
          context "without other options" do
            let ( :parameters ) { %w(import --account ec2-us-east-1a --description /path/to/file --id ami-123456) }
            let ( :options_hash ) { { :provider_account => ['ec2-us-east-1a'], :description => '/path/to/file', :id =>  'ami-123456' } }

            its ( :options ) { should include( options_hash ) }
          end
        end

        context "for build command" do
          context "with --template FILE" do
            let ( :parameters ) { %w(build --target ec2,rackspace --template my.tmpl) }
            let ( :options_hash ) { { :target => ['ec2','rackspace'], :template => 'my.tmpl' } }

            its ( :options ) { should include( options_hash ) }
          end
        end

        context "for push command" do
          context "without other options" do
            let ( :parameters ) { %w(push --account ec2-us-east1 --image 12345) }
            let ( :options_hash ) { { :account => ['ec2-us-east1'], :image => '12345' } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --build ID" do
            let ( :parameters ) { %w(push --account ec2-us-east1 --build 12345) }
            let ( :options_hash ) { { :account => ['ec2-us-east1'], :build => '12345' } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --targetimage ID" do
            let ( :parameters ) { %w(push --account ec2-us-east1 --targetimage 12345) }
            let ( :options_hash ) { { :account => ['ec2-us-east1'], :targetimage => '12345' } }

            its ( :options ) { should include( options_hash ) }
          end
        end

        context "for status command" do
          context "with --targetimage" do
            let ( :parameters ) { %w(status --targetimage 789) }
            let ( :options_hash ) { { :targetimage => '789' } }

            its ( :options ) { should include( options_hash ) }
          end
          context "with --providerimage" do
            let ( :parameters ) { %w(status --providerimage 789) }
            let ( :options_hash ) { { :providerimage => '789' } }

            its ( :options ) { should include( options_hash ) }
          end
        end
      end

    end
  end
end
