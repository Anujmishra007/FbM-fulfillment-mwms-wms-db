-- rdt_838PntShipLbl05
-- FCR-6483
EXECUTE rdt.rdtDropMsg 243901  , 243950

EXECUTE rdt.rdtAddMsg 243901, 10, '243901InvalidExOrdkey', 'us_english', 1864, 0, '243901 Invalid ExternOrderkey'
EXECUTE rdt.rdtAddMsg 243902, 10, '243902Invalid Conditi', 'us_english', 1864, 0, '243902 Invalid Conditition'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 243901 AND 243950
