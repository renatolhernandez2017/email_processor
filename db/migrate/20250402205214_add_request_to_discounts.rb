class AddRequestToDiscounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :discounts, :request, foreign_key: true
  end
end
