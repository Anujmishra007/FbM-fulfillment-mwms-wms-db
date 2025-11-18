--rdt_521ExtValid10
execute rdt.rdtdropmsg 250851 , 250900

execute rdt.rdtAddMsg 250851, 10, '250851SKUGpNotMat', 'us_english', 521,'0', '250851 SKUGroup not allowed on this floor'
execute rdt.rdtAddMsg 250852, 10, '250852ToLocHadQty', 'us_english', 521,'0', '250852 ToLoc Scanned Not Empty'
