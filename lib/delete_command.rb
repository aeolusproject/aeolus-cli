module Aeolus
  module Image
    class DeleteCommand < BaseCommand
      def initialize(opts={}, logger=nil)
        super(opts, logger)
      end

      def provider_image
        check_id(@options[:providerimage], "Provider Image")
        begin
          delete_provider_image(@options[:providerimage])
          puts "Provider Image: '" + provider_image + "' was succesfully deleted"
          exit(0)
        rescue RestClient::ResourceNotFound
          puts "Error: Could not find Target Image with ID: '" + provider_image  + "'"
          exit(1)
        rescue => e
          puts "Error: Could not delete Target Image with ID: '" + provider_image  + "'"
          puts e.inspect
          exit(1)
        end
      end

      def target_image
        check_id(@options[:targetimage], "Target Image")
        begin
          delete_target_image(@options[:targetimage])
          puts "Target Image: '" + @options[:targetimage] + "' was succesfully deleted"
          exit(0)
        rescue RestClient::ResourceNotFound
          puts "Error: Could not find Target Image with ID: '" + @options[:targetimage]  + "'"
          exit(1)
        rescue => e
          puts "Error: Could not delete Target Image with ID: '" + @options[:targetimage]  + "'"
          puts e.inspect
          exit(1)
        end
      end

      def build
        check_id(@options[:build], "Build")
        begin
          delete_build(@options[:build])
          puts "Build: '" + @options[:build] + "' was succesfully deleted"
          exit(0)
        rescue RestClient::ResourceNotFound
          puts "Error: Could not find Build with ID: '" + @options[:build]  + "'"
          exit(1)
        rescue => e
          puts "Error: Could not delete Build with ID: '" + @options[:build]  + "'"
          puts e.inspect
          exit(1)
        end
      end

      def image
        check_id(@options[:image], "Image")
        begin
          delete_image(@options[:image])
          puts "Image: '" + @options[:image] + "' was succesfully deleted"
          exit(0)
        rescue RestClient::ResourceNotFound
          puts "Error: Could not find Image with ID: '" + @options[:image]  + "'"
          exit(1)
        rescue => e
          puts "Error: Could not delete Image with ID: '" + @options[:image]  + "'"
          puts e.inspect
          exit(1)
        end
      end

      # Deletes all objects.  Iterates through each object to make sure any stray objects are deleted.
      def iwhd
        list_command = ListCommand.new
        list_command.list_providerimages(nil, true).each do |provider_image|
          iwhd['/provider_images/' + provider_image].delete
        end

#        list_command.list_targetimages(nil, true).each do |target_image|
#          iwhd['/target_images/' + target_image].delete
#        end
#        
#        list_command.list_builds(nil, true).each do |build|
#          iwhd['/builds/' + build].delete
#        end
#        
#        list_command.list_images.each do |image|
#          iwhd['/images/' + image].delete
#        end
#        puts "IWHD was successfully cleared"
        exit(0)
      end

      private
      def delete_provider_image(provider_image)
        iwhd['/provider_images/' + provider_image].delete
      end

      def delete_target_image(target_image)
        # Delete Provider Images
        list_command = ListCommand.new
        list_command.list_providerimages(target_image).each do |provider_image|
          begin
            delete_provider_image(provider_image)
          rescue
          end
        end
        # Delete Target Image
        iwhd['/target_images/' + target_image].delete
      end

      def delete_build(build)
        # Delete Target Images
        list_command = ListCommand.new
        list_command.list_targetimages(build).each do |target_image|
          begin
            delete_target_image(target_image)
          rescue
          end
        end
        # Delete Build
        iwhd['/builds/' + build].delete
      end

      def delete_image(image)
        # Delete Builds
        list_command = ListCommand.new
        list_command.list_builds(image).each do |build|
          begin
            delete_build(build)
          rescue
          end
        end
        # Delete Image
        iwhd['/images/' + image].delete
      end

      def check_id(uuid, type)
        if !(is_uuid?(uuid))
          puts "Error: '" + uuid + "' is not a valid " + type + " ID"
          exit(1)
        end
      end
    end
  end
end
