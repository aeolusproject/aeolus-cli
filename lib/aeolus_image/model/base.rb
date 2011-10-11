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

require 'active_resource'
module Aeolus
  module CLI
    class Base < ActiveResource::Base
      self.timeout = 600
      class << self
        def instantiate_collection(collection, prefix_options = {})
          unless collection.kind_of? Array
            [instantiate_record(collection, prefix_options)]
          else
            collection.collect! { |record| instantiate_record(record, prefix_options) }
          end
        end
      end
    end
  end
end