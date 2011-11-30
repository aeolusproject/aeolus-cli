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
    describe StatusCommand do
      it "should return status for target image" do
        VCR.use_cassette('command/status_command/targetimage') do
          @options[:targetimage] = ['1a0b179b-eb8a-4ce5-96e5-2b01ef2089cb']

          s = StatusCommand.new(@options, @output)
          begin
            s.run
          rescue SystemExit => e
            e.status.should == 0
          end
          $stdout.string.should include("Build Status: FAILED")
        end
      end

      it "should return status for provider image" do
        VCR.use_cassette('command/status_command/providerimage') do
          @options[:providerimage] = ['1ad1ca1d-d6d8-4892-a255-c4d49c03ed9b']

          s = StatusCommand.new(@options, @output)
          begin
            s.run
          rescue SystemExit => e
            e.status.should == 0
          end
          $stdout.string.should include("Push Status: COMPLETE")
        end
      end
    end
  end
end
