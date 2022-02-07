-- rdt_1581RcptCfm05
execute rdt.rdtDropMsg 130951 , 131000

execute rdt.rdtAddMsg 130951, 10, '30951^NO RSO        ', 'us_english', 1581
execute rdt.rdtAddMsg 130952, 10, '30952^Unexpt SKU Err', 'us_english', 1581
execute rdt.rdtAddMsg 130953, 10, '30953^Unexpt QTY Err', 'us_english', 1581
execute rdt.rdtAddMsg 130954, 10, '30954^Unexpt QTY Err', 'us_english', 1581

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 130951 AND 131000
