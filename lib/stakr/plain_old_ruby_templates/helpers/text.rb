module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Helpers #:nodoc:
      
      # TODO
      module Text
        
        # Pushes the escaped <tt>string</tt> into the output buffer.
        # 
        # Valid options are:
        # * <tt>:escape</tt> - TODO
        # * <tt>:format</tt> - transforms the escaped <tt>string</tt> to <tt>:simple_format</tt> or <tt>:textile</tt>.
        # * <tt>:cc</tt> - surrounds the text with a conditional comment. the value is the condition.
        def text(string, options = nil)
          options = (options || {}).with_indifferent_access
          string = escape_once(string) if !options.include?(:escape) || options[:escape]
          concat conditional_comments_wrapper(format_helper(string, options[:format]), options)
        end
        
      end
      
    end
  end
end
