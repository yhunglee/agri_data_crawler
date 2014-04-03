# encoding: utf-8
# Author: howardsun
# Create date: 2013/07/12
def only_summary_csv_to_json_transform( q_type, csv_file_name)
# same as function: only_marketBased_data_csv_to_json_transform.
# 2014/03/30 written: need to test.

	summary_json_string_array = Array.new
	summary_stored_json_string = String.new

	splited_string_array = Array.new

	summary_json_string_array << "["

	File.open("./query_results/summary_"+csv_file_name, "r"){ |fp|
		while line = fp.gets

			line = line.chomp #去除最右邊的換行符號
			splited_string_array = line.split(/,/u) #取得分開後的summary每欄資料
			case q_type
				when 0 # means vegetable
					#Summary格式:{代號&產品名稱}, 交易日期, 總交易量, 總平均價 
					summary_stored_json_string = "{\"產品名稱\":\""+ splited_string_array[0] + "\", \"交易日期\":\"" + splited_string_array[1] + "\", \"總交易量\":\"" + \
					splited_string_array[2]  + "\", \"總平均價\":\"" + splited_string_array[3] + "\"}" 
				when 1 # means fruit
					#Summary格式：{代號&產品名稱}, 品種名稱, 處理別, 交易日期, 總交易量, 總平均價
					summary_stored_json_string = "{\"產品名稱\":\""+ splited_string_array[0] + "\", \"品種名稱\":\"" + splited_string_array[1] + "\", \"處理別\":\"" + \
					splited_string_array[2]  + "\", \"交易日期\":\"" + splited_string_array[3] + "\", \"總交易量\":\"" + splited_string_array[4] + "\",\"總平均價\":\"" + \
					splited_string_array[5] + "\"}" 
				when 2 # means flowers
					#Summary格式：{代號&產品名稱}, 交易日期, 總交易量, 總平均價, 總殘貨量
					summary_stored_json_string = "{\"產品名稱\":\""+ splited_string_array[0] + "\", \"交易日期\":\"" + splited_string_array[1] + "\", \"總交易量\":\"" + \
					splited_string_array[2]  + "\", \"總平均價\":\"" + splited_string_array[3] + "\", \"總殘貨量\":\"" + splited_string_array[4] + "\"}"
				else
					puts "未知的農產品種類, 已停止轉換格式。"
					exit
			end

			if !(fp.eof?)
				#如果還沒處理完全部檔案內容，則表示要在這筆JSON資料結尾補上逗號
				summary_stored_json_string << ", \n"
			end
			splited_string_array.clear # 清除本回合取得的summary csv資料

			summary_json_string_array << summary_stored_json_string 
		end # read string from csv file, and then store them into after reorganizing into json format.

		summary_json_string_array << "]" # represent end of json format summary.
	}

	# write json content to file
	puts "===================================="
	puts "寫入summary轉換結果中，請勿中斷程式......"
	File.open("./query_results/summary_"+ARGV[1], "a"){ |json_output_file|
		summary_json_string_array.each{ |element|
			json_output_file.puts(element)
		}
	}
	puts "summary json寫入完畢."
	puts "===================================="
	# write json content to file
	
end

