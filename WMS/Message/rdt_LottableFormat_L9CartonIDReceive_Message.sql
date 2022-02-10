-- rdt_LottableFormat_L9CartonIDReceive
execute rdt.rdtDropMsg 105601, 105650

execute rdt.rdtAddMsg 105601, 10, '105601Need carton ID', 'us_english', 608
execute rdt.rdtAddMsg 105602, 10, '105602Double scanned', 'us_english', 608
