module SharedData
  extend ActiveSupport::Concern

  included do
    before_action :load_shared_data
  end

  private

  def load_shared_data
    @representatives = Representative.where(active: true).order("representatives.name ASC")
  end
end
