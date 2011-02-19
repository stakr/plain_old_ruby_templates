require 'stakr/plain_old_ruby_templates/fixes/hash_with_indifferent_access'
require 'stakr/plain_old_ruby_templates/fixes/form_helper'

require 'stakr/plain_old_ruby_templates/helpers/commons'
require 'stakr/plain_old_ruby_templates/helpers/empty'
require 'stakr/plain_old_ruby_templates/helpers/doctype'
require 'stakr/plain_old_ruby_templates/helpers/render'
require 'stakr/plain_old_ruby_templates/helpers/script'
require 'stakr/plain_old_ruby_templates/helpers/smart'
require 'stakr/plain_old_ruby_templates/helpers/text'

require 'stakr/plain_old_ruby_templates/views/buffer'
require 'stakr/plain_old_ruby_templates/views/content_builder'
require 'stakr/plain_old_ruby_templates/views/handler'
require 'stakr/plain_old_ruby_templates/views/view'

::HashWithIndifferentAccess.class_eval do
  include ::Stakr::PlainOldRubyTemplates::Fixes::HashWithIndifferentAccess
  alias_method_chain :merge, :block_support
end

::ActionView::Base.class_eval do
  include ::Stakr::PlainOldRubyTemplates::Fixes::FormHelper
end

::ActionView::Template.register_template_handler :port, ::Stakr::PlainOldRubyTemplates::Views::Handler
::ActionView::Base.class_eval do
  # view extension
  include ::Stakr::PlainOldRubyTemplates::Views::View
  # new helpers
  include ::Stakr::PlainOldRubyTemplates::Helpers::Commons
  include ::Stakr::PlainOldRubyTemplates::Helpers::Empty
  include ::Stakr::PlainOldRubyTemplates::Helpers::Doctype
  include ::Stakr::PlainOldRubyTemplates::Helpers::Render
  include ::Stakr::PlainOldRubyTemplates::Helpers::Script
  include ::Stakr::PlainOldRubyTemplates::Helpers::Smart
  include ::Stakr::PlainOldRubyTemplates::Helpers::Text
end
