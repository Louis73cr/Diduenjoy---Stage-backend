def display_orders(all_order_data, debug_mode = false)
    if debug_mode
        puts "[INFO] Displaying orders"
    end
  
    puts "========== ORDER =========="
    all_order_data.each do |index, data|
        puts "Order : n°#{index} | #{data[:sheet_name]}"
        data[:package].each do |package_id, package|
            puts "  Package ID: #{package_id}"
            package[:items].each do |item_id, item|
                puts "    Item ID: #{item_id}"
                item.each do |label, value|
                    puts "      #{label}: #{value}"
                end
            end
        end
    end
    puts "==========================="
end
  