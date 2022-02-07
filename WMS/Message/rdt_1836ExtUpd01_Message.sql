--rdt_1836ExtUpd01
exec rdt.rdtdropmsg 151001, 151050

execute rdt.rdtAddMsg 151001, 10, '51001^UpdPickdetFail', 'us_english', 1836
execute rdt.rdtAddMsg 151002, 10, '51002^UpdTaskdetFail', 'us_english', 1836


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 151001 AND 151050


