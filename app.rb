require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative 'functions.rb'
include Functions

# Display Landing Page
#
get('/') do
    params["username"] = session[:username]
    products = get_products
    user_information = user_info

    slim(:index, locals:{ products: products, user_info: user_information})
end

# Display a Login form
#
get('/login') do
    slim(:login)
end

# Display a Register form
#
get('/register') do
    slim(:register)
end

# Attempts login and updates the session
#
# @param [String] username, The username that was inputed
# @param [String] password, The password that was inputed
# @see Functions#sign_in
post('/sign_in') do
    info = sign_in(params)
    session[:username] = params["username"]
    session[:password] = params["password"]

    if info == []
        session[:username] = nil
        session[:password] = nil
        session[:id] = nil
        redirect('/no_access')
    else
        if session[:username] == info[0][0] and BCrypt::Password.new(info[0][1]) == session[:password]
            session[:id] = info[0][2]
            redirect('/')
        else
            session[:username] = nil
            session[:password] = nil
            session[:id] = nil
            redirect('/no_access')
        end
    end
end

# Attempts register and creates a user
#
# @param [String] new_username, The username that was inputed
# @param [String] new_password, The password that was inputed
# @param [String] confirm_password, The confirmation password that was inputed
# @see Functions#create_user
post('/create_user') do
    create_user(params)    
    if params["error"] != nil
        if params["error"] == 1
            session[:error] = "No username was inputed please try again"
        elsif params["error"] == 2
            session[:error] = "This username already exist please try again"
        elsif params["error"] == 3
            session[:error] = "No password was inputed please try again"
        elsif params["error"] == 4
            session[:error] = "Passwords does not match please try again"
        end
        redirect('/error')
    else
        redirect('/')
    end
end

# Displays a single Product
#
# @param [Integer] :id, The Id of the product
# @see Functions#productpage
# @see Functions#get_comments
get('/productpage/:id') do
    session[:productid] = params["id"]
    product_page = productpage(params)
    comments = get_comments(params)


    slim(:productpage, locals:{ productpage: product_page, comments: comments})
end

# Attempts finding products and redirects to '/search_result'
#
# @param [String] search, The search parameter that was inputed
# @see Functions#search
post('/search') do
    session[:search_results] = search(params)
    redirect('/search_result')
end

# Displays search results
#
get('/search_result') do
    slim(:search_result, locals:{ results: session[:search_results]})
end

# Updates an existing rating and redirects back
#
# @param [Integer] productid, The Id of the product
# @see Functions#thumbs_up
post('/thumbs_up') do
    if session[:id] != nil
        params["productid"] = session[:productid]
        thumbs_up(params)
    end
    if session[:id] != nil
        redirect back
    else
        redirect('/rating_error')
    end
end

# Updates an existing rating and redirects back
#
# @param [Integer] productid, The Id of the product
# @see Functions#thumbs_down
post('/thumbs_down') do
    if session[:id] != nil
        params["productid"] = session[:productid]
        thumbs_down(params)
    end
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

# Displays a user's profile
#
# @param [String] username, The username of the current user
# @see Functions#profiles
get('/profile') do
    params["username"] = session[:username]
    profile = profiles(params)
    slim(:profile, locals:{ profiles: profile})
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

# Creates a new comment and redirects back
#
# @param [String] comment, The comment that was inputed
# @param [String] username, The username of the current user
# @param [Integer] productid, The Id of the product
# @param [Integer] id, The Id of the user
# @see Functions#create_comment
post('/create_comment') do
    p session[:productid]
    params["username"] = session[:username]
    params["productid"] = session[:productid]
    params["id"] = session[:id]
    create_comment_error = create_comment(params)
    if create_comment_error == 1
        create_comment_error = nil
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

# Updates an existing comment and redirects to '/'
#
# @param [String] update_comment, The new comment that was inputed
# @param [Integer] commentid, The Id of the comment
# @see Functions#update_comment
post('/edit_comment') do
    params["commentid"] = session[:comment_id]
    update_comment_error = update_comment(params)
    if update_comment_error == 1
        update_comment_error = nil
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

# Deletes an existing comment and redirects to '/'
#
# @param [Integer] commentid, The Id of the comment
# @see Functions#delete_comment
post('/delete_comment') do
    params["commentid"] = session[:comment_id]
    delete_comment(params)
    redirect('/')
end

# Displays an update form for a singel profile
#
get('/edit_profile') do
    slim(:edit_profile)
end

# Updates an existing profile and redirects to '/articles'
#
# @param [String] username, The username of the current user
# @param [String] profile_description, The new description that was inputed
# @param [String] item, The bew favorite item that was inputed
# @param [String] interest, The new interest that was inputed
# @see Functions#update_profile
post('/update_profile') do
    params["username"] = session[:username]
    update_profile(params)
    redirect('/profile')
end

# Creates a product display in '/kundvagn'
#
# @param [Integer] productid, The Id of the product
# @param [Integer] id, The Id of the user
# @see Functions#add_to_cart
post('/add_to_cart') do
    params["productid"] = session[:productid]
    params["id"] = session[:id]
    add_to_cart_error = add_to_cart(params)
    if add_to_cart_error == 1
        add_to_cart_error = nil
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

# Displays a singel user's cart
#
# @param [Integer] id, The Id of the user
# @see Functions#get_cart
get('/cart/:id') do
    params["id"] = session[:id]
    items = get_cart(params)
    slim(:cart, locals:{ items: items})
end

# Displays cart for non logged in users
#
get('/cart') do
    slim(:cart)
end

# Deletes products from a singel user's cart
#
# @param [Integer] id, The Id of the user
# @see Functions#buy_products
post('/buy_products') do
    params["id"] = session[:id]
    buy_products(params)
    redirect back
end

# Displays a confirmation message when deleting a singel product from a singel user's cart
#
get('/edit_order/:id') do
    session[:itemid] = params["id"]

    slim(:edit_order)
end

# Deletes a singel product from a singel user's cart
#
# @param [Integer] id, The Id of the user
# @see Functions#delete_item
post('/delete_item') do
    params["id"] = session[:itemid]
    delete_item(params)
    redirect('/')
end