-- nspTTMRP26
-- FCR-14963
EXECUTE rdt.rdtdropmsg 276151 , 276200

EXECUTE rdt.rdtAddMsg 276151, 10, '276151^UpdTaskDetFail', 'us_english', 1764
EXECUTE rdt.rdtAddMsg 276152, 10, '276152^UpdTaskDetFail', 'us_english', 1764
EXECUTE rdt.rdtAddMsg 276153, 10, '276153^UpdTaskDetFail', 'us_english', 1764
EXECUTE rdt.rdtAddMsg 276154, 10, '276154^UpdTaskDetFail', 'us_english', 1764
EXECUTE rdt.rdtAddMsg 276155, 10, '276155^LckTaskDetFail', 'us_english', 1764, 0, '276155 Fail to Lock other tasks with same groupkey'
EXECUTE rdt.rdtAddMsg 276156, 10, '276156^UpdTaskDetFail', 'us_english', 1764
EXECUTE rdt.rdtAddMsg 276157, 10, '276157^UpdTaskDetFail', 'us_english', 1764

SELECT * FROM rdt.rdtMsg WHERE Message_ID BETWEEN 276151 AND 276200