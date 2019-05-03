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

def create_comment
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:comment] = params["comment"]

    if session[:comment] == ""
        session[:create_comment_error] = 1
    elsif session[:id] == nil
        redirect('/login')
    else
        db.execute("INSERT INTO comments (Comment,Commenter,Productid,Userid) VALUES (?,?,?,?)",session[:comment],session[:username],session[:produktid],session[:id])
    end
end

def get_comments
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:comments] = db.execute("SELECT Comment,Commenter,Productid,Userid,Commentid FROM comments WHERE Productid = (?)", session[:produktid])
end

def update_comment
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true

    session[:update_comment] = params["update_comment"]

    if session[:update_comment] == ""
        session[:update_comment_error] = 1
    else
        db.execute("UPDATE comments SET Comment = (?) WHERE Commentid = (?)",session[:update_comment],session[:comment_id])
    end
end

def delete_comment
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true

    db.execute("DELETE FROM comments WHERE Commentid = ?", session[:comment_id])
end

def update_profile
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true

    session[:profile_description] = params["profile_description"]
    session[:item] = params["item"]
    session[:interest] = params["interest"]

    db.execute("UPDATE profiles SET Profiledescription = ?, Item = ?, Interest = ? WHERE Username = ?",session[:profile_description],session[:item],session[:interest],session[:username])
end

def add_to_cart
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    item_name = db.execute("SELECT Name FROM products WHERE Productid = (?)",session[:produktid])
    item_price = db.execute("SELECT Price FROM products WHERE Productid = (?)",session[:produktid])

    if session[:id] != nil
        db.execute("INSERT INTO kundvagnar (Product,Userid,Productid,Price) VALUES (?,?,?,?)",item_name[0][0],session[:id],session[:produktid],item_price[0][0])
    else
        session[:add_to_cart_error] = 1
    end
end

def get_kundvagn
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:items] = db.execute("SELECT Product,Userid,Productid,Price,Itemid FROM kundvagnar WHERE Userid = (?)",session[:id])
end

def buy_products
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true

    db.execute("DELETE FROM kundvagnar WHERE Userid = ?", session[:id])
end

def delete_item
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true

    db.execute("DELETE FROM kundvagnar WHERE Itemid = ?", session[:itemid])
end