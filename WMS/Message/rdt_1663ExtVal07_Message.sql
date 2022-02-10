--rdt_1663ExtVal07
exec rdt.rdtdropmsg 137901, 137950

execute rdt.rdtAddMsg 137901, 10, 'Not All Ctn Scanned',    'us_english', 1663
execute rdt.rdtAddMsg 137902, 10, 'TOP 5 Order With',       'us_english', 1663
execute rdt.rdtAddMsg 137903, 10, 'Missing Carton',         'us_english', 1663
execute rdt.rdtAddMsg 137904, 10, '37904^Inv TrackingNo',   'us_english', 1663

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 137901 AND 137950
