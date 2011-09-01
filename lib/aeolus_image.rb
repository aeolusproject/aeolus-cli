require 'optparse'
require 'logger'
require File.join(File.dirname(__FILE__), 'aeolus_image/command', 'base_command')
require File.join(File.dirname(__FILE__), 'aeolus_image/command', 'list_command')
require File.join(File.dirname(__FILE__), 'aeolus_image/command', 'build_command')
require File.join(File.dirname(__FILE__), 'aeolus_image/command', 'push_command')
require File.join(File.dirname(__FILE__), 'aeolus_image/command', 'import_command')
require File.join(File.dirname(__FILE__), 'aeolus_image/command', 'delete_command')
require File.join(File.dirname(__FILE__), 'aeolus_image/command', 'config_parser')
require File.join(File.dirname(__FILE__), 'aeolus_image/model', 'warehouse_client') # Not sure we need this
require File.join(File.dirname(__FILE__), 'aeolus_image/model', 'warehouse_model')  # We may be able to factor this out?
require File.join(File.dirname(__FILE__), 'aeolus_image/model', 'image')
require File.join(File.dirname(__FILE__), 'aeolus_image/model', 'image_build')
require File.join(File.dirname(__FILE__), 'aeolus_image/model', 'provider_image')
require File.join(File.dirname(__FILE__), 'aeolus_image/model', 'target_image')