RedditStat::Application.routes.draw do

  root 'index#home'

  match 'user/:username' => 'users#user', via: [:get]
  match 'user_search' => 'users#user_search', via: [:get]

  # JSON
  match 'json/:username' => 'json#user', via: [:get]

end
