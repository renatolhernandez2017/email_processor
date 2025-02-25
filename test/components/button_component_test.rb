# frozen_string_literal: true

require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  def test_component_renders_something_useful
    assert_equal(
      %(<span class="material-symbols-outlined">list</span>),
      render_inline(ButtonComponent.new(icon_name: "list", title: "", onclick: "modal_leads_filter")).css("span").to_html
    )
  end
end
