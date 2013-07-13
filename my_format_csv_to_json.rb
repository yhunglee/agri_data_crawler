# encoding: utf-8
# Author: howardsun
# Create date: 2013/07/12

	json_string_array = Array.new # store many json data within an array.
	File.open(ARGV[0],"r"){ |fp|
		origin_array = Array.new(2) # original csv data in a file. Only including meta data and transaction_price.
		meta_data_csv_array = Array.new # store meta data, whose commas are removed, from file.
		transaction_price_csv_array = Array.new # store transaction price data, whose commas are removed, from file.
		stored_json_string = String.new # store a json data that have proceed.
		line_indicator = 0 # indicator we are processing meta data or transaction price
		record_count = 0 # reference for json_string_array
		while line = fp.gets

			line.chomp!
			if line_indicator == 0 # read meta data

				origin_array[line_indicator] = line
				origin_array[line_indicator].split(/[,:]/u).each{ |meta_element|
					meta_data_csv_array << meta_element
				} # split meta under delimiter: comma, colon
				stored_json_string = "{ \"" + meta_data_csv_array[2] + \
					"\":\"" + meta_data_csv_array[3] + "\", \"" + \
					meta_data_csv_array[0] + "\":\"" + meta_data_csv_array[1] + \
					"\", \"" + meta_data_csv_array[4] + "\":\"" + meta_data_csv_array[5] + \
					"\", \"" + meta_data_csv_array[6] + "\":\"" + meta_data_csv_array[7] + "\", " 
				json_string_array[record_count] = stored_json_string

				meta_data_csv_array.clear
				line_indicator = 1
			elsif line_indicator == 1 # read transaction price
				origin_array[line_indicator] = line

				origin_array[line_indicator].split(/,/u).each { |transaction_element|
					if transaction_element.eql?("\"\"") || transaction_element.eql?("-")
						transaction_price_csv_array << "null"
					else
						transaction_price_csv_array << transaction_element
					end
				}
				size_transaction_price_csv_array = transaction_price_csv_array.size
				stored_json_string = json_string_array[record_count]
				stored_json_string.concat( "\"交易市場價格資料\":[" )
				transaction_count = 10 # start from 10
				quotient = size_transaction_price_csv_array / 10
				i = 0
				j = 2
				if quotient >= 2
					for j in 2..quotient do # because contains column names, we ignore first 10.
						stored_json_string.concat( "{" )
						for i in 0..8 do
							if transaction_price_csv_array[transaction_count].eql? "null"
								stored_json_string << "\"" + transaction_price_csv_array[i] + "\":" + transaction_price_csv_array[transaction_count] +", "
							elsif transaction_price_csv_array[transaction_count] =~ /[+-]?[0-9]+[.]?[0-9]*$/u
								stored_json_string << "\"" + transaction_price_csv_array[i] + "\":" + transaction_price_csv_array[transaction_count] + ", "
							else
								stored_json_string << "\"" + transaction_price_csv_array[i] + "\":\"" + transaction_price_csv_array[transaction_count] + "\", "
							end
							transaction_count += 1
						end

						# print for column of 增減% 
						i = 9
						if transaction_price_csv_array[transaction_count].eql? "null"
							stored_json_string << "\"" + transaction_price_csv_array[i] + "\":" + transaction_price_csv_array[transaction_count] +"}"
						else transaction_price_csv_array[transaction_count] =~ /[+-]?[0-9]+[.]?[0-9]*$/u
							stored_json_string << "\"" + transaction_price_csv_array[i] + "\":" + transaction_price_csv_array[transaction_count] + "}"
						end
						transaction_count += 1
						# print for column of 增減% 

						if j != quotient # if it still has unprocessed transaction markets, append comma symbol.
							stored_json_string << ", "
						end
					end # append json string with quotient-times
				end

				stored_json_string << " ]"


				json_string_array[record_count] = stored_json_string
				# puts json_string_array[record_count] #debug
				record_count += 1
				transaction_price_csv_array.clear
				
				puts "正在轉換第 " + record_count.to_s + " 筆"
				line_indicator = 0
				#  break #debug
			end
		end
	}

	puts "===================================="
	puts "寫入轉換結果中，請勿中斷程式......"
	File.open("./query_results/"+ARGV[1], "a"){ |fp2|
		json_string_array.each{| element |
			fp2.puts(element)
		}
	}

	puts "寫入完畢."
	puts "===================================="

