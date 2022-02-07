--rdt_1760ExtUpd01
--execute rdt.rdtdropmsg 53101 , 53150

execute rdt.rdtAddMsg '53101', 10, '53101^GetCCKeyFail',       'us_english', 1760
execute rdt.rdtAddMsg '53102', 10, '53102^GetTaskKeyFail',     'us_english', 1760
execute rdt.rdtAddMsg '53103', 10, '53103^InsCCTaskFail',      'us_english', 1760
execute rdt.rdtAddMsg '53104', 10, '53104^UpdCCTaskFail',      'us_english', 1760


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 53101 AND 53150


