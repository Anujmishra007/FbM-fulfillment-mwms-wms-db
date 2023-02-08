--rdt_1638ExtVal17
exec rdt.rdtdropmsg 194801 , 194850	

execute rdt.rdtAddMsg 194801, 10, '194801 PALLET CLOSED', 'us_english', 1638
execute rdt.rdtAddMsg 194802, 10, '194802 NEED TRACKNO ', 'us_english', 1638
execute rdt.rdtAddMsg 194803, 10, '194803 TRACKNO EXIST', 'us_english', 1638
execute rdt.rdtAddMsg 194804, 10, '194804 SCAN ALL CASE', 'us_english', 1638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 194801 AND 194850
