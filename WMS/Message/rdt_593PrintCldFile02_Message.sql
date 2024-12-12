-- rdt_593PrintCldFile02_message
execute rdt.rdtDropMsg 228501 , 228550		

execute rdt.rdtAddMsg 228501, 10, '228501MISSCODECONF', 'us_english', 593, 0, '228501 Missing CODELKUP Setup'
execute rdt.rdtAddMsg 228502, 10, '228503INVALIDCOND', 'us_english', 593, 0, '228502 Invalid Condition'
execute rdt.rdtAddMsg 228503, 10, '228503MISSWSCONF', 'us_english', 593, 0, '228503 Miss WS Config'
execute rdt.rdtAddMsg 228504, 10, '228504FAILENCRYPT', 'us_english', 593, 0, '228504 Failed to encrypt file path'
execute rdt.rdtAddMsg 228505, 10, '228505REPORTNOTEXIST', 'us_english', 593, 0, '228505 Report Not Exist'
execute rdt.rdtAddMsg 228506, 10, '228506PRINTERNOTEXIST', 'us_english', 593, 0, '228506 Printer Not Exist'
execute rdt.rdtAddMsg 228507, 10, '228507MISSCLDID', 'us_english', 593, 0, '228507 Miss Cloud Print ID'
execute rdt.rdtAddMsg 228508, 10, '228508JOBINSFAIL', 'us_english', 593, 0, '228508 Job Insert Fail'
execute rdt.rdtAddMsg 228509, 10, '228509JOBSUBFAIL', 'us_english', 593, 0, '228509 Job Submit Fail'
execute rdt.rdtAddMsg 228510, 10, '228510NEEDEXTKEY', 'us_english', 593, 0, '228510 Need Ext Order Key'
execute rdt.rdtAddMsg 228511, 10, '228511NEEDORDKEY', 'us_english', 593, 0, '228511 Need Order Key'
execute rdt.rdtAddMsg 228512, 10, '228512MULTICARTON', 'us_english', 593, 0, '228512 Multiple Order Found'
execute rdt.rdtAddMsg 228513, 10, '228513INVALIDLABELNO', 'us_english', 593, 0, '228513 Invalid LabelNo'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 228501 AND 228550