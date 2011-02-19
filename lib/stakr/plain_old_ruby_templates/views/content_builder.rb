module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Views #:nodoc:
      
      # A content builder can generate an HTML fragment using the specified block
      class ContentBuilder
        
        attr_reader :view
        attr_reader :options
        attr_reader :block
        
        def initialize(view, options, block)
          @view     = view
          @options  = options
          @block    = block
        end
        
        # generate content lazy
        def to_s(*args)
          @content = view.capture(*args, &block).with(options).to_s unless defined? @content # render only once
          @content
        end
        
        def blank?
          to_s.blank? # content builder should look like a string, thus, delegate blank? to to_s method
        end
        
      end
    end
  end
end
