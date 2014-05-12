# 臺灣農產品市場大盤價格情報（原名：臺灣農產品價格情報）
 
* 聲明：
1. 本軟體專案僅是提供市場交易資料和簡易獲取交易資料的工具，並無意圖影響交易市場行情。若有其他軟體專案、開發者或不特定之個人和團體，基於本軟體專案或是本軟體專案衍生的各種軟體專案、活動，進行影響交易市場行情之一切行為，本軟體專案概不負責。
2. 本軟體專案公布的市場交易資料Raw data皆是來自中華民國政府農產業部門相關網站公布的資料，皆相依於資料來源中各網站的資料正確性和完整性。
3. 本軟體專案並無能力、人力...等等泛稱資源的項目，去保證資料的正確性、完整性，所以若您因為使用本軟體專案提供的市場交易資料和簡易獲取交易資料的工具，造成您名譽上或實質上的任何損失，本軟體專案概不負責。若您無法接受這項聲明，敬請不要使用本軟體專案提供的任何項目，謝謝。
4. 程式碼授權採用BSD 3-Clause License授權條款；市場交易資料之授權條款<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/tw/deed.zh_TW"><img alt="創用 CC 授權條款" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/tw/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">臺灣農產品市場大盤價格情報</span>由<a xmlns:cc="http://creativecommons.org/ns#" href="https://github.com/yhunglee/agri_data_crawler" property="cc:attributionName" rel="cc:attributionURL">Howardsun</a>製作，以<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/tw/deed.zh_TW">創用CC 姓名標示-相同方式分享 3.0 台灣 授權條款</a>釋出。

* 目標：提供開發者Raw data，方便運用至預想之發展，例如視覺化資料、分析價格情報趨勢......等等用途。

* 資料來源：中華民國政府農產業部門相關網站公布的資料。
1. http://amis.afa.gov.tw
陸續加入中。


* 預計涵蓋品項範圍：蔬菜、水果、花卉、盆花、家禽、漁產、畜產......等等，會持續擴展範圍。
 
* 目前涵蓋範圍：蔬菜（自2013-06-21開始提供功能），水果（自2013-10-12開始提供功能），花卉（自2013-07-13開始提供功能）。
 
* 目前類似且具代表性的網站：中華民國行政院農業委員會的農業化行動平台 http://m.coa.gov.tw/  。

* 目前提供：CSV（自2013-06-21開始提供），JSON（自2013-07-13開始提供）。

