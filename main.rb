require 'pry'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'active_support/all'
require 'HTTParty'
require 'JSON'
require 'pg'

before do
  array = [] # SPLIT STRINGS INTO ARRAYS AND ENTER INTO NEW ARRAY
  menu = "SELECT distinct genre FROM memes"
  @nav_rows = sql_query(menu)
  @nav_rows.each do |row|
    row['genre'].split(', ').each do |separate|
      array << separate
    end
  end
  @nav_rows = array.uniq!.sort!
end

get '/' do
  all_vids = "SELECT * FROM memes ORDER BY fav DESC"
  @rows = sql_query(all_vids)
  erb :home
end

get '/new' do
  erb :new
end

post '/create' do
  string = genre_add
  a_vid = "INSERT INTO memes (title, description, vid_url, genre, fav) VALUES ('#{params[:title].titleize}','#{params[:description].gsub("'","*&")}','#{params[:vid_url]}', '#{string}', 0);"
  sql_query(a_vid)
  redirect to('/')
end

post '/video/:id/fav' do
  fav_vid = "UPDATE memes SET fav = fav + 1 WHERE id = #{params[:id]}"
  sql_query(fav_vid)
  redirect to('/')
end

get '/video/star' do
  all_vids = "SELECT * FROM memes WHERE star = 't';"
  @rows = sql_query(all_vids)
  erb :home
end

post '/video/:id/star' do
  sql = "SELECT star FROM memes WHERE id = #{params[:id]}"
  status = sql_query(sql).values[0]
  star_vid = "UPDATE memes SET star = true WHERE id = #{params[:id]}" if status == ['f']
  star_vid = "UPDATE memes SET star = false WHERE id = #{params[:id]}" if status == ['t']
  sql_query(star_vid)
  redirect to('/')
end

get '/video/:category' do
  vid_cat = "SELECT * FROM memes WHERE genre like '%#{params[:category]}%' ORDER BY fav DESC"
  @rows = sql_query(vid_cat)
  erb :home
end

post '/video/:id/delete' do
  remove_vid = "DELETE FROM memes WHERE id = #{params[:id]}"
  sql_query(remove_vid)
  redirect to('/')
end

get '/video/:id/edit' do
  edit_vid = "SELECT * FROM memes WHERE id = #{params[:id]}"
  rows = sql_query(edit_vid)
  @row = rows.first
  erb :edit
end

post '/video/:id' do
  string = genre_add
  update_video = "UPDATE memes SET title = '#{params['title'].titleize}', vid_url = '#{params['vid_url']}', description = '#{params['description'].gsub("'","*&")}', genre = '#{string}' WHERE id = #{params[:id]}"
  sql_query(update_video)
  redirect to('/')
end

def sql_query(sql)
  conn = PG.connect(:dbname =>'meme_app', :host => 'localhost')
  results = conn.exec(sql)
  conn.close
  results
end

def genre_add
  genre = []
  genre << "animation" if params['animation']
  genre << "artsy" if params['artsy']
  genre << "beautiful" if params['beautiful']
  genre << "emotional" if params['emotional']
  genre << "funny" if params['funny']
  genre << "indie" if params['indie']
  genre.join(", ")
end
