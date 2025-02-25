# frozen_string_literal: true

module RegistryManageable
  extend ActiveSupport::Concern

  def create_client(cart_fields, user)
    Client.create!(
      name: cart_fields[:name],
      email: cart_fields[:email],
      mobile: cart_fields[:mobile],
      message: cart_fields[:message],
      cpf: cart_fields[:cpf],
      user: user
    )
  end

  def sale_create(cart_fields, cart)
    Sale.create!(
      price: cart.final_price,
      parcel_number: cart_fields[:parcel_number],
      cart: cart,
      user: cart.user,
      client: cart.client,
      issuer_id: cart_fields["issuer_id"],
      status: "created"
    )
  end

  def sale_update(sale, response)
    transaction_data = response["point_of_interaction"]["transaction_data"]

    sale.update(
      link_payment: transaction_data["ticket_url"],
      qr_code: transaction_data["qr_code"],
      qr_code_base64: transaction_data["qr_code_base64"],
      transaction_id: response["id"],
      issuer_id: response["issuer_id"],
      taxes_amount: response["taxes_amount"],
      date_expiration: response["date_of_expiration"]
    )

    sale
  end

  def payment_create(cart_fields, sale)
    Payment.create!(
      name: cart_fields[:payment_name],
      parcel_number: cart_fields[:parcel_number],
      sale: sale,
      kind: cart_fields[:kind]
    )
  end

  def transfer_create(sale, products)
    products.each do |product|
      Transfer.create!(
        sale: sale,
        amout: products.amount,
        fee: 0,
        status: "blocked",
        percentual: 0,
        due_date: DateTime.now
      )
    end
  end

  def cart_create(products, client)
    Cart.create!(
      total: products.sum(:price),
      final_price: products.sum(:price),
      total_discount: 0,
      status: "created",
      status_detail: StatusDetail.first,
      client: client,
      user: products.first.user
    )
  end

  def cart_items_create(cart, products)
    products.each do |product|
      CartItem.create!(
        cart: cart,
        product: product,
        price: product.price,
        quantity: 1,
        discount: 0,
        final_price: product.price
      )
    end
  end
end
