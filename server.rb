require 'sinatra'
require 'pry'
require 'pg'
require 'net/http'

#The method that connects us to the news database
def db_connection
  begin
    connection = PG.connect(dbname:'news')
      yield(connection)
  ensure
    connection.close
  end
end

#This method takes params hash and inserts its contents into the database.
def save_post(params)
  sql= 'INSERT INTO posts (title, description, url, created_at)
        VALUES($1,$2,$3,NOW())'
  db_connection do |conn|
    conn.exec_params(sql,[params[:title],params[:description],params[:url]])
  end
end

#A method that saves comments to the database
def save_comments(params)
  sql = 'INSERT INTO comments(post_id,description,created_at)
        VALUES($1,$2, NOW())'
    db_connection do |conn|
      conn.exec_params(sql,[params[:comment]])
    end
end

def check_if_url_exists_in_db?(params)
  sql = 'SELECT * FROM posts WHERE url = $1'
  check = db_connection do |conn|
    conn.exec_params(sql,[params[:url]])
  end

  if check.values.empty?
    false
  else
    true
  end
end

#This method check if the user input is valid
def check_title_and_description(params)
  if params[:title] == nil
    @errors << "Title can't be empty"
  end
  if params[:description] == nil
    @errors << "You need to add description"
  elsif params[:description].length < 20
    @errors << "description can't be less than 20 characters"
  end
end

#This method checks if url is valid or not
def check_submissions(url)
  url = url.downcase
  if url.include?("http://www.")
    valid_url?(url) ? url : false
  elsif url.include?("www.")
    valid_url?(url.insert(0,"http://")) ? url : false
  else
    valid_url?(url.insert(0,"http://www.")) ? url : false
  end
end

#This method validate the url before it is stored in the database
def valid_url?(url)
  begin
    Net::HTTP.get_response(URI(url)).code == "200" ? true : false
  rescue SocketError
    false
  end
end

#This get method redirects the user to the articles page.
get '/' do
  redirect '/articles'
end

#Method that gets the articles from the database
get '/articles' do

  sql = 'SELECT * FROM posts'
  @posts = db_connection do |conn|
    conn.exec(sql)
  end

  erb :index
end

#This get method gets the users' input from the form and
#invokes the save_post method which inserts user's informationt into the database
post '/articles/new' do
    @errors = []
  check_to_url = check_submissions(params[:url])
    if check_to_url == false
      @errors << "your url is not valid"
    end

  check_title_and_description(params)

  if check_if_url_exists_in_db?(params) == true
    @errors << "This article already exists"
    erb :show
  elsif @errors.empty?
    save_post(params)
    redirect '/articles'
  else
    erb :show
  end
end

#get post method that gets comments to be stored in the database
post '/comments' do
  save_comments(params)

  redirect '/articles'
end


get '/articles/new' do
  @errors = []
  erb :show
end
