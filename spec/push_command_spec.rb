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
  module Image
    describe PushCommand do

      before(:each) do
        @options[:provider] = ['mock']
        @options[:user] = 'admin'
        @options[:password] = 'password'
      end

      describe "#run" do
        before(:each) do
          options = {}
          options[:target] = ['mock','ec2']
          options[:template] = "#{File.dirname(__FILE__)}" + "/../examples/custom_repo.tdl"
          b = BuildCommand.new(options)
          sleep(5)
          tmpl_str = b.send(:read_file, options[:template])
          b.console.build(tmpl_str, ['mock','ec2']).each do |adaptor|
            @build_id = adaptor.image
          end
          b.console.shutdown
          @options[:id] = @build_id
        end

        it "should push an image with valid options" do
          p = PushCommand.new(@options, @output)
          begin
            p.run
          rescue SystemExit => e
            e.status.should == 0
          end
          $stdout.string.should include("Image:")
          $stdout.string.should include("Provider Image:")
          $stdout.string.should include("Build:")
        end
      end

      describe "#combo_implemented?" do
        it "should give useful feedback if no template or target is specified" do
          @options.delete(:id)
          @options.delete(:provider)
          b = PushCommand.new(@options, @output)
          begin
            b.combo_implemented?
          rescue SystemExit => e
            e.status.should == 1
          end
          $stdout.string.should  include("This combination of parameters is not currently supported")
        end
      end
    end
  end
end
