class TransactionsController < ApplicationController


  def index
    @transactions = current_user.transaction_histories_sent + current_user.transaction_histories_received
  end

end
