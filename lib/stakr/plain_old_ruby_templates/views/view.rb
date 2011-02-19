module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Views #:nodoc:
      module View #:nodoc:
        
        def self.included(base)
          base.alias_method_chain :capture, :plain_old_ruby_template
        end
        
        BLOCK_CALLED_FROM_PLAIN_OLD_RUBY_TEMPLATE = 'defined? __in_plain_old_ruby_template'
        
        if RUBY_VERSION < '1.9.0'
          def block_called_from_plain_old_ruby_template?(block)
            block && eval(BLOCK_CALLED_FROM_PLAIN_OLD_RUBY_TEMPLATE, block)
          end
        else
          def block_called_from_plain_old_ruby_template?(block)
            block && eval(BLOCK_CALLED_FROM_PLAIN_OLD_RUBY_TEMPLATE, block.binding)
          end
        end
        
        def capture_with_plain_old_ruby_template(*args, &block)
          if block_called_from_plain_old_ruby_template?(block)
            with_output_buffer(::Stakr::PlainOldRubyTemplates::Views::Buffer.new(self)) { block.call(*args) }
          else
            capture_without_plain_old_ruby_template(*args, &block)
          end
        end
        
        def content_for(name, content = nil, &block)
          ivar = "@content_for_#{name}"
          content = capture(&block) if block_given?
          content.with(:join => "\n", :skip_line_breaks => true) if content.is_a?(::Stakr::PlainOldRubyTemplates::Views::Buffer)
          instance_variable_set(ivar, "#{instance_variable_get(ivar)}#{content}".html_safe)
          nil
        end
        
        attr_accessor :smart_form_builder
        
        def with_form_builder(f)
          self.smart_form_builder, old_form_builder = f, smart_form_builder
          yield
        ensure
          self.smart_form_builder = old_form_builder
        end
        
        attr_accessor :smart_form_group
        
      end
      
    end
  end
end