* 資料下載處：[蔬菜1996年1月到2013年7月] ( https://mega.co.nz/#!zVUVGbYa!e4EyKjLq7VGJDaH-tEh7Cnw1ONMQ7tDjp9vcNdrs_Gc ) 、[蔬菜2013年8月到10月](https://mega.co.nz/#!PYdRXBCT!FeWniDMzd6aQIzur0NFbQUk-QhB6ubSA5z2ngvimzKk
)、[花卉類不含盆花1996年1月到2013年7月] (https://mega.co.nz/#!DQU3USpa!D6Ie1i1S0bYOvxPWU4NNsyb5NAlG4iSGeL9HWXd8ojU)、[花卉類不含盆花2013年8月到10月](https://mega.co.nz/#!6E1VTJIb!dsDragWb1M-NQwoOk11jyl3FpnNObZK_1Lz_5o3cuZg
)、[水果1996年1月到2013年7月] (https://mega.co.nz/#!7AtGyAxb!eZEQAW8uIhrt4-V1_1VR7wymZ34ASOFZ6VvNss3jXcw)、[水果2013年8月到10月](https://mega.co.nz/#!7VNVnLLQ!Vq_KRH68-09jQlJgvXaW7gPgR9hPRyhJQxGjN6zmr_I)

* my_automate_operator.rb程式執行指令說明：
命令列指令：
<pre><code>ruby myautomator.rb &lt;StartDate&gt; &lt;EndDate&gt; &lt;OutputFileName&gt; &lt;QueryKindName&gt; [onlyconvertojson] </code></pre>
查詢開始日期最早只能是1996年1月1日，查詢結束日期最晚只能是查詢時的當天；輸出檔名請自行輸入名稱，程式會自動按月份存檔；查詢種類目前有蔬菜、水果、花卉；若在命令列的最後輸入onlyconvertojson，只會轉換本機現有的csv檔案成json檔，並不會從網路抓取資料。

* 資料格式說明：

## 蔬菜CSV正確格式說明
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

## 花卉CSV正確格式說明
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

## 水果CSV正確格式說明
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

## 蔬菜JSON正確格式說明
總類：
1. 每1行是一種蔬菜在某天臺灣所有大盤市場的一筆完整交易資料，是整合自csv格式檔的奇數行和偶數行，每1行都只有5個欄位。
2. 前4個欄位是CSV格式檔奇數行的值，第5個欄位是交易市場價格資料，使用來自CSV格式檔的偶數行，第5個欄位值是一個JSON格式的陣列，陣列裡面每一個元素(element)都是每個大盤交易市場的資料，每個市場的資料欄位如蔬菜CSV格式敘述，所以不再贅述；如果欄位值出現null，代表原本在CSV格式檔裡面是雙引號(\"\")。
3. 完整例子請參考vegetable_amis_Sep2012.json 。

總量：
{item_id & item_name}, transaction_date, total_transaction_quantity, total_average_price

各市場交易價格資料：
{item_id & item_name}, transaction_date, market_name, type_name, processing_type, upper_price, middle_price, down_price, average_price, change_percentage_of_average_price, transaction_quantity, change_percentage_of_transaction_quantity
## 花卉JSON正確格式說明
總類：
1. 每1行是一種花卉在某天臺灣所有大盤市場的一筆完整交易資料，是整合自csv格式檔的奇數行和偶數行，每1行都只有6個欄位。
2. 前5個欄位是CSV格式檔奇數行的值，第6個欄位是交易市場價格資料，使用來自CSV格式檔的偶數行，第6個欄位值是一個JSON格式的陣列，陣列裡面每一個元素(element)都是每個大盤交易市場的資料，每個市場的資料欄位如花卉CSV格式敘述，所以不再贅述；如果欄位值出現null，代表原本在CSV格式檔裡面是雙引號(\"\")。
3. 完整例子請參考flowers_amis_Sep2012.json 。

總量欄位：
{item_id & item_name}, transaction_date, total_quantity, total_average_price, total_nest_quantity

各市場交易價格資料欄位：
{item_id & item_name}, transaction_date, market_name, type_name, highest_price, upper_price, middle_price, down_price, average_price, change_percentage_of_average_price, transaction_quantity, change_percentage_of_transaction_quantity, nest_quantity
## 水果JSON正確格式說明
總類：
1. 每1行是一種水果在某天臺灣所有大盤市場的一筆完整交易資料，是整合自csv格式檔的奇數行和偶數行，每1行都只有7個欄位。
2. 前6個欄位是CSV格式檔奇數行的值，第7個欄位是交易市場價格資料，使用來自CSV格式檔的偶數行，第7個欄位值是一個JSON格式的陣列，陣列裡面每一個元素(element)都是每個大盤交易市場的資料，每個市場的資料欄位如花卉CSV格式敘述，所以不再贅述；如果欄位值出現null，代表原本在CSV格式檔裡面是雙引號(\"\")。
3. 完整例子請參考flowers_amis_Sep2012.json 。

總量欄位：
{item_id & item_name}, type_name, processing_type, transaction_date, total_transaction_quantity, total_average_price

各市場交易價格資料欄位：
{item_id & item_name}, transaction_date, market_name, weather, upper_price, middle_price, down_price, average_price, change_percentage_of_average_price, transaction_quantity, change_percentage_of_transaction_quantity

***

- Copyright (c) 2013, yhunglee
All rights reserved.

- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
