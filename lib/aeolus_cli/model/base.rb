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
          if collection.is_a?(Hash) && collection.size == 1
            value = collection.values.first
            if value.is_a?(Array)
              value.collect! { |record| instantiate_record(record,prefix_options) }
            else
              [ instantiate_record(value, prefix_options) ]
            end
          elsif collection.is_a?(Hash)
            instantiate_record(collection, prefix_options)
          else
            begin
              collection.collect! { |record| instantiate_record(record, prefix_options) }
            rescue
              []
            end
          end
        end
      end

      # Active Resrouce Uses dashes instead of underscores, this method overrides to use underscore
      def to_xml(options={})
        options[:dasherize] ||= false
        super({ :root => self.class.element_name }.merge(options))
      end

      # Instance Methods
      def to_s
        id
      end
    end
  end
end