require 'bundler'
Bundler.require :default

# Datamapper
DataMapper::Logger.new $stdout, :debug
DataMapper.setup :default, 'mysql://localhost/nid_development'
DataMapper::Pagination.defaults[:size] = 5
DataMapper::Pagination.defaults[:per_page] = 20
DataMapper::Pagination.defaults[:pager_class] = "pager group"

class Nid < Sinatra::Base

  require 'app/models'
  require 'app/importer'

  NID_CONFIG = YAML.load_file File.join(File.dirname(__FILE__), "config/nid.yml")

  # Routes

  # sinatra configuration {{{
  enable :static
  set :public, File.join(File.dirname(__FILE__), "public")
  # }}}

  get %r{^(.+)/$} do |path| # {{{
    redirect path, 301
  end # }}}

  get "/" do # {{{
    @tweets = Tweet.page((params[:page] || 1), :per_page => 20, :order => :created_at.desc)
    set_sidebar
    haml :index
  end # }}}

  get "/tweets.json" do # {{{
    @tweets = Tweet.page((params[:page] || 1), :per_page => 20, :order => :created_at.desc)
    content_type "application/json"
    output = {}
    output[:html] = haml :_tweets, :layout => false, :locals => { :tweets => @tweets }
    output[:pagination] = @tweets.pager
    output.to_json
  end # }}}

  get "/mentions" do # {{{
    @users = User.page((params[:page] || 1), :per_page => 20, :order => :mention_count.desc)
    @max_mentions = User.first(:order => :mention_count.desc).mention_count

    @subtitle = "Mentionned users"
    set_sidebar
    haml :users
  end # }}}

  get "/mentions/:username" do # {{{
    user = User.first :username => params[:username]
    return "error" unless user

    @tweets = Mention.all(:user_id => user.id).tweets.page((params[:page] || 1), :per_page => 20, :order => :created_at.desc)

    @subtitle = "Tweets mentionning #{user.username}"
    set_sidebar
    haml :index
  end # }}}

  get "/tags" do # {{{
    @tags = Tag.all :order => :tag.asc
    @max_hashtags = @tags.first.hashtag_count

    @subtitle = "Hashtags"
    set_sidebar
    haml :tags
  end # }}}

  get "/tags/:tag" do # {{{
    tag = Tag.first :tag => params[:tag]
    return "error" unless tag

    @tweets = Hashtag.all(:tag_id => tag.id).tweets.page((params[:page] || 1), :per_page => 20, :order => :created_at.desc)

    @subtitle = "Tweets tagged with #{tag.hashtag}"
    set_sidebar
    haml :index
  end # }}}

  get %r{^/([0-9]{4})$} do |year| # {{{
    start_date = DateTime.parse "#{year}-01-01 00:00:00"
    end_date = DateTime.parse "#{year}-12-31 23:59:59"
    @tweets = Tweet.page((params[:page] || 1), :per_page => 20, :created_at => (start_date..end_date), :order => :created_at.desc)

    @subtitle = "Tweets posted in #{year}"
    set_sidebar
    haml :index
  end # }}}

  get %r{^/([0-9]{4})/([0-9]{2})$} do |year, month| # {{{
    start_date = DateTime.parse "#{year}-#{month}-01 00:00:00"
    end_date = DateTime.parse "#{year}-#{month}-31 23:59:59"
    @tweets = Tweet.page((params[:page] || 1), :per_page => 20, :created_at => (start_date..end_date), :order => :created_at.desc)

    @subtitle = "Tweets posted in #{month} #{year}"
    set_sidebar
    haml :index
  end # }}}

  get %r{^/([0-9]{4})/([0-9]{2})/([0-9]{2})$} do |year, month, day| # {{{
    start_date = DateTime.parse "#{year}-#{month}-#{day} 00:00:00"
    end_date = DateTime.parse "#{year}-#{month}-#{day} 23:59:59"
    @tweets = Tweet.page((params[:page] || 1), :per_page => 20, :created_at => (start_date..end_date), :order => :created_at.desc)

    @subtitle = "Tweets posted on #{day} #{month} #{year}"
    set_sidebar
    haml :index
  end # }}}

  get %r{^/([0-9]{4})/([0-9]{2})/([0-9]{2})/([0-9]+)$} do |year, month, day, tweet_id| # {{{
    @tweets = [].push Tweet.all(:tweet_id => tweet_id, :limit => 1).first
    haml :index
  end # }}}

  # Filters

  def set_sidebar # {{{
    @side_users = User.all :limit => 10, :order => :mention_count.desc
    @side_tags = Tag.all :limit => 10, :order => :hashtag_count.desc
  end # }}}

end
# vim: fdm=marker:
