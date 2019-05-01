require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative 'functions.rb'

before('/') do
    get_products
end

get('/') do
    slim(:index, locals:{ products: session[:products]})
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