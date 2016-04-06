# encoding: utf-8
# Author: yhunglee
# Date: 2013/10/30
#
# ************************************
#  This is a robot for crawling data of long times, which are considered in months, and converting csv to json.
#  It will issue commands to my_vegetable_crawler.rb heavily for aquiring data of long-term time period from a website.
#  We could assign what it would acquire such vegetable, fruit and flowers 
# ************************************

require 'date'

unless ARGV.length > 2 && ARGV.length < 6
	puts "Available command: ruby my_automate_operator.rb <Start Date:YYYY-MM-01> <End Date:YYYY-MM-28> <Name format of output file> [vegetable|fruit|flowers] [onlyconvertojson]"
	puts "RECOMMEND: QUERY From first day of every month to last one in the month."
	puts "Format of start and end date is using AD. YYYY-MM-DD, I will transform it to format of Republic of China."
	puts "Available value range of start date is 1996-01, and we can't query someday that in the future."
	puts "Available value range of end date is greater than or equal to start date."
	puts "Name format of output file is {vegetable|fruit|flowers}_amis_. I will append MONTH and YEAR."
	puts "-------------------------------------------------------"
	puts "Every output file is putted at under directory of query_results. Content format is csv-style originally."
	puts "Kind of parameter:vegetable|fruit|flowers is optional, and vegetable is the implicit value."
	puts "Parameter of onlyconvertojson is optional, and the implicit value is doing both generating csv-file and conversion from csv to json. Explict value is only do the task converting from existed csv files to json ones."
	exit
end

begin
	argv_start_date = Date.parse ARGV[0] # ARGV[0] is the start date
	if argv_start_date.year < 1996

		puts "Error: Start date must start from 1996A.D.."
		exit
	elsif (argv_start_date <=> Date.today) == 1

		puts "Error: We can't query information in the future via this program when start date is greater than today."
		exit
	end
rescue ArgumentError
	puts "Error: Start date's value isn't exist in calendar."
	exit
	
end


#ARGV[1] is the ending time
begin
	argv_end_date = Date.parse ARGV[1] # ARGV[1] is the end date
	#ARGV[1] is the <end date>

	if (argv_end_date <=> argv_start_date) == -1
		puts "Error: End date must greater than or equal to start date."
		exit
	elsif (argv_end_date <=> Date.today) == 1
		# This may have a bug, but I don't care because I just want to crawl date in large time range. 
		puts "Error: We can't query information in the future via this program when end date is greater than today."
		exit
	end
rescue ArgumentError
	puts "Error: End date's value isn't exist in calendar."
	exit
end


#ARGV[2] is the name format of output file
argv_output_file = ARGV[2] + "_"
puts "argv_output_file: "+argv_output_file #debug

#ARGV[3] is an option for quering vegetable, fruit or flowers.
if ARGV[3].nil?
	q_type = 1
	onlyconvertojson = false
	# false of onlyconvertojson means we do both crawling data from websites and conversion files from csv to json.
else
	argv_query_type = ARGV[3].downcase
	case argv_query_type
	when "vegetable"
		q_type = 1
	when "fruit"
		q_type = 2
	when "flowers"
		q_type = 3
	when "onlyconvertojson"
		q_type = 1 # for vegetable
		onlyconvertojson = true
		# true of onlyconvertojson means we only do conversion files from csv to json.
	else
		puts "Error: Parameter of query_type must be vegetable, fruit or flowers. I don't care UPCASE or downcase."
		exit
	end
end

if ARGV[4].nil? # ARGV[4] is a flag for turning off crawling data.
	onlyconvertojson = false
	# false of onlyconvertojson means we do both crawling data from websites and conversion files from csv to json.
else

	argv_flag_of_onlyconvertojson = ARGV[4].downcase
	case argv_flag_of_onlyconvertojson
	when "onlyconvertojson"
		onlyconvertojson = true
		# true of onlyconvertojson means we only do conversion files from csv to json.
	else
		puts "Error: Parameter of onlyconvertojson must be setted onlyconvertojson. I don't care UPCASE or downcase."
		exit
	end

end

