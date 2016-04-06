# encoding: utf-8
# Author: yhunglee
# Date: 20150815
# Objective: Do massive tasks of transforming overview and specified market files from original csv format to compact with relational databases format such as postgres and mysql through function: execuate_repeat_command
# It also imports generated database-compacted files to postgresql using function: import_csvfiles_to_db. This function only works with database-compacted files.
# It will interact with reorganize_rawdata_to_db.rb heavily.
# If you only want to do tasks of importing existed database-compacted files, please disable the function: execuate_repeat_command through masking its execuation.
# Before using this file, you have to set up postgres, create an user named Howard, create a database named mytest, create two tables in mytest database named overview_vegetable and specified_vegetable.
# The structure of two tables should be name, code, total_average_price, total_transaction_quantity and name, code, transaction_date, trade_location, kind, detail_processing_type, upper_price, middle_price, and lower_price, average_price, trade_quantity columns respectly.
require 'optparse'
require 'pg'

def get_csvoutputfilenames(runTimeArray, outputfileprefix)
	overviewCsvfilenameArray = Array.new
	specifiedCsvfilenameArray = Array.new

	runTimeArray.each{ |runtime|
		overviewCsvfilenameArray << (outputfileprefix + runtime + "-overview.csv" )
		specifiedCsvfilenameArray << (outputfileprefix + runtime + "-specified.csv" )
	}
	return overviewCsvfilenameArray, specifiedCsvfilenameArray
end

def retrieve_connect_settings_of_postgres
	# return dbname, user, password
	# We assume the database is located at local machine.
	arrayOfparameters = Array.new
	i = 0
	if Dir.exist?("./config") && File.exist?("./config/accountsetting.txt")
		File.open(".config/accountsetting.txt", "r") do |f|
			f.each_line do |line|
				if line =~ /^dbname=/u
					arrayOfparameters << line
				elsif line =~ /^user=/u
					arrayOfparameters << line
				elsif line =~ /^password=/u
					arrayOfparameters << line
				else
					puts "Stop executing."
					abort "Format of accountsetting.txt is wrong. Format of accountsettting.txt:\ndbname=YOURDBNAME\nuser=YOURDBUSERNAME\npassword=YOURDBPASSWORD\n  Besides, this file must contain only settings for only one user."
				end
				i += 1
				if i > 2 && arrayOfparameters.length == 3
					puts "Notice: We only use first setting, and following settings in config/accountsetting.txt won't be consider."
					break
				elsif i > 3
					puts "Stop executing."
					abort "Too many unuseful settings for database connection."
				end 
			end 
		end 
	else
		if !(Dir.exist?("./config"))
			Dir.mkdir("./config")
		end 
		if !(File.exist?("./config/accountsetting.txt"))
			File.open("./config/accountsetting.txt", "w") do |f|
				f.puts("dbname=","user=","password=")
			end 
		end 
		puts "Stop executing."
		abort "Error: You have to define a directory named config and a file named accountsetting.txt .\n Content of accountsetting.txt:\ndbname=YOURDBNAME\nuser=YOURDBUSERNAME\npassword=YOURDBPASSWORD"
	end

	arrayOfparameters.each do |value|
		if value =~ /^dbname=/u
			dbname = value.sub(/^dbname=/u,"")
		elsif value =~ /^user=/u
			user = value.sub(/^user=/u,"")
		elsif value =~ /^password=/u
			password = value.sub(/^password=/u,"")
		end
	end 
	return dbname, user, password
end 

def import_csvfiles_to_db(overviewfilenames, specifiedfilenames)

	dbname, user, password = retrieve_connect_settings_of_postgres
	conn = PG.connect(dbname: dbname, user: user, password: password)
	overviewfilenames.each{ |overviewFile|
		conn.exec("COPY overview_vegetable(name,code,date,total_average_price,total_transaction_quantity) from '#{Dir.pwd}/query_results/#{overviewFile}' WITH (DELIMITER ',', FORMAT csv, QUOTE '\"', ENCODING 'UTF8')")
	}
	specifiedfilenames.each{ |specifiedFile|
		conn.exec("COPY specified_vegetable(name,code,transaction_date,trade_location, kind, detail_processing_type, upper_price, middle_price, lower_price, average_price, trade_quantity) from '#{Dir.pwd}/query_results/#{specifiedFile}' WITH (DELIMITER ',', FORMAT csv ,QUOTE '\"', ENCODING 'UTF8')")
	}
end 

