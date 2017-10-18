# encoding: utf-8
# Author: howardsun
# Date: 2013/03/10
# Crawling data of vegetables, fruits and flowers from a website of Taiwan government.

require 'net/http'
require 'date'
require 'watir'
require 'headless'
FILE_OF_VEGETABLE = "txt_at_amis_vegetable.txt"
FILE_OF_FRUIT = "txt_at_amis_fruit.txt"
FILE_OF_FLOWERS = "txt_at_amis_flowers.txt"
FILE_PREFIX_OF_OLD_VEGETABLE = "txt_at_amis_vegetable-OLD-"
FILE_SUFFIX_OF_OLD_VEGETABLE = ".txt"
FILE_PREFIX_OF_OLD_FRUIT = "txt_at_amis_fruit-OLD-"
FILE_SUFFIX_OF_OLD_FRUIT = ".txt"
FILE_PREFIX_OF_OLD_FLOWERS = "txt_at_amis_flowers-OLD-"
FILE_SUFFIX_OF_OLD_FLOWERS = ".txt"
PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY = "./data_format_at_every_site/"
PATH_OF_QUERY_RESULTS_DIRECTORY = "./query_results/"
#ADDRESS_OF_VEGETABLE_PRODUCT_ITEMS = "http://210.69.71.171/Selector/VegProductSelector.aspx"
#ADDRESS_OF_FRUIT_PRODUCT_ITEMS = "http://210.69.71.171/Selector/FruitProductSelector.aspx"
#ADDRESS_OF_FLOWERS_PRODUCT_ITEMS = "http://210.69.71.171/Selector/FlowerProductSelector.aspx"
ADDRESS_OF_VEGETABLE_PRODUCT_ITEMS = "http://amis.afa.gov.tw/Selector/VegProductSelector.aspx"
ADDRESS_OF_FRUIT_PRODUCT_ITEMS = "http://amis.afa.gov.tw/Selector/FruitProductSelector.aspx"
ADDRESS_OF_FLOWERS_PRODUCT_ITEMS = "http://amis.afa.gov.tw/Selector/FlowerProductSelector.aspx"
FILE_OF_CHANGELOG_VEGETABLE = "CHANGELOG-VEGETABLE.txt"
FILE_OF_CHANGELOG_FRUIT = "CHANGELOG-FRUIT.txt"
FILE_OF_CHANGELOG_FLOWERS = "CHANGELOG-FLOWERS.txt"
FILE_OF_TMPCHANGELOG = "tmpchangelog.txt"
#ADDRESS_OF_VEGETABLE_QUERY = "210.69.71.171/veg/VegProdDayTransInfo.aspx"
#ADDRESS_OF_FRUIT_QUERY = "210.69.71.171/fruit/FruitProdDayTransInfo.aspx"
#ADDRESS_OF_FLOWERS_QUERY = "210.69.71.171/flower/FlowerProdDayTransInfo.aspx"
ADDRESS_OF_VEGETABLE_QUERY = "http://amis.afa.gov.tw/veg/VegProdDayTransInfo.aspx"
ADDRESS_OF_FRUIT_QUERY = "http://amis.afa.gov.tw/fruit/FruitProdDayTransInfo.aspx"
ADDRESS_OF_FLOWERS_QUERY = "http://amis.afa.gov.tw/flower/FlowerProdDayTransInfo.aspx"
WAIT_TIME_FOR_REMOTE_ITEMS = 30 # seconds
RETRY_TIME = 5 # retry limit when encountering exceptions.
LIMIT_OF_RETRY_OF_STALE_ELEMENT_REFERENCE_ERROR = 20 # retry limit when encountering exceptions of selenium::webdriver::error::staleelementreference .
LIMIT_OF_RETRY_OF_UNKNOWN_OBJECT_ERROR = 20 # retry limit when encountering exceptions of watir::exception::unknownobjectexception .
LIMIT_OF_RETRY_OF_UNKNOWN_ERROR = 20 # retry limit when encountering exceptions of selenium::webdriver::error::unknownerror .
LIMIT_OF_RETRY_OF_TIMEOUT_ERROR = 20 # retry limit when encountering exceptions of watir::wait::timeouterror .
LIMIT_OF_RETRY_OF_CONNECT_REFUSED_ERROR = 20 # retry limit when encountering exceptions of errno::econnrefused .

=begin
class AlertForNoDataException < Exception
end 
=end

def read_items_from_file query_type

	array_mpno = Array.new
	array_mpno_name = Array.new
	if query_type == 1
		#file_name = "txt_at_amis_vegetable.txt"
		#file_name = "test_txt_at_amis_vegetable.txt"
		file_name = FILE_OF_VEGETABLE 
	elsif query_type == 2
		#file_name = "txt_at_amis_fruit.txt"
		file_name = FILE_OF_FRUIT 
	elsif query_type == 3
		#file_name = "txt_at_amis_flowers.txt"
		#file_name = "test_txt_at_amis_flowers.txt"
		file_name = FILE_OF_FLOWERS 
	else
		puts "Error: unknown query_type at method: read_items_from_file."
		exit
	end
	File.open(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + file_name, "r"){ |f|
		while line = f.gets
			# puts "line: "+line #debug
			content = line.split("\t")
			# puts "content: "+content.to_s #debug
			if query_type == 2
				# For fruit
				
				tmp_item_name_array = Array.new 
				# For storing mpno_name and its detail type.

				if content[1].eql?("　")
					# skip content[1] for storing into array_mpno_name
					array_mpno << (content[2].delete! "\n")
					tmp_item_name_array << content[0]
					array_mpno_name << tmp_item_name_array

				elsif 2 == content.size && content[1][/([A-Z]|[0-9])+/u] != nil
					array_mpno << (content[1].delete! "\n")
					# This is for fruit item: [藍莓\t46] 和 [其他\tZZZZZ] ...etc.
					tmp_item_name_array << content[0]
					array_mpno_name << tmp_item_name_array

				else
					# for storing mpno_name of [椰子\t進口\t119]-like items
					array_mpno << (content[2].delete! "\n")
					tmp_item_name_array << content[0] << content[1]
					array_mpno_name << tmp_item_name_array
				end

			else
				# For vegetable and flowers
				array_mpno_name << content[0]
				array_mpno << (content[1].delete! "\n")
			end
		end
	}

	return array_mpno, array_mpno_name
end

def get_remote_item_list(queryType)
	if( queryType == 1 ) # 1 means vegetable
		qAddr = ADDRESS_OF_VEGETABLE_PRODUCT_ITEMS 
	elsif( queryType == 2 ) # 2 means fruit
		qAddr = ADDRESS_OF_FRUIT_PRODUCT_ITEMS 
	elsif( queryType == 3 ) # 3 means flowers
		qAddr = ADDRESS_OF_FLOWERS_PRODUCT_ITEMS 
	else
		puts "Error: unknown queryType at method: get_remote_item_list."
		exit
	end

	keyArray = Array.new
	valueString = String.new
	valueArray = Array.new

	headless = Headless.new
	headless.start
	# for firefox 46 and earlier version
	#browser = Watir::Browser.start(qAddr) if ( (!browser) || !(browser.exist?))
	
	# just for a trial when debugging
	#browser = Watir::Browser.new(:firefox, marionette: true) if ( (!browser) || !(browser.exist?))
	#browser.goto(qAddr)
	
	# For firefox 48 and onward version
	netExceptionCount = 0
	browserUnknownExceptionCount = 0
	begin 
		browser = Watir::Browser.new(:firefox) if ( (!browser) || !(browser.exist?) )
		browser.goto(qAddr)
	rescue Net::ReadTimeout => e
		puts "Suffering congestion. It seems our network or target site connections busy now. We will retry."
		netExceptionCount += 1
		retry unless netExceptionCount > RETRY_TIME 
		abort e.message 

	rescue Selenium::WebDriver::Error::UnknownError => e
		puts "The uncontrolled browser exists, and we will close and restart it."
		browser.close
		browserUnknownExceptionCount += 1

		retry unless browserUnknownExceptionCount > RETRY_TIME

		abort e.message

	end 

	remoteItemListExceptionCount = 0 # for staleelementexception
	unknownObjectExceptionCount = 0
	timeOutExceptionCount = 0
	if( queryType == 1 ) # 1 means vegetable 
		# vegetable 使用大項產品的清單
		#browser.execute_script('window.document.getElementById("radlProductType_1").checked=true;') # 雖然我們可以用這個選擇大項產品，但因為該表格的選項有綁定click事件，去驅動抓取現有產品名稱清單，所以從原本的設定項目checked，改成使用click事件
		browser.execute_script('window.document.getElementById("radlProductType_1").click();')
		begin
=begin
			if( false == browser.select(id: 'lstProduct').present?  )
				puts "等待取得遠端清單區塊 " + WAIT_TIME_FOR_REMOTE_ITEMS.to_s + " 秒"
				browser.select(id: 'lstProduct').wait_until(timeout: WAIT_TIME_FOR_REMOTE_ITEMS, &:present?)
				
			end 
=end
			puts "等待顯示遠端清單 " + WAIT_TIME_FOR_REMOTE_ITEMS.to_s + " 秒"
                        sleep WAIT_TIME_FOR_REMOTE_ITEMS 
			browser.select(id: 'lstProduct').wait_until(timeout: WAIT_TIME_FOR_REMOTE_ITEMS, &:present?)
			#browser.select(id: 'lstProduct').wait_while(timeout: WAIT_TIME_FOR_REMOTE_ITEMS, &:present?)
			#puts "options' values: " + browser.select(id: 'lstProduct').options 
			#puts "select texts: " + browser.select(id: 'lstProduct').text
		rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
			# Because it doesn't find the element when waiting element id: lstProduct and generates the StaleElementReferenceError, we reclick the checkbox of list again.
			
			browser.execute_script('window.document.getElementById("radlProductType_1").click();')
			remoteItemListExceptionCount += 1

			retry unless remoteItemListExceptionCount > LIMIT_OF_RETRY_OF_STALE_ELEMENT_REFERENCE_ERROR 
			abort e.message

		rescue Watir::Exception::UnknownObjectException => e
			puts "遠端清單尚未出現，繼續等待。Watir::Exception::UnknownObjectException raised. We will retry."
			unknownObjectExceptionCount += 1
			retry unless unknownObjectExceptionCount > LIMIT_OF_RETRY_OF_UNKNOWN_OBJECT_ERROR  
			abort e.message 

		rescue Watir::Wait::TimeoutError => e
			if( true == browser.select(id: 'lstProduct').present? )
				puts "等待的遠端清單已經出現"
			else
				puts "遠端清單尚未出現，繼續等待 " + WAIT_TIME_FOR_REMOTE_ITEMS.to_s + " 秒"
				timeOutExceptionCount += 1

				retry unless timeOutExceptionCount > LIMIT_OF_RETRY_OF_TIMEOUT_ERROR 
				abort e.message 
			end 
		ensure 
			# This block will alway executed on pathways without retry.
			# This block can fix both bugs of wait_until_present, which handle nothing, and duties in TimeoutError.
			optionArray = browser.select(id: 'lstProduct').options.to_a
			optionArray.each{ |element|
				# Get item code
				#puts "option value: "+ element.value.to_s
				keyArray << element.value
			}

=begin
			# get item name (and/or (kind and/or processing type) ).
			valueString = browser.select(id: 'lstProduct').text.clone()
			valueString = valueString.gsub(/[a-zA-Z0-9]+[ ](?=[a-zA-Z0-9 \u4E00-\u9FFF]+([\n]|$))/u,"")
			tmpvalueArray = valueString.split("\n")
			tmpvalueArray.each{ |element|
				valueArray << element.split(" ")
			}
			#puts "valueArray: " + valueArray.to_s #debug
			# get item name (and/or (kind and/or processing type) ).
=end
                        optionArray.each { |element|
                            tmpvalue = element.text.gsub(/[a-zA-Z0-9]+[ ](?=[a-zA-Z0-9 \u4E00-\u9FFF]+([\n]|$))/u,"")
                            valueArray << tmpvalue.split(" ")
                        }
		end
	elsif( queryType == 2 )	# 2 means fruit
		# fruit 使用細項產品的清單
		#browser.execute_script('window.document.getElementById("radlProductType_2").checked=true;') # 雖然我們可以用這個選擇細項產品，但因為該表格的選項有綁定click事件，去驅動抓取現有產品名稱清單，所以從原本的設定項目checked，改成使用click事件
		browser.execute_script('window.document.getElementById("radlProductType_2").click();')
		begin
=begin
			if( false == browser.select(id: 'lstProduct').present? )
				puts "等待取得遠端清單區塊 " + WAIT_TIME_FOR_REMOTE_ITEMS.to_s + " 秒"
				browser.select(id: 'lstProduct').wait_until(timeout: WAIT_TIME_FOR_REMOTE_ITEMS, &:present?)
			end 
