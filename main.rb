require 'rubyXL'
require_relative 'orderParser'
require_relative 'orderDisplay'

file_path = './Orders.xlsx'

workbook = RubyXL::Parser.parse(file_path)

all_order_data = {}

workbook.worksheets.each_with_index do |worksheet, index|
    parser = OrderParser.new
    parser.validate_file_format(worksheet)
    parser.read_worksheet(worksheet)
    all_order_data[index] = parser.get_order_data
end

display_order(all_order_data)

