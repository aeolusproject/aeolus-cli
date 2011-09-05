module Aeolus
  module Image
    class Template < WarehouseModel
      @bucket_name = 'templates'

      def initialize(attrs)
        attrs.each do |k,v|
          sym = :attr_accessor
          self.class.send(sym, k.to_sym) unless respond_to?(:"#{k}=")
          send(:"#{k}=", v)
        end
      end
    end
  end
end