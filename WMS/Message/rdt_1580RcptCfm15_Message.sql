--rdt_1580RcptCfm15
execute rdt.rdtDropMsg 151101, 151150

execute rdt.rdtAddMsg 151101, 10, '51101^OVER RECEIVED', 'us_english', 1580

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 151101 AND 151150