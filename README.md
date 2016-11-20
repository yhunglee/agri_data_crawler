# 臺灣農產品市場大盤價格情報（原名：臺灣農產品價格情報）  
因為原本的網站在20160531改版了，從20160531開始抓取的花卉原始資料網頁將不含天氣資料。   
即將從Firefox 47，轉向支援Firefox 48及48後續版本的瀏覽器，Firefox 47及更早之前的版本將不會再支援。預計升級到watir 6.0套件和使用geckodriver 0.11.1及後續版本。   

## 聲明
1. 本軟體專案僅是提供市場交易資料和簡易獲取交易資料的工具，並無意圖影響交易市場行情。若有其他軟體專案、開發者或不特定之個人和團體，基於本軟體專案或是本軟體專案衍生的各種軟體專案、活動，進行影響交易市場行情之一切行為，本軟體專案概不負責。
2. 本軟體專案公布的市場交易資料Raw data皆是來自中華民國政府農產業部門相關網站公布的資料，皆相依於資料來源中各網站的資料正確性和完整性。
3. 本軟體專案並無能力、人力...等等泛稱資源的項目，去保證資料的正確性、完整性，所以若您因為使用本軟體專案提供的市場交易資料和簡易獲取交易資料的工具，造成您名譽上或實質上的任何損失，本軟體專案概不負責。若您無法接受這項聲明，敬請不要使用本軟體專案提供的任何項目，謝謝。
4. 程式碼授權採用BSD 3-Clause License授權條款；市場交易資料之授權條款<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/tw/deed.zh_TW"><img alt="創用 CC 授權條款" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/tw/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">臺灣農產品市場大盤價格情報</span>由<a xmlns:cc="http://creativecommons.org/ns#" href="https://github.com/yhunglee/agri_data_crawler" property="cc:attributionName" rel="cc:attributionURL">Howardsun</a>製作，以<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/tw/deed.zh_TW">創用CC 姓名標示-相同方式分享 3.0 台灣 授權條款</a>釋出。

## 目標
* 提供開發者Raw data，方便運用至預想之發展，例如視覺化資料、分析價格情報趨勢......等等用途。

## 資料來源
* 中華民國政府農產業部門相關網站公布的資料。
1. http://amis.afa.gov.tw
陸續加入中。   


## 預計涵蓋品項範圍：
盆花、家禽、漁產、畜產......等等，會持續擴展範圍。  
 
## 目前涵蓋範圍
* 蔬菜（自2013-06-21開始提供功能），水果（自2013-10-12開始提供功能），花卉（自2013-07-13開始提供功能）。
* 目前類似且具代表性的網站：中華民國行政院農業委員會的農業化行動平台 http://m.coa.gov.tw/  。

* 目前提供：CSV（自2013-06-21開始提供），JSON（自2013-07-13開始提供）。

