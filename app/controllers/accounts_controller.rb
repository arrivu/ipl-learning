class AccountsController < ApplicationController

  def index
  	@accounts =  Account.order(:ac_name)
  end

  def new
  	@account = Account.new
  end

  def edit
  end

  def create
		@account = Account.new(params[:account])
		if @account.save
			flash[:success] = "account added successfully!!!!"
			redirect_to accounts_path
		else
			redirect_to new_account_path
		end
	end
  def adduser
    
  end
end