=end
			puts "等待顯示遠端清單 " + WAIT_TIME_FOR_REMOTE_ITEMS.to_s + " 秒"
                        sleep WAIT_TIME_FOR_REMOTE_ITEMS
			browser.select(id: 'lstProduct').wait_until(timeout: WAIT_TIME_FOR_REMOTE_ITEMS, &:present?)
			#browser.select(id: 'lstProduct').wait_while(timeout: WAIT_TIME_FOR_REMOTE_ITEMS, &:present?)
		rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
			# Because it doesn't find the element when waiting element id: lstProduct and generates the StaleElementReferenceError, we reclick the checkbox of list again.
			browser.execute_script('window.document.getElementById("radlProductType_2").click();')
			remoteItemListExceptionCount += 1	
			retry unless remoteItemListExceptionCount > LIMIT_OF_RETRY_OF_STALE_ELEMENT_REFERENCE_ERROR 
			abort e.message
		rescue Watir::Exception::UnknownObjectException => e
			puts "遠端清單尚未出現，繼續等待。Watir::Exception::UnknownObjectException raised. We will retry."
			unknownObjectExceptionCount += 1
			retry unless unknownObjectExceptionCount > LIMIT_OF_RETRY_OF_UNKNOWN_OBJECT_ERROR 
			abort e.message

		rescue Watir::Wait::TimeoutError => e
			if( true == browser.select(id: 'lstProduct').present? )
				puts "等待的遠端清單已經出現"
			else
				puts "遠端清單尚未出現，繼續等待 " + WAIT_TIME_FOR_REMOTE_ITEMS.to_s + " 秒"
				timeOutExceptionCount += 1
				retry unless timeOutExceptionCount > LIMIT_OF_RETRY_OF_TIMEOUT_ERROR
				abort e.message 

			end 
		ensure
			# This block will alway executed on pathways without retry.
			# This block can fix both bugs of wait_until_present, which handle nothing, and duties in TimeoutError.
			optionArray = browser.select(id: 'lstProduct').options.to_a
			optionArray.each{ |element|
				# Get item code
				#puts "option value: "+ element.value.to_s
				keyArray << element.value
			}
			puts "keyArray: " + keyArray.to_s #debug

=begin
			# get item name (and/or (kind and/or processing type) ).
			valueString = browser.select(id: 'lstProduct').text.clone()
			valueString = valueString.gsub(/[a-zA-Z0-9]+[ ](?=[a-zA-Z0-9 \u4E00-\u9FFF\u3100-\u312F]+([\n]|$))/u,"") # \u4E00-\u9FFF是中日韓文範圍, \u3100-\u312F是注音符號的範圍, 加上注音符號的範圍是為了解決代號71的蕃茄 一般的用字，它使用注音符號的「ㄧ」
			tmpvalueArray = valueString.split("\n")
			tmpvalueArray.each{ |element|
				valueArray << element.split(" ")
			}
			puts "valueArray: " + valueArray.to_s #debug
			# get item name (and/or (kind and/or processing type) ).
=end

                        optionArray.each { |element|
                            tmpvalue = element.text.gsub(/[a-zA-Z0-9]+[ ](?=[a-zA-Z0-9 \u4E00-\u9FFF\u3100-\u312F]+([\n]|$))/u,"") # \u4E00-\u9FFF是中日韓文範圍, \u3100-\u312F是注音符號的範圍, 加上注音符號的範圍是為了解決代號71的蕃茄 一般的用字，它使用注音符號的「ㄧ」
                            valueArray << tmpvalue.split("")
                        }
		end
	elsif( queryType == 3 ) # 3 means flowers
		# flowers 使用分類產品的清單
		#browser.execute_script('window.document.getElementById("rdoListProductType_1").checked=true;') # 雖然我們可以用這個選擇大項產品，但因為該表格的選項有綁定click事件，去驅動抓取現有產品名稱清單，所以從原本的設定項目checked，改成使用click事件
		browser.execute_script('window.document.getElementById("radlProductType_1").click();')
		begin
=begin
			if( false == browser.select(id: 'lstbProduct').present? )
				puts "等待取得遠端清單區塊 " + WAIT_TIME_FOR_REMOTE_ITEMS.to_s + " 秒"
				browser.select(id: 'lstbProduct').wait_until(timeout: WAIT_TIME_FOR_REMOTE_ITEMS, &:present?)
			end 
=end
			puts "等待顯示遠端清單 " + WAIT_TIME_FOR_REMOTE_ITEMS.to_s + " 秒"
                        sleep WAIT_TIME_FOR_REMOTE_ITEMS
			browser.select(id: 'lstbProduct').wait_until(timeout: WAIT_TIME_FOR_REMOTE_ITEMS, &:present?)
			#browser.select(id: 'lstbProduct').wait_while(timeout: WAIT_TIME_FOR_REMOTE_ITEMS, &:present?)
		rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
			# Because it doesn't find the element when waiting element id: lstbProduct and generates the StaleElementReferenceError, we reclick the checkbox of list again.
			browser.execute_script('window.document.getElementById("radlProductType_1").click();')
			remoteItemListExceptionCount += 1
			retry unless remoteItemListExceptionCount > LIMIT_OF_RETRY_OF_STALE_ELEMENT_REFERENCE_ERROR 
			abort e.message

		rescue Watir::Exception::UnknownObjectException => e
			puts "遠端清單尚未出現，繼續等待。Watir::Exception::UnknownObjectException raised. We will retry."
			unknownObjectExceptionCount += 1
			retry unless unknownObjectExceptionCount > LIMIT_OF_RETRY_OF_UNKNOWN_OBJECT_ERROR
			abort e.message 
		rescue Watir::Wait::TimeoutError => e
			if( true == browser.select(id: 'lstbProduct').present? ) 
				puts "等待的遠端清單已經出現"
			else
				puts "遠端清單尚未出現，繼續等待 " + WAIT_TIME_FOR_REMOTE_ITEMS.to_s + " 秒"
				timeOutExceptionCount += 1
				retry unless timeOutExceptionCount > LIMIT_OF_RETRY_OF_TIMEOUT_ERROR 
				abort e.message 
			end
		ensure
			# This block will alway executed on pathways without retry.
			# This block can fix both bugs of wait_until_present, which handle nothing, and duties in TimeoutError.
			optionArray = browser.select(id: 'lstbProduct').options.to_a
			optionArray.each{ |element|
				# Get item code
				#puts "option value: "+ element.value.to_s
				keyArray << element.value
			}

=begin
			# get item name (and/or (kind and/or processing type) ).
			valueString = browser.select(id: 'lstbProduct').text.clone()
			valueString = valueString.gsub(/[a-zA-Z0-9]+[ ](?=[a-zA-Z0-9 \u4E00-\u9FFF]+([\n]|$))/u,"")
			tmpvalueArray = valueString.split("\n")
			tmpvalueArray.each{ |element|
				valueArray << element.split(" ")
			}
			#puts "valueArray: " + valueArray.to_s #debug
			# get item name (and/or (kind and/or processing type) ).
=end
                        optionArray.each { |element|
                            tmpvalue = element.text.gsub(/[a-zA-Z0-9]+[ ](?=[a-zA-Z0-9 \u4E00-\u9FFF]+([\n]|$))/u,"")
                            valueArray << tmpvalue.split(" ")
                        }

		end 
	end
	
	browser.close
	headless.destroy 

	# Assign code as key of a hash. Assign name and type as value of a hash.
	codeAndNameAndTypeHash = Hash.new
	keyArray.each_index{|idx|
		codeAndNameAndTypeHash[ (keyArray[idx]) ] = valueArray[idx]
	}
	# Assign code as key of a hash. Assign name and type as value of a hash.
	return codeAndNameAndTypeHash
end
def check_difference_between_localItem_and_remoteItem( queryType, localItemsHash, remoteItemsHash, changeSignCollectionHash)


	puts "開始檢查本機與遠端清單更動的項目"
	# Note whether remote website's items has different with local file.
	localItemsHash.each_key{ |key|
		if (localItemsHash[key].is_a?(String)) 
			# vegetable-like cases that type of values of Hash is String
			localItemsHash[key] = localItemsHash[key].split(" ")
		end 
		# if there is a type of values of Hash is Array like fruits, it won't split from String to Array.
	} # transform type of value of localItemsHash from String to Array of String.

	remoteItemsHash.each_pair{ |key,value|
		if localItemsHash.has_key?(key)
			valueOfLocalItems = localItemsHash[key]
			sizeOfValueOfLocalItems = valueOfLocalItems.length
			sizeOfValue = value.length
			if sizeOfValueOfLocalItems == sizeOfValue
				# may have changed name and/or kind, processing type. Or have no changed anything.
				valueOfLocalItems.each_index{ |index|
					if( false == (valueOfLocalItems[index].eql?(value[index])) )
						if index == 0
							changeSign = 1 # means name has changed
						elsif index == 1
							changeSign = 2 # means kind has changed
						elsif index == 2
							changeSign = 3 # means processing type has changed
						end 
						changeSignArray = ( nil == changeSignCollectionHash[key] )? (Array.new) : changeSignCollectionHash[key]
						changeSignArray << changeSign
						changeSignCollectionHash[key] = changeSignArray 
					#else situation => do nothing
					end 
				}

			elsif sizeOfValueOfLocalItems > sizeOfValue 
				# may have changed/removed name, kind or processing type
				differNumber = sizeOfValueOfLocalItems - sizeOfValue 
				valueOfLocalItems.each_index{ |index|
					# 不考慮一個處理別分項合併到另一產品主項的情況，只考慮處理別分項合併到品種分項。
					# 產品主項>品種分項>處理別分項。
					if( (index + differNumber) == (sizeOfValueOfLocalItems - 1 ) )
						changeSign = 5 # means kind and/or processing type removed and remote website has removed processing type.
						changeSignArray = ( nil == changeSignCollectionHash[key] )? (Array.new) : changeSignCollectionHash[key]
						changeSignArray << changeSign
						changeSignCollectionHash[key] = changeSignArray 

						break
					else
					       # if index + differNumber < sizeOfValueOfLocalItems - 1	
						if( false == (valueOfLocalItems[index].eql?(value[index])) ) 
							if index == 0
								changeSign = 4 # means name changed and remote item's name, kind and/or processing type may have been removed or modified contrast to local file.
							elsif index == 1
								changeSign = 5 # means kind changed and remote item's kind and/or processing type may have been removed or modified contrast to local file.
							end 
							changeSignArray = ( nil == changeSignCollectionHash[key] )? (Array.new) : changeSignCollectionHash[key]
							changeSignArray << changeSign
							changeSignCollectionHash[key] = changeSignArray 
						end 
					end 
				}
			elsif sizeOfValueOfLocalItems < sizeOfValue 
				# may have changed/added name, kind or processing type
				differNumber = sizeOfValue - sizeOfValueOfLocalItems
				value.each_index{ |index|
					if( (index + differNumber) == (sizeOfValue - sizeOfValueOfLocalItems) )
						changeSign = 7 # means 修改品名或可能新增處理別
						changeSignArray = ( nil == changeSignCollectionHash[key] )? (Array.new) : changeSignCollectionHash[key]
						changeSignArray << changeSign
						changeSignCollectionHash[key] = changeSignArray 
						break
					else
						if( false == (value[index].eql?(valueOfLocalItems[index])) )
							if index == 0
								changeSign = 6 # means 產品名稱改名，而且可能新增品種分項或處理別分項
							elsif index == 1 
								changeSign = 7 # means 品種改名，而且可能新增處理別分項
							end 
							changeSignArray = ( nil == changeSignCollectionHash[key] )? (Array.new) : changeSignCollectionHash[key]
							changeSignArray << changeSign
							changeSignCollectionHash[key] = changeSignArray 
						end 
					end 
				}
			end 
		else
			#if localItemsHash has no this key
			changeSignArray = Array.new
			changeSign = 8 # means 新增產品
			changeSignArray << changeSign 
			changeSignCollectionHash[key] = changeSignArray
		end 
	}
	localItemsHash.each_key{|key|
		if( !remoteItemsHash.has_key?(key) )
			changeSignArray = Array.new
			changeSign = 9 # means 移除產品
			changeSignArray << changeSign 
			changeSignCollectionHash[key] = changeSignArray
		end 
	}
	# Note whether remote website's items has different with local file.
	puts "結束檢查本機與遠端清單更動的項目"
end

