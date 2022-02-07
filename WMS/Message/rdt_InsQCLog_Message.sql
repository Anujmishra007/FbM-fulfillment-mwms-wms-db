--rdt_InsQCLog
--execute rdt.rdtdropmsg 76601 - 76650


execute rdt.rdtAddMsg '76601', 10, '76601^INS QCLOG FAIL',      'us_english'


select * from rdt.rdtmsg (nolock) where message_id between 76601 and 76650

