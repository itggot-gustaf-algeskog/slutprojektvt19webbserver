def get_products
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:products] = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products")
end

def user_info
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:user_info] = db.execute("SELECT Id FROM users WHERE Name = (?)",session[:username])
end

def inloggning
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:username] = params["username"]
    session[:password] = params["password"]

    person = db.execute("SELECT (Id) FROM users WHERE Name = (?)",session[:username])
    
    if person[0] == nil
        redirect('/no_access')
    else
        session[:id] = person[0][0]
    end

    session[:info] = db.execute("SELECT * FROM users WHERE Id = (?)",session[:id])
end

def registrering
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:new_username] = params["new_username"]
    session[:new_password] = params["new_password"]
    session[:confirm_password] = params["confirm_password"]

    existing_username = db.execute("SELECT Name FROM users WHERE Name = (?)",session[:new_username])
    if existing_username == []
        existing_username = ""
    else
        existing_username = existing_username[0][0]
    end

    if session[:new_username] == ""
        session[:error] = 1
    elsif existing_username == session[:new_username]
        session[:error] = 2
    elsif session[:new_password] == ""
        session[:error] = 3
    elsif session[:new_password] != session[:confirm_password]
        session[:error] = 4
    else
        session[:error] = nil
        hashat_password = BCrypt::Password.create(session[:new_password])
        db.execute("INSERT INTO users (Name,Secret) VALUES (?,?)",session[:new_username],hashat_password)
        db.execute("INSERT INTO profiles (Profiledescription,Item,Interest,Username) VALUES (?,?,?,?)","hej","hej","hej",session[:new_username])
    end
end

def produktsida
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:produktsida] = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products WHERE Productid = (?)",session[:produktid])
end

def search
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:search] = params["search"].capitalize

    session[:results] = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products WHERE Name = (?)",session[:search])
end

def thumbs_up
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    rating = db.execute("SELECT Rating FROM products WHERE Productid = (?)",session[:produktid])
    
    new_rating = rating[0][0] + 1

    db.execute("UPDATE products SET Rating = (?) WHERE Productid = (?)",new_rating,session[:produktid])
end

def thumbs_down
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    rating = db.execute("SELECT Rating FROM products WHERE Productid = (?)",session[:produktid])
    
    new_rating = rating[0][0] - 1

    db.execute("UPDATE products SET Rating = (?) WHERE Productid = (?)",new_rating,session[:produktid])
end

def profiles
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:profiles] = db.execute("SELECT Profiledescription,Item,Interest,Username FROM profiles WHERE Username = (?)",session[:username])
end