require 'ostruct'
require 'httparty'
require 'byebug'

class User < Struct.new(:id, :payment_id)
end

class Order < Struct.new(:id, :user_id, :amount, :transaction_id, :payment_status)
end

class PaymentProcessor
  attr_reader :user, :order

  def self.call(user, order)
    new(user, order).call
  end

  def initialize(user, order)
    @user = user
    @order = order
  end

  def call
    response = PaymentGateway.charge(payment_id: user.payment_id, amount: order.amount)
    order.transaction_id = response.transaction_id
    order.payment_status = response.payment_status

    order
  end
end

class PaymentGateway
  def self.charge(payment_id:, amount:)
    # Execute third party api
    # Returns an object containing transaction id and payment status
    response = HTTParty.get('http://example.com/charge', query: { payment_id: payment_id, amount: amount })
    result = Struct.new(:transaction_id, :payment_status)
    result.new(response['transaction_id'], response['payment_status'])
  end
end

RSpec.describe PaymentProcessor do
  subject { described_class.call(user, order) }

  # let(:user) { instance_double(User, id: 1, payment_id: '00112233') }
  # let(:order) do
  #   instance_double(
  #     Order,
  #     id: 1,
  #     user_id: 1,
  #     amount: 500.00,
  #     :transaction_id= => mock_response.transaction_id,
  #     :payment_status= => mock_response.payment_status,
  #     :transaction_id => mock_response.transaction_id,
  #     :payment_status => mock_response.payment_status
  #   )
  # end
  # let(:mock_response) do
  #   double('PaymentGatewayResponse', transaction_id: '12345678', payment_status: 'success')
  # end

  let(:user) { User.new(id: 1, payment_id: '00112233') }
  let(:order) { Order.new(id: 1, user_id: 1, amount: 500.00) }
  let(:mock_response) do
    OpenStruct.new(transaction_id: '12345678', payment_status: 'success')
  end

  before(:example) do
    allow(PaymentGateway).to receive(:charge)
      .with(payment_id: user.payment_id, amount: order.amount)
      .and_return(mock_response)
  end

  it 'returns successful payment' do
    expect(subject.transaction_id).to eq('12345678')
    expect(subject.payment_status).to eq('success')
  end
end
