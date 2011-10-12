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

$: << File.expand_path(File.join(File.dirname(__FILE__), "../lib/aeolus_cli/command/"))
$: << File.expand_path(File.join(File.dirname(__FILE__), "../lib/aeolus_cli/model/"))

require 'rubygems'
require 'base'
require 'image'
require 'build'
require 'target_image'
require 'provider_image'
require 'config_parser'
require 'stringio'
require 'base_command'
require 'list_command'
require 'build_command'
require 'push_command'
require 'import_command'
require 'delete_command'



module Helpers
  # Silences any stream for the duration of the block.
  #
  #   silence_stream(STDOUT) do
  #     puts 'This will never be seen'
  #   end
  #
  #   puts 'But this will'
  #
  # (Taken from ActiveSupport)
  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end
end

RSpec.configure do |config|
  config.include Helpers
  config.before(:all) do
    Aeolus::Image::BaseCommand.class_eval do
      def load_config
        YAML::load(File.open(File.join(File.dirname(__FILE__), "/../examples/aeolus-cli")))
      end
    end
  end
  config.before(:each) do
    @output = double('output')
    @stdout_orig = $stdout
    $stdout = StringIO.new
    @options = {}
  end
  config.after(:each) do
    $stdout = @stdout_orig
  end
end
