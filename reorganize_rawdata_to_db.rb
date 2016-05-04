# encoding: utf-8
# Author: yhunglee
# This script is only for reorganizing the raw data in directory: query_results into format of database-compatible, which are postgresql and mysql.
# The script will deal with vegetable, fruit and flowers from all-in-one-table csv file to separate-table csv file.
# Note: This file can be execuated by autocomplete_repeat_commands.rb.

require 'optparse'
require 'csv'

def write_to_separate_files(outputOverviewContent, outputSpecifiedContent, outputCsvFileName, handle_type)

	if outputCsvFileName.nil? 
		abort "Error: You must specify what output file name you want. "
	end 
	outputOverviewFileName = outputCsvFileName + "-overview.csv"
	outputSpecifiedFileName = outputCsvFileName + "-specified.csv"
	if  (false == (File.exist?("./query_results/" + outputOverviewFileName))) && (false == (File.exist?("./query_results/" +  outputSpecifiedFileName)))

		if handle_type == "vegetable"
			CSV.open( "query_results/" + outputOverviewFileName , "w" ) do |csv|
				i = 0
				while i < outputOverviewContent.size

					csv << [ outputOverviewContent[i], outputOverviewContent[i+1], outputOverviewContent[i+2], outputOverviewContent[i+3], outputOverviewContent[i+4] ]
					i += 5
				end

			end

			CSV.open( "query_results/" + outputSpecifiedFileName , "w" ) do |csv|

				i = 0
				while i < outputSpecifiedContent.size

					csv << [outputSpecifiedContent[i], outputSpecifiedContent[i+1], outputSpecifiedContent[i+2], outputSpecifiedContent[i+3], outputSpecifiedContent[i+4], outputSpecifiedContent[i+5], outputSpecifiedContent[i+6], outputSpecifiedContent[i+7], outputSpecifiedContent[i+8], outputSpecifiedContent[i+9], outputSpecifiedContent[i+10] ]
					i += 11
				end 
			end 
		elsif handle_type == "fruit"
			CSV.open( "query_results/" + outputOverviewFileName , "w" ) do |csv|
				i = 0
				while i < outputOverviewContent.size

					csv << [ outputOverviewContent[i], outputOverviewContent[i+1], outputOverviewContent[i+2], outputOverviewContent[i+3], outputOverviewContent[i+4], outputOverviewContent[i+5], outputOverviewContent[i+6] ]
					i += 7
				end

			end

			CSV.open( "query_results/" + outputSpecifiedFileName , "w" ) do |csv|

				i = 0
				while i < outputSpecifiedContent.size

					csv << [outputSpecifiedContent[i], outputSpecifiedContent[i+1], outputSpecifiedContent[i+2], outputSpecifiedContent[i+3], outputSpecifiedContent[i+4], outputSpecifiedContent[i+5], outputSpecifiedContent[i+6], outputSpecifiedContent[i+7], outputSpecifiedContent[i+8], outputSpecifiedContent[i+9], outputSpecifiedContent[i+10] ]
					i += 11
				end 
			end 

		end 
		puts "Finished. You can see the contents in " + outputOverviewFileName + " and " + outputSpecifiedFileName + " now."
	else
		puts "Output files exist so they would be overwritten."
		if handle_type == "vegetable"
			CSV.open( "query_results/" + outputOverviewFileName , "w" ) do |csv|
				i = 0
				while i < outputOverviewContent.size

					csv << [ outputOverviewContent[i], outputOverviewContent[i+1], outputOverviewContent[i+2], outputOverviewContent[i+3], outputOverviewContent[i+4] ]
					i += 5
				end

			end

			CSV.open( "query_results/" + outputSpecifiedFileName , "w" ) do |csv|

				i = 0
				while i < outputSpecifiedContent.size

					csv << [outputSpecifiedContent[i], outputSpecifiedContent[i+1], outputSpecifiedContent[i+2], outputSpecifiedContent[i+3], outputSpecifiedContent[i+4], outputSpecifiedContent[i+5], outputSpecifiedContent[i+6], outputSpecifiedContent[i+7], outputSpecifiedContent[i+8], outputSpecifiedContent[i+9], outputSpecifiedContent[i+10] ]
					i += 11
				end 
			end 
		elsif handle_type == "fruit"
			CSV.open( "query_results/" + outputOverviewFileName , "w" ) do |csv|
				i = 0
				while i < outputOverviewContent.size

					csv << [ outputOverviewContent[i], outputOverviewContent[i+1], outputOverviewContent[i+2], outputOverviewContent[i+3], outputOverviewContent[i+4], outputOverviewContent[i+5],outputOverviewContent[i+6] ]
					i += 7
				end

			end

			CSV.open( "query_results/" + outputSpecifiedFileName , "w" ) do |csv|

				i = 0
				while i < outputSpecifiedContent.size

					csv << [outputSpecifiedContent[i], outputSpecifiedContent[i+1], outputSpecifiedContent[i+2], outputSpecifiedContent[i+3], outputSpecifiedContent[i+4], outputSpecifiedContent[i+5], outputSpecifiedContent[i+6], outputSpecifiedContent[i+7], outputSpecifiedContent[i+8], outputSpecifiedContent[i+9], outputSpecifiedContent[i+10] ]
					i += 11
				end 
			end 

		elsif handle_type == "flowers"
		else 
		end 
		puts "Finished. You can see the contents in " + outputOverviewFileName + " and " + outputSpecifiedFileName + " now."
	end 

