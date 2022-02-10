-- rdt_Inquiry_V7
rdt.rdtDropMsg 126151 , 126200

execute rdt.rdtAddMsg 126151, 10, '26151^No record',      'us_english', 628
execute rdt.rdtAddMsg 126152, 10, '26152^No more record', 'us_english', 628

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 126151 AND 126200