--rdt_1812ReplTask01   FCR-989
exec rdt.rdtdropmsg 228001 , 228050

execute rdt.rdtAddMsg 228001, 10, '228001^NO Repl cfg(Qcmd)', 'us_english', 600 , 0, '228001^No Replenishment config  of QCommander.'


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 228001 AND 228050
