# encoding: utf-8
# Author: howardsun
# Date: 2013/03/10

require 'net/http'
require 'date'

def read_items_from_file

	array_mpno = Array.new
	array_mpno_name = Array.new
	File.open("txt_at_amis_vegetable.txt", "r"){ |f|
		while line = f.gets
			puts "line: "+line #debug
			content = line.split("\t")
			puts "content: "+content.to_s #debug
			array_mpno_name << content[0]
			array_mpno << (content[1].delete! "\n")
		end
	}

	return array_mpno, array_mpno_name
end

def crawl_data_and_filter(q_time, q_machanize)

	target_site = URI.parse("http://amis.afa.gov.tw/v-asp/v101r.asp")
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
	# req.set_form_data('myy' => '102', 'mmm' => '06', 'mdd' => '11', 'mhidden1' => 'false', 'mpno' => 'FD', 'mpnoname' => '花胡瓜')
	# 蔬菜查詢網址不會檢查名稱

	respond = Net::HTTP.start(target_site.host, target_site.port) do |http|

		#respond = Net::HTTP.post_form(target_site, {'myy' => '100', 'mmm' => '11', 'mdd' => '10', 'mhidden1' => 'false', 'mpno' => 'FB', 'mpnoname' => '康乃馨' })
		http.request(req)
	end
	
	return false,nil if respond.body.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/\<table[^$]*\<\/table\>/u).nil?
	
	table_string = String.new
	table_string << respond.body.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/\<table[^$]*\<\/table\>/u)
	# puts "table_string"+table_string #debug
	table_array = Array.new( table_string.split(/[\s]+\<\/div\>\<div[\s]align\=\"left\"\>[\s]+/u) )




	

	# 正在過濾變成utf8編碼後的網頁，尚未成功，已經濾得差不多了
	# Date: 20130525 
	i = 0
	string_array = Array.new
	table_array.each{|table|
		#table = table.force_encoding("utf-8")
		# string_array << table.slice(/\>([^\>\<\\r\\n\s]|\\)+\</u)
		if( i == 0 ) # meta data 額外處理
			string_array << table.gsub!(/\<(\/)?[^\<]+(\")?\>/u,'').gsub!("\r\n","").gsub!(/((?<=[^ ])( ){1,2}(?=[^ ]))|&nbsp;/u,'').gsub!(/[ ]+/u,',').gsub!(/(^,)|(,$)/u,'')#.gsub!(/[　]+/u,'""')
		else
			string_array << table.gsub!(/\<(\/)?[^\<]+(\")?\>/u,'').gsub!("\r\n","").gsub!(/((?<=[^ ])( ){1,2}(?=[^ ]))|&nbsp;/u,'').gsub!(/[ ]+/u,',').gsub!(/(^,)|(,$)/u,'').gsub!(/[　]+/u,'""')
		end
		i += 1
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


recv_mpno_list, recv_mpname_list = read_items_from_file()
puts "mpno_list: "+recv_mpno_list.to_s#debug
puts "====" #debug
puts "mpname_list: "+recv_mpname_list.to_s #debug

#qi_addr = ARGV[1] #ARGV[1] is the vegetable address

=begin
qi_year = ARGV[2] #ARGV[2] is the starting time
qi_month = ARGV
qi_day # not complete

=end

#ARGV[3] is the ending time
qi_time = Array.new
result_array = Array.new #store result for writing to file.

thirty_day_count = 0
date_today = Date.today
begin
	qi_year = date_today.year - 1911
	qi_month = date_today.month
	qi_day = date_today.day

	qi_time << qi_year.to_s #type conversion

	if qi_month < 10 && qi_month > 0
		qi_time << "0"+qi_month.to_s
	else
		qi_time << qi_month.to_s
	end
	if qi_day < 10 && qi_month > 0
		qi_time << "0"+qi_day.to_s
	else
		qi_time << qi_day.to_s
	end

	qi_machanize = Array.new
	i = 0
	recv_mpno_list.each{ |mpno|
		puts "i: "+ i.to_s # for debug
		qi_machanize[0] = mpno.to_s
		qi_machanize[1] = recv_mpname_list[i] 
		result_signal, tmp_array = crawl_data_and_filter(qi_time, qi_machanize)
		puts "編號: "+mpno+", 名稱: "+recv_mpname_list[i]+" 在此查詢類別不存在!" if result_signal == false
		result_array << tmp_array if tmp_array.nil? == false
		i += 1
		# break
	}

	qi_time.clear # clear query time array
	thirty_day_count += 1
	date_today -= 1	
end until( thirty_day_count >= 2 )

result_array.flatten!
File.open("data_thirty_days_vegetable.txt","w"){ |f|
	result_array.each{|element|
		f.puts(element)
	}
}
#可使用stdout重導向寫到檔案, at g0v hackth3n


