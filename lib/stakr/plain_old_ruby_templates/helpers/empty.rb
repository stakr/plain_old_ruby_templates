module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Helpers #:nodoc:
      
      module Empty
        
        # TODO: design only tag
        def empty(comment, options = {})
          concat content_tag(:div, "<!-- #{h(comment)} -->", options)
        end
        
      end
      
    end
  end
end
