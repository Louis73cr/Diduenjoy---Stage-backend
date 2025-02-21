class OrderParser
    attr_accessor :packageID_index, :itemID_index, :label_index, :value_index

    def initialize
        @packageID_index = nil
        @itemID_index = nil
        @label_index = nil
        @value_index = nil
        @order_data = {}
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
        puts "Invalid file format. Please ensure the file contains 4 columns: [packages, items, labels, values]"
        exit
        end
    end

    def validateCell(cell)
        if cell.nil?
            return ""
        else
            return cell.value.to_s
        end
    end

    def read_worksheet(worksheet)
        row_index = 1

        worksheet.each_with_index do |row, row_index|
            next if row.cells.compact.empty?

            package_id = validateCell(row.cells[@packageID_index])
            item_id = validateCell(row.cells[@itemID_index])
            label = validateCell(row.cells[@label_index])
            value = validateCell(row.cells[@value_index])

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
