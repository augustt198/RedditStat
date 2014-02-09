class JsonController < ApplicationController

  require 'json'

  def user
    username = params[:username]
    data = user_data(username)
    if params[:formatted] == "true"
      render :json => JSON.pretty_generate(data)
    else
      render :json => data
    end
  end

end