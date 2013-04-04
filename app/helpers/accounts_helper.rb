module AccountsHelper
	def errormessage
		 respond_to do |format|
      if @post.save
        $error =nil
        format.js
        format.html { redirect_to (account_path(params[:ac_id])) }
        flash[:success] = "user added to account successfully!!!!"
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        $error =nil
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        format.html { redirect_to (account_path(params[:ac_id])) }
        $error = @post

      end
    end
	end
end
