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
    describe CLIParser do
      it "should parse the specified command" do
          ConfigParser.any_instance.should_receive(:process).with(any_args()).and_return(true)
          parser = CLIParser.new(%w(image list --images))
          parser.process
          parser.command.should == 'image'
      end

      context "output help" do
        before(:each) do
          @out = double("out")
          @out.should_receive(:puts).with(instance_of(OptionParser)).once
        end

        it "should output help if no params passed" do
          parser = CLIParser.new([], @out)
          parser.process
        end

        it "should output help if -h passed" do
          parser = CLIParser.new(%w(-h), @out)
          parser.process
        end

        it "should output help if --help passed" do
          parser = CLIParser.new(%w(--help), @out)
          parser.process
        end
      end
    end
  end
end
