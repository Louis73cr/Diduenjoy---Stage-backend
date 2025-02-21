require 'rubyXL'
require_relative 'orderParser'
require_relative 'orderDisplay'
require_relative 'orderSave'

debugMode = false
file_path = nil

if ARGV.empty?
    puts "[ERROR] Retry with -h option for help"
    exit
end

ARGV.each_with_index do |arg, index|
    case arg
    when "-h", "--help"
        puts "Usage: ruby main.rb [OPTIONS]"
        puts "Options:"
        puts "  -f, --file FILE_PATH    Specify the path to the xlsx file to load"
        puts "  -d, --debug             Enable debug mode"
        exit
    when "-f", "--file"
        if ARGV[index + 1] && !ARGV[index + 1].start_with?("-")
        file_path = ARGV[index + 1]
        else
        puts "[ERROR] Missing file path after -f or --file"
        exit
        end
    when "-d", "--debug"
        debugMode = true
        puts "[INFO] Debug mode enabled"
    end
end

if file_path.nil?
    puts "[ERROR] File path is required. Use -f or --file to specify the file path."
    exit
end

begin
    workbook = RubyXL::Parser.parse(file_path)
rescue => e
    if debugMode
        puts "[ERROR] Failed to load xlsx file: #{e.message}"
    else
        puts "[ERROR] Failed to load xlsx file. Use -d option for more details."
    end
    exit
end

all_order_data = {}

workbook.worksheets.each_with_index do |worksheet, index|
    parser = OrderParser.new(debugMode)
    parser.validate_file_format(worksheet)
    parser.read_worksheet(worksheet)
    all_order_data[index] = {} unless all_order_data[index]
    all_order_data[index][:sheet_name] = worksheet.sheet_name
    all_order_data[index][:package] = parser.get_order_data
end

display_orders(all_order_data, debugMode)
save_orders(all_order_data)
