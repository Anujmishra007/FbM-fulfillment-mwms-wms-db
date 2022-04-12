-- rdt_1581RcptCfm07
execute rdt.rdtDropMsg 163751, 163800

execute rdt.rdtAddMsg 163751, 10, '163751^NO RSO       ', 'us_english', 1581
execute rdt.rdtAddMsg 163752, 10, '163752Unexpt SKU Err', 'us_english', 1581
execute rdt.rdtAddMsg 163753, 10, '163753Unexpt QTY Err', 'us_english', 1581
execute rdt.rdtAddMsg 163754, 10, '163754Unexpt QTY Err', 'us_english', 1581
execute rdt.rdtAddMsg 163755, 10, '163755^UPD Fail     ', 'us_english', 1581

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 163751 AND 163800
