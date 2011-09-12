module Aeolus
  module Image
    class ProviderImage < WarehouseModel
      @bucket_name = 'provider_images'

      def initialize(attrs)
        attrs.each do |k,v|
          if [:provider, :target_image].include?(k.to_sym)
            sym = :attr_writer
          else
            sym = :attr_accessor
          end
          self.class.send(sym, k.to_sym) unless respond_to?(:"#{k}=")
          send(:"#{k}=", v)
        end
      end

      def target_image
        TargetImage.find(@target_image) if @target_image
      end

      def provider_name
        @provider
      end

      # Deletes this provider image
      def delete!
        ProviderImage.delete(@uuid)
      end
    end
  end
end
