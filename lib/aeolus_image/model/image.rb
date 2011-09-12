module Aeolus
  module Image
    class Image < WarehouseModel
      OS = Struct.new(:name, :version, :arch)

      @bucket_name = 'images'

      def initialize(attrs)
        attrs.each do |k,v|
          if k.to_sym == :latest_build
            sym = :attr_writer
          else
            sym = :attr_accessor
          end
          self.class.send(sym, k.to_sym) unless respond_to?(:"#{k}=")
          send(:"#{k}=", v)
        end
        @xml_body = Nokogiri::XML @body
      end

      def template_xml
        unless @template_xml
          begin
            @template_xml = Nokogiri::XML image_builds.first.target_images.first.target_template.body
          rescue
            @template_xml = Nokogiri::XML "<template></template>"
          end
        end
        @template_xml
      end

      def latest_pushed_build
        ImageBuild.find(@latest_build) if @latest_build
      end

      def image_builds
        ImageBuild.find_all_by_image_uuid(@uuid)
      end

      #TODO: We should get the image fields from the object body once we have it defined.
      def name
        unless @name
          @name = @xml_body.xpath("/image/name").text
          if @name.empty?
            @name = template_xml.xpath("/template/name").text
          end
        end
        @name
      end

      def os
        unless @os
          @os = OS.new(template_xml.xpath("/template/os/name").text, template_xml.xpath("/template/os/version").text, template_xml.xpath("/template/os/arch").text)
        end
        @os
      end

      def description
        unless @description
          @description = template_xml.xpath("/template/description").text
        end
        @description
      end

      # Delete this image and all child objects
      def delete!
        begin
          image_builds.each do |build|
            build.delete!
          end
        rescue NoMethodError
        end
        Image.delete(@uuid)
      end
    end
  end
end
