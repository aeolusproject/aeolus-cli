module Aeolus
  module Image
    class TargetImage < WarehouseModel
      @bucket_name = 'target_images'

      def initialize(attrs)
        attrs.each do |k,v|
          if k.to_sym == :build
            sym = :attr_writer
          else
            sym = :attr_accessor
          end
          self.class.send(sym, k.to_sym) unless respond_to?(:"#{k}=")
          send(:"#{k}=", v)
        end
      end

      def build
        ImageBuild.find(@build) if @build
      end

      def provider_images
        ProviderImage.all.select{|pi| pi.target_image and (pi.target_image.uuid == self.uuid)}
      end

      def target_template
        Template.find(@template) if @template
      end

      # Deletes this targetimage and all child objects
      def delete!
        begin
          provider_images.each do |pi|
            pi.delete!
          end
        rescue NoMethodError
        end
        TargetImage.delete(@uuid)
      end
    end
  end
end
