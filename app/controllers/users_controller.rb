class UsersController < ApplicationController

  require 'json'

  def user
    @username = params[:username]
    if !user_exists?(@username)
      flash[:danger] = "User not found"
      redirect_to '/'
      return
    end
    @data = user_data(@username)
  end

  def user_search
    username = params[:user]
    if !user_exists?(username)
      flash[:danger] = "User not found"
      redirect_to '/'
    else
      redirect_to '/user/' + username
    end
  end

end