-- rdt_LotOrder_Confirm
exec rdt.rdtdropmsg 198551, 198600

execute rdt.rdtAddMsg 198551, 10, '198551Fully scanned ', 'us_english', 655
execute rdt.rdtAddMsg 198552, 10, '198552INS LOG Fail  ', 'us_english', 655
execute rdt.rdtAddMsg 198553, 10, '198553LotExpired ', 'us_english', 655