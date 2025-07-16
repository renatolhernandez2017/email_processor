module SharedData
  extend ActiveSupport::Concern

  included do
    before_action :load_shared_data
  end

  private

  def load_shared_data
    @branches = Branch.pluck(:name, :id, :branch_number)
    @representatives = Representative.all
  end
end
