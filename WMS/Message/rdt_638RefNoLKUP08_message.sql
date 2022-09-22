
-- rdt_638RefNoLKUP08
execute rdt.rdtDropMsg 190401  , 190450		

execute rdt.rdtAddMsg 190401, 10, '190401InvalidColumn', 'us_english', 638
execute rdt.rdtAddMsg 190402, 10, '190402ColumnNoIndex', 'us_english', 638
execute rdt.rdtAddMsg 190403, 10, 'TrackingNo', 'us_english', 638
execute rdt.rdtAddMsg 190404, 10, 'Not Exists', 'us_english', 638
execute rdt.rdtAddMsg 190405, 10, 'Transmitlog2', 'us_english', 638
execute rdt.rdtAddMsg 190406, 10, 'Generate', 'us_english', 638

SELECT TOP 10 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 170301 and 170350


