module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Fixes #:nodoc:
      module HashWithIndifferentAccess #:nodoc:
        
        def merge_with_block_support(hash)
          if block_given?
            result = dup
            hash.each do |key, value|
              result[key] = key?(key) ? yield(convert_key(key), self[key], value) : value
            end
            result
          else
            merge_without_block_support(hash)
          end
        end
        
      end
    end
  end
end
