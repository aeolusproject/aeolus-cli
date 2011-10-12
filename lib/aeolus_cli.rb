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

require 'optparse'
require 'logger'
require File.join(File.dirname(__FILE__), 'aeolus_cli/command', 'base_command')
require File.join(File.dirname(__FILE__), 'aeolus_cli/command', 'list_command')
require File.join(File.dirname(__FILE__), 'aeolus_cli/command', 'build_command')
require File.join(File.dirname(__FILE__), 'aeolus_cli/command', 'push_command')
require File.join(File.dirname(__FILE__), 'aeolus_cli/command', 'import_command')
require File.join(File.dirname(__FILE__), 'aeolus_cli/command', 'delete_command')
require File.join(File.dirname(__FILE__), 'aeolus_cli/command', 'config_parser')

require File.join(File.dirname(__FILE__), 'aeolus_cli/model', 'base')
require File.join(File.dirname(__FILE__), 'aeolus_cli/model', 'image')
require File.join(File.dirname(__FILE__), 'aeolus_cli/model', 'build')
require File.join(File.dirname(__FILE__), 'aeolus_cli/model', 'provider_image')
require File.join(File.dirname(__FILE__), 'aeolus_cli/model', 'target_image')
require File.join(File.dirname(__FILE__), 'aeolus_cli/model', 'provider')
require File.join(File.dirname(__FILE__), 'aeolus_cli/model', 'provider_account')
require File.join(File.dirname(__FILE__), 'aeolus_cli/model', 'provider_type')
