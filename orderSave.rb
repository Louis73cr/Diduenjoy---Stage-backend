require 'dotenv/load'
require 'pg'

Dotenv.load

def connect_db
    PG.connect(
        dbname: ENV['DB_NAME'],
        user: ENV['DB_USER'],
        password: ENV['DB_PASSWORD'],
        host: ENV['DB_HOST'],
        port: ENV['DB_PORT']
    )
end

class SaveOrder
    def initialize(debug_mode = false)
        @db = connect_db
        @debugMode = debug_mode
    end

    def insert_order(order_id, order_name)
        existing_order = @db.exec_params("SELECT * FROM orders WHERE orderid = $1;", [order_id]).first
    
        if existing_order
            if @debugMode
                puts "[ERROR] OrderID already exists. Generating new OrderID"
            end
            order_id = find_new_order_id
        end
    
        result = @db.exec_params(
            "INSERT INTO orders (orderid, odername) VALUES ($1, $2) RETURNING orderid;",
            [order_id, order_name]
        )
        
        return result[0]['orderid'].to_i
    end
    
    def find_new_order_id
        existing_order_ids = @db.exec("SELECT orderid FROM orders;").map { |row| row['orderid'].to_i }
        order_id = 1

        while existing_order_ids.include?(order_id)
        order_id += 1
        end

        if @debugMode
            puts "[INFO] New OrderID generated: #{order_id}"
        end
        return order_id
    end

    def insert_package(order_id, package_id)
        existing_package = @db.exec_params("SELECT * FROM packages WHERE packageid = $1;", [package_id]).first
    
        if existing_package
            if @debugMode
                puts "[ERROR] PackageID already exists. Generating new PackageID"
            end
            package_id = find_new_package_id
        end
    
        result = @db.exec_params(
            "INSERT INTO packages (packageid, orderid) VALUES ($1, $2) RETURNING packageid;",
            [package_id, order_id]
        )
    
        return result[0]['packageid'].to_i
    end

    def find_new_package_id
        existing_package_ids = @db.exec("SELECT packageid FROM packages;").map { |row| row['packageid'].to_i }
        package_id = 1

        while existing_package_ids.include?(package_id)
        package_id += 1
        end

        if @debugMode
            puts "[INFO] New PackageID generated: #{package_id}"
        end
        return package_id
    end

    def insert_item(package_id, item_id, item)
        name = item['name'] || 'Inconnu'
        price = item['price']&.to_i || 0
        ref = item['ref'] || 'N/A'
        warranty = item['warranty'] == 'true'
        duration = item['duration']&.to_i || 0
    
        existing_item = @db.exec_params("SELECT * FROM items WHERE itemid = $1;", [item_id]).first
    
        if existing_item
        if @debugMode
            puts "[ERROR] ItemID already exists. Generating new ItemID"
        end
        item_id = find_new_item_id
        end
    
        @db.exec_params(
            "INSERT INTO items (itemid, name, price, ref, packageid, warranty, duration) VALUES ($1, $2, $3, $4, $5, $6, $7);",
            [item_id, name, price, ref, package_id, warranty, duration]
        )
    
        return item_id
    end
    
    def find_new_item_id
        existing_item_ids = @db.exec("SELECT itemid FROM items;").map { |row| row['itemid'].to_i }
        item_id = 1

        while existing_item_ids.include?(item_id)
        item_id += 1
        end

        if @debugMode
            puts "[INFO] New ItemID generated: #{item_id}"
        end
        return item_id
    end

    def close
        @db.close if @db
    end
end

def save_orders(all_order_data, debug_mode = false)
    save_order = SaveOrder.new(debug_mode)

    begin
        all_order_data.each do |order_id, data|
        order_name = data[:sheet_name]
        order_id = save_order.insert_order(order_id, order_name)

        data[:package].each do |package_id, package|
            package_db_id = save_order.insert_package(order_id, package_id)

            package[:items].each do |item_id, item|
            save_order.insert_item(package_db_id, item_id, item)
            end
        end
        end
    rescue PG::Error => e
        if (debug_mode)
            puts "[ERROR] Database error: #{e.message}"
        end
    ensure
        save_order.close
    end
end