* 資料下載處：[蔬菜1996年1月到2013年10月單日交易價格Postgresql資料庫備份](https://drive.google.com/file/d/0B6LCYMv5HpdWemswYUlpMnlXZ1U/view?usp=sharing)、[蔬菜1996年1月到2013年10月單日全台各市場交易價格Postgresql資料庫備份](https://drive.google.com/file/d/0B6LCYMv5HpdWSjk1VFdoMThoWXc/view?usp=sharing)
、[花卉類不含盆花1996年1月到2013年7月] (https://drive.google.com/file/d/0B6LCYMv5HpdWaUozZ1pUVEtkcDQ/view?usp=sharing)、[花卉類不含盆花2013年8月到10月](https://drive.google.com/file/d/0B6LCYMv5HpdWU1ZGbXNtUmo2QkU/view?usp=sharing
)、[水果1996年1月到2013年7月] (https://drive.google.com/file/d/0B6LCYMv5HpdWS2lPSTYzU2lHdEk/view?usp=sharing)、[水果2013年8月到10月](https://drive.google.com/file/d/0B6LCYMv5HpdWVUI1cmQ5aktkdVk/view?usp=sharing)  

## 各程式功能說明
1. my_vegetable_crawler.rb：用於抓取資料，可以提供蔬菜，水果和花卉的資料抓取。
2. my_automate_operator.rb ：用於下指令給my_vegetable_crawler.rb，可指定長時間資料區段的抓取。為了讓cron task program只須用一個單一進入點，已新增流程：呼叫autocomplete_repeat_commands.rb進行短時間(一日)或長時間(一日以上)的倒入已抓取資料到postgres資料庫中。
3. reorganize_rawdata_to_db.rb：用於整理my_vegetable_crawler.rb產生的CSV格式檔案，以便由autocomplete_repeat_commands.rb匯入postgresql資料庫。（目前只完成整理蔬菜，尚未完成水果和花卉的整理）
4. autocomplete_repeat_commands.rb：向reorganize_rawdata_to_db.rb下達指令，指定長時間資料區間的檔案匯入postgresql資料庫。
5. my_format_csv_to_json.rb：用於轉換CSV格式到JSON格式。由於轉換到JSON的結果果不符正統JSON及可匯入資料庫格式，現已停用，建議不使用這份程式進行轉換。
6. my_rm_duplicate_lines.rb：以每列為單位，用以刪除重複的資料。由於已經忘記何時會用到這份程式，現已停用，建議不使用它。

## 使用各程式的預先準備工作
1. 在Mac OSX 10.10 以後的版本，必須安裝XQuartz，因為本專案會用到Headless套件去呼叫XVFB，再經由XVFB啟動火狐(Firefox)瀏覽器，所以也請確認必須先安裝火狐瀏覽器。  
2. 不論是執行 my_vegetable_crawler.rb 檔案，或是經由 autocomplete_repeat_commands.rb 檔案執行 my_vegetable_crawler.rb 檔案，第一次執行時會遇到錯誤訊息:   
<pre><code> ... (skip) directory /tmp/.X11-unix will not be created ... (skip) </code></pre>   
請在終端機(Terminal)畫面輸入以下指令即可解決：  
<pre><code> mkdir /tmp/.X11-unix 
sudo chmod 1777 /tmp/.X11-unix
</code></pre>  解決方法資料來源網頁: [http://wineskin.urgesoftware.com/tiki-view_forum_thread.php?comments_parentId=3675](http://wineskin.urgesoftware.com/tiki-view_forum_thread.php?comments_parentId=3675)
3. 在Linux Debian/Ubuntu 環境，則請依照[Headless gem 在 GitHub page 的指示](https://github.com/leonid-shevtsov/headless)，安裝 XVFB 和 Headless 套件。
<pre><code>sudo apt-get install xvfb  
gem install headless
</code></pre>   
4. 目前的程式碼僅適用Firefox 46含先前的版本，Firefox 47 以後的版本因目前 Marionette 軟體忽略 UnhandledAlertError，而 my_vegetable_crawler.rb 需要使用 UnhandledAlertError ，所以暫時無法使用。  
5. 預計將轉向支援Firefox 48及後續版本的瀏覽器，目前本分支正在進行籌備與撰寫程式的工作。   
6. 請從[Geckodriver在GitHub的專案網址下載](https://github.com/mozilla/geckodriver/releases)，本專案已經測試過0.11.1可以正常使用。另外，Geckodriver請放在執行機器的**$PATH**值的目錄，例如**$PATH**的值是_/usr/local/bin/:/Users/<YOURNAME>/.rvm/rubies/bin:/usr/bin_，Geckodriver檔案可以放在這三個目錄中的其中一個即可。   

## 設定config目錄
* 執行autocomplete_repeat_commands.rb檔案前，請在專案家目錄之下建立config目錄，並於config目錄內，新增一個純文字檔案，名稱是accountsetting.txt，以方便本機的postgresq資料庫程式。 
* accountsetting.rb檔案內容格式是
<pre><code>dbname=YOURDBNAME   
user=YOURDBUSERNAME   
password=YOURDBUSERPASSWORD   
</code></pre>
* 空密碼不用輸入

* my_automate_operator.rb程式執行指令說明：
命令列指令  
<pre><code>ruby my_automate_operator.rb &lt;StartDate&gt; &lt;EndDate&gt; &lt;OutputFileName&gt; &lt;vegetable|fruit|flowers&gt; [onlyconvertojson] </code></pre>  
查詢開始日期最早只能是1996年1月1日，查詢結束日期最晚只能是查詢時的當天；輸出檔名請自行輸入名稱，程式會自動按月份存檔；查詢種類目前有蔬菜、水果、花卉；若在命令列的最後輸入onlyconvertojson，只會轉換本機現有的csv檔案成json檔，並不會從網路抓取資料。   
* reorganize_rawdata_to_db.rb程式執行指令說明：
命令列指令   
<pre><code>ruby reorganize_rawdata_to_db.rb -i INPUTFILE -o OUTPUTFILE -k INPUTKIND</code></pre>
-i是輸入檔案的參數，INPUTFILE可以包含輸入檔案的目錄路徑；-o是輸出檔案的參數，OUTPUTFILE只能是輸出檔案的前綴名稱，不能包含檔案的目錄路徑，且輸出檔案會強制放在query_results這個資料夾下，INPUTKIND是告訴城市依照蔬菜，水果或花卉的格式處理資料。
reorganize_rawdata_to_db.rb執行結果會分別產生OUTPUTFILE-overview.csv和OUTPUTFILE-specified.csv兩類檔案，可運用autocomplete_repeat_commands.rb讀取這些檔案以批量輸入資料庫。reorganize_rawdata_to_db.rb --help會顯示操作說明的英文版。   
* autocomplete_repeat_commands.rb程式執行指令說明：
命令列指令
<pre><code>ruby autocomplete_repeat_commands.rb -b BEGINMONTH -e ENDMONTH -i INPUTFILE_PREFIX -o OUTPUTFILE_PREFIX </code></pre>  
Or
<pre><code>ruby autocomplete_repeat_commands.rb -i INPUTFILE_PREFIX -o OUTPUTFILE_PREFIX </code></pre>  
-b 是批量輸入月份檔案的開始月份參數，BEGINMONTH的格式是月份的英文名前三個字元與西元年份四個字元，例如Aug2013；-e是批量輸入月份檔案的結束月份參數，ENDMONTH的格式是月份的英文名前三個字元與西元年份四個字元，例如Oct2013。-i是輸入檔案的參數，INPUTFILE_PREFIX僅能使用輸入檔案的前綴名稱，程式會自動加上月份與年份的後綴字，可以包含檔案的目錄路徑，例如query_results/vegetable_amis_；-o是輸出檔案的參數，OUTPUTFILE_PREFIX只能是輸出檔案的前綴名稱，程式會自動加上月份與年份的後綴字，不能包含檔案的目錄路徑，例如:vegetable_，且輸出檔案會強制放在query_results這個資料夾之下。  
若沒同時給予-b和-e，以及其相對應的參數值，則預設只抓取執行當日的前一天資料。

## 資料格式說明

### 蔬菜CSV正確格式說明
總類：   
1. 每2行是一種蔬菜在某天臺灣所有大盤市場的一筆交易資料，例如第1行和第2行構成一筆交易資料。   
2. 奇數行只有4個欄位種類, 依序是交易日期、產品名稱、總交易量、總平均價，以半形冒號分開描述欄位文字與欄位值。   
3. a)奇數行是一種蔬菜在某天臺灣所有大盤市場的交易資料之概觀，總交易量和總平均價是來自各大盤市場的計算加總與平均值。   
b)偶數行只有10個欄位種類, 依序是市場名稱、品種名稱、處理別、上價、中價、下價、平均價、增減%、交易量、增減%，第一個增減%是指今日特定市場平均價價格與前一次/天的平均價價格的比較，第二個增減%是指今日特定市場交易量與前一次/天的交易量比較。   
4. 偶數行包含描述欄位種類的文字(如本格式說明的第3點)，實際欄位數量是10的倍數。   
5. 如果增減%欄位值出現 \+\*\*\* 或是\-\*\*\*，則表示今日相較於前一次/天，增長或減少幅度超越 100%。   
6. 如果欄位值出現\"\"，則表示在官方資料中，此欄位是空白。   
7. 完整例子請參考vegetable_amis_Sep2012.csv 。   

總量欄位：   
{item_id & item_name}, transaction_date, total_transaction_quantity, total_average_price   

各市場交易價格資料欄位：   
market_name, type_name, processing_name, upper_price, middle_price, down_price, average_price, change_percentage_of_average_price, transaction_quantity, change_percentage_of_transaction_quantity   

### 花卉CSV正確格式說明   
總類：   
1. 每2行是一種花卉在某天台灣所有大盤市場的一筆交易資料，例如第1行和第2行構成一筆交易資料。   
2. 奇數行只有5個欄位種類, 依序是交易日期、總平均價、總交易量、總殘貨量、產品名稱（欄位名稱順序與蔬菜、水果不同），以半形冒號分開描述欄位文字與欄位值。   
3. a)奇數行是一種花卉在某天臺灣所有大盤市場的交易資料之概觀，總交易量和總平均價是來自各大盤市場的計算加總與平均值。   
b)偶數行只有11個欄位種類, 依序是市場名稱、品種名稱、最高價、上價、中價、下價、平均價、增減%、交易量、增減%、殘貨量，第一個增減%是指今日特定市場平均價價格與前一次/天的平均價價格的比較，第二個增減%是指今日特定市場交易量與前一次/天的交易量比較。   
4. 偶數行包含描述欄位種類的文字(如本格式說明的第3點)，實際欄位數量是11的倍數。   
5. 如果增減%欄位值出現 \+\*\*\* 或是\-\*\*\*，則表示今日相較於前一次/天，增長或減少幅度超越 100%。   
6. 如果欄位值出現\"\"，則表示在官方資料中，此欄位是空白。   
7. 完整例子請參考flowers_amis_Apr1996.csv 。   

總量欄位：   
{item_id & item_name}, transaction_date, total_transaction_quantity, total_nest_quantity, total_average_price, total_nest_quantity    

各市場交易價格資料欄位：   
{item_id & item_name}, transaction_date, market_name, type_name, highest_price, upper_price, middle_price, down_price, average_price, change_percentage_of_average_price, transaction_quantity, change_percentage_of_transaction_quantity, nest_quantity     

### 水果CSV正確格式說明  
總類：   
1. 每2行是一種水果在某天台灣所有大盤市場的一筆交易資料，例如第1行和第2行構成一筆交易資料。   
2. 奇數行只有6個欄位種類, 依序是交易日期、產品名稱、品種名、處理別、總交易量、總平均價，以半形冒號分開描述欄位文字與欄位值。   
3. a)奇數行是一種水果在某天臺灣所有大盤市場的交易資料之概觀，總交易量和總平均價是來自各大盤市場的計算加總與平均值。   
b)偶數行只有11個欄位種類, 依序是市場名稱、天氣、上價、中價、下價、平均價、增減%、交易量、增減%，第一個增減%是指今日特定市場平均價價格與前一次/天的平均價價格的比較，第二個增減%是指今日特定市場交易量與前一次/天的交易量比較。   
4. 偶數行包含描述欄位種類的文字(如本格式說明的第3點)，實際欄位數量是9的倍數。   
5. 如果增減%欄位值出現 \+\*\*\* 或是\-\*\*\*，則表示今日相較於前一次/天，增長或減少幅度超越 100%。   
6. 如果欄位值出現\"\"，則表示在官方資料中，此欄位是空白。   
7. 完整例子請參考fruit_amis_Apr1996.csv 。   

