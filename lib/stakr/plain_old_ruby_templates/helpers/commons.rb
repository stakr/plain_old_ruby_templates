module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Helpers #:nodoc:
      
      module Commons #:nodoc:
        
        def format_helper(string, format)
          case format.to_s
          when 'simple'
            simple_format(string)
          when 'textile'
            textilize(string)
          else
            string
          end
        end
        
        def conditional_comments_wrapper(string, options)
          if condition = options[:cc]
            "<!--[if #{condition}]>#{string}<![endif]-->"
          elsif condition = options[:rcc]
            "<!--[if #{condition}]><!-->#{string}<!--<![endif]-->"
          else
            string
          end
        end
        
      end
      
    end
  end
end
