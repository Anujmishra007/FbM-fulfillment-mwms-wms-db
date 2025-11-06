
--rdt_898ExtVal05 
--FCR-926
execute rdt.rdtdropmsg 225301, 225350			

execute rdt.rdtAddMsg 225301, 10, '225301^ToIDClosed',            'us_english',898
--FCR-2724
execute rdt.rdtAddMsg 225302, 10, '225302^OnLOT not triggered',   'us_english',898, 0, '225302 OnLOT not triggered'

--FCR-4531
execute rdt.rdtAddMsg 225303, 10, '225303Invalid Loc ', 'us_english', 898

--UWP-35355
execute rdt.rdtAddMsg 225304, 10, '225304^POClosed',   'us_english',898, 0, '225304 PO is closed'
execute rdt.rdtAddMsg 225305, 10, '225305^CancelDatePast',   'us_english',898, 0, '225305 Cancel Date Past'
execute rdt.rdtAddMsg 225306, 10, '225306^MultiPOInReceipt',   'us_english',898, 0, '225306MultiPOInReceipt'
execute rdt.rdtAddMsg 225307, 10, '225307^POTypeNotReturn',   'us_english',898, 0, '225307 POTypeNotReturn'
execute rdt.rdtAddMsg 225308, 10, '225308^',   'us_english',898, 0, '225308 UCC From PO Closed/ Unavailable'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 225301 AND 225350