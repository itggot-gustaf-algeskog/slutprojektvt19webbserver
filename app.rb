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