def generate_changelog_for_item_lists( queryType, localItemsHash, remoteItemsHash, changeSignCollectionHash)

	# Generate CHANGELOG-<QUERTYPE>.txt
	if( false == changeSignCollectionHash.empty? )
	        puts "開始更新本機本次查詢清單種類的CHANGELOG."
		if( queryType == 1 ) # 1 means vegetable
			changelogFile = FILE_OF_CHANGELOG_VEGETABLE 
		elsif( queryType == 2 ) # 2 means fruit
			changelogFile = FILE_OF_CHANGELOG_FRUIT 
		elsif( queryType == 3 ) # 3 means flowers
			changelogFile = FILE_OF_CHANGELOG_FLOWERS 
		end 
		tmpchangelog = FILE_OF_TMPCHANGELOG 
		if( File.exist?(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + changelogFile) )
			File.copy_stream(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + changelogFile, PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + tmpchangelog)
		end 
		originalFilePointer = File.open(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + changelogFile, "w")
		originalFilePointer.puts("==============", Date.today.to_s, "")
		setForChangeNameOrKindOrProcessingType = [1,2,3]
		changeSignCollectionHash.each_pair{ |key,value|
			case ((value - setForChangeNameOrKindOrProcessingType)[0])
			when 1 # rest 1 means kind or processing type has changed
				originalFilePointer.puts("#{key}#{(localItemsHash[key])[0]} 已經改變它的品名或處理別")
			when 2 # rest 2 means name or processing type has changed
				originalFilePointer.puts("#{key}#{(localItemsHash[key])[0]} 已經改變它的名稱或處理別")
			when 3 # rest 3 means name or kind has changed
				originalFilePointer.puts("#{key}#{(localItemsHash[key])[0]} 已經改變它的名稱或品名")
			when nil # rest nil means name, kind and processing type have changed
				originalFilePointer.puts("#{key}已經改變它的名稱,品名和處理別")
			else
				setForChangeNameOrKindOrProcessingType = [4,5]
				case((value - setForChangeNameOrKindOrProcessingType)[0])
				when 4 # rest 4 means kind changed and processing type may has removed.
					originalFilePointer.puts("#{key}#{(localItemsHash[key])[0]}已經改變它的品名,處理別可能已經移除")
				when 5 # rest 5 means name has changed and kind and/or processing type may have removed.
					originalFilePointer.puts("#{key}#{(localItemsHash[key])[0]}已經改變它的名稱,另外它的品名和處理別可能已經修改或移除")
				when nil
					originalFilePointer.puts("#{key}已經改變它的名稱,品名和處理別")
				else
					setForChangeNameOrKindOrProcessingType = [6,7]
					case((value - setForChangeNameOrKindOrProcessingType)[0])
					when 6 # rest 6 means 品種改名，而且可能修改處理別分項
						originalFilePointer.puts("#{key}#{(localItemsHash[key])[0]}已經改變它的品名,而且可能新增處理別分項")
					when 7 # rest 7 means 產品名稱改名，而且可能新增品種分項或處理別分項
						originalFilePointer.puts("#{key}#{(localItemsHash[key])[0]}已經改變它的名稱,另外它的品名和處理別可能已經新增品種分項或處理別")
					when nil # rest nil means 已經改變產品名稱,品名和處理別
						originalFilePointer.puts("#{key}已經改變它的名稱,品名和處理別")
					end 
				end 	
			end 
			if(value.include?(8) && remoteItemsHash.has_key?(key) ) # means 新增產品
				originalFilePointer.puts("在本次執行發現新增#{key}#{(remoteItemsHash[key])[0]}項目")
			elsif(value.include?(9) && localItemsHash.has_key?(key) ) # means刪除產品
				originalFilePointer.puts("在本次執行發現已刪除#{key}#{(localItemsHash[key])[0]}項目")
			end 

		}
		if( File.exist?(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + tmpchangelog) )
			originalFilePointer.puts("==========================")
			originalFilePointer.write("#{File.open(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + tmpchangelog,"r").read}")
		end 
		
		originalFilePointer.close
		if( File.exist?(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + tmpchangelog) )
			File.delete(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + tmpchangelog)
		end
	        puts "更新完畢本機本次查詢清單種類的CHANGELOG."
	end 
	# Generate CHANGELOG-<QUERTYPE>.txt

end 

def generate_new_file_for_updated_targets( queryType, remoteItemsHash, changeSignCollectionHash)

	# Generate new file for updated targets
	if( false == changeSignCollectionHash.empty? )
		puts "開始更新本機查詢清單"
		if( queryType == 1 ) # 1 means vegetable
			originFile = FILE_OF_VEGETABLE 
			changeToOldName = FILE_PREFIX_OF_OLD_VEGETABLE + Date.today.to_s + FILE_SUFFIX_OF_OLD_VEGETABLE 
		elsif( queryType == 2 ) # 2 means fruit
			originFile = FILE_OF_FRUIT 
			changeToOldName = FILE_PREFIX_OF_OLD_FRUIT + Date.today.to_s + FILE_SUFFIX_OF_OLD_FRUIT
		elsif( queryType == 3 ) # 3 means flowers
			originFile = FILE_OF_FLOWERS 
			changeToOldName = FILE_PREFIX_OF_OLD_FLOWERS + Date.today.to_s + FILE_SUFFIX_OF_OLD_FLOWERS 
		end
	        File.rename(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + originFile, PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + changeToOldName)

		keyArrayOfRemoteItems = Array.new(remoteItemsHash.keys).sort!
		File.open(PATH_OF_DATA_FORMAT_AT_EVERY_SITE_DIRECTORY + originFile,"w"){ |f|
			keyArrayOfRemoteItems.each{ |element|
				valueArrayOfRemoteItems = remoteItemsHash[element]
				writeString = ( nil == writeString)? String.new() : writeString.clear
				valueArrayOfRemoteItems.each{ |value|
					writeString += (value + "\t")
				}
				f.puts("#{writeString}#{element}")
			}	
			 
		}
		puts "更新完畢本機查詢清單"
	end 
	# Generate new file for updated targets
end 

def generate_newer_hash_of_item_list(remoteItemsHash)

	puts "開始產生適合遠距查詢的新清單"
	# Generate a newer hash of items lists and return it.
	updatedItemsHash = Hash.new
	remoteItemsHash.each_key{ |key|
		newerValueString = (nil == newerValueString)? String.new() : newerValueString.clear

		valueArray = remoteItemsHash[key]
		valueArray.each{|value|
			newerValueString += (value + " ")
		}
		updatedItemsHash[key] = newerValueString
	}

	puts "結束產生適合遠距查詢的新清單"
	return updatedItemsHash
	# Generate a newer hash of items lists and return it.
end 

def update_item_list(queryType, localItemsHash, remoteItemsHash)
# compare item lists between local file and remote website, and then do three things:
# 1) generate newer a hash of item lists and return it.
# 2) generate a changelog file for item list of the query type, which this time we use. Format of the file name is CHANGELOG-<QUERYTYPE>.txt
# 3) copy old item list of query type of this time to <OLDNAME>-OLD-<DATE>.txt . And generate new file for new list of query type, and please use names coded in header of this script.
	changeSignCollectionHash = Hash.new

	check_difference_between_localItem_and_remoteItem( queryType, localItemsHash, remoteItemsHash, changeSignCollectionHash)
	generate_changelog_for_item_lists( queryType, localItemsHash, remoteItemsHash, changeSignCollectionHash)

	generate_new_file_for_updated_targets( queryType, remoteItemsHash, changeSignCollectionHash)

	changeSignCollectionHash.clear
	updatedItemsHash = generate_newer_hash_of_item_list(remoteItemsHash)
	return updatedItemsHash 
end

