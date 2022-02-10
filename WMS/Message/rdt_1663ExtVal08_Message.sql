
-- rdt_1663ExtVal08

exec rdt.rdtdropmsg 138301, 138350

execute rdt.rdtAddMsg 138301, 10, 'Not All Ctn Scanned',    'us_english', 1663
execute rdt.rdtAddMsg 138302, 10, 'TOP 5 Order With',       'us_english', 1663
execute rdt.rdtAddMsg 138303, 10, 'Missing Carton',         'us_english', 1663
execute rdt.rdtAddMsg 138304, 10, '38304^Inv TrackingNo',   'us_english', 1663
--WMS14798
execute rdt.rdtAddMsg 138305, 10, '138305GroupNoSetup',    'us_english',1663
execute rdt.rdtAddMsg 138306, 10, '138306CourierGrpDiff',    'us_english',1663

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 138301 AND 138350
