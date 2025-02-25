module StatusDetailManageable
  extend ActiveSupport::Concern

  def status_translation
    self.class.human_attribute_name("status/#{status}")
  end
end
