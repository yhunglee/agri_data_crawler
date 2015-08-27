# encoding: utf-8
# Author: yhunglee
# This script is only for reorganizing the raw data in directory: query_results into format of database-compatible, which are postgresql and mysql.
# The script will deal with vegetable, fruit and flowers from all-in-one-table csv file to separate-table csv file.
require 'optparse'
require 'csv'

def write_to_separate_files(outputOverviewContent, outputSpecifiedContent, outputCsvFileName)

	if outputCsvFileName.nil? 
		abort "Error: You must specify what output file name you want. "
	end 
	outputOverviewFileName = outputCsvFileName + "-overview.csv"
	outputSpecifiedFileName = outputCsvFileName + "-specified.csv"
	if  (false == (File.file? outputOverviewFileName)) && (false == (File.file? outputSpecifiedFileName))

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
		puts "Finished. You can see the contents in " + outputOverviewFileName + " and " + outputSpecifiedFileName + " now."
	else
		puts "Output files exist so they would be overwritten."
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
		puts "Finished. You can see the contents in " + outputOverviewFileName + " and " + outputSpecifiedFileName + " now."
	end 

end

def read_origin_csv_file( inputCsvFile )

	if false == (File.file? inputCsvFile)
		abort "Error: The input file doesn't exist. Abort execution."
	else
		fileContent = File.readlines inputCsvFile
		fileContent 
	end 
end

def parse_to_separate_csv_format( loadedFullContent )
	# 1)parse Taiwan Date format
	# 2)Distinguish vegetable, fruit and flowers' format
	refilteredOverviewContent = Array.new 
	refilteredSpecifiedContent = Array.new

	lines_sum = loadedFullContent.size 
	beProcessString = String.new
	beProcessStringArray = Array.new
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

			refilteredOverviewContent << beProcessStringArray[2] << beProcessStringArray[1] << beProcessStringArray[0] << beProcessStringArray[4] << beProcessStringArray[3]
		else
			# Extract specified file content
			# Input format for vegetable: trade_location, kind, detail_processing_type, Upper_price, middle_price, lower_price, average_price, increase or decrease percentage for  average price, trade_quantity, increase or decrease percentage for trade quantity
			# Output format for vegetable for Database: name, code, DB-fitted issue_time, trade_location, kind, detail_processing_type, Upper_price, middle_price, lower_price, average_price, trade_quantity
			#
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
	overviewContent, specifiedContent = parse_to_separate_csv_format loadedFileContent 
	puts command_options[:outputfile] #debug
	write_to_separate_files(overviewContent,specifiedContent,command_options[:outputfile])


	
