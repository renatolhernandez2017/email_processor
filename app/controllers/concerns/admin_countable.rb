module AdminCountable
  extend ActiveSupport::Concern

  included do
    before_action :set_counts
  end

  private

  def set_counts
    @carts_count = Cart.count_records
    @products_count = Product.count_records
    @guests_count = Guest.where.not(name: ["Tawany", "Renato"]).count_records
    @guests_confirmed_count = Guest.where.not(name: ["Tawany", "Renato"]).where(confirmed: true).count_records
    @users_count = User.count_records
    @clients_count = Client.count_records
  end
end
