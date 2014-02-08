def user_comments_long(username)
  base = "http://www.reddit.com/user/" + username + '/comments.json?limit=1000'
  opts = ""
  comments = []
  count = 0
  while true do
    data = Net::HTTP.get_response(URI.parse(base + opts)).body
    json = JSON.parse(data)
    if json["error"] == 404
      return comments
    end
    json["data"]["children"].each do |comment|
      comments << comment["data"]
    end
    if json["data"]["after"] != nil
      opts = "&after=" + json["data"]["after"]
    else
      break
    end
  end
  return comments
end

def user_about(username)
  base = "http://www.reddit.com/user/" + username +'/about.json'
  data = Net::HTTP.get_response(URI.parse(base)).body
  json = JSON.parse(data)
  return json["data"]
end

def user_submitted(username)
  base = "http://www.reddit.com/user/" + username + '/submitted.json'
  opts = ""
  submits = []
  while true do
    data = Net::HTTP.get_response(URI.parse(base + opts)).body
    json = JSON.parse(data)
    json["data"]["children"].each do |post|
      submits << post["data"]
    end
    if json["data"]["after"] != "null"
      opts = "?after=" + json["data"]["after"]
    else
      break
    end
  end
  return submits
end

def user_exists?(username)
  url = "http://www.reddit.com/user/" + username + ".json"
  data = Net::HTTP.get_response(URI.parse(url)).body
  json = JSON.parse(data)
  return json["error"] != 404
end

def user_comments_short(username)
  base = "http://www.reddit.com/user/" + username + '/comments.json?'
  data = Net::HTTP.get_response(URI.parse(base + opts)).body
  json = JSON.parse(data)
  @comments = []
  json["data"]["children"].each do |comment|
    @comments << comment["data"]
  end
  return {comments: @comments}
end

def user_comment_percentiles(username)
  base = "http://www.reddit.com/user/" + username + '/comments.json?'
  data = Net::HTTP.get_response(URI.parse(base)).body
  json = JSON.parse(data)
  subreddits = Hash.new
  c_count = 0
  json["data"]["children"].each do |comment|
    c_count += 1
    c_data = comment["data"]
    if subreddits[c_data["subreddit"]] == nil
      subreddits[c_data["subreddit"]] = 1
    else
      subreddits[c_data["subreddit"]] += 1
    end
  end
  groups = []
  subreddits.each do |s|
    group = Hash.new
    group["label"] = s[0]
    group["value"] = (s[1].to_f / c_count) * 100
    groups << group
  end
  return {data: groups}
end