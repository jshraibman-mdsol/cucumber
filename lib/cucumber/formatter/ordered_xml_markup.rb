begin
  require 'builder'
rescue LoadError
  gem 'builder'
  require 'builder'
end

module Cucumber
  module Formatter
    # Emits attributes ordered alphabetically, so that we can predicatbly test output.
    class OrderedXmlMarkup < Builder::XmlMarkup
      def _insert_attributes(attrs, order=[])
        return if attrs.nil?
        no_sort = (attrs.keys - [:version, :encoding] == []) #HACK to ensure the 'version' attribute is first in xml declaration.
        keys = attrs.keys.map{|k| k.to_s}
        keys.sort! unless no_sort
        keys.each do |k|
          v = attrs[k.to_sym] || attrs[k]
          @target << %{ #{k}="#{_attr_value(v)}"} if v
        end
      end
    end
  end
end