def initial_start_and_end_month_year(begintime, endtime)

	beExecuteTimearray = Array.new 
	monthArray = Array.new
	yearArray = Array.new
	currentYear = Time.now.year 
	for i in 1996..currentYear
		yearArray << i
	end 
	monthArray << "Jan" << "Feb" << "Mar" << "Apr" << "May" << "Jun" 
	monthArray << "Jul" << "Aug" << "Sep" << "Oct" << "Nov" << "Dec"

	beginMonth = begintime[0..2].capitalize
	if true == (monthArray.include?(beginMonth))

		beginMonthIndexInMonthArray = monthArray.index(beginMonth)
		beginYear = begintime[3..6].to_i 
		if true == (yearArray.include?(beginYear))

			endMonth = endtime[0..2].capitalize
			if true == (monthArray.include?(endMonth))

				endMonthIndexInMonthArray = monthArray.index(endMonth)
				endYear = endtime[3..6].to_i
				if true == (yearArray.include?(endYear))

					if 0 == (endYear - beginYear)
						for i in beginMonthIndexInMonthArray..endMonthIndexInMonthArray
							beExecuteTimearray << (monthArray[i] + (beginYear.to_s))
						end
						# solve the duration in same year.	
					else 
						increment_month = beginMonthIndexInMonthArray 
						for j in beginYear...endYear
							while increment_month < 12
								beExecuteTimearray << (monthArray[increment_month] + (j.to_s))
								increment_month += 1
							end 
							increment_month = 0
						end # generate First part month and year string: from (beginMonth concate BeginYear) to (December concate BeginYear). And generate second part month and year string: from (January concate (BeginYear+1) ) to (December concate (EndYear-1))

						while increment_month <= endMonthIndexInMonthArray 
							beExecuteTimearray << (monthArray[increment_month] + (endYear.to_s) )
							increment_month += 1
						end # generate last part month and year string: from (January concate EndYear) to (endMonth concate EndYear).
					end 
				else
					abort "Error: Wrong end year. Please check again. "
				end 
			else
				abort "Error: Wrong end month name. Please check again. "
			end 
		else
			abort "Error: Wrong begin year. Please check again!"
		end 
	else
		abort "Error: Wrong begin month name. Please check again."
	end

	return beExecuteTimearray
end

def execuate_repeat_command(runTimearray, inputfileprefix, outputfileprefix)

	inputfilesuffix = ".csv"
	runTimearray.each{ |runtime|
		if true == (File.file?(inputfileprefix + runtime + inputfilesuffix))
			system("ruby reorganize_rawdata_to_db.rb -i #{inputfileprefix}#{runtime}#{inputfilesuffix} -o #{outputfileprefix}#{runtime}")
		else
			abort "Error: The input file #{inputfileprefix}#{runtime}#{inputfilesuffix} doesn't exist."
		end

	}	
	 
end 


	command_options = Hash.new
	optionParser = OptionParser.new do |opts|
		opts.banner = "Usage: automcomplete_repeat_commands.rb {options}"
		opts.separator ""
		opts.separator "Specific options:"
		opts.on("-b BEGINTIME", "--begintime=MONYYYY", "specify what time is the start month for reorganizing files. Besides, the month format is from the first character to third of the month name. ") do |value|
			command_options[:begintime] = value
		end 

		opts.on("-e ENDTIME", "--endtime=MONYYYY", "specify what time is the end month for reorganziing files. Besides, the month format is from the first character to third of the month name. ") do |value|
			command_options[:endtime] = value 
		end 

		opts.on("-i INPUTFILE_PREFIX", "--inputfileprefix=DIRECTORY/INPUTFILE_PREFIX", "specify which directory and what the name prefix of files is . These files must be csv-format, so the script can concate prefix with month, year and dot_csv. ") do |value|
			command_options[:inputfileprefix] = value
		end

		opts.on("-o OUTPUTFILE_PREFIX", "--outputfileprefix=OUTPUTFILE_PREFIX", "specify what the name prefix of output files is and then the script can concate the prefix with month, year and dot_csv. Output files will placed at query_results directory. ") do |value| 
			command_options[:outputfileprefix] = value
		end

		opts.on_tail("-h", "--help", "show options" ) do 
			puts opts
			exit
		end

	end

	optionParser.parse!
	execuateTimeArray = initial_start_and_end_month_year(command_options[:begintime], command_options[:endtime])
	execuate_repeat_command(execuateTimeArray, command_options[:inputfileprefix], command_options[:outputfileprefix])
	overviewCsvfilenames, specifiedCsvfilenames = get_csvoutputfilenames(execuateTimeArray, command_options[:outputfileprefix])
	import_csvfiles_to_db(overviewCsvfilenames, specifiedCsvfilenames)
