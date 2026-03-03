--rdt_1764ExtValid01
rdt.rdtDropMsg 180041 , 180050

execute rdt.rdtAddMsg 180041, 10, '180041^Invalid Location',   'us_english', 1764

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 180041 AND 180050