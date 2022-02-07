--TrackingIDSortationByASN
rdt.rdtDropMsg 150051 , 149450	

execute rdt.rdtAddMsg 150051, 10, '50051^Ins Track Fail',       'us_english', 644
execute rdt.rdtAddMsg 150052, 10, '50052^ReceiveASN Off',       'us_english', 644
execute rdt.rdtAddMsg 150053, 10, '50053^Plt Not Full',         'us_english', 644
execute rdt.rdtAddMsg 150054, 10, '50054^ReleaseLOC Err',       'us_english', 644

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 150051 AND 150100	