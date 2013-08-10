# encoding: utf-8
# Author: howardsun
# Date: 2013/03/10

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
			array_mpno_name << content[0]
			array_mpno << (content[1].delete! "\n")
		end
	}

	return array_mpno, array_mpno_name
end

def crawl_data_and_filter(q_time, q_machanize, query_type)

	if query_type == 1
		q_addr = "http://amis.afa.gov.tw/v-asp/v101r.asp"
	elsif query_type == 2
		q_addr = "http://amis.afa.gov.tw/t-asp/v103r.asp"
	elsif query_type == 3
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

	req.set_form_data('myy' => m_year, 'mmm' => m_month, 'mdd' => m_day, 'mhidden1' => 'false', 'mpno' => m_mpno, 'mpnoname' => m_mpname)
	# req.set_form_data('myy' => '102', 'mmm' => '06', 'mdd' => '12', 'mhidden1' => 'false', 'mpno' => 'FD', 'mpnoname' => '花胡瓜')
	# 蔬菜查詢網址不會檢查名稱

	count_retry = 0
	begin
		respond = Net::HTTP.start(target_site.host, target_site.port) do |http|

			#respond = Net::HTTP.post_form(target_site, {'myy' => '100', 'mmm' => '11', 'mdd' => '10', 'mhidden1' => 'false', 'mpno' => 'FB', 'mpnoname' => '康乃馨' })
			http.request(req)
		end
	rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
	       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
		puts "Timeout:Error or something happened."
		puts "We will retry."
		count_retry += 1
		sleep 1 # sleep one second for later retry
		retry if count_retry < 5 # only retry 5 times.
	end
	count_retry = 0 # count retry times when every single crawling
	
	return false,nil if respond.body.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/\<table[^$]*\<\/table\>/u).nil?
	
	table_string = String.new
	table_string << respond.body.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/\<table[^$]*\<\/table\>/u)
	# puts "table_string"+table_string #debug
	table_array = Array.new( table_string.split(/[\s]+\<\/div\>\<div[\s]align\=\"left\"\>[\s]+/u) )




	
	meta_signal = 0
	# 正在過濾變成utf8編碼後的網頁，尚未成功，已經濾得差不多了
	# Date: 20130525 
	string_array = Array.new
	table_array.each{|table|

		# 2013/07/13 Fixed bug: FA0 台北一 會少一個空字串 	
		table.gsub!(/\<(\/)?[^\<]+(\")?\>/u,'').gsub!("\r\n","").gsub!(/((?<=[^ ])( ){1,2}(?=[^ ]))/u,'').gsub!(/[ ]+/u,',').gsub!(/(^,)|(,$)/u,'')#.gsub!(/[　]+/u,'""')
		if meta_signal == 0 # deal with pattern: ,&nbsp; 
			meta_signal = 1
		elsif meta_signal == 1
			table.gsub!(/,&nbsp;/u, ',""')
			table.gsub!(/&nbsp;/u, '')
			meta_signal = 0
		end
		# 2013/07/13 Fixed bug: FA0 台北一 會少一個空字串 	

		if table.include? "　" # if it contains full stylish of <SPACE>, just replace it with double quote mark. 
			string_array << table.gsub!(/[　]+/u,'""')
		else
			# Here are table for whole elements are filled with values.
			string_array << table
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
	 sleep 2 # sleep 2 seconds for decreasing payload of amis_website
	 return true,string_array 
end

unless ARGV.length > 2 && ARGV.length < 5
	puts "Available command: ruby myvegetable_crawler.rb <Start Date> <End Date> <Output file> [vegetable|fruit|flower]"
	puts "Notice: Fruit-query temporarily unavailable since problem of parse file format."
	puts "Format of start and end date is using AD. yyyy-mm-dd, I will transform it to format of Republic of China."
	puts "Available value range of start date is 1996-01-01, and we can't query someday in the future."
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
		puts "編號: "+mpno+", 名稱: "+recv_mpname_list[count_mpno]+" 在此查詢類別不存在!" if result_signal == false
		puts "編號: "+mpno+", 名稱: "+recv_mpname_list[count_mpno]+" 成功抓取資料" if result_signal != false
		result_array << tmp_array if tmp_array.nil? == false
		count_mpno += 1
		puts "===================================="
	}

	qi_time.clear # clear query time array
	q_date += 1
	count_day += 1 # for counting we have procceed how many days.

	puts "寫入查詢結果中，請勿中斷程式......"
	result_array.flatten!
	File.open("./query_results/"+argv_output_file,"a"){ |f|
		result_array.each{|element|
			f.puts(element)
		}
	}
	result_array.clear
	puts "寫入完畢."
	puts "===================================="

	#可使用stdout重導向寫到檔案, at g0v hackth3n



	# break #debug
end until( (argv_end_date <=> q_date) == -1 )


