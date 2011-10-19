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
        it "should push an image with valid options" do
          VCR.use_cassette('command/push_command/push_image') do
            @options = ({ :image => "ae24eed8-6190-4725-877a-24bb1517fb54",
                          :build => "accaad33-6bc7-4cd0-9260-3fd5c1b73ff9",
                          :targetimage => "817ab83c-beda-4b84-bad1-38d90ebfe5ea",
                          :account => "ec2-acc",
                          :provider => "ec2-us-east-1" })
            p = PushCommand.new(@options, @output)
            begin
              p.run
            rescue SystemExit => e
              e.status.should == 0
            end
            $stdout.string.should include("Image: ae24eed8-6190-4725-877a-24bb1517fb54")
            $stdout.string.should include("Build: accaad33-6bc7-4cd0-9260-3fd5c1b73ff9")
            $stdout.string.should include("Target Image: 817ab83c-beda-4b84-bad1-38d90ebfe5ea")
            $stdout.string.should include("Provider Image: 92f03089-99a6-473d-afef-0a91b67b481a")
            $stdout.string.should include("Status:")
          end
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
