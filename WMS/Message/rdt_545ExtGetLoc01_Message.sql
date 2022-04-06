-- rdt_545ExtGetLoc01
exec rdt.rdtdropmsg 185551 , 185600

execute rdt.rdtAddMsg 185551, 10, '185551Lock LOC fail ', 'us_english', 545
execute rdt.rdtAddMsg 185552, 10, '185552No avail LOC  ', 'us_english', 545

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 185551 AND 185600


