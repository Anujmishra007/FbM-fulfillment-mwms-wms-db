-- rdt_600DecodeSP05
execute rdt.rdtDropMsg 134651 , 134700

execute rdt.rdtAddMsg 134651, 10, '34651^Invalid Value',    'us_english', 600
execute rdt.rdtAddMsg 134652, 10, '34652^Decode Col Req',   'us_english', 600


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 134651 AND 134700


