-- rdt_898ExtVal03
execute rdt.rdtDropMsg 138101 , 138150	

execute rdt.rdtAddMsg 138101, 10, '38101^Invalid POType',   'us_english', 898
execute rdt.rdtAddMsg 138102, 10, '38102^L10 Need Blank',   'us_english', 898
execute rdt.rdtAddMsg 138103, 10, '38103^ASN MULTI LOTS',   'us_english', 898

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 138101 AND 138150	

