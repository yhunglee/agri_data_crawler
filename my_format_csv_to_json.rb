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
		if ARGV[2].nil? || ARGV[2].eql?("vegetable")
			type_item = 0 # 0 means vegetable
		elsif ARGV[2].eql?("flowers")
			type_item = 2 # 2 means flowers
		elsif ARGV[2].eql?("fruit")
			type_item = 1 # 1 means fruit
		end

		 # 2014/02/18 written: 修改JSON格式。not complete and not begin
		json_string_array << "[ " # "[" means JSON file's start point.
		record_count += 1
		while line = fp.gets

			line.chomp!
			if line_indicator == 0 # read meta data

				origin_array[line_indicator] = line
				origin_array[line_indicator].split(/[,:]/u).each{ |meta_element|
					meta_data_csv_array << meta_element
				} # split meta under delimiter: comma, colon
				case type_item
					when 0 # vegetable
						stored_json_string = "{ \"" + meta_data_csv_array[2] + \
							"\":\"" + meta_data_csv_array[3] + "\", \"" + \
							meta_data_csv_array[0] + "\":\"" + meta_data_csv_array[1] + \
							"\", \"" + meta_data_csv_array[4] + "\":\"" + meta_data_csv_array[5] + \
							"\", \"" + meta_data_csv_array[6] + "\":\"" + meta_data_csv_array[7] + "\", " 
					when 2 # flowers
						stored_json_string = "{ \"" + meta_data_csv_array[8] + \
						"\":\"" + meta_data_csv_array[9] + "\", \"" + \
						meta_data_csv_array[0] + "\":\"" + meta_data_csv_array[1] + \
						"\", \"" + meta_data_csv_array[4] + "\":\"" + meta_data_csv_array[5] + \
						"\", \"" + meta_data_csv_array[2] + "\":\"" + meta_data_csv_array[3] + \
						"\", \"" + meta_data_csv_array[6] + "\":\"" + meta_data_csv_array[7] + "\", "

					when 1 # fruit
						stored_json_string = "{ \"" + meta_data_csv_array[2] + \
							"\":\"" + meta_data_csv_array[3] + "\", \"" + \
							"品種\":\"" + ((meta_data_csv_array[4].eql?("\"\""))?(""):(meta_data_csv_array[4])) + "\", \"" + \
							"處理別\":\"" + ((meta_data_csv_array[5].eql?("\"\""))?(""):(meta_data_csv_array[5])) + "\", \"" + \
							meta_data_csv_array[0] + "\":\"" + meta_data_csv_array[1] + \
							"\", \"" + meta_data_csv_array[6] + "\":\"" + meta_data_csv_array[7] + \
							"\", \"" + meta_data_csv_array[8] + "\":\"" + meta_data_csv_array[9] + "\", " 
				else
					puts "encounter error when dealing meta_data_csv_array."
				end
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
				case type_item
					when 0 # 0 means vegetable
						transaction_count = 10 # index count of price data array start from 10
						divisor = 10
					when 2 # 2 means flowers
						transaction_count = 11 # index count of price data array start from 11
						divisor = 11
					when 1 # 1 means fruit
						transaction_count = 9 # index count of price data array start from 9
						divisor = 9
					else
						exit
				end
				quotient = size_transaction_price_csv_array / divisor
				i = 0
				j = 2
				if quotient >= 2
					for j in 2..quotient do # because contains column names, we ignore first 10.
						stored_json_string.concat( "{" )
						for i in 0..(divisor-2) do 
						# for loop will run (divisor-1) times from index 0 to divisor-2 .
							if transaction_price_csv_array[transaction_count].eql? "null"
								stored_json_string << "\"" + transaction_price_csv_array[i] + "\":" + transaction_price_csv_array[transaction_count] +", "
							elsif nil != (transaction_price_csv_array[transaction_count] =~ /[\+\-]?[0-9]+[.]?[0-9]*$/u)
								# 2013/10/13 written: unreachable, so strange!
								# 2014/02/25 written: have modified R.E. for correct numbers, need to confirm later.
								stored_json_string << "\"" + transaction_price_csv_array[i] + "\":" + transaction_price_csv_array[transaction_count] + ", "
							else
								stored_json_string << "\"" + transaction_price_csv_array[i] + "\":\"" + transaction_price_csv_array[transaction_count] + "\", "
							end
							transaction_count += 1
						end # for-end

						# print for column of 增減% 
						i = divisor-1
						if transaction_price_csv_array[transaction_count].eql? "null"
							stored_json_string << "\"" + transaction_price_csv_array[i] + "\":" + transaction_price_csv_array[transaction_count] +"}"
						elsif nil != (transaction_price_csv_array[transaction_count] =~ /[\+\-]?[0-9]+[.]?[0-9]*$/u) 
							# 2013/10/13 written: unreachable, so strange!
							# 2014/02/25 written: have modified R.E. for correct numbers, need to confirm later.
							stored_json_string << "\"" + transaction_price_csv_array[i] + "\":" + transaction_price_csv_array[transaction_count] + "}"
						else
							stored_json_string << "\"" + transaction_price_csv_array[i] + "\": \"***\"}" 
						end
						transaction_count += 1
						# print for column of 增減% 

						if j != quotient # if it still has unprocessed transaction markets, append comma symbol.
							stored_json_string << ", "
						end
					end # for-end # append json string with quotient-times
				end # if-end

				stored_json_string << " ] }"

				if !(fp.eof?) 
					#如果還沒處理完全部檔案內容，則表示要在這筆JSON資料結尾補上逗號
					# 2014/02/25 written: 寫完還沒確認執行結果
					stored_json_string << ", \n"
				end

				json_string_array[record_count] = stored_json_string
				# puts json_string_array[record_count] #debug
				record_count += 1
				transaction_price_csv_array.clear
			
				puts "正在轉換第 " + record_count.to_s + " 筆"
				line_indicator = 0
				#  break #debug

			end # for if-end
		end #for while-end
		# 2014/03/02 written: 檔案結尾已補上陣列的右括弧符號
		json_string_array << "] "
		record_count += 1
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

