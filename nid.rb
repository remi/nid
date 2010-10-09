require 'sinatra/base'
require 'haml'
require 'json'
require 'yaml'
require 'open-uri'
require 'twitter'

# Datamapper
require 'dm-core'
require 'dm-migrations'

DataMapper::Logger.new $stdout, :debug
DataMapper.setup :default, 'mysql://localhost/nid_development'

# ActionView
require 'action_view'

class Nid < Sinatra::Base

  require 'app/models'

  NID_CONFIG = YAML.load_file File.join(File.dirname(__FILE__), "config/nid.yml")

  # sinatra configuration {{{
  enable :static
  set :public, File.join(File.dirname(__FILE__), "public")
  # }}}

  get "/import" do # {{{
    return "no more import!"
    #DataMapper.auto_upgrade!

    DataMapper.auto_migrate!

    twitter_config = NID_CONFIG["twitter"]
    oauth = Twitter::OAuth.new twitter_config["consumer_key"], twitter_config["consumer_secret"]
    oauth.authorize_from_access twitter_config["access_token"], twitter_config["access_secret"]

    client = Twitter::Base.new(oauth)
    tweets = client.user_timeline(:count => 200, :include_entities => 1)

    tweets.each do |tweet|
      new_tweet = Tweet.create({
        :tweet_id => tweet.id,
        :text => tweet.text,
        :created_at => tweet.created_at
      })

      # Import user @mentions
      tweet.entities.user_mentions.each do |mention|
        new_tweet.mentions.push({ :user_id => User.first_or_create({ :user_id => mention.id, :username => mention.screen_name, }).id })
      end

      # Import #hashtags
      tweet.entities.hashtags.each do |hashtag|
        new_tweet.hashtags.push({ :tag_id => Tag.first_or_create({ :tag => hashtag.text, }).id })
      end

      new_tweet.save
    end

    "done."
  end # }}}

  get "/" do # {{{
    @tweets = Tweet.all :limit => 20
    haml :index
  end # }}}

  get "/statuses/:id" do # {{{
    @tweets = [].push Tweet.first :tweet_id => params[:id]
    haml :index
  end # }}}

  get "/mentions/:username" do # {{{
    user = User.first :username => params[:username]
    return "error" unless user

    @tweets = Mention.all(:user_id => user.id).tweets

    @subtitle = "Tweets mentionning #{user.username}"
    haml :index
  end # }}}

  get "/tags/:tag" do # {{{
    tag = Tag.first :tag => params[:tag]
    return "error" unless tag

    @tweets = Hashtag.all(:tag_id => tag.id).tweets

    @subtitle = "Tweets tagged with #{tag.hashtag}"
    haml :index
  end # }}}

end
# vim: fdm=marker:
