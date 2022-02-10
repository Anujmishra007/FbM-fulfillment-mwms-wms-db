-- rdt_876ExtInfo02
execute rdt.rdtDropMsg 142451 , 142500

execute rdt.rdtAddMsg 142451, 10, 'Orders QR Scan',    'us_english', 876
execute rdt.rdtAddMsg 142452, 10, 'Completed',         'us_english', 876
execute rdt.rdtAddMsg 142453, 10, 'Orders QR Scan',    'us_english', 876
execute rdt.rdtAddMsg 142454, 10, 'Not Complete',      'us_english', 876
execute rdt.rdtAddMsg 142455, 10, 'Over Scan',         'us_english', 876

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 142451 AND 142500
