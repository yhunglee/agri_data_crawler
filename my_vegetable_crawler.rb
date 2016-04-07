# encoding: utf-8
# Author: howardsun
# Date: 2013/03/10
# Crawling data of vegetables, fruits and flowers from a website of Taiwan government.

require 'net/http'
require 'date'

def read_items_from_file query_type

	array_mpno = Array.new
	array_mpno_name = Array.new
	if query_type == 1
		file_name = "txt_at_amis_vegetable.txt"
	elsif query_type == 2
		file_name = "txt_at_amis_fruit.txt"
	elsif query_type == 3
		file_name = "txt_at_amis_flowers.txt"
	else
		puts "Error: unknown query_type at method: read_items_from_file."
		exit
	end
	File.open("./data_format_at_every_site/"+file_name, "r"){ |f|
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

def crawl_data_and_filter(q_time, q_machanize, query_type)

	if query_type == 1 # vegetable
		q_addr = "http://amis.afa.gov.tw/v-asp/v101r.asp"
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

	req = Net::HTTP::Post.new(target_site.request_uri)
	req.delete "User-Agent"
	req.add_field "User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36"

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
		# 蔬菜查詢網址不會檢查名稱
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
		sleep 10 # sleep one second for later retry
		puts "Now will start #{count_retry} retry"
		retry #if count_retry < 5 # only retry 5 times.
	end
	count_retry = 0 # count retry times when every single crawling
	
	return false,nil if respond.body.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/\<table[^$]*\<\/table\>/u).nil?
	
	sleep 7
	puts "Behave like human."


	table_string = String.new
	table_string << respond.body.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/\<table[^$]*\<\/table\>/u)
	# puts "table_string"+table_string #debug
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

								else # if location_count的前一個位置內容是"增減％"
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

recv_mpno_list, recv_mpname_list = read_items_from_file(q_type)
total_mpno_number = recv_mpno_list.size # for showing total number of be processced mpno
puts "mpno_list: "+recv_mpno_list.to_s#debug
puts "====" #debug
puts "mpname_list: "+recv_mpname_list.to_s #debug

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

	qi_time.clear # clear query time array
	q_date += 1
	count_day += 1 # for counting we have procceed how many days.

	puts "寫入查詢結果中，請勿中斷程式......"

	if !(Dir.exist? "./query_results")
		Dir.mkdir "./query_results"
	end # if there is no directory named query_results, it will create an one.

	result_array.flatten!
	File.open("./query_results/"+argv_output_file,"w"){ |f| # 20160406: change from a mode to w mode because we start to use cron task program with same file name.
		result_array.each{|element|
			f.puts(element)
		}
	} # write detail-version information

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
	result_array.clear
	puts "寫入完畢."
	puts "===================================="

	#可使用stdout重導向寫到檔案, at g0v hackth3n



	# break #debug
end until( (argv_end_date <=> q_date) == -1 )


