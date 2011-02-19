module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Helpers #:nodoc:
      
      module Script
        
        # TODO
        #   script :src => 'foo.js.'
        #   script "alert('Hello World!')"
        def script(script_or_options)
          if script_or_options.is_a?(Hash)
            options = script_or_options.with_indifferent_access
            concat javascript_include_tag(options[:src])
          else
            concat javascript_tag(script_or_options.split($/).map { |l| l.strip }.join($/))
          end
        end
        
      end
      
    end
  end
end
