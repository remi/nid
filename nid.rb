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
  require 'app/importer'

  NID_CONFIG = YAML.load_file File.join(File.dirname(__FILE__), "config/nid.yml")

  # Routes

  # sinatra configuration {{{
  enable :static
  set :public, File.join(File.dirname(__FILE__), "public")
  # }}}

  get "/import" do # {{{
    Importer.import!
    "Done importing."
  end # }}}

  get "/update" do # {{{
    Importer.update!
    "Done updating."
  end # }}}

  get "/" do # {{{
    @tweets = Tweet.all :limit => 20, :order => :created_at.desc
    haml :index
  end # }}}

  get "/statuses/:id" do # {{{
    @tweets = [].push Tweet.first :tweet_id => params[:id]
    haml :index
  end # }}}

  get "/mentions" do # {{{
    @users = User.all :order => :mention_count.desc
    @max_mentions = @users.first.mention_count

    @subtitle = "Mentionned users"
    haml :users
  end # }}}

  get "/mentions/:username" do # {{{
    user = User.first :username => params[:username]
    return "error" unless user

    @tweets = Mention.all(:user_id => user.id).tweets.all :order => :created_at.desc

    @subtitle = "Tweets mentionning #{user.username}"
    haml :index
  end # }}}

  get "/tags/:tag" do # {{{
    tag = Tag.first :tag => params[:tag]
    return "error" unless tag

    @tweets = Hashtag.all(:tag_id => tag.id).tweets.all :order => :created_at.desc

    @subtitle = "Tweets tagged with #{tag.hashtag}"
    haml :index
  end # }}}

end
# vim: fdm=marker:
