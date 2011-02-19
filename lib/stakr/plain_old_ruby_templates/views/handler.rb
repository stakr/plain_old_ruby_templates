module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Views #:nodoc:
      class Handler < ::ActionView::TemplateHandler #:nodoc:
        include ::ActionView::TemplateHandlers::Compilable
        
        def compile(template)
          "__in_plain_old_ruby_template=true;" +
          "self.output_buffer=::Stakr::PlainOldRubyTemplates::Views::Buffer.new(self,\"\\n\",true);" + 
          template.source + ";\n" +
          "output_buffer.to_s"
        end
        
      end
    end
  end
end
