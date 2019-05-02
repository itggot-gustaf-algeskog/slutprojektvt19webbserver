require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative 'functions.rb'

before('/') do
    get_products
    user_info
end

get('/') do
    slim(:index, locals:{ products: session[:products], user_info: session[:user_info]})
end

get('/login') do
    slim(:login)
end

get('/register') do
    slim(:registrera)
end

before('/logga_in') do
    inloggning
end

post('/logga_in') do
    if session[:username] == session[:info][0][0] and BCrypt::Password.new(session[:info][0][1]) == session[:password]
        redirect('/')
    else
        redirect('/no_access')
    end
end

before('/registrering') do
    registrering
end

post('/registrering') do    
    redirect('/')
end

before('/produktsida/:id') do
    session[:produktid] = params["id"]
    produktsida
end

get('/produktsida/:id') do
    slim(:produktsida, locals:{ produktsida: session[:produktsida]})
end

before('/search') do
    search
end

post('/search') do
    redirect('/search_result')
end

get('/search_result') do
    slim(:search_result, locals:{ results: session[:results]})
end

before('/thumbs_up') do
    if session[:id] != nil
        thumbs_up
    end
end

post('/thumbs_up') do
    if session[:id] != nil
        redirect('/')
    else
        redirect('/rating_error')
    end
end

before('/thumbs_down') do
    if session[:id] != nil
        thumbs_down
    end
end

post('/thumbs_down') do
    if session[:id] != nil
        redirect('/')
    else
        redirect('/rating_error')
    end
end

get('/rating_error') do
    slim(:rating_error)
end