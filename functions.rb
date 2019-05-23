#Here is all the functions
module Functions
    # Connects functions to database
    #
    # @return [Array] containing the data of all matching articles
    def connect_to_db
        db = SQLite3::Database.new('db/shop.db')
        db.results_as_hash = true

        return db
    end
    
    # Finds products
    #
    # @return [Array] containing the data of all products
    def get_products
        db = connect_to_db

        products = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products")

        return products
    end

    # Gets users id
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    #
    # @return [Array] containing the id of the user
    def user_info
        db = connect_to_db
        user_info = db.execute("SELECT Id FROM users WHERE Name = (?)",params["username"])

        return user_info
    end

    # Gets information about user before performing log in
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    #
    # @return [Array] containing all the data of matching user
    def sign_in(params)
        db = connect_to_db

        person = db.execute("SELECT (Id) FROM users WHERE Name = (?)",params["username"])
        
        if person[0] == nil
            
        else
            params["person_id"] = person[0][0]
        end

        info = db.execute("SELECT * FROM users WHERE Id = (?)",params["person_id"])

        return info
    end

    # Attempts to create a new user
    #
    # @param [Hash] params form data
    # @option params [String] new_username The new username
    # @option params [String] new_password The new password
    # @option params [String] confirm_password Confirm new password
    #
    # @return [Integer] containing the number of a specific error
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

        return params["error"]
    end

    # Gets product information of a specific product
    #
    # @param [Hash] params form data
    # @option params [Integer] id The id of a product
    #
    # @return [Array] containing all the data of the matching product
    def productpage(params)
        db = connect_to_db

        productpage = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products WHERE Productid = (?)",params["id"])

        return productpage
    end

    # Searches title and content for any matching text
    #
    # @param [Hash] params form data
    # @option params [String] search The search term
    #
    # @return [Array] containing the data of all matching articles
    def search(params)
        db = connect_to_db

        search = params["search"].capitalize

        search_results = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products WHERE Name = (?)",search)
        
        return search_results
    end

    # Updates the rating of a specific product
    #
    # @param [Hash] params form data
    # @option params [Integer] productid The id of a product
    #
    def thumbs_up(params)
        db = connect_to_db

        rating = db.execute("SELECT Rating FROM products WHERE Productid = (?)",params["productid"])
        
        new_rating = rating[0][0] + 1

        db.execute("UPDATE products SET Rating = (?) WHERE Productid = (?)",new_rating,params["productid"])
    end

    # Updates the rating of a specific product
    #
    # @param [Hash] params form data
    # @option params [Integer] productid The id of a product
    #
    def thumbs_down(params)
        db = connect_to_db

        rating = db.execute("SELECT Rating FROM products WHERE Productid = (?)",params["productid"])
        
        new_rating = rating[0][0] - 1

        db.execute("UPDATE products SET Rating = (?) WHERE Productid = (?)",new_rating,params["productid"])
    end

    # Gets profile information from a specific user
    #
    # @param [Hash] params form data
    # @option params [Integer] productid The id of a product
    #
    # @return [Array] containing all the data of the matching user
    def profiles(params)
        db = connect_to_db

        profile = db.execute("SELECT Profiledescription,Item,Interest,Username FROM profiles WHERE Username = (?)",params["username"])

        return profile
    end

    # Attempts to create a comment on a specific product
    #
    # @param [Hash] params form data
    # @option params [String] comment The comment
    # @option params [String] username The username
    # @option params [Integer] productid The id of a product
    # @option params [Integer] id The id of a user
    #
    # @return [Integer] containing the number of a specific error
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

    # Gets all comments on a specific product
    #
    # @param [Hash] params form data
    # @option params [Integer] id The id of a product
    #
    # @return [Array] containing the data of all matching comments
    def get_comments(params)
        db = connect_to_db

        comments = db.execute("SELECT Comment,Commenter,Productid,Userid,Commentid FROM comments WHERE Productid = (?)", params["id"])

        return comments
    end

    # Attempts to update a specific comment
    #
    # @param [Hash] params form data
    # @option params [String] update_comment The new comment
    # @option params [Integer] commentid The id of a comment
    #
    # @return [Integer] containing the number of a specific error
    def update_comment(params)
        db = connect_to_db

        if params["update_comment"] == ""
            update_comment_error = 1
        else
            db.execute("UPDATE comments SET Comment = (?) WHERE Commentid = (?)",params["update_comment"],params["commentid"])
        end

        return update_comment_error
    end

    # Deletes a specific comment
    #
    # @param [Hash] params form data
    # @option params [Integer] commentid The id of a comment
    #
    def delete_comment(params)
        db = connect_to_db

        db.execute("DELETE FROM comments WHERE Commentid = ?", params["commentid"])
    end

    # Updates a specific user's profile
    #
    # @param [Hash] params form data
    # @option params [String] profile_description The description on a profile
    # @option params [String] item The favorite item of a user
    # @option params [String] interest The interest of a user
    # @option params [String] username The username
    #
    def update_profile(params)
        db = connect_to_db

        db.execute("UPDATE profiles SET Profiledescription = ?, Item = ?, Interest = ? WHERE Username = ?",params["profile_description"],params["item"],params["interest"],params["username"])
    end

    # Attempts to add a product to a specific user's cart
    #
    # @param [Hash] params form data
    # @option params [Integer] productid The id of a product
    # @option params [Integer] id The id of a user
    #
    # @return [Integer] containing the number of a specific error
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

    # Gets a specific user's cart
    #
    # @param [Hash] params form data
    # @option params [Integer] id The id of a user
    #
    # @return [Array] containing the data of the matching user's cart
    def get_cart(params)
        db = connect_to_db

        items = db.execute("SELECT Product,Userid,Productid,Price,Itemid FROM kundvagnar WHERE Userid = (?)",params["id"])

        return items
    end

    # Clears all products from a user's cart
    #
    # @param [Hash] params form data
    # @option params [Integer] id The id of a user
    #
    def buy_products(params)
        db = connect_to_db

        db.execute("DELETE FROM kundvagnar WHERE Userid = ?", params["id"])
    end

    # Deletes a specific item from a user's cart
    #
    # @param [Hash] params form data
    # @option params [Integer] id The id of a user
    #
    def delete_item(params)
        db = connect_to_db

        db.execute("DELETE FROM kundvagnar WHERE Itemid = ?", params["id"])
    end
end