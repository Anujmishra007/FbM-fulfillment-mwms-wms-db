--rdt_845CloseSP01
execute rdt.rdtdropmsg 176051, 176100

execute rdt.rdtAddMsg 176051, 10, '176051 UPD UCC Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 176052, 10, '176052 UPD UCC Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 176053, 10, '176053 INS UCC Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 176054, 10, '176054 UPD Log Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 176055, 10, '176055 UPD Log Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 176056, 10, '176056 UPD UCC Fail  ', 'us_english', 845
execute rdt.rdtAddMsg 176057, 10, '176057 UPD UCC Fail  ', 'us_english', 845


SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 176051 and 176100
