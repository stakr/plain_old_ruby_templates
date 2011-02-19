module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Views #:nodoc:
      
      # A buffer can generate an HTML fragment from a sequence of strings
      class Buffer
        
        def initialize(view, join = '', skip_line_breaks = false)
          @view = view
          @parts = []
          self.join = join
          self.skip_line_breaks = skip_line_breaks
        end
        
        def concat(string)
          @parts << string
        end
        alias << concat
        alias safe_concat concat
        
        def with(options)
          if options.key?(:sentence)
            self.sentence = options[:sentence]
          else
            self.join = options[:join]
          end
          self.format = options[:format]
          self.skip_tag = options[:skip_tag]
          self.skip_line_breaks = true if options[:skip_line_breaks]
          return self
        end
        
        attr_reader :join
        def join=(connector)
          if connector == :glue
            @join = ActionController::Base.perform_caching ? '' : "<!-- glue to avoid whitespace\n-->"
          elsif connector.is_a?(Symbol)
            @join = "\n<#{connector} />\n"
          else
            @join = connector || ''
          end
          @sentence = nil # only one, join or sentence, can be applied
        end
        
        attr_reader :sentence
        def sentence=(options = {})
          @join = nil # only one, join or sentence, can be applied
          @sentence = options.is_a?(Hash) ? options : {}
        end
        
        attr_accessor :format
        
        attr_accessor :skip_tag
        
        attr_accessor :skip_line_breaks
        
        def to_s
          unless defined? @content # render only once
            content = @view.format_helper(sentence ? @parts.to_sentence(sentence) : @parts.join(join), self.format)
            content = "\n#{content}\n" if !skip_line_breaks && !skip_tag && !content.blank? && join.include?("\n") # pretty print
            @content = content
          end
          return @content
        end
        
      end
    end
  end
end
