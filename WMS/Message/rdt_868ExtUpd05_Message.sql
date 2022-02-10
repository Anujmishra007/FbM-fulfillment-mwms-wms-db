--rdt_868ExtUpd05
execute rdt.rdtDropMsg 163101, 163150

execute rdt.rdtAddMsg 163101, 10, '63101^PackCfm Fail', 'us_english', 868

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 163101 AND 163150	