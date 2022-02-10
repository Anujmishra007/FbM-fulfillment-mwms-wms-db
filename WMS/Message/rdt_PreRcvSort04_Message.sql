--rdt_PreRcvSort04
exec rdt.rdtDropMsg 134801 , 134850

execute rdt.rdtAddMsg 134801, 10, '34801^Setup Prefix',     'us_english', 1829
execute rdt.rdtAddMsg 134802, 10, '34802^Ins PreRcv Err',   'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 134801 AND 134850