def crawl_data(query_type, q_merchandize, q_time, infoToPrint)
	if query_type == 1 # vegetable
		#q_addr = "http://amis.afa.gov.tw/v-asp/v101r.asp" #210.69.71.16
		q_addr = ADDRESS_OF_VEGETABLE_QUERY 
		#q_addr = "amis.afa.gov.tw/veg/VegProdDayTransInfo.aspx"
	elsif query_type == 2 # fruit
		#q_addr = "http://amis.afa.gov.tw/t-asp/v103r.asp" #210.69.71.16
		q_addr = ADDRESS_OF_FRUIT_QUERY 
		#q_addr = "amis.afa.gov.tw/fruit/FruitProdDayTransInfo.aspx"
	elsif query_type == 3 # flowers
		#q_addr = "http://amis.afa.gov.tw/l-asp/v101r.asp" #210.69.71.16
		q_addr = ADDRESS_OF_FLOWERS_QUERY 
		#q_addr = "210.69.71.171/flower/FlowerProdDayTransInfo.aspx"
	else
		puts "Error: unknown query_type at method: crawl_data"
		exit
	end

	queryResultStringArray = Array.new

	headless = Headless.new
	headless.start
	# for firefox 46 and earlier version
	#browser = Watir::Browser.start q_addr if( (!browser) || !(browser.exist?))
	
	# just for a trial when debugging
	#browser = Watir::Browser.new(:firefox, marionette: true ) if( (!browser) || !(browser.exist?))
	#browser.goto(q_addr)

	netExceptionCount = 0
	# For firefox 48 and onward version
	begin 
		browser = Watir::Browser.new(:firefox) if ( (!browser) || !(browser.exist?) )
		browser.goto(q_addr)
	rescue Net::ReadTimeout => e
		puts "Suffering congestion. It seems our network or target site connections busy now. We will retry."
		netExceptionCount += 1
		retry unless netExceptionCount > RETRY_TIME 
		abort e.message 
	end 

	startDate = infoToPrint[0]
	endDate = infoToPrint[1]
	currentDayCount = infoToPrint[2]
	totalDaysWillBeProcessing = infoToPrint[3]
	currentYear = infoToPrint[4]
	currentMonth = infoToPrint[5]
	currentDay = infoToPrint[6]
	totalMpNoNumber = infoToPrint[7]
	currentMpNoCount = 0

	q_merchandize.each_pair{ |key, value|
		staleElementReferenceExceptionCount = 0
		unknownObjectExceptionCount = 0
		unknownErrorCount = 0
		timeOutExceptionCount = 0
        	netExceptionCount = 0	

		puts "本次查詢範圍是民國 "+(startDate.year - 1911).to_s+" 年 "+(startDate.month).to_s+" 月 "+(startDate.day).to_s+" 號 至 "+(endDate.year - 1911).to_s+" 年 "+(endDate.month).to_s+" 月 "+(endDate.day).to_s+" 號."
		puts "現在處理的是第 "+currentDayCount.to_s+"/"+totalDaysWillBeProcessing.to_s+" 天"	
		puts "現在處理的是民國 "+currentYear.to_s+" 年 "+currentMonth.to_s+" 月 "+currentDay.to_s+" 號的第 "+(currentMpNoCount + 1).to_s+"/"+totalMpNoNumber.to_s+" 個"
		begin 
			browser.radio(id: 'ctl00_contentPlaceHolder_ucSolarLunar_radlSolarLunar_0', value: 'S').wait_until(&:present?).set # Setting date mode for solar or lunar
		rescue Selenium::WebDriver::Error::UnknownError => e1
			$stderr.puts "There is no radio element to set. We will wait 3 seconds to set."

			puts "There is no radio element to set. We will wait 3 seconds to set."
			sleep 3
			unknownErrorCount += 1
			retry unless unknownErrorCount > LIMIT_OF_RETRY_OF_UNKNOWN_ERROR 
			abort e1.message 
		end 
		browser.execute_script('window.document.getElementById("ctl00_contentPlaceHolder_txtSTransDate").value="' + q_time[0] + '/' + q_time[1] + '/' + q_time[2] + '";') # Setting start date for query
		browser.execute_script('window.document.getElementById("ctl00_contentPlaceHolder_txtETransDate").value="' + q_time[0] + '/' + q_time[1] + '/' + q_time[2] + '";') # Setting end date for query
		browser.execute_script('window.document.getElementById("ctl00_contentPlaceHolder_txtMarket").value="全部市場";') # Setting value of market name
		browser.execute_script('window.document.getElementById("ctl00_contentPlaceHolder_hfldMarketNo").value="ALL";') # Setting value of market number
		browser.execute_script('window.document.getElementById("ctl00_contentPlaceHolder_txtProduct").title="' + key + ' ' + value + '";') # Setting product code and name for examining query
		browser.execute_script('window.document.getElementById("ctl00_contentPlaceHolder_txtProduct").value="' + key + ' ' + value + '";') # Setting value of product code and name for posting a request 
		browser.execute_script('window.document.getElementById("ctl00_contentPlaceHolder_hfldProductNo").value="' + key + '";') # Setting value of product number for posting a request

		if( query_type == 1 || query_type == 3) # 1 means vegetable, and 3 means flowers
			# vegetable and flowers 用大項產品的方式查詢
			browser.execute_script('window.document.getElementById("ctl00_contentPlaceHolder_hfldProductType").value="B";') # Setting value of product type for posting a request
		elsif( query_type == 2) # 2 means fruit.
			# fruit 用細項產品的方式查詢
			browser.execute_script('window.document.getElementById("ctl00_contentPlaceHolder_hfldProductType").value="S";') # Setting value of product type for posting a request
		end 
		
		# The reason I preserve the following code is to remind everybody that set() won't work for all hidden inputs if DOM tree isn't at ready state.
		#browser.text_field(id: 'ctl00_contentPlaceHolder_txtSTransDate').set('105/05/17')
		#browser.text_field(id: 'ctl00_contentPlaceHolder_txtETransDate').set('105/05/17')
		#browser.textarea(id: 'ctl00_contentPlaceHolder_txtMarket').wait_until_present
		#browser.hidden(id: 'ctl00_contentPlaceHolder_hfldMarketNo').set(value: 'ALL') #if browser.hidden(id: 'ctl00_contentPlaceHolder_hfldMarketNo').exists?
		#browser.hidden(id: 'ctl00_contentPlaceHolder_hfldProductNo').set(value: 'FA0') #if browser.hidden(id: 'ctl00_contentPlaceHolder_hfldProductNo').exists?
		#browser.hidden(id: 'ctl00_contentPlaceHolder_hfldProductType').set(value: 'S') #if browser.hidden(id: 'ctl00_contentPlaceHolder_hfldProductType').exists? 
		# The reason I preserve the above code is to remind everybody that set() won't work for all hidden inputs if DOM tree isn't at ready state.

		begin 
			browser.button(id: 'ctl00_contentPlaceHolder_btnQuery', name: 'ctl00$contentPlaceHolder$btnQuery').wait_until(&:present?) # waiting submit button ready to click
			browser.button(id: 'ctl00_contentPlaceHolder_btnQuery', name: 'ctl00$contentPlaceHolder$btnQuery').click # click the submit button
		rescue Selenium::WebDriver::Error::UnknownError => e1 
			$stderr.puts "There are no button to click. We will wait 3 seconds to retry."
			puts "There are no button to click. We will wait 3 seconds to retry."
			sleep 3
			unknownErrorCount += 1
			retry unless unknownErrorCount > LIMIT_OF_RETRY_OF_UNKNOWN_ERROR 
			abort e1.message 

		end 

=begin
		begin 
			browser.image(alt: 'Process').wait_while_present # waiting when image of ajax procedure presenting
		rescue Watir::Wait::TimeoutError
			puts "Timeout for image processing of ajax. We will retry."
			retry
		end 
=end
		begin
			browser.image(alt: 'Process').wait_while(&:present?) # waiting when image of ajax procedure presenting
=begin			
			# When data of some fields don't exist, it must be check whether an alert window of notices exists or not. If it exists, close it and show notices in the terminal.
			if ( browser.alert.exists? ) 
				# check whether the notice of finding no data exists or not.
				browser.alert.ok
				#browser.alert.close
				raise AlertForNoDataException, "Found no data for " + key + " " + value
			else
				# If there are data for query conditions.

				#browser.div(id: 'ctl00_contentPlaceHolder_panel').wait_until(&:present?) # wait for ajax response
				# change the write convention from supporting firefox 46 and earlier version to firefox 48 and onward ones.
				if( browser.div(id: 'ctl00_contentPlaceHolder_panel').exists? == false  ) # wait and check values for ajax response
					browser.div(id: 'ctl00_contentPlaceHolder_panel').wait_until(&:present?) # wait for ajax response
				end 

				Watir::Wait.until{
					#browser.span(id: 'ctl00_contentPlaceHolder_lblProducts').text.include?(key + " " + value) # 因為蔬菜類的FA0 其他花類，網頁上的「其他花類」後面會有多一個空白符號或其他符號，導致無法如原本預期的運作，所以改成只偵測是否有產品代碼
					browser.span(id: 'ctl00_contentPlaceHolder_lblProducts').text.include?(key)# + " " + value)
				}

				# Don't add check statement for existence of browser.div(id: 'ctl00_contentPlaceHolder_panel').tables.[](2) because it will skip execution of the below line when it exists. It doesn't contain information when the moment it just starts to exist.
				browser.div(id: 'ctl00_contentPlaceHolder_panel').tables.[](2).wait_until(&:present?) # wait for ajax response is ready to present 

			end 
=end 
			# If there are data for query conditions.

			#browser.div(id: 'ctl00_contentPlaceHolder_panel').wait_until(&:present?) # wait for ajax response
			# change the write convention from supporting firefox 46 and earlier version to firefox 48 and onward ones.
			if( browser.div(id: 'ctl00_contentPlaceHolder_panel').exists? == false  ) # wait and check values for ajax response
			    browser.div(id: 'ctl00_contentPlaceHolder_panel').wait_until(&:present?) # wait for ajax response
			end 

			Watir::Wait.until{
			    #browser.span(id: 'ctl00_contentPlaceHolder_lblProducts').text.include?(key + " " + value) # 因為蔬菜類的FA0 其他花類，網頁上的「其他花類」後面會有多一個空白符號或其他符號，導致無法如原本預期的運作，所以改成只偵測是否有產品代碼
			    browser.span(id: 'ctl00_contentPlaceHolder_lblProducts').text.include?(key)# + " " + value)
			}

			# Don't add check statement for existence of browser.div(id: 'ctl00_contentPlaceHolder_panel').tables.[](2) because it will skip execution of the below line when it exists. It doesn't contain information when the moment it just starts to exist.
			browser.div(id: 'ctl00_contentPlaceHolder_panel').tables.[](2).wait_until(&:present?) # wait for ajax response is ready to present 
                rescue Selenium::WebDriver::Error::UnexpectedAlertOpenError => e1
			browser.alert.ok
                        puts "Found no data for " + key + " " + value
			#browser.alert.close
			#raise AlertForNoDataException, "Found no data for " + key + " " + value

		rescue Selenium::WebDriver::Error::StaleElementReferenceError => e1
			puts "Encounter Selenium::WebDriver::Error::StaleElementReferenceError. We will reclick the submit button to try again"
			browser.button(id: 'ctl00_contentPlaceHolder_btnQuery', name: 'ctl00$contentPlaceHolder$btnQuery').click # reclick the submit button
			staleElementReferenceExceptionCount += 1
			retry unless staleElementReferenceExceptionCount > LIMIT_OF_RETRY_OF_STALE_ELEMENT_REFERENCE_ERROR
			abort e1.message 

		rescue Selenium::WebDriver::Error::UnknownError => e1 
			# We add this exception handling because watir-6.0 doesn't compromise Selenium::WebDriver::Error::UnknownError with Watir::Exception::UnknownObjectException. 
			# In the version of supporting firefox 46 and olderones of this program and gem watir-webdriver 0.9.1, Watir::Exception::UnknowObjectException is the one and only used for handling the situation of finding no specified elements on webpages.
			# But when using watir-6.0 and its latest version,  Watir::Exception::UnknownObjectException and Selenium::WebDriver::Error::UnknownError are used for handling the situation of finding no assigned elements in webpages. Remarks, Selenium::WebDriver::Error::UnknownError can also be used other ones according information I get from Internet.
			puts "We haven't found the assigned element in the webpage, so we will recheck."
			unknownErrorCount += 1
			retry unless unknownErrorCount > LIMIT_OF_RETRY_OF_UNKNOWN_ERROR 
			abort e1.message 

		rescue Watir::Exception::UnknownObjectException => e1
			puts "Watir::Exception::UnknownObjectException raised because we don't find dedicate data for some fields. We will retry."
			unknownObjectExceptionCount += 1
			retry unless unknownObjectExceptionCount > LIMIT_OF_RETRY_OF_UNKNOWN_OBJECT_ERROR 
			abort e1.message

		rescue Watir::Wait::TimeoutError => e1
			puts "Timeout for " + key + " " + value + ". We will retry."
			timeOutExceptionCount += 1
			retry unless timeOutExceptionCount > LIMIT_OF_RETRY_OF_TIMEOUT_ERROR 
			abort e1.message 
=begin
		rescue AlertForNoDataException => e
			puts e.message
=end                  
		rescue Errno::ECONNREFUSED => e1
			$stderr.puts e1.message
			netExceptionCount += 1
			retry unless netExceptionCount > LIMIT_OF_RETRY_OF_CONNECT_REFUSED_ERROR 
			abort e1.message 
		else
			# If there is no *exception occurred, it will execute below code.

			response = [key, value, browser.div(id: 'ctl00_contentPlaceHolder_panel').tables.[](2).text] # store ajax response into variable.
			puts "response: "+response.to_s #debug

			queryResultStringArray << response

		end
		puts "Behave like human."
	        sleep 7	# sleep 7 seconds
		currentMpNoCount += 1
	}
	browser.close
	headless.destroy
	return queryResultStringArray
end

