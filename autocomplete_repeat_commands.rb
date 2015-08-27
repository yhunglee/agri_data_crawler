# encoding: utf-8
# Author: yhunglee
# Date: 20150815
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

def import_csvfiles_to_db(overviewfilenames, specifiedfilenames)

	conn = PG.connect(dbname: 'mytest', user: 'Howard')

	overviewfilenames.each{ |overviewFile|
		conn.exec("COPY overview_vegetable(name,code,date,total_average_price,total_transaction_quantity) from '#{Dir.pwd}/query_results/#{overviewFile}' WITH (DELIMITER ',', FORMAT csv, QUOTE '\"', ENCODING 'UTF8')")
	}

=begin
	specifiedfilenames.each{ |specifiedFile|
		conn.exec("COPY specified_vegetable(name,code,transaction_date,trade_location, kind, detail_processing_type, upper_price, middle_price, lower_price, average_price, trade_quantity) from '#{Dir.pwd}/query_results/#{specifiedFile}' WITH (DELIMITER ',', FORMAT csv ,QUOTE '\"', ENCODING 'UTF8')")
	}
=end
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
