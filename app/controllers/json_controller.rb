class JsonController < ApplicationController

  def comment_percentiles
    username = params[:username]
    data = user_comment_percentiles(username)
    if params[:formatted] == "true"
      render :json => JSON.pretty_generate(data)
    else
      render :json => data
    end
  end

end