require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative 'functions.rb'
include Functions

before('/') do
    get_products
    user_info
end

# Display Landing Page
#
get('/') do
    slim(:index, locals:{ products: session[:products], user_info: session[:user_info]})
end

# Display a Login form
#
get('/login') do
    slim(:login)
end

# Display a Register form
#
get('/register') do
    slim(:registrera)
end

before('/logga_in') do
    inloggning
end

# Attempts login and updates the session
#
post('/logga_in') do
    if session[:username] == session[:info][0][0] and BCrypt::Password.new(session[:info][0][1]) == session[:password]
        redirect('/')
    else
        session[:username] = nil
        session[:password] = nil
        session[:id] = nil
        redirect('/no_access')
    end
end

before('/registrering') do
    registrering
end

# Attempts register and creates a user
#
post('/registrering') do    
    if session[:error] != nil
        redirect('/error')
    else
        redirect('/')
    end
end

before('/produktsida/:id') do
    session[:produktid] = params["id"]
    produktsida
    get_comments
end

# Displays a single Product
#
get('/produktsida/:id') do
    slim(:produktsida, locals:{ produktsida: session[:produktsida], comments: session[:comments]})
end

before('/search') do
    search
end

# Attempts finding products and redirects to '/search_result'
#
post('/search') do
    redirect('/search_result')
end

# Displays search results
#
get('/search_result') do
    slim(:search_result, locals:{ results: session[:results]})
end

before('/thumbs_up') do
    if session[:id] != nil
        thumbs_up
    end
end

# Updates an existing rating and redirects back
#
post('/thumbs_up') do
    if session[:id] != nil
        redirect back
    else
        redirect('/rating_error')
    end
end

before('/thumbs_down') do
    if session[:id] != nil
        thumbs_down
    end
end

# Updates an existing rating and redirects back
#
post('/thumbs_down') do
    if session[:id] != nil
        redirect back
    else
        redirect('/rating_error')
    end
end

# Displays an error message
#
get('/rating_error') do
    slim(:rating_error)
end

before('/profile') do
    profiles
end

# Displays a user's profile
#
get('/profile') do
    slim(:profile, locals:{ profiles: session[:profiles]})
end

# Updates session
#
post('/logout') do
    session[:username] = nil
    session[:password] = nil
    session[:id] = nil
    redirect('/')
end

# Displays an error message
#
get('/no_access') do
    slim(:no_access)
end

# Displays an error message
#
get('/error') do
    slim(:error)
end

before('/create_comment') do
    create_comment
end

# Creates a new comment and redirects back
#
post('/create_comment') do
    if session[:create_comment_error] == 1
        session[:create_comment_error] = nil
        redirect('/create_comment_error')
    elsif session[:id] == nil
        redirect('/login')
    else
        redirect back
    end
end

# Displays an error message
#
get('/create_comment_error') do
    slim(:create_comment_error)
end

# Displays an update form for a singel comment
#
get('/edit_comment/:id') do
    session[:comment_id] = params["id"]

    slim(:edit_comment)
end

before('/redigera') do
    update_comment
end

# Updates an existing comment and redirects to '/'
#
post('/redigera') do
    if session[:update_comment_error] == 1
        session[:update_comment_error] = nil
        redirect('/update_comment_error')
    else
        redirect('/')
    end
end

# Displays an error message
#
get('/update_comment_error') do
    slim(:update_comment_error)
end

before('/delete_comment') do
    delete_comment
end

# Deletes an existing comment and redirects to '/'
#
post('/delete_comment') do
    redirect('/')
end

# Displays an update form for a singel profile
#
get('/edit_profile') do
    slim(:edit_profile)
end

before('/update_profile') do
    update_profile
end

# Updates an existing profile and redirects to '/articles'
#
post('/update_profile') do
    redirect('/profile')
end

before('/add_to_cart') do
    add_to_cart
end

# Creates a product display in '/kundvagn'
#
post('/add_to_cart') do
    if session[:add_to_cart_error] == 1
        session[:add_to_cart_error] = nil
        redirect('/add_to_cart_error')
    else
        redirect back
    end
end

# Displays an error message
#
get('/add_to_cart_error') do
    slim(:add_to_cart_error)
end

before('/kundvagn/:id') do
    get_kundvagn
end

# Displays a singel user's cart
#
get('/kundvagn/:id') do
    slim(:kundvagn, locals:{ items: session[:items]})
end

# Displays cart for non logged in users
#
get('/kundvagn') do
    slim(:kundvagn)
end

before('/buy_products') do
    buy_products
end

# Deletes products from a singel user's cart
#
post('/buy_products') do
    redirect back
end

# Displays a confirmation message when deleting a singel product from a singel user's cart
#
get('/edit_order/:id') do
    session[:itemid] = params["id"]

    slim(:edit_order)
end

before('/delete_item') do
    delete_item
end

# Deletes a singel product from a singel user's cart
#
post('/delete_item') do
    redirect('/')
end