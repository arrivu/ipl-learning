class AccountsController < ApplicationController

  def index
  	@accounts =  Account.order(:ac_name)
  end

  def new
  	@account = Account.new
  end

  def edit
    @account = Account.find(params[:id])
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
 
  def show
    @account =Account.find(params[:id])
    
  end
end
def adduser

end

def update
  @account = Account.find(params[:id])
  if @account.update_attributes(params[:account])
    flash[:sucess] = "Accout updated sucessfuly"
    redirect_to accounts_path
  else
    render :edit
  end
end

def destroy
  @account = Account.find(params[:id])
  @account.destroy
  flash[:success] = "Successfully destroyed account."
  redirect_to accounts_path
end

end