總量欄位：   
{item_id & item_name}, type_name, processing_name, transaction_date, total_transaction_quantity, total_average_price   

各市場交易價格資料欄位：  
{item_id & item_name}, transaction_date, market_name, weather, upper_price, middle_price, down_price, average_price, change_percentage_of_average_price, transaction_quantity, change_percentage_of_transaction_quantity   


***
# Transactional prices of agricultural products of wholesale markets in Taiwan   
Because the original website of agricultural data had changed at thirty-one May 2016, we don't provide weather information inside flowers data from that day.    
We are planning letting it to support Firefox 48 and onward versions, and we are working on this branch now. It will use watir 6.0 and geckodriver 0.11.1 versions, which include newer ones. This branch hasn't complete the work.

## Claims
1. This software is provided as a tool only for collecting transactional prices easily and we don't have any intention to make impacts on trade markets in Taiwan. If there are some projects, developers, or interested groups and people influencing trade markets for agricultural products, this software and we won't take responsibities for them.      
2. Raw data of transactional prices announced by this software come from departments of agriculture-related of Taiwan, and these data all depend on ones they have released.    
3. This software project and we don't guarantee correctness and integrity of data. If you lose in reputation or substance due to use data or the software we provide, we won't take any responsibities for you. If you refuse to accept this claim, please don't use anything we offer. Thank you.   
4. This software's license is BSD3-Clause and the license of transactional data in Taiwan markets released at here is Creative Commons.<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/tw/deed.zh_TW"><img alt="創用 CC 授權條款" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/tw/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">臺灣農產品市場大盤價格情報</span>由<a xmlns:cc="http://creativecommons.org/ns#" href="https://github.com/yhunglee/agri_data_crawler" property="cc:attributionName" rel="cc:attributionURL">Howardsun</a>製作，以<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/tw/deed.zh_TW">創用CC 姓名標示-相同方式分享 3.0 台灣 授權條款</a>釋出    