def filter_data(queryType, rawDataArray, infoToPrint)

	currentYear = infoToPrint[0]
	currentMonth = infoToPrint[1]
	currentDay = infoToPrint[2]

	filteredDataArray = Array.new
	if queryType == 1 # 1 means vegetable
		rawDataArray.each{ |element|
			element[2] = element[2].gsub!("市場 產品 上價 中價 下價 平均價\n(元/公斤) 跟前一\n交易日\n比較% 交易量\n(公斤) 跟前一\n交易日\n比較%\n","").gsub(",","")
			#element[2] = element[2].gsub("\n"," ") 不需要這麼早處理, 因為還有正負號的問題
			element[2] = element[2].gsub(/(?<=[\n])[\d]{3}[ ]/u,"") # 刪除地區市場代碼
			element[2] = element[2].gsub(/(?<=[[\n][\u3000\u4E00-\u9FFF]+[ ]([[a-zA-Z0-9]{2}][ ][\u4E00-\u9FFF]+)?[[[[\d]+[\.]?[\d]*][ ]]{4}]][\-\+])[ ](?=([\-]?[\d]+[\.]?[\d]*)[ ]((?![\+\-][ ]?[\d]+\.?\d*)|([\d]+[\.]?[\d]*[ ](([\-\+]?[ ]?[\d]+[\.]?[\d]*)|([\-\+]?[\*]+))))(\n|$))/u,"")#2016/05/25 written: 為了面對1996/04/01的LG芹菜，在鳳山區青梗的交易量增減%欄位出現+***這樣的內容。也有面對當產品名稱欄位沒有資料時，也能正確選出平均價與前一交易日增減%欄位正負號與數字之間的空白。本行用途只是刪掉平均價與前一交易日增減％欄位 正負號與數字之間的空白。 #20160730 add: 因為桃園改成「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
			element[2] = element[2].gsub(/(?<=[[\+\-]?])[ ](?=[\d]+[\.]?[\d]*(\n|$))/u,"") #刪掉交易量與前一交易日增減％欄位 正負號與數字之間的空白
			element[2] = element[2].gsub(/[\n ]+/u,",") # 用逗號取代有出現換行符號或空白符號的地方
			#element[2] = element[2].gsub(/[,]{2,}/u,",") # 用一個逗號取代連續二個以上逗號的地方
			puts "element[2]: "+ element[2] #debug 印出乾淨的各市場交易價格
			searchArray = element[2].partition(/(?<=小計,)(([\-],)|([\-]?[\d]+[\.]?[\d]*,)){2}(?=[\u3000\u4E00-\u9FFF]{2,3})/u) # 選出總交易量和總平均價的資料 # 加入 [\-]?，因為2016/06/30 有品項的小計後面欄位出現 - , #20160901: 因為LL1茼蒿 小計出現平均價是'-'的資料，所以改寫原本的正規表示式  #20161016 add: 因為20161015 MG巴西蘑菇出現第一筆資料是「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
			arrayOfTotalTradeQuantityAndAveragePrice = searchArray[1].split(",")
			element[1] = element[1].strip # remove whitespaces after the name
=begin
			#debug block
			puts "searchArray: #{searchArray.to_s}" #debug
			puts "element[0]: #{element[0]}" #debug
			puts "element[1]: #{element[1]}" #debug
			puts "arrayOfTotalTradeQuantityAndAveragePrice[0]: #{arrayOfTotalTradeQuantityAndAveragePrice[0]}" #debug
			puts "arrayOfTotalTradeQuantityAndAveragePrice[1]: #{arrayOfTotalTradeQuantityAndAveragePrice[1]}" #debug
=end
			overviewData = "交易日期:" + currentYear.to_s + "年" + currentMonth.to_s + "月" + currentDay.to_s + "日,產品名稱:" + element[0] + element[1] + ",總交易量:" + arrayOfTotalTradeQuantityAndAveragePrice[1] + "公斤,總平均價:" + (arrayOfTotalTradeQuantityAndAveragePrice[0] == '-' ? 0.to_s : arrayOfTotalTradeQuantityAndAveragePrice[0]) + "元/公斤" # 20160901: 因為LL1茼蒿 小記出現平均價是'-'的資料，所以加入判斷式自行轉換成0
			parseArray = searchArray[2].gsub(/(?<=[\u3000\u4E00-\u9FFF]),([a-zA-Z0-9]{1,4}),[\u3000\u4E00-\u9FFF]+(?=,(([\(\)\<\>\u3000\u4E00-\u9FFF])|([\d]+[\.]?[\d]*)))/u,"").split(",") # 去除產品代碼與產品名稱。最後再用逗號分離每個欄位資料 #20160730 add: 因為桃園改成「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
			puts "parseArray: "+parseArray.to_s #debug

			# insert empty string for processing type.
			locationCount = 0
			tableSize = parseArray.size
			while locationCount < tableSize
				if tableSize == 10
					#do nothing
					puts "parseArray fit size 10 and its content: " + parseArray.to_s #debug
					break
				elsif tableSize < 10
					nextOnePosition = locationCount + 1 
					nextTwoPosition = locationCount + 2
					if( nil != (parseArray[nextOnePosition] =~ /((\"\")|[\u3000\u4E00-\u9FFF]+)/u) )
						if( nil != (parseArray[nextTwoPosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ))
							parseArray.insert(nextTwoPosition,"\"\"")
							tableSize += 1
						#else
							#else situation shouldn't happen
						end 
						
					elsif( nil != (parseArray[nextOnePosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ) )
						if( nil != (parseArray[nextTwoPosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ))
							parseArray.insert(nextOnePosition,"\"\"")
							parseArray.insert(nextTwoPosition,"\"\"")
							tableSize += 2
						#else
							#else situation shouldn't happen
						end 
					end 
					break
				elsif tableSize > 10

					if locationCount % 10 == 0
						precedingLocation = locationCount - 1
						nextOnePosition = locationCount + 1 
						nextTwoPosition = locationCount + 2

						if( nil != (parseArray[locationCount] =~ /[\u3000\u4E00-\u9FFF]+/u) )
							if ( nil != (parseArray[precedingLocation] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u))

								if( nil != (parseArray[nextOnePosition] =~ /((\"\")|[\u3000\u4E00-\u9FFF]+)/u) )
									if( nil != (parseArray[nextTwoPosition] =~ /((\"\")|[\u3000\u4E00-\u9FFF]+)/u) )
										locationCount += 10
									elsif( nil != (parseArray[nextTwoPosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ))
										parseArray.insert(nextTwoPosition,"\"\"")
										tableSize += 1
										locationCount += 10
									end

								elsif( nil != (parseArray[nextOnePosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ) )
									if( nil != (parseArray[nextTwoPosition] =~ /((\"\")|[\u3000\u4E00-\u9FFF]+)/u )) 
										swapString = (swapString.nil?)? String.new(parseArray[nextOnePosition]) : parseArray[nextOnePosition].clone
										parseArray[nextOnePosition] = parseArray[nextTwoPosition].clone()
										parseArray[nextTwoPosition] = swapString.clone()
										parseArray.insert(nextTwoPosition, "\"\"")
										tableSize += 1
										locationCount += 10
									elsif( nil != (parseArray[nextTwoPosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ))
										parseArray.insert(nextOnePosition, "\"\"" )
										parseArray.insert(nextTwoPosition, "\"\"" )
										tableSize += 2
										locationCount += 10
									end
								end
							elsif( nil != (parseArray[precedingLocation] =~ /((\"\")|[\u3000\u4E00-\u9FFF]+)/u ) )	
								# locationCount 位置可能是品種或是處理別
								# 在這裡不應該發生，如果發生，一定有缺資料。
								puts "資料有缺漏，請檢查原始網頁內容。" 
								if( nil != (parseArray[nextOnePosition] =~ /((\"\")|[\u3000\u4E00-\u9FFF]+)/u ))

									locationCount += 9
								elsif( nil != (parseArray[nextOnePosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u) )
									locationCount += 8
								end

							end 
						elsif( nil != (parseArray[locationCount] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u))
							puts "資料有缺漏，請檢查原始網頁內容。" 

							locationCount += 1
						end 

					else
						puts "資料不如預期是10的倍數，資料可能有多有少。必須檢查原始網頁內容。"
						locationCount += (10 - (locationCount % 10))
					end 
				end 

			end 


			detailData = "市場名稱,品種名稱,處理別,上價,中價,下價,平均價,增減%,交易量,增減%,"
			countParseArray = 0
			sizeParseArray = parseArray.size 
			while countParseArray < (sizeParseArray - 1)
				detailData << (parseArray[countParseArray] + ",")
				countParseArray += 1
			end 
			detailData << parseArray[countParseArray]

			filteredDataArray << [overviewData, detailData]
		}
	elsif queryType == 2 # means fruit

		rawDataArray.each{ |element|
			element[2] = element[2].gsub!("市場 產品 上價 中價 下價 平均價\n(元/公斤) 跟前一\n交易日\n比較% 交易量\n(公斤) 跟前一\n交易日\n比較%\n","").gsub(",","")
			#element[2] = element[2].gsub("\n"," ") 不需要這麼早處理, 因為還有正負號的問題
			element[2] = element[2].gsub(/(?<=[\n])[\d]{3}[ ]/u,"") # 刪除地區市場代碼
			element[2] = element[2].gsub(/(?<=[[\n][\u3000\u4E00-\u9FFF]+[ ]([[a-zA-Z0-9]{2}][ ][0-9]*[\(\)\<\>\u3100-\u312F\u4E00-\u9FFF]+)?[[[[\d]+[\.]?[\d]*][ ]]{4}]][\-\+])[ ](?=([\-]?[\d]+[\.]?[\d]*)[ ]((?![\+\-][ ]?[\d]+\.?\d*)|([\d]+[\.]?[\d]*[ ](([\-\+]?[ ]?[\d]+[\.]?[\d]*)|([\-\+]?[\*]+))))(\n|$))/u,"")#2016/05/25 written: 為了面對1996/04/01的LG芹菜，在鳳山區青梗的交易量增減%欄位出現+***這樣的內容。也有面對當產品名稱欄位沒有資料時，也能正確選出平均價與前一交易日增減%欄位正負號與數字之間的空白。本行用途只是刪掉平均價與前一交易日增減％欄位 正負號與數字之間的空白。20160607 add: 為了解決71 小番茄 ㄧ般和G1 蛋黃果 (仙桃)和G2 鳳眼果(乒乓)和O8 梨 4029梨的品種與處理別名稱，所以正規表示式加上注音符號,數字,左右括號和大小於的符號的範圍 #20160730 add: 因為桃園改成「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
			element[2] = element[2].gsub(/(?<=[[\+\-]?])[ ](?=[\d]+[\.]?[\d]*(\n|$))/u,"") #刪掉交易量與前一交易日增減％欄位 正負號與數字之間的空白
			element[2] = element[2].gsub(/[\n ]+/u,",") # 用逗號取代有出現換行符號或空白符號的地方
			#element[2] = element[2].gsub(/[,]{2,}/u,",") # 用一個逗號取代連續二個以上逗號的地方
			puts "element[2]: "+ element[2] #debug 印出乾淨的各市場交易價格
			searchArray = element[2].partition(/(?<=小計,)([\d]+[\.]?[\d]*,){2}(?=[\u3000\u4E00-\u9FFF]{2,3})/u) # 選出總交易量和總平均價的資料 #20160730 add: 因為桃園改成「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
			arrayOfTotalTradeQuantityAndAveragePrice = searchArray[1].split(",")
			overviewData = "交易日期:" + currentYear.to_s + "年" + currentMonth.to_s + "月" + currentDay.to_s + "日,產品名稱:" + element[0]
		        arrayOfItemNameAndKindAndProcessingType = element[1].split(" ")
			if arrayOfItemNameAndKindAndProcessingType.size == 1
				overviewData += (arrayOfItemNameAndKindAndProcessingType[0] + ",\"\",\"\"")
			elsif arrayOfItemNameAndKindAndProcessingType.size == 2
				overviewData += (arrayOfItemNameAndKindAndProcessingType[0] + "," + arrayOfItemNameAndKindAndProcessingType[1] + ",\"\"" )
			end 
			overviewData += (",總交易量:" + arrayOfTotalTradeQuantityAndAveragePrice[1] + "公斤,總平均價:" + arrayOfTotalTradeQuantityAndAveragePrice[0] + "元/公斤")
			parseArray = searchArray[2].gsub(/(?<=[\u3000\u4E00-\u9FFF]),([a-zA-Z0-9]{1,4}),([0-9]*[\(\)\<\>\u3000\u3100-\u312F\u4E00-\u9FFF])+(,[0-9]*[\(\)\<\>\u3000\u3100-\u312F\u4E00-\u9FFF]+)?(?=,([\d]+[\.]?[\d]*))/u,"").split(",") # 去除產品代碼與產品名稱與品種與處理別。最後再用逗號分離每個欄位資料. 20160607 add: 為了解決71 小番茄 ㄧ般和G1 蛋黃果 (仙桃)和G2 鳳眼果(乒乓)和O8 梨 4029梨的品種與處理別名稱，所以正規表示式加上注音符號,數字,左右括號和大小於的符號的範圍 #20160730 add: 因為桃園改成「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
			puts "parseArray: "+parseArray.to_s #debug

			# insert empty string for processing type.
			locationCount = 0
			tableSize = parseArray.size
			while locationCount < tableSize
				if tableSize == 9
					#do nothing
					puts "parseArray fit size 9 and its content: " + parseArray.to_s #debug
					break
				elsif tableSize < 9
					nextOnePosition = locationCount + 1 
					if( nil != (parseArray[nextOnePosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ) )
						parseArray.insert(nextOnePosition,"\"\"")
						tableSize += 1
					end 
					break
				elsif tableSize > 9

					if locationCount % 9 == 0
						precedingLocation = locationCount - 1
						nextOnePosition = locationCount + 1 
						nextTwoPosition = locationCount + 2

						if( nil != (parseArray[locationCount] =~ /[0-9]*[\(\)\<\>\u3000\u3100-\u312F\u4E00-\u9FFF]+/u) )# 20160607 add: 為了解決71 小番茄 ㄧ般和G1 蛋黃果 (仙桃)和G2 鳳眼果(乒乓)和O8 梨 4029梨的品種與處理別名稱，所以正規表示式加上注音符號,數字,左右括號和大小於的符號的範圍 ##20160730 add: 因為桃園改成「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
							if ( nil != (parseArray[precedingLocation] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u))

								if( nil != (parseArray[nextOnePosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ) )
									parseArray.insert(nextOnePosition, "\"\"")
									tableSize += 1
									locationCount += 9
								end

							end 
						elsif( nil != (parseArray[locationCount] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u))
							puts "資料有缺漏，請檢查原始網頁內容。" 

							locationCount += 1 # +1 僅代表儘速離開這個迴圈。盡快跳過這列，繼續處理下一筆。
						end 

					else
						puts "資料不如預期是9的倍數，資料可能有多有少。必須檢查原始網頁內容。"
						locationCount += (9 - (locationCount % 9))
					end 
				end 

			end 


			detailData = "市場名稱,天氣,上價,中價,下價,平均價,增減%,交易量,增減%,"
			countParseArray = 0
			sizeParseArray = parseArray.size 
			while countParseArray < (sizeParseArray - 1)
				detailData << (parseArray[countParseArray] + ",")
				countParseArray += 1
			end 
			detailData << parseArray[countParseArray]

			filteredDataArray << [overviewData, detailData]
		}
	elsif queryType == 3 # means flowers
		rawDataArray.each{ |element|
			#puts "element[2]: "+ element[2] #debug
			element[2] = element[2].gsub!("市場 產品 最高價 上價 中價 下價 平均價 增減% 交易量 增減% 殘貨量\n","").gsub(",","")
			element[2] = element[2].gsub(/(?<=[\n])[\d]{3}[ ]/u,"") # 刪除地區市場代碼
			element[2] = element[2].gsub(/(?<=[[\n][\u3000\u4E00-\u9FFF]+[ ]([[a-zA-Z0-9]{5}][ ][\u3000\u4E00-\u9FFF]+)?[[[[\d]+[\.]?[\d]*][ ]]{5}]][\-\+])[ ](?=([\-]?[\d]+[\.]?[\d]*)[ ]((?![\+\-][ ]?[\d]+\.?\d*)|([\d]+[\.]?[\d]*[ ](([\-\+]?[ ]?[\d]+[\.]?[\d]*)|([\-\+]?[\*]+)){2}))(\n|$))/u,"")#2016/05/26 written: 為了面對在花卉類出現蔬菜類1996/04/01的LG芹菜，在鳳山區青梗的交易量增減%欄位出現+***這樣的內容。也有面對當產品名稱欄位沒有資料時，也能正確選出平均價與增減%欄位正負號與數字之間的空白。本行用途只是刪掉平均價與前一交易日增減％欄位 正負號與數字之間的空白。 #20160730 add: 因為桃園改成「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
			element[2] = element[2].gsub(/(?<=[[\+\-]?])[ ](?=[\d]+[\.]?[\d]*[ ][\d]+[\.]?[\d]*(\n|$))/u,"") #刪掉交易量與增減％欄位 正負號與數字之間的空白
			element[2] = element[2].gsub(/[\n ]+/u,",") # 用逗號取代有出現換行符號或空白符號的地方
			#element[2] = element[2].gsub(/[,]{2,}/u,",") # 用一個逗號取代連續二個以上逗號的地方
			#puts "element[2]: "+ element[2] #debug
			searchArray = element[2].partition(/(?<=小計,)([\d]+[\.]?[\d]*,){3}(?=[\u3000\u4E00-\u9FFF]{4})/u) # 選出總交易量和總平均價和殘貨量的資料 #20160730 add: 因為桃園改成「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
			# puts "searchArray: " + searchArray.to_s #debug
			arrayOfTotalTradeQuantityAndAveragePriceAndRestQuantity = searchArray[1].split(",")
			element[1] = element[1].rstrip # remove whitespaces after the name.
			overviewData = "交易日期:" + currentYear.to_s + "年" + currentMonth.to_s + "月" + currentDay.to_s + "日,總平均價:" +arrayOfTotalTradeQuantityAndAveragePriceAndRestQuantity[0]  + "元/把,總交易量:" + arrayOfTotalTradeQuantityAndAveragePriceAndRestQuantity[1] + "公斤,總殘貨量:" + arrayOfTotalTradeQuantityAndAveragePriceAndRestQuantity[2] + "把,產品名稱:" + element[0] + element[1]
			parseArray = searchArray[2].gsub(/(?<=[\u3000\u4E00-\u9FFF]),([a-zA-Z0-9]{5}),[\u3000\u4E00-\u9FFF\(\)\<\>]+(?=,(([\(\)\<\>\u4E00-\u9FFF])|([\d]+[\.]?[\d]*)))/u,"").split(",") # 去除產品代碼與產品名稱。最後再用逗號分離每個欄位資料. 花卉類當中有1)IY087 進口樺木(假葉), 2)FH185 嘉蘭<火焰百合>, 這兩種資料，所以加上\(\)\<\> 。 #20160730 add: 因為桃園改成「桃　農」交易市場，所以RE新增全形空白的unicode: \u3000
			puts "parseArray: "+parseArray.to_s #debug

				
			# insert empty string for processing type.
			locationCount = 0
			tableSize = parseArray.size
			while locationCount < tableSize
				if tableSize == 11
					#do nothing
					puts "parseArray fit size 11 and its content: " + parseArray.to_s #debug
					break
				elsif tableSize < 11
					nextOnePosition = locationCount + 1 
					# if( nil != (parseArray[nextOnePosition] =~ /((\"\")|[\(\)\<\>\u4E00-\u9FFF]+)/u) ) 
					# This situation shouldn't happen.
					# end
						
					if( nil != (parseArray[nextOnePosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ) )
						parseArray.insert(nextOnePosition,"\"\"")
						tableSize += 1
					#else situation shouldn't happen
					end 
					break
				elsif tableSize > 11

					if locationCount % 11 == 0
						precedingLocation = locationCount - 1
						nextOnePosition = locationCount + 1 

						if( nil != (parseArray[locationCount] =~ /[\u3000\u4E00-\u9FFF]+/u) )
							if ( nil != (parseArray[precedingLocation] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u))

								if( nil != (parseArray[nextOnePosition] =~ /((\"\")|[\(\)\<\>\u3000\u4E00-\u9FFF]+)/u) )
									locationCount += 11

								elsif( nil != (parseArray[nextOnePosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u ) )
									parseArray.insert(nextOnePosition, "\"\"" )
									tableSize += 1
									locationCount += 11
								end
							elsif( nil != (parseArray[precedingLocation] =~ /((\"\")|[\u3000\u4E00-\u9FFF]+)/u ) )	
								# locationCount 位置可能是產品名稱
								# 在這裡不應該發生，如果發生，一定有缺資料。
								puts "資料有缺漏，請檢查原始網頁內容。" 

								if( nil != (parseArray[nextOnePosition] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u) )
									locationCount += 10
								end

							end 
						elsif( nil != (parseArray[locationCount] =~ /([\-]|[\+\-]?[\d]+[\.]?[\d]*|[\+\-]?[\*]+)/u))
							puts "資料有缺漏，請檢查原始網頁內容。" 

							locationCount += 1
						end 

					else
						puts "資料不如預期是11的倍數，資料可能有多有少。必須檢查原始網頁內容。"
						locationCount += (11 - (locationCount % 11))
					end 
				end 

			end 


			detailData = "市場名稱,產品名稱,最高價,上價,中價,下價,平均價,增減%,交易量,增減%,殘貨量,"
			countParseArray = 0
			sizeParseArray = parseArray.size 
			while countParseArray < (sizeParseArray - 1)
				detailData << (parseArray[countParseArray] + ",")
				countParseArray += 1
			end 
			detailData << parseArray[countParseArray]

			filteredDataArray << [overviewData, detailData]
		}
	end

	return filteredDataArray	
end 

=begin
def crawl_data_and_filter(q_time, q_machanize, query_type)

	if query_type == 1 # vegetable
		#q_addr = "http://210.69.71.171/veg/VegProdDayTransInfo.aspx"
		q_addr = "amis.afa.gov.tw/veg/VegProdDayTransInfo.aspx"
	elsif query_type == 2 # fruit
		q_addr = "http://amis.afa.gov.tw/t-asp/v103r.asp"
	elsif query_type == 3 # flowers
		q_addr = "http://amis.afa.gov.tw/l-asp/v101r.asp"
	else
		puts "Error: unknown query_type at method: crawl_data_and_filter"
		exit
	end
	target_site = URI.parse(q_addr)
	# target_site = URI(q_addr)
	# http://amis.afa.gov.tw/v-asp/v101q.asp is the page of vegetable query form.

	m_year = q_time[0]
	m_month = q_time[1]
	m_day = q_time[2]
	# m_mpno = q_machanize
	m_mpno = q_machanize[0]
	m_mpname = q_machanize[1]



	if query_type == 2
		# for fruits
		if m_mpname.length > 1
			#  This means containing both item name and its detail type. 
			req.set_form_data('myy' => m_year, 'mmm' => m_month, 'mdd' => m_day, 'mhidden1' => 'false', 'mpno' => m_mpno, \
					'mpnoname' => ( (m_mpname[0].length > 4)?( m_mpname[0][0,4]):(m_mpname[0]) ), \
					'mpnokind' => ( (m_mpname[0].length > 4)?( m_mpname[0][4,( ( (m_mpname[0].length - 8) > 4)?( 4 ):( m_mpname[0].length - 4) )] ):( (m_mpname[1].length > 4)?(m_mpname[1][0,4]):(m_mpname[1]) ) ), \
					'mtrtname' => ( (m_mpname[1].length > 4)?( m_mpname[1][4,( ( (m_mpname[1].length - 8) > 4)?( 4 ):( m_mpname[1].length - 4) )] ):( '' ) ) \
					)
			# Use so many tenary if-expressions because we want to act like a human 
			# sending requests via browsers with items which are [香蕉\t芭蕉紅芭蕉\tA2]-like and [柚子\t西施柚進口\tH69]-like .

			# The fruit-query's HTML page has some constraints in input field of query form:
			# a. Field: mpnoname can only contain 4 words at most. If words, which will filled in this field, are greater than 4, remainders would be filled in field: mpnokind and mtrtname by 4 words sequentially.
			# b. Field: mpnokind can only contain 4 words at most. If words, which will filled in this field, are greater than 4, remainders would be filled in field: mtrtname by 4 words sequentially.
			# c. Field: mtrtname can only contain 6 words at most. Seldom use this field.
			# d. Every word in above fields are considered double-byte, which include digits and symbols.

		else
			# This means only contains item name

			req.set_form_data('myy' => m_year, 'mmm' => m_month, 'mdd' => m_day, 'mhidden1' => 'false', 'mpno' => m_mpno, \
					'mpnoname' => ( (m_mpname[0].length > 4)?( m_mpname[0][0,4]):(m_mpname[0]) ), \
					'mpnokind' => ( (m_mpname[0].length > 4)?( m_mpname[0][4,( ( (m_mpname[0].length - 8) > 4)?( 4 ):( m_mpname[0].length - 4) )] ):( '' ) ), \
					'mtrtname' => ( (m_mpname[0].length > 8)?( m_mpname[0][8,( ( (m_mpname[0].length - 8) > 6)?( 6 ):( m_mpname[0].length - 8) )] ):( '' ) ) \
					)
			# Use so many tenary if-expressions because we want to act like a human 
			# sending requests via browsers with items which are [葡萄無子進口\tS49]-like.

			# The fruit-query's HTML page has some constraints in input field of query form:
			# a. Field: mpnoname can only contain 4 words at most. If words, which will filled in this field, are greater than 4, remainders would be filled in field: mpnokind and mtrtname by 4 words sequentially.
			# b. Field: mpnokind can only contain 4 words at most. If words, which will filled in this field, are greater than 4, remainders would be filled in field: mtrtname by 4 words sequentially.
			# c. Field: mtrtname can only contain 6 words at most. Seldom use this field.
			# d. Every word in above fields are considered double-byte, which include digits and symbols.
		end
	else
		# for vegetable and flowers
		req.set_form_data('myy' => m_year, 'mmm' => m_month, 'mdd' => m_day, 'mhidden1' => 'false', 'mpno' => m_mpno, 'mpnoname' => m_mpname)
	# req.set_form_data('myy' => '102', 'mmm' => '06', 'mdd' => '12', 'mhidden1' => 'false', 'mpno' => 'FD', 'mpnoname' => '花胡瓜')
		
		
	end

	count_retry = 0
	begin
		respond = Net::HTTP.start(target_site.host, target_site.port) do |http|

			#respond = Net::HTTP.post_form(target_site, {'myy' => '100', 'mmm' => '11', 'mdd' => '10', 'mhidden1' => 'false', 'mpno' => 'FB', 'mpnoname' => '康乃馨' })
			http.request(req)
		end

	rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
		   Errno::EHOSTUNREACH, Errno::ECONNREFUSED, SocketError, #for DNS-server unvailable
	       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
		puts "Timeout:Error or something happened."
		puts "We will retry."
		count_retry += 1
		sleep 10 # sleep ten second for later retry
		puts "Now will start #{count_retry} retry"
		retry #if count_retry < 5 # only retry 5 times.
	end
	count_retry = 0 # count retry times when every single crawling



	return false,nil if respond.body.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/(\<table[^$]*\<\/table\>)|(\<div[\s]id\=\"ctl00_contentPlaceHolder_panel\"\>[^$]*\<\/div\>)/u).nil?
	#puts "response: "+response #debug
	#return false,nil if response.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/(\<table[^$]*\<\/table\>)|(\<div[\s]id\=\"ctl00_contentPlaceHolder_panel\"\>[^$]*\<\/div\>)/u).nil?
	
	sleep 7
	puts "Behave like human."


	table_string = String.new
	table_string << respond.body.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/(\<table[^$]*\<\/table\>)|(\<div[\s]id\=)/u)
	#table_string << response.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/(\<table[^$]*\<\/table\>)|(\<div[\s]id\=)/u)
	table_array = Array.new( table_string.split(/[\s]+\<\/div\>\<div[\s]align\=\"left\"\>[\s]+/u) )



	
	meta_signal = 0
	# 正在過濾變成utf8編碼後的網頁，尚未成功，已經濾得差不多了
	# Date: 20130525 
	string_array = Array.new
	table_array.each{|table|

		# 2013/10/13 發現fruit bug: 抓蘋果系列(X09,X19,X29,...etc)的資料會有query form和query result的名稱不同的情況，
		# 應該要訂定使用fruit query時的特別條件，處理產品名稱中的代號、品種和處理別。尚未修好。
		# 2013/10/29 Written: Fix 2013/10/13 Fruit's bug. 

		# 2013/07/13 Fixed bug: FA0 台北一 會少一個空字串 	
		# table.gsub!(/\<(\/)?[^\<]+(\")?\>/u,'').gsub!("\r\n","").gsub!(/((?<=[^ ])( ){1,2}(?=[^ ]))/u,'').gsub!(/[ ]+/u,',').gsub!(/(^,)|(,$)/u,'')#.gsub!(/[　]+/u,'""')
		# 2013/09/30 Fixed bug: Ruby 1.9.3p374 String class concate too many gsub!(), which over 3 times, will sometimes report the string variable is nil:NilClass.
		# So I divide one statement into two statements.  
		if query_type != 2 #means vegetable or flowers
			table = table.gsub!(/\<(\/)?[^\<]+(\")?\>/u,'').gsub!("\r\n","").gsub(/((?<=[^ ])( ){1,2}(?=[^ ]))/u,'')
			# puts "test 1:"+table #debug
			table.gsub!(/[ ]+/u,',').gsub!(/(^,)|(,$)/u,'')#.gsub!(/[　]+/u,'""')
		# 2013/09/30 Fixed bug: Ruby 1.9.3p374 String class concate too many gsub!(), which over 3 times, will sometimes report the string variable is nil:NilClass.
		# So I divide one statement into two statements. 
		# 2013/10/29 Written: Sorry, this is my misunderstanding about return value of String.gsub() and String.gsub!(). 
		# 2014/03/23 Written: 花卉網頁資料不知何時開始多最高價的欄位資料，可能會使抓取資料錯誤。本敘述寫在這邊不表示可能會在這邊出錯，只是先寫在這裡，待執行錯誤再檢視敘述。

		else # if query_type == 2 # means fruit

			table = table.gsub!(/\<(\/)?[^\<]+(\")?\>/u,'').gsub!("\r\n","").gsub(/((?<=[^ \d\+\-])( ){1,}(?=[^ \d\+\-]))/u,',') # <- 最後一個gsub()過濾品種和處理別
			# puts "test 1:"+table #debug
			table = table.gsub(/((?<=[^ ])( ){1,2}(?=[^ ]))/u,'') # <- 承上一行, 像vegetable和flowers一樣，過濾每欄之間的空白
			table.gsub!(/[ ]+/u,',').gsub!(/(^,)|(,$)/u,'')#.gsub!(/[　]+/u,'""')

		end
		# puts table #debug
		# puts "data class: "+ table.class.to_s #debug
		if meta_signal == 1 # deal with pattern: ,&nbsp;
			# 1 means market transaction data
			table.gsub!(/,&nbsp;/u, ',""')
			table.gsub!(/&nbsp;/u, '')
		end
		# 2013/07/13 Fixed bug: FA0 台北一 會少一個空字串 	

		if table.include? "　" # if it contains full stylish of <SPACE>, just replace it with double quote mark. 
			if query_type == 1 # for vegetable

				table.gsub!(/[　]+/u,'""') # remove full stylish of <SPACE>

				if meta_signal == 1 # 1 means market transaction data
					# 2014/02/05 written: 解決1996年4月1日蔬菜類代號LJ「芥菜仁」台北二市場的缺平均價和交易量增減%的欄位。
					# 備註：本項問題也可能會出現在沒有全型空白的蔬菜類「處理別」欄位，
					# 故也要在下方if-else區塊處理。
					# 更理想的作法，抽出驗證欄位數量的程式功能，在蔬菜類、水果類和盆花類都使用驗證欄位數量的功能函式。
					# 目前因為時間有限，暫時只在這個處理全形空白if-else區塊，驗證蔬菜類欄位數量。 
					# 用每個交易市場名稱正常的欄位數量驗證是否缺少欄位。
					location_start_position = 10 # 市場交易名稱的陣列起始位置
					tmp_array = Array.new 
					tmp_array = table.split(/[,]/u)
					location_count = location_start_position # 從第一個地區的市場名稱開始檢查
					table_size = tmp_array.size

					while location_count < table_size
						if (nil == (tmp_array[location_count] =~ /([\-]|[\+\-]?[0-9]+(.)?[0-9]*|[\+\-]?[\*]+)/u))
							# 如果location_count這個位置不是數字（包含正負），也不是無資料(-)
							# 那麼就有可能是市場名稱、品種名稱和處理別這三種欄位。
							# 2014/02/09 written: pattern新增[\+\-]?[\*]+ 是因為1996/04/01的LG芹菜，在鳳山區青梗的交易量增減%欄位出現+***這樣的內容。 
							puts "At tmp_array[location_count]不是數字、也不是無資料" #debug
							previous_location = location_count - 1
							if nil == (tmp_array[previous_location] =~ /([\-]|[\+\-]?[0-9]+(.)?[0-9]*|[\+\-]?[\*]+)/u)
								if 0 != (tmp_array[previous_location] <=> "增減%")
									# do something 區分市場名稱和品種和處理別。
									nextOnePosition = location_count + 1
									nextTwoPosition = location_count + 2
									if nil == (tmp_array[nextOnePosition] =~ /([\-]|[\+\-]?[0-9]+(.)?[0-9]*|[\+\-]?[\*]+)/u)
										# 2014/02/09 written: pattern新增[\+\-]?[\*]+ 是因為1996/04/01的LG芹菜，在鳳山區青梗的交易量增減%欄位出現+***這樣的內容。 
										if nil == (tmp_array[nextTwoPosition] =~ /([\-]|[\+\-]?[0-9]+(.)?[0-9]*)|[\+\-]?[\*]+/u)
											# location_count位置是市場名稱
											# 進行下一回合的驗證資料欄位數量
											location_count += 10
										else # location_count位置是品種名稱
											previous_location -= 1
											tmp_array.insert(previous_location, "-")
											previous_location += 2 
											tmp_array.insert(previous_location, "-")
											location_count += 10
										end
									else
										# location_count位置是處理別
										previous_location -= 2
										tmp_array.insert(previous_location, "-")
										previous_location += 2
										tmp_array.insert(previous_location, "-")
										location_count += 10
									end

								else # if location_count的前一個位置內容是"增減%"
									if table_size == 20
										#已預設location_count的位置是市場名稱
										break # do nothing
									elsif table_size < 20
										#已預設location_count的位置是市場名稱
										tmp_array.insert(17, "-")
										tmp_array << "-"
										break
									else # if table_size > 20
										location_count += 10	
									end
								end

							else
								# 如果previous_location是數字（包含正負）、無資料
								# 而且location_count可能是市場名稱、品種名稱和處理別這三種，
								# 那麼可確定是location_count位置是市場名稱
								location_count += 10
							end

						else
							# 如果location_count這個位置是數字（包含正負）、無資料(-)，
							# 則location_count減1
							location_count -= 1

						end
					end
					# 2014/02/08 written: 已將tmp_array存到table裡面。  
					element_count_for_tmp_array = 0
					table.clear #清掉舊的字串				
					while element_count_for_tmp_array < (tmp_array.size - 1)
						table << (tmp_array[element_count_for_tmp_array] +",")
						element_count_for_tmp_array += 1
					end
					table << tmp_array[element_count_for_tmp_array]

				end
				string_array << table

			elsif query_type == 2 #for fruits
			
				table.gsub!(/[　]+/u, '""')

				if 9 == table.split(/[,:]/u).size
					# This is fix bug for [C6佛利檬,"",總交易量:]-like item: Only 9 elements.
					# Meta-data must have 10 elements.
					table.sub!(",總交易量", ",\"\",總交易量")
				end

				string_array << table

			elsif query_type == 3 #for flowers

				string_array << table.gsub!(/[　]+/u,'')

			end

		else
			# Here are table for whole elements are filled with values.

			# 2013/10/14 發現fruit bug: 桃園縣的水果資料沒提供天氣資料，那欄會是空白的，
			# 所以要注重抓水果資料的天氣欄位。尚未修好, ex: 51百香果。天氣種類：晴天、陰天、雨天、颱風
			# 2013/10/24 written: Fix fruit 天氣資訊bug
			if query_type == 2 # for fruits

				if 17 <= table.split(/[,]/u).size # 正常要考慮大於18, 但想到一種水果當天可能只有桃園縣的交易資料，所以改定成大於或等於17
					# Fix bug of losing weather information, like 51百香果.
					puts "fruitttttttttttttttttttttttttttttttttttttttttt"#debug
					tmp_array = Array.new 
					tmp_array = table.split(/[,]/u)
					table_size = tmp_array.size
					weather_count = 10 # 從第一個地區的天氣資訊開始檢查
					while weather_count < table_size
						puts "tmp_array[#{weather_count}]: "+tmp_array[weather_count] #debug
						if nil == (tmp_array[weather_count] =~ /([\-]|[\+\-]?[0-9]+(.)?[0-9]*)/u)
							# 如果weather_count這個位置不是數字(包含正負)，也不是無資料(-)
							
							if nil != (tmp_array[weather_count] =~ /[晴天|雨天|陰天|颱風]/u)
								# 是天氣資訊
								puts "test 1: tmp_array[weather_count] 是天氣資訊" #Debug 
								weather_count += 9
							else
								# 不是天氣資訊, 預期是鄉鎮名, 除非有上面沒記錄到的天氣資訊, 例如冰雹、下雪...etc 
								# 目前(20131024 written)觀測交易記錄只有四種天氣資訊：晴天、雨天、陰天、颱風

								if nil != (tmp_array[weather_count + 1] =~ /([\-]|[\+\-]?[0-9]+(.)?[0-9]*)/u)
									# 如果weather_count的下一個位置是數字或是無資料(-)，
									# 則在weather_count現在的位置新增一個空字串，
									puts "test 2: tmp_array[weather_count] 不是天氣資訊, weather_count + 1的位置是數字或無資料" # debug 
									tmp_array[weather_count] << ",\"\""
									weather_count += 10

								else
									# 如果weather_count的下一個位置不是數字也不是無資料(-)，
									#  則檢查weather_count的前八個位置是否是數字或無資料
									if nil != (tmp_array[weather_count - 8] =~ /([\-]|[\+\-]?[0-9]+(.)?[0-9]*)/u)
										# 如果weather_count的前八個位置是數字或是無資料(-)，
										# 則weather_count的位置減8 
									puts "test 3: tmp_array[weather_count] 不是天氣資訊, weather_count - 8的位置是數字或無資料" # debug 
										weather_count -= 8
									else
								
										if nil != (tmp_array[weather_count - 8] =~ /[晴天|雨天|陰天|颱風]/u)
											# 如果weather_count的前八個位置是天氣資訊，
											# 則weather_count加10，前進下一個市場資料或是結束這個水果當天交易資料
											puts "test 4: tmp_array[weather_count] 不是天氣資訊, weather_count - 8的位置是天氣資訊" # debug 
											weather_count += 10
										else
											# 如果weather_count的前八個位置依然是縣市鄉鎮名，
											# 則weather_count減8 
											puts "test 5: tmp_array[weather_count] 不是天氣資訊, weather_count - 8的位置是鄉鎮名" # debug 
											weather_count -= 8
										end
									end
								end

							end

						else
							# 若weather_count這個位置可能是數字(包含正負)或是無資料(-)，
							# 則繼續看weather_count的前一個位置
							
							if nil == (tmp_array[weather_count - 1] =~ /([\-]|[\+\-]?[0-9]+(.)?[0-9]*)/u)
								# 如果weather_count的前一個位置不是數字也不是無資料(-)，
								# 則檢查是不是天氣資訊
								if nil != (tmp_array[weather_count - 1] =~ /[晴天|雨天|陰天|颱風]/u)
									# 如果weather_count的前一個位置是天氣資訊，
									# 則weather_count += 8
									puts "test 6: tmp_array[weather_count] 不是天氣資訊, weather_count - 1的位置是天氣資訊" # debug 
									weather_count += 8
								else
									# 如果weather_count的前一個位置是鄉鎮名，
									# 則新增空字串到weather_count的前一個位置尾端，
									# 並且weather_count現在的位置加8 
									puts "test 7: tmp_array[weather_count] 不是天氣資訊, weather_count - 1的位置是鄉鎮名" # debug 
									tmp_array[weather_count - 1] << ",\"\"" 
									weather_count += 8
								end
							else
								# 這個else-expression block預期weather_count的前一個位置只有兩種情況：a)鄉鎮名, b)數字或無資料，
								# 用刪去法，從1)天氣資訊、2)數字或無資料、3)鄉鎮名這三種資訊，鎖定非(數字或無資料)和非(天氣資訊)，以確定weather_count的前一個位置是鄉鎮名。
								# 如果weather_count的前一個位置依然是數字，或是無資料(-)，
								# 則在weather_count的前二個位置字串尾端補上
								# 兩個double qoutes，以表示空白的鄉鎮名和天氣資訊； 
								# 又或者是weather_count的前一個位置是鄉鎮市名，則weather_count的前一個位置補上double qoute，以表示空白的天氣資訊。 


								if nil != (tmp_array[weather_count - 1] =~ /(([\-])|([\+\-]?[0-9]+(.)?[0-9]*))/u)
								# 2013/11/02 written:針對weather_count的前一個位置應對策略，
								# 我們因為遭遇到C1椪柑在民國85年4月23號的單一產品單一交易行情，
								# 多一欄沒有市場名稱和天氣資訊的資料，所以
								# 要新增兩個double quote當做市場名稱和天氣資訊，並且跳到下一筆市場交易資料預期的天氣欄位，所以weather_count要加7。
								# 2013/11/02 written: 這個else-statement block不處理連續沒有市場名稱與天氣資訊的情況，
								# 因為我預期只有一筆C1椪柑的市場價格特殊價格資料，
								# 專對C1椪柑在民國85年4月23號的單一產品單一交易行情的處理。
									# 如果weather_count的前一個位置確定是數字或無資料，
									# 則在weather_count的前二個位置補上兩個
									# double-qoute，以表示鄉鎮名和天氣資訊。
 
									puts "test 8: tmp_array[weather_count] 不是天氣資訊, weather_count - 1的位置是數字或無資料, tmp_array[weather_count-1]: #{tmp_array[weather_count - 1]}" # debug 
									tmp_array[weather_count - 2] << ",\"\",\"\""
									weather_count += 7
								else
									# 在缺乏天氣資訊的交易市場名稱後面加上一對double qoute，
									# 用以表示缺乏天氣資訊，例如桃園縣的交易資料就缺乏天氣資訊。 	
									puts "test 9: tmp_array[weather_count] 不是天氣資訊, weather_count - 1的位置是鄉鎮名" # debug 
									tmp_array[weather_count - 1] << ",\"\""
									weather_count += 8
								end
								
							end
						end
					end

					element_count_for_tmp_array = 0
					table.clear # 清掉舊的字串
					while element_count_for_tmp_array < (tmp_array.size - 1)
						table << (tmp_array[element_count_for_tmp_array] +",")
						element_count_for_tmp_array += 1
					end
					table << tmp_array[element_count_for_tmp_array]

				end
			end

			string_array << table
		end

		if meta_signal == 0 # 0 means meta data
			meta_signal = 1
		elsif meta_signal == 1 # deal with pattern: ,&nbsp;
			# 1 means market transaction data
			meta_signal = 0
		end

	}
  	# 印出來尚有問題，要消除空白和<p>！date:20130525
	# Date: 20130527
	# 已經去除<p>和&nbsp;和多餘的全形和半形空白，
	# 還有讓正負符號結合數字與去除頭尾的逗號，
	# 目前剩下轉成json格式。
	
	# Date: 20130608
	# 為空白的處理別欄位資料加上雙引號, 以表示有此欄位。
	 puts string_array.to_s	#debug
	 # sleep 2 # sleep 2 seconds for decreasing payload of amis_website
	 return true,string_array 
end
=end 
=begin
def query_results_transform( q_type, results )
# use to get summary and market-based information of every item.
# 2014/03/04 written: not complete
# 2014/03/23 written: coding this function complete. NEED to testing this one.
	summary = Array.new
	marketBased_info = Array.new
	sizeOfResults = results.size # total number of lines
	tmp_string_array = Array.new
	tmp_string = String.new
	tmp_summary_array = Array.new
	j = 0

	case q_type
	
		when 1 # means vegetable
			column_number_of_meta_data = 10
		when 2 # means fruit
			column_number_of_meta_data = 11
		when 3 # means flowers
			column_number_of_meta_data = 9
		else
			exit
	end

	for i in 0...sizeOfResults do

		
		if 0 == (i % 2) # for meta data of items daily
			tmp_summary_array = results[i].split(/[,:\/]/u)
			case q_type
				when 1 # means vegetable
					summary << (tmp_summary_array[3] + "," + \
							tmp_summary_array[1] + "," + \
							tmp_summary_array[5] + "," + \
							tmp_summary_array[7])
					#Summary格式:{代號&產品名稱}, 交易日期, 總交易量, 總平均價 

					marketBased_info[j] = tmp_summary_array[3] + "," + \
										  tmp_summary_array[1] + "," # storing item's name and transaction date into transaction market data
					# marketBased_info格式：{代號與產品名稱}, 交易日期, 市場名稱, 品種名稱, 處理別, 上價, 中價, 下價, 平均價, 平均價增減%, 交易量, 交易量增減%
				when 2 # means fruit
					summary << (tmp_summary_array[3] + "," + \
							tmp_summary_array[4] + "," + \
							tmp_summary_array[5] + "," + \
							tmp_summary_array[1] + "," + \
							tmp_summary_array[7] + "," + \
							tmp_summary_array[9])
					#Summary格式：{代號&產品名稱}, 品種名稱, 處理別, 交易日期, 總交易量, 總平均價

					marketBased_info[j] = tmp_summary_array[3] + "," + \
										  tmp_summary_array[1] + "," # storing item's name and transaction date into transaction market data
					# marketBased_info格式：{代號與產品名稱}, 交易日期, 市場名稱, 天氣, 上價, 中價, 下價, 平均價, 平均價增減%, 交易量, 交易量增減%
				when 3 # means flowers
					summary << (tmp_summary_array[10] + "," + \
						tmp_summary_array[1] + "," + \
						tmp_summary_array[6] + "," + \
						tmp_summary_array[3] + "," + \
						tmp_summary_array[8])
					#Summary格式：{代號&產品名稱}, 交易日期, 總交易量, 總平均價, 總殘貨量

					marketBased_info[j] = tmp_summary_array[10] + "," + \
										  tmp_summary_array[1] + "," # storing item's name and transaction date into transaction market data
					# marketBased_info格式：{代號與產品名稱}, 交易日期, 市場名稱, 品種名稱, 最高價, 上價, 中價, 下價, 平均價, 平均價增減%, 交易量, 交易量增減%, 殘貨量
				else
					puts "Error when extracting summary."
					exit
			end

		else # for transaction market data for every item.



			sizeOfLineInTransaction = results[i].split(/,/u).size # get total column number for transaction market data in every item.
			upperBound_of_sizeOfLineInTransaction = sizeOfLineInTransaction - column_number_of_meta_data
			tmp_string_array = results[i].split(/,/u)[column_number_of_meta_data, upperBound_of_sizeOfLineInTransaction] # extract actually transaction data from ones containing description of transaction market data in every item.

			# append nest transaction market data to one line 
			element_count_for_tmp_string_array = 0
			while element_count_for_tmp_string_array < upperBound_of_sizeOfLineInTransaction

				if 0 != (element_count_for_tmp_string_array % column_number_of_meta_data)
					if (column_number_of_meta_data - 1) != (element_count_for_tmp_string_array % column_number_of_meta_data)

						marketBased_info[j].concat(tmp_string_array[element_count_for_tmp_string_array] + "," )

					else # 當遇到一筆市場資料的最後一欄
						marketBased_info[j].concat(tmp_string_array[element_count_for_tmp_string_array])
						
					end
				else # if 0 == (element_count_for_tmp_string_array % column_number_of_meta_data)

					if element_count_for_tmp_string_array != 0 # to avoid skipping the first market price data.
						j += 1
					end

					case q_type
						when 1 # means vegetable
							marketBased_info[j] = tmp_summary_array[3] + "," + \
												  tmp_summary_array[1] + "," # storing item's name and transaction date into transaction market data
							# marketBased_info格式：{代號與產品名稱}, 交易日期, 市場名稱, 品種名稱, 處理別, 上價, 中價, 下價, 平均價, 平均價增減%, 交易量, 交易量增減%
						when 2 # means fruit
							marketBased_info[j] = tmp_summary_array[3] + "," + \
										  		  tmp_summary_array[1] + "," # storing item's name and transaction date into transaction market data
							# marketBased_info格式：{代號與產品名稱}, 交易日期, 市場名稱, 天氣, 上價, 中價, 下價, 平均價, 平均價增減%, 交易量, 交易量增減%
						when 3 # means flowers
							marketBased_info[j] = tmp_summary_array[10] + "," + \
								       			  tmp_summary_array[1] + "," # storing item's name and transaction date into transaction market data
							# marketBased_info格式：{代號與產品名稱}, 交易日期, 市場名稱, 品種名稱, 最高價, 上價, 中價, 下價, 平均價, 平均價增減%, 交易量, 交易量增減%, 殘貨量
						else
							exit
					end
					marketBased_info[j].concat(tmp_string_array[element_count_for_tmp_string_array] + "," )
				end
				element_count_for_tmp_string_array += 1
			end
			# append nest transaction market data to one line 
			j += 1	
		end
	end
	return summary, marketBased_info
end
=end

unless ARGV.length > 2 && ARGV.length < 5
	puts "Available command: ruby my_vegetable_crawler.rb <Start Date> <End Date> <Output file> [vegetable|fruit|flowers]"
	puts "Format of start and end date is using AD. yyyy-mm-dd, I will transform it to format of Republic of China."
	puts "Available value range of start date is 1996-01-01, and we can't query someday that in the future."
	puts "Available value range of end date is greater than or equal to start date."
	puts "-------------------------------------------------------"
	puts "Every output file is putted at under directory of query_results. Content format is csv-style originally."

	puts "Last parameter is optional, and vegetable is the implicit value."
	exit 
end

argv_start_date = Date.parse ARGV[0] # ARGV[0] is the start date
qs_year = argv_start_date.year #ARGV[0] is the <start date>
qs_month = argv_start_date.month
qs_day = argv_start_date.day
if Date.valid_date?(qs_year, qs_month, qs_day) == false
	puts "Error: Start date's value isn't exist in calendar."
	exit
else
	if qs_year < 1996
		puts "Error: Start date must start from 1996A.D.."
		exit
	elsif (argv_start_date <=> Date.today) == 1
		puts "Error: We can't query information in the future via this program when start date is greater than today."
		exit
	end
end

#ARGV[1] is the ending time
argv_end_date = Date.parse ARGV[1] # ARGV[1] is the end date
qe_year = argv_end_date.year #ARGV[1] is the <end date>
qe_month = argv_end_date.month
qe_day = argv_end_date.day
if Date.valid_date?(qe_year, qe_month, qe_day) == false
	puts "Error: End date's value isn't exist in calendar."
	exit
else
	if (argv_end_date <=> argv_start_date) == -1
		puts "Error: End date must greater than or equal to start date."
		exit
	elsif (argv_end_date <=> Date.today) == 1
		puts "Error: We can't query information in the future via this program when end date is greater than today."
		exit
	end
end

#For showing how many days will be crawled
total_days_will_be_processing = (argv_end_date - argv_start_date).to_i + 1

#ARGV[2] is the output file
argv_output_file = ARGV[2]

#ARGV[3] is an option for quering vegetable, fruit or flowers.
if ARGV[3].nil?
	q_type = 1
else
	argv_query_type = ARGV[3].downcase
	case argv_query_type
	when "vegetable"
		q_type = 1
	when "fruit"
		q_type = 2
	when "flowers"
		q_type = 3
	else
		puts "Error: Parameter of query_type must be vegetable, fruit or flowers. I don't care UPCASE or downcase."
		exit
	end
end


recv_mpno_list, recv_mpname_list = read_items_from_file(q_type)
puts "mpno_list: "+recv_mpno_list.to_s#debug
puts "====" #debug
puts "mpname_list: "+recv_mpname_list.to_s #debug

# mpname and its mpno transfer from array to hash: recvMerchandizeHash
counter_mpname_list = 0
recvMerchandizeHash = Hash.new
recv_mpno_list.each{ | number |
	recvMerchandizeHash[number] = recv_mpname_list[counter_mpname_list]
	counter_mpname_list += 1
}
counter_mpname_list = 0
# mpname and its mpno transfer from array to hash: recvMerchandizeHash


remoteItemsHash = get_remote_item_list(q_type) # get item list at remote website.
updatedItemsHash = update_item_list(q_type, recvMerchandizeHash, remoteItemsHash) # compare item lists between local file and remote website, and then do three things:
# 1) generate newer a hash of item lists and return it.
# 2) generate a changelog file for item list of the query type, which this time we use. Format of the file name is CHANGELOG-<QUERYTYPE>.txt
# 3) copy old item list of query type of this time to <OLDNAME>-<DATE>.txt . And generate new file for new list of query type, and please use names coded in header of this script.
total_mpno_number = updatedItemsHash.keys.size # for showing total number of be processced mpno

qi_time = Array.new
result_array = Array.new #store result for writing to file.

count_day = 1
q_date = argv_start_date
begin
	q_year = q_date.year - 1911
	q_month = q_date.month
	q_day = q_date.day
	
	if q_year < 100
		qi_time << "0"+q_year.to_s # prepend 0 when year number is smaller than 100
	else
		qi_time << q_year.to_s #type conversion
	end

	if q_month < 10 && q_month > 0
		qi_time << "0"+q_month.to_s # prepend 0 when month number is smaller than 10 and greater than 0
	else
		qi_time << q_month.to_s
	end
	if q_day < 10 && q_day > 0 
		qi_time << "0"+q_day.to_s # prepend 0 when day number is smaller than 10 and greater than 0
	else
		qi_time << q_day.to_s
	end

=begin
	qi_machanize = Array.new
	count_mpno = 0
	recv_mpno_list.each{ |mpno|
		puts "本次查詢範圍是民國 "+(argv_start_date.year - 1911).to_s+" 年 "+(argv_start_date.month).to_s+" 月 "+(argv_start_date.day).to_s+" 號 至 "+(argv_end_date.year - 1911).to_s+" 年 "+(argv_end_date.month).to_s+" 月 "+(argv_end_date.day).to_s+" 號."
		puts "現在處理的是第 "+count_day.to_s+"/"+total_days_will_be_processing.to_s+" 天"	
		puts "現在處理的是民國 "+q_year.to_s+" 年 "+q_month.to_s+" 月 "+q_day.to_s+" 號的第 "+(count_mpno + 1).to_s+"/"+total_mpno_number.to_s+" 個"
		qi_machanize[0] = mpno.to_s
		qi_machanize[1] = recv_mpname_list[count_mpno] 
		result_signal, tmp_array = crawl_data_and_filter(qi_time, qi_machanize, q_type)

		if recv_mpname_list[count_mpno].class != Array

			puts "編號: "+mpno+", 名稱: "+recv_mpname_list[count_mpno]+" 在此查詢類別不存在!" if result_signal == false
			puts "編號: "+mpno+", 名稱: "+recv_mpname_list[count_mpno]+" 成功抓取資料" if result_signal != false
			
		else

			puts "編號: "+mpno+", 名稱: "+recv_mpname_list[count_mpno].to_s+" 在此查詢類別不存在!" if result_signal == false
			puts "編號: "+mpno+", 名稱: "+recv_mpname_list[count_mpno].to_s+" 成功抓取資料" if result_signal != false

		end
		result_array << tmp_array if tmp_array.nil? == false
		count_mpno += 1
		puts "===================================="
	}
=end 

	infoArrayToPrint = [argv_start_date, argv_end_date, count_day, total_days_will_be_processing, q_year, q_month, q_day, total_mpno_number]
	tmp_array = crawl_data(q_type, updatedItemsHash, qi_time, infoArrayToPrint) #open browser and send requests through browser to collect data we want.
	infoArrayToPrint.clear
	infoArrayToPrint = [qi_time[0], qi_time[1], qi_time[2]] # [year, month, day]
	result_array = filter_data(q_type, tmp_array, infoArrayToPrint)
	puts "===================================="
	infoArrayToPrint.clear

	qi_time.clear # clear query time array
	q_date += 1
	count_day += 1 # for counting we have procceed how many days.


	puts "寫入查詢結果中，請勿中斷程式......"

	if !(Dir.exist? PATH_OF_QUERY_RESULTS_DIRECTORY)
		Dir.mkdir PATH_OF_QUERY_RESULTS_DIRECTORY
	end # if there is no directory named query_results, it will create an one.

	result_array.flatten!
	File.open(PATH_OF_QUERY_RESULTS_DIRECTORY + argv_output_file,"a"){ |f|
		result_array.each{|element|
			f.puts(element)
		}
	} # write detail-version information

=begin
	summary_result_array = Array.new
	marketBased_result_array = Array.new
	summary_result_array, marketBased_result_array = query_results_transform( q_type, result_array )
	# 2014/03/04 written: write summary-version of information, which are about every item in every market.
	File.open("./query_results/summary_"+argv_output_file,"a"){ |f|
		summary_result_array.each{ |element|
			f.puts(element)
		}
	}
	# 2014/03/04 written: write summary-version of information, which are about every item in every market.

	# 2014/03/04 written: write market-based information of every item whose exclude summary-version.
	File.open("./query_results/marketBased_"+argv_output_file,"a"){ |f|
		marketBased_result_array.each{ |element|
			f.puts(element)
		}
	}
	# 2014/03/04 written: write market-based information of every item whose exclude summary-version.
=end

	result_array.clear
	puts "寫入完畢."
	puts "===================================="
	#可使用stdout重導向寫到檔案, at g0v hackth3n



	# break #debug
end until( (argv_end_date <=> q_date) == -1 )


