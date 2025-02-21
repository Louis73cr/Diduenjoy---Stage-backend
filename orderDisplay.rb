def display_order(all_order_data)
    all_order_data.each do |sheet_name, orders|
        puts "Order: #{sheet_name}"
        orders.each do |package_id, package|
            puts "  Package ID: #{package_id}"
            package[:items].each do |item_id, item|
                puts "    Item ID: #{item_id}"
                item.each do |label, value|
                    puts "      #{label}: #{value}"
                end
            end
        end
    end
end