## Goal
* To provide raw data to every interested person and group to do what they want. For example, we think someone would use them to do data-visualization or analysis based on them.    

## Data sources
* Departments of agriculture-related of Taiwan    
1. http://amis.afa.gov.tw     
We continue to add others into the list as soon as possible.   

## Roadmap to other products in agricultural markets
* Potted flowers, poultry, fishes, livestock    

## Currently, we provide
* Vegetable(start from 2013-06-21), fruit(start from 2013-10-12) and flowers(start from 2013-07-13).   
* The other similar website is http://m.coa.gov.tw . That website is built by Council of Agriculture of Taiwan.    
* Links for downloading: [Data of vegetable start from January 1996 to October 2013 everyday in format of Postgres dump](https://drive.google.com/file/d/0B6LCYMv5HpdWemswYUlpMnlXZ1U/view?usp=sharing)、[Data of vegetable in main markets of Taiwan range from January 1996 to October 2013 in format of Postgres dump](https://drive.google.com/file/d/0B6LCYMv5HpdWSjk1VFdoMThoWXc/view?usp=sharing)
、[Data of flowers range from January 1996 to July 2013 everyday in format of Postgres dump] (https://drive.google.com/file/d/0B6LCYMv5HpdWaUozZ1pUVEtkcDQ/view?usp=sharing)、[Data of flowers range from August 2013 to October 2013 everyday in format Postgres dump](https://drive.google.com/file/d/0B6LCYMv5HpdWU1ZGbXNtUmo2QkU/view?usp=sharing
)、[Data of fruit range from January 1996 to July 2013 everyday in format of Postgres dump] (https://drive.google.com/file/d/0B6LCYMv5HpdWS2lPSTYzU2lHdEk/view?usp=sharing)、[Data of fruit range frrom August 2013 to October 2013 everyday in format of Postgres dump](https://drive.google.com/file/d/0B6LCYMv5HpdWVUI1cmQ5aktkdVk/view?usp=sharing)

## Explanations for every program    
1. my_vegetable_crawler.rb: used for collecing data of vegetables, fruit and flowers from remote websites.   
2. my_automate_operator.rb: send commands to my_vegetable_crawler.rb, and we can dispatch crawling jobs for long-time range. The program has added a procedure about crawling short, which is an one-day collection, and long periods, which are over than one-day, and then dumping them into databases by single entry point of crontab tasks calling autocomplete_repeat_commands.rb.    
3. reorganized_rawdata_to_db.rb: used for reorganizing to CSV format from raw data filtered and generated by my_vegetable_crawler.rb. And then autocomplete_repeat_commands.rb can import CSV-format data to Postgres databases. Currently, we only finish the part for vegetable. Parts for fruit and flowers haven't finished.    
4. autocomplete_repeat_commands.rb: This program can send commands to reorganize_rawdata_to_db.rb for arranging data of long-time periods and importing them to Postgres.    
5. my_format_csv_to_json.rb: Don't use this program now because we don't need it to convert CSV-data to json and its converted results may be wrong. This program is used for transform CSV data to json ones.    
6. my_rm_duplicate_lines.rb: Used as deleting duplicate data by tuples. As same as my_format_csv_to_json.rb now, don't use this program. We have forgotten when it should be performed.    

## Prerequites before perform each program we listed above
1. After versions of mac OSX 10.10, you should install XQuartz. We need it to work with Headless gem and XvfB software. You also need to install firefox browser because XvfB will interact with firefox.    
2. No matter performing my_vegetable_crawler.rb directly or run it by autocomplete_repeat_commands.rb, you may receive an error message like this:   
<pre><code> ...(skip) directory /tmp/.X11-unix will not be created ... (skip) </code></pre>    
Please type following comands in a terminal for fixing it :    
<pre><code> mkdir /tmp/.X11-unix
sudo chmod 1777 /tmp/.X11-unix
</code></pre> This solution refers from a webpage: [http://wineskin.urgesoftware.com/tiki-view_forum_thread.php?comments_parentId=3675](http://wineskin.urgesoftware.com/tiki-view_forum_thread.php?comments_parentId=3675)   
3. When the software will run in Linux Debian or Ubuntu, please follow [Headless's instructions inside the github's webpage](https://github.com/leonid-shevtsov/headless) to install XvfB software and Headless gem.    
<pre><code>sudo apt-get install xvfb
gem install headless
</code></pre>     
4. Current version of this software can only be executed with Firefox 46 and earlier release. It can't run with Firefox 47 and later ones because the Marionette software ignore the exception:UnhandledAlertError. That's what my_vegetable_crawler.rb needs, so it can't available for Firefox 47 and later ones.    

## Configure directory of config    
* Before executing autocomplete_repeat_commands.rb, please create a directory named config. Then you put a new text file named accountsetting.txt under the config directory. Format of accountsetting.txt is :    
<pre><code>dbname=YOUDBNAME
user=YOURDBUSERNAME
password=YOURDBUSERPASSWORD
</code></pre>    
* Don't write anything if the db password is empty.    

* Explanation of my_automate_operator.rb commands:
Command   
<pre><code>ruby my_automate_operator.rb &lt;StartDate&gt; &lt;EndDate&gt; &lt;OutputFileName&gt; &lt;vegetable|fruit|flowers&gt; [onlyconvertojson] </code></pre>
The earliet date of the parameter: startdate only can be 1996-01-01, and the latest date of the parameter: enddate only can be the day when you sending the query. Please assign what name you like for output file name and the software will save contents' order by months. You can assign query type what you want and we provide vegetable, fruit and flowers. If you append onlyconvertojson in the end of command line, it only executes functions of converting local CSV files to JSON instead of crawling data from a remote website.    
* Explanation of reorganize_rawdata_to_db.rb:    
Command    
<pre><code>ruby reorganize_rawdata_to_db.rb -i INPUTFILE -o OUTPUTFILE -k INPUTKIND</code></pre>
The parameter of -i indicates execution with an input file. You can assign a real file at position of INPUTFILE and this position can contain path of the file. The parameter of -o indicates execution with an output file. You can assign a real file at position of OUTPUTFILE and this position CANNOT contain path of the file. The parameter of -k indicates what kind you want to re-arrange and import to Postgres. The value of INPUTKIND can be vegetable, fruit or flowers.    
Results of executing reorganize_rawdata_to_db.rb named OUTPUTFILE-overview.csv and OUTPUTFILE-specified.csv can be read and imported to Postgres database by autocomplete_repeat_commands.rb. <pre><code>reorganize_rawdata_to_DB.RB --help</code></pre> will display how to use it.    

* Explanation of executing autocomplete_repeat_commands.rb: 
Command    
<pre><code>ruby autocomplete_repeat_commands.rb -b BEGINMONTH -e ENDMONTH -i INPUTFILE_PREFIX -o OUTPUTFILE_PREFIX</code></pre>    
<pre><code>ruby autocomplete_repeat_commands.rb -i INPUTFILE_PREFIX -o OUTPUTFILE_PREFIX</code></pre>    
The parameter of -b indicates name of start month for bulk-loading and format of its content: BEGINMONTH is first-to-third characters of its abbreviation concated with 4 numbers of common era such as Aug2013. The purpose of parameter of -e is similar with -b, but it indicates name of the end month. The purpost and format of parameter of ENDMONTH is similar with BEGINMONTH, but its value indicates name of the end month for quering.  The parameter of -i is used to indicate that you will set an prefix of a inputfile. You can assign prefix name of an input file through parameter of INPUTFILE_PREFIX, and it can contain path of a file such as query_results/vegetable_amis_. The purpose of parameter -o indicates that you will set an prefix of output files.  The purpose and value of parameter OUTPUTFILE_PREFIX is similar as INPUTFILE_PREFIX, but its value cannot contain path of an output file. OUTPUTFILE_PREFIX is used for setting prefix of an output file and you don't need to append any month and year. The program will do it for you. Besides, the location of output files are under the directory: query_results .    
If you don't put -b, -e, BEGINMONTH and ENDMONTH simultaneously, this program will crawl data at remote website implicitly.    




- Copyright (c) 2013, yhunglee
All rights reserved.

- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
