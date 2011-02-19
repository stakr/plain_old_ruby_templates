module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Helpers #:nodoc:
      
      module Render
        
        # TODO
        def partial(partial, options = {})
          render(options.merge(:partial => partial)).tap do |s|
            concat s if s.present?
          end
        end
        
      end
      
    end
  end
end
