# encoding: utf-8
# Author: howardsun
# Date: 2013/03/10

require 'net/http'

def read_items_from_file

	array_mpno = Array.new
	array_mpno_name = Array.new
	File.open("txt_vegetable.txt", "r"){ |f|
		while line = f.gets
			content = line.split("\t")
			array_mpno << content[0]
			array_mpno_name << (content[1].delete! "\n")
		end
	}

	return array_mpno, array_mpnoname
end


	target_site = URI("http://amis.afa.gov.tw/v-asp/v101r.asp")
	# http://amis.afa.gov.tw/v-asp/v101q.asp is the page of vegetable query form.

	req = Net::HTTP::Post.new(target_site.path)
	req.set_form_data('myy' => '102', 'mmm' => '05', 'mdd' => '26', 'mhidden1' => 'false', 'mpno' => 'FD', 'mpnoname' => '花胡瓜')

	respond = Net::HTTP.start(target_site.host, target_site.port) do |http|

		#respond = Net::HTTP.post_form(target_site, {'myy' => '100', 'mmm' => '11', 'mdd' => '10', 'mhidden1' => 'false', 'mpno' => 'FB', 'mpnoname' => '康乃馨' })
		http.request(req)
	end
	

	#puts respond.body #debug


	table_string = String.new
	table_string << respond.body.encode('UTF-8', 'BIG5', :invalid => :replace, :undef => :replace, :replace => ' ').slice(/\<table[^$]*\<\/table\>/u)
	# puts "table_string"+table_string #debug
	table_array = Array.new( table_string.split(/[\s]+\<\/div\>\<div[\s]align\=\"left\"\>[\s]+/u) )




	# puts table_array.to_s #debug
	puts "table_array size: "+ table_array.size.to_s #debug
	

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