def only_marketBased_data_csv_to_json_transform( q_type, csv_file_name )
# same as function: only_summary_csv_to_json_transform.
# 2014/03/30 written: need to test.

	marketBased_json_string_array = Array.new
	marketBased_stored_json_string = String.new
	splited_string_array = Array.new

	marketBased_json_string_array << "["

	File.open("./query_results/marketBased_"+csv_file_name, "r"){ |fp|
		while line = fp.gets

			line = line.chomp #移除最右邊的換行符號
			splited_string_array = line.split(/,/u) #取得分開後的marketBased每欄資料
			case q_type
				when 0 # means vegetable
					# marketBased_info格式：{代號與產品名稱}, 交易日期, 市場名稱, 品種名稱, 處理別, 上價, 中價, 下價, 平均價, 平均價增減%, 交易量, 交易量增減%
					marketBased_stored_json_string = "{\"產品名稱\":\"" + splited_string_array[0] + "\", \"交易日期\":\"" + \
					splited_string_array[1] + "\", \"市場名稱\":\"" + splited_string_array[2] + "\", \"品種名稱\":\"" + \
					splited_string_array[3] + "\", \"處理別\":\"" + splited_string_array[4] + "\", \"上價\":\"" + \
					splited_string_array[5] + "\", \"中價\":\"" + splited_string_array[6] + "\", \"下價\":\"" + \
					splited_string_array[7] + "\", \"平均價\":\"" + splited_string_array[8] + "\", \"平均價增減%\":\"" + \
					splited_string_array[9] + "\", \"交易量\":\"" + splited_string_array[10] + "\", \"交易量增減%\":\"" + \
					splited_string_array[11] + "\"}"
				when 1 # means fruit
					# marketBased_info格式：{代號與產品名稱}, 交易日期, 市場名稱, 天氣, 上價, 中價, 下價, 平均價, 平均價增減%, 交易量, 交易量增減%
					marketBased_stored_json_string = "{\"產品名稱\":\"" + split_string_array[0] + "\", \"交易日期\":\"" + \
					splited_string_array[1] + "\", \"市場名稱\":\"" + splited_string_array[2] + "\", \"天氣\":\"" + \
					splited_string_array[3] + "\", \"上價\":\"" + splited_string_array[4] + "\", \"中價\":\"" + \
					splited_string_array[5] + "\", \"下價\":\"" + splited_string_array[6] + "\", \"平均價\":\"" + \
					splited_string_array[7] + "\", \"平均價增減%\":\"" + splited_string_array[8] + "\", \"交易量\":\"" + \
					splited_string_array[9] + "\", \"交易量增減%\":\"" + splited_string_array[10] + "\"}"
				when 2 # means flowers
					# marketBased_info格式：{代號與產品名稱}, 交易日期, 市場名稱, 品種名稱, 最高價, 上價, 中價, 下價, 平均價, 平均價增減%, 交易量, 交易量增減%, 殘貨量
					marketBased_stored_json_string = "{\"產品名稱\":\"" + split_string_array[0] + "\", \"交易日期\":\"" + \
					splited_string_array[1] + "\", \"市場名稱\":\"" + splited_string_array[2] + "\", \"品種名稱\":\"" + \
					splited_string_array[3] + "\", \"最高價\":\"" + splited_string_array[4] + "\", \"上價\":\"" + \
					splited_string_array[5] + "\", \"中價\":\"" + splited_string_array[6] + "\", \"下價\":\"" + \
					splited_string_array[7] + "\", \"平均價\":\"" + splited_string_array[8] + "\", \"平均價增減%\":\"" + \
					splited_string_array[9] + "\", \"交易量\":\"" + splited_string_array[10] + "\", \"交易量增減%\":\"" + \
					splited_string_array[11] + "\", \"殘貨量\":\"" + splited_string_array[12] + "\"}"
				else
					puts "未知的農產品種類, 已停止轉換格式。"
					exit
			end

			if !(fp.eof?)
				#如果還沒處理完全部檔案內容，則表示要在這筆JSON資料結尾補上逗號
				marketBased_stored_json_string << ", \n"
			end

			splited_string_array.clear #清除本回合取得的marketBased csv 資料

			marketBased_json_string_array << marketBased_stored_json_string
		end # read string from csv file, and then store them into after reorganizing into json format.

		marketBased_json_string_array << "]" # represent end of json format marketBased data.
	}

	# write json content to file
	puts "===================================="
	puts "寫入marketBased_data轉換結果中，請勿中斷程式......"
	File.open("./query_results/marketBased_"+ARGV[1], "a"){ |json_output_file|
		marketBased_json_string_array.each{ |element|
			json_output_file.puts(element)
		}
	}
	puts "marketBased data json寫入完畢."
	puts "===================================="
	# write json content to file
end

	type_item = 0 # used to verify processing item_type
	json_string_array = Array.new # store many json data within an array.
	if ARGV[0].include? "/"
		csv_file_name = ARGV[0].split(/\//u).last # get the csv file name
	else 
		csv_file_name = ARGV[0]
	end
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

		 # 2014/02/18 written: 修改JSON格式。
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


	only_summary_csv_to_json_transform( type_item, csv_file_name )
	only_marketBased_data_csv_to_json_transform( type_item, csv_file_name )