end

def read_origin_csv_file( inputCsvFile )

	if false == (File.exist?("./query_results/" + inputCsvFile))
		abort "Error: The input file doesn't exist. Abort execution."
	else
		fileContent = File.readlines("./query_results/" + inputCsvFile)
		fileContent 
	end 
end

def parse_to_separate_csv_format( loadedFullContent, handle_type )
	# 1)parse Taiwan Date format
	# 2)Distinguish vegetable, fruit and flowers' format
	refilteredOverviewContent = Array.new 
	refilteredSpecifiedContent = Array.new

	lines_sum = loadedFullContent.size 
	beProcessString = String.new
	beProcessStringArray = Array.new
	kind = String.new #use for specified_fruit file and table
	for i in 0...lines_sum do 

		if 0 == (i % 2)
			# Extract overview file content
			# Input format for vegetable: issue_time, code and name, total_quantity, total_average_price
			# Output format for vegetable: name, code, DB-fitted issue_time, DB-fitted total average price, DB-fitted total quantity
			beProcessString = loadedFullContent[i].gsub(/[^,&&.]{4}:/u, "") # for vegetable
			beProcessStringArray = beProcessString.chomp.gsub!("元/公斤","").gsub!("公斤", "").split(",") #for vegetable removing chinese words at total quantity and total average price
			#beProcessStringArray = beProcessString.split(/([,]||[\u{516C 65A4}]*||[\u{5143}\/\u{516C 65A4}]*)/u)# for vegetable . (u516C, u65A4)=(公,斤), (u5143, u516C, u65A4)=(元, 公, 斤)

			# The following is for transforming date from Taiwan format to Western one.
			year = beProcessStringArray[0].match(/[\d]+/u).to_s
			adyear = (1911 + year.to_i).to_s
			beProcessStringArray[0].sub!(year, adyear).sub!("年", "").sub!("月","").sub!("日","") #(年,月,日)的unicode字碼=(u5E74, u6708, u65E5 ) 
			# The above is for transforming date from Taiwan format to Western one.
			# The following is for extracting the code from name.
			code = beProcessStringArray[1].match(/[\w]+/u).to_s
			beProcessStringArray[1].sub!(code, "")
			beProcessStringArray.insert( 1, code )
			name = beProcessStringArray[2]
			date = beProcessStringArray[0]
			# The above is for extracting the code from name.

			if handle_type == "vegetable"
				refilteredOverviewContent << beProcessStringArray[2] << beProcessStringArray[1] << beProcessStringArray[0] << beProcessStringArray[4] << beProcessStringArray[3]
			elsif handle_type == "fruit"
				#puts "beProcessStringArray: " + beProcessStringArray.to_s + ", size: " + beProcessStringArray.length.to_s #debug
				if beProcessStringArray.length == 8
					# 20160501: 為了解決2002年1月1日,OW梨 雪梨,overview的部分比一般七項多出一項,總共有八項,所以解法忽略多出來那一項, 調整檔案輸出的索引順序。
					kind = beProcessStringArray[4] # use for specified_fruit file and table
					name = beProcessStringArray[3] # use for specified_fruit file and table
					refilteredOverviewContent << beProcessStringArray[3] << beProcessStringArray[1] << beProcessStringArray[0] << beProcessStringArray[4] << beProcessStringArray[5] << beProcessStringArray[7] << beProcessStringArray[6] 
				else # beProcessStringArray.length normally is 7
					kind = beProcessStringArray[3] # use for specified_fruit file and table
					if code == 'ZZZZZ'
						# 20160504: 解決2010年9月29日ZZZZZ其他,沒有名字的bug,解法:用kind當作它的名字
						name =  beProcessStringArray[3] # use kind as name
					end 
					refilteredOverviewContent << beProcessStringArray[2] << beProcessStringArray[1] << beProcessStringArray[0] << beProcessStringArray[3] << beProcessStringArray[4] << beProcessStringArray[6] << beProcessStringArray[5] 

				end
			elsif handle_type == "flowers"
			else
			end 
		else
			# Extract specified file content
			#

			if handle_type == "vegetable"
			# Input format for vegetable: trade_location, kind, detail_processing_type, Upper_price, middle_price, lower_price, average_price, increase or decrease percentage for  average price, trade_quantity, increase or decrease percentage for trade quantity
			# Output format for vegetable for Database: name, code, DB-fitted issue_time, trade_location, kind, detail_processing_type, Upper_price, middle_price, lower_price, average_price, trade_quantity
				beProcessString = loadedFullContent[i].gsub("市場名稱,品種名稱,處理別,上價,中價,下價,平均價,增減%,交易量,增減%,", "") # for erase unuse column name.

				#puts beProcessString.chomp.gsub(/,((0)|([\-])|([\+\-][\d]+\.\d+)|([\+\-]\d+))/u, "") # get separate data from each column. debug
				#beProcessString = beProcessString.chomp.gsub(/,-(?=(,|$))/u, "") # erase data of increasing or decreasing transaction average price and quantity. And get separate data from each column. 本行指令是去除在交易平均價與數量兩者增減幅度的欄位值，1.只有負號的標點符號。
				beProcessString = beProcessString.chomp.gsub(/,(?<=[[:digit:]],)0(?=(,|$))/u, "") # erase data of increasing or decreasing transaction average price and quantity. And get separate data from each column. 本行指令是去除在交易平均價與數量兩者增減幅度的欄位值，1.單純只有零, 2.只有負號的標點符號。
				#beProcessString = beProcessString.chomp.gsub(/(,(?=[\+\-]?\d+\.?\d*)([\+\-][\d]+\.?\d*)(?=((,[^\+^\-]+)|$)))|(,-(?=(,|$)))/u, "")# 為了避免誤刪台中市的蔬菜交易量偶爾會出現負值的情況, 所以先去除一部分在交易平均價與數量兩者增減幅度的欄位值，本行指令去除的是帶有正負號的數值，並使用逗號取代。erase data of increasing or decreasing transaction average price and quantity. And get separate data from each column.
				beProcessString = beProcessString.chomp.gsub(/(,(?<=[[:digit:]],)[\+\-]\d+\.?\d*(?=(,(\d+|[\u4E00-\u9FFF]+)|$)))|(,-(?=(,|$)))/u, "")# 為了避免誤刪台中市的蔬菜交易量偶爾會出現負值的情況, 所以先去除一部分在交易平均價與數量兩者增減幅度的欄位值，本行指令去除的是帶有正負號的數值和只有負號，不使用逗號取代。erase data of increasing or decreasing transaction average price and quantity. And get separate data from each column.
				#beProcessStringArray = beProcessString.chomp.gsub(/,((0(?=(,[^\-])|$))|([\-\+][\*]+)|[\-](?!\d+\.?\d*))/u, "").split(",") # erase data of increasing or decreasing transaction average price and quantity. And get separate data from each column. 本行指令是去除在交易平均價與數量兩者增減幅度的欄位值，1.單純只有零和正負符號的星號*, 2.只有負號的標點符號。
				beProcessStringArray = beProcessString.chomp.gsub(/,[\-\+][\*]+/u, "").split(",") # erase data of increasing or decreasing transaction average price and quantity. And get separate data from each column. 本行指令是去除在交易平均價與數量兩者增減幅度的欄位值，1.單純只有正負符號的星號*, 2.只有負號的標點符號。
				# 3. \w目前沒有任意意義，只是隨便指定一個值接在[^\-^\+]後面，只用於解決2001年04月23日, SJ芋，遇到的交易量0的問題。
				#beProcessStringArray = beProcessString.chomp.split(",")
				puts "Array:" + beProcessStringArray.to_s #debug

				# erase data of increase/decrease percentage of transaction average price and quantity.
				item_sum = beProcessStringArray.size 
				for j in 0...item_sum do 
					if 0 == (j % 8)
					#if 0 == (j % 10)
						refilteredSpecifiedContent << name << code << date << beProcessStringArray[j] 
					#elsif 7 == (j % 10) 
					#	next
					#elsif 9 == (j % 10)
					#	next
					else 
						refilteredSpecifiedContent << beProcessStringArray[j]
					end 
				end
			elsif handle_type == "fruit"
				beProcessString = loadedFullContent[i].gsub("市場名稱,天氣,上價,中價,下價,平均價,增減%,交易量,增減%,", "") # for erase unuse column name.

				beProcessString = beProcessString.chomp.gsub(/,(?<=[[:digit:]],)0(?=(,|$))/u, "") # erase data of increasing or decreasing transaction average price and quantity. And get separate data from each column. 本行指令是去除在交易平均價與數量兩者增減幅度的欄位值，1.單純只有零, 2.只有負號的標點符號。
				beProcessString = beProcessString.chomp.gsub(/(,(?<=[[:digit:]],)[\+\-]\d+\.?\d*(?=(,(\d+|[\u4E00-\u9FFF]+|[\"]{2})|$)))|(,-(?=(,|$)))/u, "")# 為了避免誤刪台中市的蔬菜交易量偶爾會出現負值的情況, 所以先去除一部分在交易平均價與數量兩者增減幅度的欄位值，本行指令去除的是帶有正負號的數值和只有負號，不使用逗號取代。erase data of increasing or decreasing transaction average price and quantity. And get separate data from each column. \u4E00-\u9FFF是中日韓認同表意文字主區.  20160501 add: 為了讓1996年2月10日51百香果在高雄市交易價格的bug和1996年4月23日C1椪柑在台北一之後沒有交易市場與天氣資訊的bug, 輪流被解決, 這行可以先刪掉C1椪柑的交易量增減%資料,所以改寫成這樣.
				beProcessStringArray = beProcessString.chomp.gsub(/,[\-\+][\*]+/u, "").split(",") # erase data of increasing or decreasing transaction average price and quantity. And get separate data from each column. 本行指令是去除在交易平均價與數量兩者增減幅度的欄位值，1.單純只有正負符號的星號*, 2.只有負號的標點符號。
				# beProcessStringArray = beProcessString.gsub("\"\",","").split(",") # 20160501: 刪掉程式在1996年2月10日,51百香果的高雄市交易資料中，多出的雙引號. 因後續遇到1996年4月23日C1椪柑的bug, 所以隱藏這行,讓2月10日的51百香果高雄市交易資料bug在下面whileloop解決。

				# 20160501: for fixing data bug of fruit file Jan1996.csv: C1椪柑 at 1996年1月2日, 有兩個東勢區的資料，其中第二個沒標出名字. 
				item_size = beProcessStringArray.size
				k = 0
				beProcessStringArray.delete("\"\"") #20160501: 解決1996年2月10日,51百香果在高雄市交易價格多出來的雙引號bug; 也解決1996年8月11日O2梨 秋水梨在東勢區的下一筆交易價格多出兩個雙引號的bug,也解決1996年8月16日O4梨 新興梨在嘉義市多出兩個雙引號的bug 
				while k < item_size do
					if( nil != (beProcessStringArray[k] =~ /[\u4E00-\u9FFF]+/u) && nil != (beProcessStringArray[k+1] =~ /\d+\.?\d*/u) && nil != (beProcessStringArray[k-1] =~ /\d+\.?\d*/u) )
						# 20160502:這個解決1996年8月16日O4新興梨交易價格資訊嘉義市的前一筆沒有提供交易市場資訊bug，做法是填入unknownMarket當做交易市場
						# 20160502:這個解決1996年8月16日S1葡萄 巨峰沒有交易市場的bug
						# 20160501: for fixing data bug of fruit file Jan1996.csv: C1椪柑 at 1996年1月2日, 有兩個東勢區的資料，其中第二個沒標出名字. 
						beProcessStringArray.insert(k,"unknownMarket")
						item_size += 1
					elsif( nil != (beProcessStringArray[k] =~ /\d+\.?\d*/u) && nil != (beProcessStringArray[k+1] =~ /\d+\.?\d*/u) && nil != (beProcessStringArray[k-1] =~ /\d+\.?\d*/u)) # 20160501: 這個解決1996年4月23日C1椪柑台北一之後沒有交易市場和天氣的bug
						#beProcessStringArray[k] = beProcessStringArray[k-7]
						#beProcessStringArray[k+1] = beProcessStringArray[k-6]
						beProcessStringArray.insert(k, 'unknownMarket')
						beProcessStringArray.insert(k+1,'unknownWeather')
						item_size += 2

					end 
					k += 7
				end 
				# 20160501: for fixing data bug of fruit file Jan1996.csv: C1椪柑 at 1996年1月2日, 有兩個東勢區的資料，其中第二個沒標出名字.
				#puts "beProcessStringArray:" + beProcessStringArray.to_s #debug

				# erase data of increase/decrease percentage of transaction average price and quantity.
				item_sum = beProcessStringArray.size 
				for j in 0...item_sum do 
					if 0 == (j % 7)
					#if 0 == (j % 10)
						refilteredSpecifiedContent << name << code << date << kind << beProcessStringArray[j] 
					#elsif 7 == (j % 10) 
					#	next
					#elsif 9 == (j % 10)
					#	next
					else 
						refilteredSpecifiedContent << beProcessStringArray[j]
					end 
				end
			elsif handle_type == "flowers"
			else
				abort "Unknown handle_type for processing. Abort execution."	
			end 
			# Use name and code from last part.

			# Input format for fruit:
			# Output format for fruit:
			#
			# Input format for flowers:
			# Output format for flowers:
		end 
	end 

	#puts refilteredOverviewContent #debug
	#puts refilteredSpecifiedContent #debug
	return refilteredOverviewContent, refilteredSpecifiedContent
end 

	command_options = Hash.new
	option_parser = OptionParser.new do |opts|

		opts.banner = "Usage: reorganize_rawdata_to_db.rb {options}"

		opts.separator ""
		opts.separator "Specific options:"
		opts.on("-i INPUTFILE", "--inputfile=INPUTFILE", "specify what input file you want to transform." ) do |value|
			command_options[:inputfile] = value
		end

		opts.on("-k DATAKIND","--kind=DATAKIND", "told the script what kind, which are flowers, fruit and vegetable, you want it process.") do |value|
			command_options[:kind] = value
		end

		opts.on("-o OUTPUTFILE", "--outputfile=OUTPUTFILE", "specify what output file you want want to generate.") do |value|
			command_options[:outputfile] = value
		end

		opts.on_tail("-h", "--help", "show options" ) do
			puts opts
			exit
		end

	end


	option_parser.parse!

	# inputFilename = ARGV[0]
	# inputFileType = ARGV[1] # Distinguish between Vegetable, fruit and flower
	# outputMainFilename = ARGV[2] # Output Main file name for input file. We divide overall data and individually ones. Sub output file name are concated with "-1" and "-2".



	loadedFileContent = read_origin_csv_file command_options[:inputfile]
	overviewContent, specifiedContent = parse_to_separate_csv_format loadedFileContent, command_options[:kind]
	puts command_options[:outputfile] #debug
	write_to_separate_files(overviewContent,specifiedContent,command_options[:outputfile],command_options[:kind])


	
