class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(valid_params)
    if @user.save
      flash.now[:success] = build_success_message(@user, 'Created')
      redirect_to get_post_save_path
    else
      # Go back to the list screen
      render 'new'
    end
  end

  def update
    # Get the lastest version of the user first.
    @user = find_by_id(params[:id])
    if @user.update_attributes(valid_params)
      flash.now[:success] = build_success_message(@user, 'Updated')
      # Go back to the list screen
      redirect_to get_post_save_path
    else
      render 'edit'
    end
  end

  def edit
    @user = find_by_id(params[:id])
  end

  def destroy

    # Get the latest version of this user from the DB first
    @user = find_by_id(params[:id])

    # And make sure this isn't the current user
    return_message = ''
    if @user.id != current_user.id
      User.find(params[:id]).destroy
      return_message = build_success_message @user, 'Deleted'
    else
      return_message = "You cannot delete yourself."
    end

    # NOTE: flash should be used when redirecting, flash.now should be used to render
    flash[:success] = return_message
    # NOTE: redirect_to should be used as redirect_to_url is depricated
    redirect_to get_post_save_path
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = find_by_id(params[:id])
  end

  private
    # User.find(user_id) is called often, so shoving it in it's own method
    def find_by_id(user_id)
      @user = User.find(user_id)
    end

    # This limits the parms that we'll take from the client
    def valid_params
      # If they didn't supply a password then we want to keep what's in the db
      if supplied_password_on_update?
        params.require(:user).permit(:f_name, :l_name, :email, :admin)
      else
        params.require(:user).permit(:f_name, :l_name, :email, :password, :password_confirmation, :admin)
      end
    end

    # Helper method so we don't duplicate code
    def build_success_message(user, action)
      "The user #{user.f_name} #{user.l_name} has been #{action} successfully."
    end

    def get_post_save_path
      users_path
    end

    # Just a test to see if on update they decided to change their password
    def supplied_password_on_update?
      !params[:user][:id].nil? && !params[:user][:password].blank? && !params[:user][:password_confirmation].blank?
    end
end
