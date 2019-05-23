module Functions
    def connect_to_db
        db = SQLite3::Database.new('db/shop.db')
        db.results_as_hash = true

        return db
    end

    def get_products
        db = connect_to_db

        products = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products")

        return products
    end

    def user_info
        db = connect_to_db
        user_info = db.execute("SELECT Id FROM users WHERE Name = (?)",params["username"])

        return user_info
    end

    def sign_in(params)
        db = connect_to_db

        params["username"]
        params["password"]

        person = db.execute("SELECT (Id) FROM users WHERE Name = (?)",params["username"])
        
        if person[0] == nil
            
        else
            params["person_id"] = person[0][0]
        end

        info = db.execute("SELECT * FROM users WHERE Id = (?)",params["person_id"])

        return info
    end

    def create_user(params)
        db = connect_to_db

        existing_username = db.execute("SELECT Name FROM users WHERE Name = (?)",params["new_username"])
        if existing_username == []
            existing_username = ""
        else
            existing_username = existing_username[0][0]
        end

        if params["new_username"] == ""
            params["error"] = 1
        elsif existing_username == params["new_username"]
            params["error"] = 2
        elsif params["new_password"] == ""
            params["error"] = 3
        elsif params["new_password"] != params["confirm_password"]
            params["error"] = 4
        else
            params["error"] = nil
            hashat_password = BCrypt::Password.create(params["new_password"])
            db.execute("INSERT INTO users (Name,Secret) VALUES (?,?)",params["new_username"],hashat_password)
            db.execute("INSERT INTO profiles (Profiledescription,Item,Interest,Username) VALUES (?,?,?,?)","hej","hej","hej",params["new_username"])
        end
    end

    def productpage(params)
        db = connect_to_db

        productpage = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products WHERE Productid = (?)",params["id"])

        return productpage
    end

    def search(params)
        db = connect_to_db

        search = params["search"].capitalize

        search_results = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products WHERE Name = (?)",search)
        
        return search_results
    end

    def thumbs_up(params)
        db = connect_to_db

        rating = db.execute("SELECT Rating FROM products WHERE Productid = (?)",params["productid"])
        
        new_rating = rating[0][0] + 1

        db.execute("UPDATE products SET Rating = (?) WHERE Productid = (?)",new_rating,params["productid"])
    end

    def thumbs_down(params)
        db = connect_to_db

        rating = db.execute("SELECT Rating FROM products WHERE Productid = (?)",params["productid"])
        
        new_rating = rating[0][0] - 1

        db.execute("UPDATE products SET Rating = (?) WHERE Productid = (?)",new_rating,params["productid"])
    end

    def profiles(params)
        db = connect_to_db

        profile = db.execute("SELECT Profiledescription,Item,Interest,Username FROM profiles WHERE Username = (?)",params["username"])
    end

    def create_comment(params)
        db = connect_to_db


        if params["comment"] == ""
            create_comment_error = 1
        elsif params["id"] == nil
        else
            db.execute("INSERT INTO comments (Comment,Commenter,Productid,Userid) VALUES (?,?,?,?)",params["comment"],params["username"],params["productid"],params["id"])
        end

        return create_comment_error
    end

    def get_comments(params)
        db = connect_to_db

        comments = db.execute("SELECT Comment,Commenter,Productid,Userid,Commentid FROM comments WHERE Productid = (?)", params["id"])

        return comments
    end

    def update_comment(params)
        db = connect_to_db

        if params["update_comment"] == ""
            update_comment_error = 1
        else
            db.execute("UPDATE comments SET Comment = (?) WHERE Commentid = (?)",params["update_comment"],params["commentid"])
        end

        return update_comment_error
    end

    def delete_comment(params)
        db = connect_to_db

        db.execute("DELETE FROM comments WHERE Commentid = ?", params["commentid"])
    end

    def update_profile(params)
        db = connect_to_db

        db.execute("UPDATE profiles SET Profiledescription = ?, Item = ?, Interest = ? WHERE Username = ?",params["profile_description"],params["item"],params["interest"],params["username"])
    end

    def add_to_cart(params)
        db = connect_to_db

        item_name = db.execute("SELECT Name FROM products WHERE Productid = (?)",params["productid"])
        item_price = db.execute("SELECT Price FROM products WHERE Productid = (?)",params["productid"])

        if params["id"] != nil
            db.execute("INSERT INTO kundvagnar (Product,Userid,Productid,Price) VALUES (?,?,?,?)",item_name[0][0],params["id"],params["productid"],item_price[0][0])
        else
            add_to_cart_error = 1
        end

        return add_to_cart_error
    end

    def get_cart(params)
        db = connect_to_db

        items = db.execute("SELECT Product,Userid,Productid,Price,Itemid FROM kundvagnar WHERE Userid = (?)",params["id"])

        return items
    end

    def buy_products(params)
        db = connect_to_db

        db.execute("DELETE FROM kundvagnar WHERE Userid = ?", params["id"])
    end

    def delete_item(params)
        db = connect_to_db

        db.execute("DELETE FROM kundvagnar WHERE Itemid = ?", params["id"])
    end
end