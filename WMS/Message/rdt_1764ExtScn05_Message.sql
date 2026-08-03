--rdt_1764ExtScn05
--FCR-14963

EXECUTE rdt.rdtdropmsg 276251, 276300

EXECUTE rdt.rdtAddMsg 276251, 10, '276251^UpdPKDFail', 'us_english', 1764, 0, '276251 Fail to release TaskDetail'

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 276251 AND 276300