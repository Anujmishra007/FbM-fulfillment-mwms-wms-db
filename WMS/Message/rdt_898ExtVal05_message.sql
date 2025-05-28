
--rdt_898ExtVal05 
--FCR-926
execute rdt.rdtdropmsg 225301, 225350			

execute rdt.rdtAddMsg 225301, 10, '225301^ToIDClosed',            'us_english',898
--FCR-2724
execute rdt.rdtAddMsg 225302, 10, '225302^OnLOT not triggered',   'us_english',898, 0, '225302 OnLOT not triggered'

--FCR-4531
execute rdt.rdtAddMsg 225303, 10, '225303Invalid Loc ', 'us_english', 898
SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 225301 AND 225350