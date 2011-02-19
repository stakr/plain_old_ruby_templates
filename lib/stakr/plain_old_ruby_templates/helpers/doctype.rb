module Stakr #:nodoc:
  module PlainOldRubyTemplates #:nodoc:
    module Helpers #:nodoc:
      
      module Doctype
        
        # TODO
        def doctype(type = :xhtml)
          concat  case type
                  when :html_4_0_1_strict
                    %q<<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">>
                  when :html_4_0_1_transitional, :html_4_0_1, :html_4, :html4, :html
                    %q<<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">>
                  when :html_4_0_1_frameset
                    %q<<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">>
                  when :xhtml_1_0_strict
                    %q<<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">>
                  when :xhtml_1_0_transitional, :xhtml_1_0, :xhtml_1, :xhtml
                    %q<<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">>
                  when :xhtml_1_0_frameset
                    %q<<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">>
                  when :xhtml_1_1
                    %q<<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">>
                  when :html5, :html_5
                    %q<<!DOCTYPE html>>
                  end
        end
        
      end
      
    end
  end
end
