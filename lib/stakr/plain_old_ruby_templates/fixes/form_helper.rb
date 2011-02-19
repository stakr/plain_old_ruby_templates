module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Fixes #:nodoc:
      module FormHelper #:nodoc:
        
        # Fixes the buggy implementation of form_for because it always pushes
        # the form tag into the output buffer and returns the output buffer
        # instead of the form tag.
        def form_for(record_or_name_or_array, *args, &proc)
          raise ArgumentError, "Missing block" unless block_given?
          
          options = args.extract_options!
          
          case record_or_name_or_array
          when String, Symbol
            object_name = record_or_name_or_array
          when Array
            object = record_or_name_or_array.last
            object_name = ActionController::RecordIdentifier.singular_class_name(object)
            apply_form_for_options!(record_or_name_or_array, options)
            args.unshift object
          else
            object = record_or_name_or_array
            object_name = ActionController::RecordIdentifier.singular_class_name(object)
            apply_form_for_options!([object], options)
            args.unshift object
          end
          
          result = ''
          result << form_tag(options.delete(:url) || {}, options.delete(:html) || {})
          result << fields_for(object_name, *(args << options), &proc)
          result << '</form>'
          
          if block_called_from_erb?(proc)
            concat result
          else
            result
          end
          
        end
        
        # Fixes the buggy implementation of fields_for because it simply yields
        # the block instead of capturing and returning its result
        def fields_for(record_or_name_or_array, *args, &block)
          raise ArgumentError, "Missing block" unless block_given?
          options = args.extract_options!
          
          case record_or_name_or_array
          when String, Symbol
            object_name = record_or_name_or_array
            object = args.first
          else
            object = record_or_name_or_array
            object_name = ActionController::RecordIdentifier.singular_class_name(object)
          end
          
          builder = options[:builder] || ActionView::Base.default_form_builder
          # to_s is required because capture result might be buffer object (which is not necessarily a string)
          result = capture(builder.new(object_name, object, self, options, block), &block).to_s
          
          if block_called_from_erb?(block)
            concat result
          else
            result
          end
          
        end
        
      end
    end
  end
end
