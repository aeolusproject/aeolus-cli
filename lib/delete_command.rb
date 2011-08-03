module Aeolus
  module Image
    class DeleteCommand < BaseCommand
      def initialize(opts={}, logger=nil)
        super(opts, logger)
      end

      def provider_image
        delete_provider_image(@options[:providerimage])
      end

      private
      def delete_provider_image(provider_image)
        if !(is_uuid?(provider_image))
          puts "Error: '" + provider_image + "' is not a valid Provider Image ID"
          exit(1)
        end

        begin
          iwhd['/provider_images/' + provider_image].delete
          puts "Provider Image: '" + provider_image + "' was succesfully deleted"
          exit(0)
        rescue RestClient::ResourceNotFound
          puts "Error: Could not find Provider Image with ID: '" + provider_image  + "'"
          exit(1)
        rescue => e
          puts "Error: Could not delete Provider Image with ID: '" + provider_image  + "'"
          puts e.inspect
          exit(1)
        end
      end
    end

  end
end
