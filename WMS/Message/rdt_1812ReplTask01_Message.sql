--rdt_1812ReplTask01   FCR-989
EXEC rdt.rdtdropmsg 228001 , 228050

EXECUTE rdt.rdtAddMsg 228001, 10, '228001^NO Repl cfg(Qcmd)', 'us_english', 1812 , 0, '228001^No Replenishment config of QCommander.'


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 228001 AND 228050
