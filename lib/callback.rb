class Callback
  attr_accessor :created_at, :message, :transaction_token

  def initialize(message, transaction_token)
    @message = message
    @transaction_token = transaction_token
    @created_at = DateTime.now
  end
end
