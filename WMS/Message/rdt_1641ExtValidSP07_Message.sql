--rdt_1641ExtValidSP07
execute rdt.rdtDropMsg 137351 , 137400	

execute rdt.rdtAddMsg 137351, 10, '37351^Diff Consignee',  'us_english', 1641
execute rdt.rdtAddMsg 137352, 10, '37352^Diff Delivery',   'us_english', 1641

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 137351 AND 137400	

