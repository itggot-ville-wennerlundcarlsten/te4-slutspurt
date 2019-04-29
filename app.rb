require 'sinatra'
require 'pg'

get '/' do
  conn = Connection.conn
  kalle = []
  conn.exec('SELECT * FROM snus') do |result|
    result.each do |row|
      # puts row
      kalle << row
    end
  end
  print kalle
  erb :index, locals: { kalle: kalle }
end

post '/save_snus' do
  conn = Connection.conn
  @snusname = params[:name]
  @filename = params[:file] [:filename]
  file = params[:file] [:tempfile]
  @brandid = eval(params[:brand])['id']
  insert_snus(params, @filename, @brandid)
  newsnus = nil
  conn.exec("SELECT id FROM snus WHERE name = '#{@snusname}'") do |result|
    result.each do |row|
      newsnus = row['id']
    end
  end
  File.open("./public/assets/img/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end
  redirect "/snus/#{newsnus}"
end

def insert_snus(
  params,
  filename,
  brandid
)
  conn = Connection.conn
  conn.exec("INSERT INTO snus (
    brandid,
    type,
    prillsize,
    description,
    taste,
    netweight,
    nicotinepergram,
    name,
    image)
    VALUES (
    #{brandid},
    '#{params[:type]}',
    #{params[:prillsize]},
    '#{params[:description]}',
    '#{params[:taste]}',
    #{params[:netweight]},
    #{params[:nicotinepergram]},
    '#{params[:name]}',
    '#{filename}')")
end

get '/add_snus' do
  conn = Connection.conn
  distributors = []
  #distributor = Distributor.get()# { {join: 'brand'}} 
  distributors = Distributor.all() #SELECT * FROM distributors
  
  erb :add_snus, locals: { distributors: distributors }
end

get '/snus/:id' do
  test = params[:id]
  puts test
  kalle = ''
  conn = Connection.conn
  conn.exec("SELECT * FROM snus WHERE id = #{test}") do |result|
    result.each do |row|
      kalle = row
    end
  end
  puts kalle
  erb :snus, locals: { kalle: kalle }
end