cmd_start_date = argv_start_date
abbr_month_names = Array.new
abbr_month_names << "" # for empty
abbr_month_names << "Jan" # 1
abbr_month_names << "Feb" # 2
abbr_month_names << "Mar" # 3
abbr_month_names << "Apr" # 4
abbr_month_names << "May" # 5
abbr_month_names << "Jun" # 6
abbr_month_names << "Jul" # 7
abbr_month_names << "Aug" # 8
abbr_month_names << "Sep" # 9
abbr_month_names << "Oct" # 10
abbr_month_names << "Nov" # 11
abbr_month_names << "Dec" # 12
month_count = 0 # count times for every pass month
while (-1 == (cmd_start_date <=> argv_end_date)) || (0 == (cmd_start_date <=> argv_end_date))

	begin

		i = cmd_start_date.month # i is index for getting abbr month name
		cmd_output_file = String.new(argv_output_file + abbr_month_names[i] + cmd_start_date.year.to_s + ".csv")
		puts "cmd_output_file: "+cmd_output_file #debug
	
		# if turning off flag of onlyconvertojson
		if onlyconvertojson == false

			# Generating cmd_query_end_date
			tmp_end_year = cmd_start_date.year
			tmp_end_month = cmd_start_date.month
			month_diff = argv_end_date.month - cmd_start_date.month # consider example: query time interval from 2000/2/24 to 2000/3/12
			day_diff = (argv_end_date - cmd_start_date).to_i

			if 2 == cmd_start_date.month

				if cmd_start_date.leap?

					if day_diff >= 29
						tmp_end_day = 29
					else
						if month_diff > 0 # consider example: query time interval from 2000/2/24 to 2000/3/12
							tmp_end_day = 29
						else
							tmp_end_day = argv_end_date.day
						end
					end
				else
					if day_diff >= 28
						tmp_end_day = 28
					else
						if month_diff > 0 # consider example: query time interval from 2000/2/24 to 2000/3/12
							tmp_end_day = 28
						else
							tmp_end_day = argv_end_date.day
						end
					end
				end
			else

				if cmd_start_date.month >= 8
					if (0 == cmd_start_date.month % 2)
						if day_diff >= 31
							tmp_end_day = 31
						else
							if month_diff > 0 # consider example: query time interval from 2000/2/24 to 2000/3/12
								tmp_end_day = 31
							else
								tmp_end_day = argv_end_date.day
							end
						end
					else
						if day_diff >= 30
							tmp_end_day = 30
						else
							if month_diff > 0 # consider example: query time interval from 2000/2/24 to 2000/3/12
								tmp_end_day = 30
							else
								tmp_end_day = argv_end_date.day
							end
						end
					end
				else # if cmd_start_date.month < 8

					if 0 == cmd_start_date.month % 2
						if day_diff >= 30
							tmp_end_day = 30
						else
							if month_diff > 0 # consider example: query time interval from 2000/2/24 to 2000/3/12
								tmp_end_day = 30
							else
								tmp_end_day = argv_end_date.day
							end
						end
					else
						if day_diff >= 31
							tmp_end_day = 31
						else
							if month_diff > 0 # consider example: query time interval from 2000/2/24 to 2000/3/12
								tmp_end_day = 31
							else
								tmp_end_day = argv_end_date.day
							end
						end
					end
				end

			end

			cmd_end_date = Date.new(tmp_end_year, tmp_end_month, tmp_end_day)
			# Generating cmd_query_end_date

			# Crawling data
			case q_type
			when 1 # vegetable
				system("ruby my_vegetable_crawler.rb #{cmd_start_date} #{cmd_end_date} #{cmd_output_file}")	
			when 2 # fruit
				system("ruby my_vegetable_crawler.rb #{cmd_start_date} #{cmd_end_date} #{cmd_output_file} fruit")	

			when 3 # flowers
				system("ruby my_vegetable_crawler.rb #{cmd_start_date} #{cmd_end_date} #{cmd_output_file} flowers")	

			else

				puts "Error: Parameter of query_type must be vegetable, fruit or flowers. I don't care UPCASE or downcase."
				exit
			end
			# Crawling data

		end
		# if turning off flag of onlyconvertojson

=begin
		# Converting csv to json
		puts "Converting csv to json"
		cmd_convert_to_json_file = cmd_output_file.sub(/\.csv/u, ".json")
		case q_type
		when 1 # vegetable
		
			system("ruby my_format_csv_to_json.rb query_results/#{cmd_output_file} #{cmd_convert_to_json_file}")	
		when 2 # fruit
			system("ruby my_format_csv_to_json.rb query_results/#{cmd_output_file} #{cmd_convert_to_json_file} fruit")	

		when 3 # flowers
			system("ruby my_format_csv_to_json.rb query_results/#{cmd_output_file} #{cmd_convert_to_json_file} flowers")	

		else

			puts "Error: Parameter of query_type must be vegetable, fruit or flowers. I don't care UPCASE or downcase."
			exit
		end
		# Converting csv to json
=end


		# Run autocomplete_repeat_commands.rb
		system("ruby autocomplete_repeat_commands.rb -b #{Date::ABBR_MONTHNAMES[cmd_start_date.month]}#{cmd_start_date.year} -e #{cmd_start_date.month}#{cmd_start_date.year} -i #{argv_output_file} -o dbimport_" )
		# Run autocomplete_repeat_commands.rb

		cmd_start_date = cmd_start_date.next_month()
		month_count += 1
		if month_count > 0
			cmd_start_date = Date.new(cmd_start_date.year, cmd_start_date.month, 1) # setting day to 1 because after first month we have queried, we need to start from first day of new month for querying.
		end
	end

end
