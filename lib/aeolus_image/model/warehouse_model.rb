module Aeolus
  module Image
    # require 'warehouse_client'
    include Warehouse
    class BucketObjectNotFound < Exception;end
    class BucketNotFound < Exception;end

    class WarehouseModel

      def ==(other_obj)
        # If the objects have different instance variables defined, they're definitely not ==
        return false unless instance_variables.sort == other_obj.instance_variables.sort
        # Otherwise, ensure that they're all the same
        instance_variables.each do |iv|
          return false unless other_obj.instance_variable_get(iv) == instance_variable_get(iv)
        end
        # They have the same instance variables and values, so they're equal
        true
      end

      class << self
        attr_accessor :warehouse, :bucket, :bucket_name

        def set_warehouse_and_bucket
          begin
            @@config ||= load_config
            self.warehouse = Warehouse::Client.new(@@config[:iwhd][:url])
            self.bucket = self.warehouse.bucket(@bucket_name)
          rescue
            raise BucketNotFound
          end
        end

        def bucket_objects
          self.set_warehouse_and_bucket if self.bucket.nil?

          begin
            self.bucket.objects
          rescue RestClient::ResourceNotFound
            []
          end
        end

        def first
        obj = bucket_objects.first
          obj ? self.new(obj.attrs(obj.attr_list)) : nil
        end

        def last
          obj = bucket_objects.last
          obj ? self.new(obj.attrs(obj.attr_list)) : nil
        end

        def all
          bucket_objects.map do |wh_object|
              self.new(wh_object.attrs(wh_object.attr_list))
          end
        end

        def find(uuid)
          self.set_warehouse_and_bucket if self.bucket.nil?
          begin
            if self.bucket.include?(uuid)
              self.new(self.bucket.object(uuid).attrs(self.bucket.object(uuid).attr_list))
            else
              nil
            end
          rescue RestClient::ResourceNotFound
            nil
          end
        end

        def where(query_string)
          self.set_warehouse_and_bucket if self.bucket.nil?
          self.warehouse.query(@bucket_name, query_string)
        end

        protected
        # Copy over entirely too much code to load the config file
        def load_config
          # TODO - Is this always the case? We should probably have /etc/aeolus-cli or something too?
          # Or allow Rails to override this
          @config_location ||= "~/.aeolus-cli"
          begin
            file_str = read_file(@config_location)
            if is_file?(@config_location) && !file_str.include?(":url")
              lines = File.readlines(File.expand_path(@config_location)).map do |line|
                "#" + line
              end
              File.open(File.expand_path(@config_location), 'w') do |file|
                file.puts lines
              end
              write_file
            end
            write_file unless is_file?(@config_location)
            YAML::load(File.open(File.expand_path(@config_location)))
          rescue Errno::ENOENT
            #TODO: Create a custom exception to wrap CLI Exceptions
            raise "Unable to locate or write configuration file: \"" + @config_location + "\""
          end
        end

        def write_file
          example = File.read(File.expand_path(File.dirname(__FILE__) + "/../../examples/aeolus-cli"))
          File.open(File.expand_path(@config_location), 'a+') do |f|
            f.write(example)
          end
        end

        def read_file(path)
          begin
            full_path = File.expand_path(path)
            if is_file?(path)
              File.read(full_path)
            else
              return nil
            end
          rescue
            nil
          end
        end

        def is_file?(path)
          full_path = File.expand_path(path)
          if File.exist?(full_path) && !File.directory?(full_path)
            return true
          end
          false
        end

      end

    end
  end
end
