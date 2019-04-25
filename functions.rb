def get_products
    db = SQLite3::Database.new('db/shop.db')
    db.results_as_hash = true

    session[:products] = db.execute("SELECT Name,Description,Rating,Price,Productid FROM products")
end