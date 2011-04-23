require 'yaml'

module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Helpers #:nodoc:
      
      # TODO
      # * Explain auto generated methods
      module Smart
        
        TAG_DEFINITIONS_FILE = "#{RAILS_ROOT}/config/tags.yml"
        TAG_DEFINITIONS = File.exists?(TAG_DEFINITIONS_FILE) ?
                            File.open(TAG_DEFINITIONS_FILE) { |f| YAML.load(f) }.with_indifferent_access :
                            { :content_tags => {}, :simple_tags => {} }.with_indifferent_access
        
        # caution: protected methods must not overridden, thus use method chaining for these methods
        PROTECTED_METHODS = [:a, :mail, :abbr, :form, :fields, :textarea, :submit, :input, :password, :hidden, :radio, :checkbox, :select_, :img, :hr]
        
        # TODO
        def a(content_or_options_with_block = nil, options = nil, &block)
          smart_content_tag_wrapper(content_or_options_with_block, options, block) do |c, o|
            if remote = o.delete(:remote)
              link_to_remote(c, { :url => o[:href] }, o)
            else
              link_to(c, o.delete(:href), o.to_hash)
            end
          end
        end
        
        # TODO: link or span with class selected
        def a_or_span(condition, content_or_options_with_block = nil, options = nil, &block)
          if block_given?
            options = (content_or_options_with_block || {}).with_indifferent_access
            auto_current = options.delete(:auto_current)
            if condition
              a(options, &block)
            else
              options.except!(:href, :title)
              options.update(:class => extend_class_attribute(options[:class], :current)) if auto_current
              span(options, &block)
            end
          else
            content = content_or_options_with_block
            options = (options || {}).with_indifferent_access
            auto_current = options.delete(:auto_current)
            if condition
              a(content, options, &block)
            else
              options.except!(:href, :title)
              options.update(:class => extend_class_attribute(options[:class], :current)) if auto_current
              span(content, options)
            end
          end
        end
        
        # TODO
        def mail(email_address, content_or_options = nil, options = nil, &block)
          if block_given? || (!content_or_options.blank? && !content_or_options.is_a?(Hash))
            # block provides the content (i.e. e-mail address is not set if blank) or
            # second parameter is real content (not blank and not a options hash)
            smart_content_tag_wrapper(content_or_options, options, block) do |c, o|
              mail_to(email_address, c, o.to_hash)
            end
          else
            # no content: use email address instead
            smart_content_tag_wrapper(email_address, content_or_options, nil) do |c, o|
              mail_to(email_address, nil, o.to_hash)
            end
          end
        end
        
        def abbr(content_or_options_with_block = nil, options = nil, &block)
          if block_given?
            options = (content_or_options_with_block || {}).with_indifferent_access
            length = options.delete(:length) || 30
            omission = options.delete(:omission) || '...'
            smart_content_tag_wrapper(options, nil, block) do |c, o|
              if c.to_s.size > length
                content_tag(:abbr, truncate(c, :length => length, :omission => omission), o.merge(:title => c).to_hash)
              else
                c.to_s
              end
            end
          else
            content = content_or_options_with_block
            options = (options || {}).with_indifferent_access
            length = options.delete(:length) || 30
            omission = options.delete(:omission) || '...'
            smart_content_tag_wrapper(content, options, nil) do |c, o|
              if c.to_s.size > length
                content_tag(:abbr, truncate(c, :length => length, :omission => omission), o.merge(:title => c).to_hash)
              else
                c.to_s
              end
            end
          end
        end
        
        # TODO
        def form(*args, &block)
          options = args.extract_options!
          if args.empty? # self-made form tag
            smart_content_tag(:form, options, &block)
          else # delegate to form_for method
            raise ArgumentError, "Missing block" unless block_given?
            smart_content_tag_wrapper(options, nil, block) do |c, o|
              xhr = o.delete(:xhr)
              o[:html] ||= {}; o[:html].update(o.except(:url, :html)) # moves all top-level attributes into the :html sub-hash
              o[:url] = url_for(:format => xhr ? 'js' : 'html') unless o[:url]
              __in_plain_old_ruby_template = true
              if xhr
                if o[:multipart]
                  o[:html][:'data-jquery-form'] = true
                  form_for(*(args << o)) do |f|
                    with_form_builder(f) { concat c.to_s(f) }
                  end
                else
                  remote_form_for(*(args << o)) do |f|
                    with_form_builder(f) { concat c.to_s(f) }
                  end
                end
              else
                form_for(*(args << o)) do |f|
                  with_form_builder(f) { concat c.to_s(f) }
                end
              end
            end
          end
        end
        
        # TODO
        def fields(*args, &block)
          options = args.extract_options!
          nested = options.include?(:nested) ? options.delete(:nested) : true
          raise ArgumentError, "Missing block" unless block_given?
          smart_content_tag_wrapper(options, nil, block, true) do |c, o|
            __in_plain_old_ruby_template = true
            if nested
              self.smart_form_builder.fields_for(*args) do |f|
                with_form_builder(f) { concat c.to_s(f) }
              end
            else
              fields_for(*args) do |f|
                with_form_builder(f) { concat c.to_s(f) }
              end
            end
          end
        end
        
        # TODO
        def label_(*args, &block)
          options = args.extract_options!
          if args.empty? # self-made input tag
            smart_content_tag_wrapper(options, nil, block) do |c, o|
              content_tag(:label, c, o.to_hash)
            end
          else # delegate to label method
            object = object_from_form_builder(self.smart_form_builder)
            method = args.shift
            text = args.shift
            text ||= object.class.human_attribute_name(method)
            concat self.smart_form_builder.label(method, text, options.to_hash)
          end
        end
        
        # TODO
        def textarea(*args, &block)
          options = args.extract_options!
          if args.empty? # self-made input tag
            smart_content_tag_wrapper(options, nil, block) do |c, o|
              content_tag(:textarea, escape_once(c), o.to_hash) # escape content because textarea tag may contains CDATA only
            end
          else # delegate to text_area method
            raise ArgumentError, "Block not allowed here" if block_given?
            group_options = options.delete(:group) || {}
            method = args.shift
            __in_plain_old_ruby_template = true
            group method, group_options do
              concat self.smart_form_builder.text_area(method, options.to_hash)
            end
          end
        end
        
        def select_(*args, &block)
          options = args.extract_options!
          if args.empty? # self-made select tag
            smart_content_tag_wrapper(options, nil, block) do |c, o|
              content_tag(:select, c, o.to_hash)
            end
          else # delegate to select method
            group_options = options.delete(:group) || {}
            method = args.shift
            include_blank = options.delete(:include_blank)
            __in_plain_old_ruby_template = true
            group method, group_options do
              object = object_from_form_builder(self.smart_form_builder)
              choices = (options.delete(:collection) || object.class.const_get(method.to_s.pluralize.upcase)).map { |c| c.is_a?(Array) ? [c.first, c.last] : [object.class.human_value(method, c), c] }
              choices.unshift(['', '']) if include_blank
              concat self.smart_form_builder.select(method, choices, {}, options.to_hash)
            end
          end
        end
        
        def submit(content_or_options_with_block = nil, options = nil, &block)
          __in_plain_old_ruby_template = true
          if block_given?
            options = (content_or_options_with_block || {}).with_indifferent_access
            group_options = options.delete(:group) || {}
            group nil, group_options.merge(:class => extend_class_attribute(group_options[:class], :submit)) do
              smart_content_tag(:button, options, &block)
            end
          else
            options = (options || {}).with_indifferent_access
            tag = options.delete(:tag) || :button
            group_options = options.delete(:group) || {}
            group nil, group_options.merge(:class => extend_class_attribute(group_options[:class], :submit)) do
              case tag
              when :button
                smart_content_tag(:button, content_or_options_with_block, options)
              else
                smart_simple_tag(:input, options.merge(:type => 'submit', :class => extend_class_attribute(options[:class], :button), :value => content_or_options_with_block))
              end
            end
          end
        end
        
        def group(method = nil, options = {}, &block)
          options = options.with_indifferent_access
          skip = options.delete(:skip)
          raise ArgumentError, "Missing block" unless block_given?
          __in_plain_old_ruby_template = true
          if smart_form_group || skip
            smart_content_tag(nil, options, nil, &block)
          else
            begin
              self.smart_form_group = true
              object = object_from_form_builder(self.smart_form_builder)
              
              # non-HTML options
              label_type      = options.include?(:label_type) ? options.delete(:label_type) : :label
              label           = options.delete(:label)
              example         = options.delete(:example)
              required        = options.delete(:required)
              error_handling  = options.delete(:errors)
              errors_of       = options.delete(:errors_of)
              errors          = Array(object.errors.on(errors_of || method))
              
              klass = extend_class_attribute(options[:class], :group)
              klass = extend_class_attribute(klass, :fieldWithErrors) if errors.present?
              
              smart_content_tag(:div, options.merge(:class => klass), nil) do
                if method
                  human_attribute_name = object.class.human_attribute_name(method)
                  
                  # label
                  label ||= human_attribute_name
                  label += '*' if required
                  case label_type.to_s
                  when 'label'
                    span :class => { :label => true } do
                      concat self.smart_form_builder.label(method, label)
                    end
                  when 'span'
                    span :class => { :label => true } do
                      concat label
                    end
                  end
                  
                  # field(s)
                  yield
                  
                  # errors or example
                  if (error_handling.blank? || error_handling.to_s != 'hide') && errors.present? # check for blank because blank cannot be converted in symbol
                    div :class => { :error => true }, :join => :br, :optional => true do
                      errors.each do |error|
                        text error
                      end
                    end
                  elsif example
                    example = object.class.human_attribute_example(method) unless example.is_a?(String)
                    span example, :class => { :description => true }
                  end
                  
                else
                  yield
                end
              end
            ensure
              self.smart_form_group = false
            end
          end
        end
        
        # Pushes a content tag of type <tt>name</tt> and its content into the output buffer.
        # If a block is given the content is generated by the block and the options are passed by
        # the <tt>content_or_options_with_block</tt> parameter; otherwise the content is passed by
        # the <tt>content_or_options_with_block</tt> parameter and the options by the <tt>options</tt>
        # parameter.
        # 
        # Special options which are not transformed into HTML attributes are:
        # * <tt>:if</tt> or <tt>:unless</tt> - pushes the tag if or unless the appended condition is complied
        # * <tt>:join</tt> or <tt>:sentence</tt> - joins the parts of the output buffer in the block using
        #   the specified string or tag (if value is a symbol: <tt>:br</tt> becomes to <tt>\<br /></tt>)
        #   or combines the parts using the <tt>Array#to_sentence</tt> method where the value of the option
        #   is passed to the <tt>to_sentence</tt> method if it is a <tt>Hash</tt>.
        #   Default behavior is <tt>:join => ''</tt>.
        # * <tt>:format</tt> - transforms the content to <tt>:simple_format</tt> or <tt>:textile</tt>.
        # * <tt>:cc</tt> - surrounds the tag with a conditional comment. the value is the condition.
        # * <tt>:rcc</tt> - surrounds the tag with a reverse conditional comment. the value is the condition.
        # * <tt>:divify</tt> - generates the specified tag and a div-tag alternative. the value is the condition.
        # * <tt>:optional</tt> - skips this tag if the content is empty
        # 
        # The tag <tt>name</tt> may be <tt>nil</tt>: In that case the options are applied to the
        # content, but only the content itself without the surrounding tag is pushed into the output
        # buffer.
        def smart_content_tag(name, content_or_options_with_block = nil, options = nil, &block)
          smart_content_tag_wrapper(content_or_options_with_block, options, block, name.nil?) do |c, o|
            if conditions = o.delete(:ie_classes)
              [].tap { |result|
                result << conditional_comments_wrapper(tag(name, o.merge(:class => extend_class_attribute(o[:class], 'ie6')), true), :cc => 'lt IE 7')
                result << conditional_comments_wrapper(tag(name, o.merge(:class => extend_class_attribute(o[:class], 'ie7')), true), :cc => 'IE 7')
                result << conditional_comments_wrapper(tag(name, o.merge(:class => extend_class_attribute(o[:class], 'ie8')), true), :cc => 'IE 8')
                result << conditional_comments_wrapper(tag(name, o, true), :rcc => '(gte IE 9)|!(IE)')
                result << c
                result << "</#{name}>"
              }.join('')
            elsif conditions = o.delete(:cc_swap)
              [].tap { |result|
                result << conditional_comments_wrapper(tag(name, o, true), :rcc => conditions.first)
                result << conditional_comments_wrapper(tag(:div, o.merge(:class => extend_class_attribute(o[:class], name)).to_hash, true), :cc => conditions.last)
                result << c
                result << conditional_comments_wrapper('</div>', :cc => conditions.last)
                result << conditional_comments_wrapper("</#{name}>", :rcc => conditions.first)
              }.join('')
            else
              content_tag(name, c, o.to_hash)
            end
          end
        end
        
        TAG_DEFINITIONS[:content_tags].each do |method, options|
          method = method.to_sym
          if PROTECTED_METHODS.include?(method) # use methods chaining for protected method name
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{method}_with_default_options(*args, &block)
                args << merge_default_options(TAG_DEFINITIONS[:content_tags][:#{method}], args.extract_options!)
                #{method}_without_default_options(*args, &block)
              end
              alias_method_chain :#{method}, :default_options
            RUBY
          else # define method for non-proctected method names
            tag = (options && options.key?(:tag)) ? options[:tag] : method
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{method}(*args, &block)
                args << merge_default_options(TAG_DEFINITIONS[:content_tags][:#{method}], args.extract_options!)
                smart_content_tag(#{tag ? ":#{tag}" : 'nil'}, *args, &block)
              end
            RUBY
          end
        end
        
        # TODO
        def meta_robots(options = {})
          __in_plain_old_ruby_template = true
          options = options.with_indifferent_access
          options.update(:index => false) if request.request_uri.include?('?')
          meta :name => 'robots', :content => options.map { |value, condition| "#{condition ? '' : 'no'}#{value}" }.sort.join(',')
        end
        
        # TODO
        def img(options = nil)
          smart_simple_tag_wrapper(options) do |o|
            image_tag(o.delete(:src), o.to_hash)
          end
        end
        
        # TODO
        def plain(*args)
          options = args.extract_options!
          group_options = options.delete(:group) || {}
          method = args.shift
          __in_plain_old_ruby_template = true
          group method, group_options do
            object = object_from_form_builder(self.smart_form_builder)
            if human_value_options = options.delete(:human_value)
              human_value_options = {} unless human_value_options.is_a?(Hash)
              text object.human_value(method, human_value_options)
            else
              text object.send(method)
            end
          end
        end
        
        # TODO
        def input(*args)
          options = args.extract_options!
          if args.empty? # self-made input tag
            smart_simple_tag_wrapper(options) do |o|
              tag(:input, o.to_hash)
            end
          else # delegate to text_field method
            group_options = options.delete(:group) || {}
            method = args.shift
            __in_plain_old_ruby_template = true
            group method, group_options do
              concat self.smart_form_builder.text_field(method, options.to_hash)
            end
          end
        end
        
        # TODO
        def password(method, options = {})
          # delegate to password_field method
          group_options = options.delete(:group) || {}
          __in_plain_old_ruby_template = true
          group method, group_options do
            concat self.smart_form_builder.password_field(method, options.to_hash)
          end
        end
        
        # TODO
        def file(method, options = {})
          # delegate to file_field method
          group_options = options.delete(:group) || {}
          spinner = options.delete(:spinner)
          __in_plain_old_ruby_template = true
          group method, group_options do
            none :join => ' ' do
              concat self.smart_form_builder.file_field(method, options.to_hash)
              img :src => spinner, :class => { :spinner => true }, :style => { :display => :none } if spinner
            end
          end
        end
        
        # TODO
        def hidden(*args)
          options = args.extract_options!
          if args.empty? # self-made input tag
            smart_simple_tag_wrapper(options) do |o|
              tag(:input, o.to_hash)
            end
          else
            # delegate to hidden_field method
            method = args.shift
            __in_plain_old_ruby_template = true
            smart_simple_tag_wrapper(options) do |o|
              self.smart_form_builder.hidden_field(method, o.to_hash)
            end
          end
        end
        
        def checkbox(*args)
          options = args.extract_options!
          if args.empty? # self-made input tag (type checkbox)
            smart_simple_tag_wrapper(options) do |o|
              tag(:input, o.to_hash)
            end
          else # delegate to radio_button method
            group_options = options.delete(:group) || {}
            method = args.shift
            __in_plain_old_ruby_template = true
            group method, group_options.reverse_merge(:label_type => nil) do
              object = object_from_form_builder(self.smart_form_builder)
              none :join => ' ' do
                description = options.delete(:description) || object.class.human_attribute_description(method)
                concat self.smart_form_builder.check_box(method, options.to_hash)
                concat self.smart_form_builder.label(method, description)
              end
            end
          end
        end
        
        def radio(*args)
          options = args.extract_options!
          if args.empty? # self-made input tag (type radio)
            smart_simple_tag_wrapper(options) do |o|
              tag(:input, o.to_hash)
            end
          else # delegate to radio_button method
            group_options = options.delete(:group) || {}
            method = args.shift
            __in_plain_old_ruby_template = true
            group method, group_options.reverse_merge(:label_type => :span) do
              object = object_from_form_builder(self.smart_form_builder)
              none :join => options.delete(:options_join) || :br do
                object.class.const_get(method.to_s.pluralize.upcase).each do |value|
                  none :join => ' ' do
                    concat self.smart_form_builder.radio_button(method, value, options.to_hash)
                    concat self.smart_form_builder.label("#{method}_#{value}", object.class.human_value(method, value))
                  end
                end
              end
            end
          end
        end
        
        def date(*args) # delegate to date_select method
          options = args.extract_options!
          group_options = options.delete(:group) || {}
          method = args.shift
          __in_plain_old_ruby_template = true
          group method, group_options do
            concat self.smart_form_builder.date_select(method, options.to_hash)
          end
        end
        
        def hr(options = nil)
          options = (options || {}).with_indifferent_access.except(:cc, :rcc)
          __in_plain_old_ruby_template = true
          none do
            smart_simple_tag :hr, options.merge(:rcc => 'gte IE 8')
            div '', options.merge(:cc => 'lt IE 8', :class => extend_class_attribute(options[:class], :hr))
          end
        end
        
        # TODO
        def smart_simple_tag(name, options = nil)
          smart_simple_tag_wrapper(options) do |o|
            tag(name, o.to_hash)
          end
        end
        
        TAG_DEFINITIONS[:simple_tags].each do |method, options|
          method = method.to_sym
          if PROTECTED_METHODS.include?(method) # use methods chaining for protected method names
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{method}_with_default_options(*args)
                args << merge_default_options(TAG_DEFINITIONS[:simple_tags][:#{method}], args.extract_options!)
                #{method}_without_default_options(*args)
              end
              alias_method_chain :#{method}, :default_options
            RUBY
          else # define method for non-proctected method names
            tag = (options && options.key?(:tag)) ? options[:tag] : method
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{method}(*args)
                args << merge_default_options(TAG_DEFINITIONS[:simple_tags][:#{method}], args.extract_options!)
                smart_simple_tag(:#{tag}, *args)
              end
            RUBY
          end
        end
        
        def consume(options = {}, &block)
          raise ArgumentError, "Missing block" unless block_given?
          ::Stakr::PlainOldRubyTemplates::Views::ContentBuilder.new(self, options, block).to_s
        end
        
        def extend_class_attribute(value, *extensions)
          value = value.to_class_attr if value.respond_to?(:to_class_attr)
          classes = value.to_s.split(' ')
          extensions.each do |ex|
            classes << ex unless classes.include?(ex)
          end
          classes.join(' ')
        end
        
        private
          
          def smart_content_tag_wrapper(content_or_options_with_block, options, block, skip_tag = false, &impl)
            # caution: do not use "block_given?" here since original block is passed as regular argument
            options = content_or_options_with_block if block
            options = (options || {}).with_indifferent_access
            
            # leave method immediately if conditions not complied
            return unless check_conditional_options!(options)
            
            # split options
            html_options = options.except(:join, :sentence, :format, :optional, :cc, :rcc)
            options.slice!(:join, :sentence, :format, :optional, :cc, :rcc)
            options[:skip_tag] = skip_tag
            
            # get content or create content builder
            content = block ?
                        ::Stakr::PlainOldRubyTemplates::Views::ContentBuilder.new(self, options, block) :
                        format_helper(escape_once(content_or_options_with_block), options[:format])
            
            # build tag including its content using &impl block
            result = yield(content, html_options)
            
            # leave method if content is empty and tag is optional, e.g. necesssary for the <ul> tag
            return if (!options.include?(:optional) || options[:optional]) && content.blank?
            
            # replace result with content only if tag name is nil,
            # this is useful if we need some smart benefits but don't want to create a surrounding tag
            result = content if skip_tag
            
            # push result into output buffer
            concat conditional_comments_wrapper(result, options)
            
          end
          
          def smart_simple_tag_wrapper(options, &impl)
            options = (options || {}).with_indifferent_access
            
            # leave method immediately if conditions not complied
            return unless check_conditional_options!(options)
            
            # split options
            html_options = options.except(:cc, :rcc)
            options.slice!(:cc, :rcc)
            
            # build tag using &impl block
            result = yield(html_options)
            
            # push result into output buffer
            concat conditional_comments_wrapper(result, options)
            
          end
          
          def check_conditional_options!(options)
            if (options.key?(:if) && !options[:if]) || options[:unless]
              false
            else
              options.except!(:if, :unless)
              true
            end
          end
          
          def merge_default_options(defaults, options)
            options ||= {}
            if defaults
              defaults = defaults.except(:tag)
              defaults = defaults.except(:join, :sentence) if options.key?(:join) || options.key?(:sentence)
              defaults.deep_merge(options) # deep_merge: if html_attributes plug-in is available class and style attributes can be merged smarter
            else
              options
            end
          end
          
          def object_from_form_builder(f)
            f.object || instance_variable_get("@#{f.object_name}")
          end
          
      end
      
    end
  end
end
