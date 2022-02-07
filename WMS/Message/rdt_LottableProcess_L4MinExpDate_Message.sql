-- rdt_LottableProcess_L4MinExpDate
execute rdt.rdtDropMsg 121001, 121050

execute rdt.rdtAddMsg 121001, 10, '121001ExpiredTooSoon', 'us_english'
execute rdt.rdtAddMsg 121002, 10, '121002ExpiryNotMatch', 'us_english'
