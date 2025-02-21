class OrderParser
    attr_accessor :packageID_index, :itemID_index, :label_index, :value_index, :debugMode

    def initialize(debug_mode = false)
        @packageID_index = nil
        @itemID_index = nil
        @label_index = nil
        @value_index = nil
        @order_data = {}
        @debugMode = debug_mode
    end

    def validate_file_format(worksheet)
        worksheet[0].cells.each_with_index do |cell, i|
        case cell&.value
        when "packages"
            @packageID_index = i
        when "items"
            @itemID_index = i
        when "lables"
            @label_index = i
        when "values"
            @value_index = i
        end
        end

        if [@packageID_index, @itemID_index, @label_index, @value_index].any?(&:nil?)
            if (debugMode)
                puts "[ERROR] Invalid file format. Please ensure the file contains 4 columns: [packages, items, labels, values]"
            end
            exit
        end
    end

    def validate_cell(cell)
        if cell.nil?
            return ""
        else
            return cell.value.to_s
        end
    end

    def read_worksheet(worksheet)

        worksheet.each_with_index do |row, row_index|
            next if row_index == 0
            next if row.cells.compact.empty?

            package_id = validate_cell(row.cells[@packageID_index])
            item_id = validate_cell(row.cells[@itemID_index])
            label = validate_cell(row.cells[@label_index])
            value = validate_cell(row.cells[@value_index])
            if (package_id == "" || item_id == "" || label == "" || value == "")
                if (debugMode)
                    puts "[ERROR] Invalid row format. Please ensure each row contains 4 columns: [packages, items, labels, values]"
                end
                next
            end

            if !@order_data.key?(package_id)
                @order_data[package_id] = { items: {} }
            end
        
            if !@order_data[package_id][:items].key?(item_id)
                @order_data[package_id][:items][item_id] = {}
            end
        
            @order_data[package_id][:items][item_id][label] = value
        end
    end

    def get_order_data
        @order_data
    end
end
