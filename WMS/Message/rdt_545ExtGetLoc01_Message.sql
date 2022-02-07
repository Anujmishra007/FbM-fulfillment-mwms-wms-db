-- rdt_545ExtGetLoc01
exec rdt.rdtdropmsg 180041 , 180050

execute rdt.rdtAddMsg 180041, 10, '80041^Lock LOC fail ', 'us_english', 545
execute rdt.rdtAddMsg 180042, 10, '80042^No avail LOC  ', 'us_english', 545

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 180041 AND 180050


