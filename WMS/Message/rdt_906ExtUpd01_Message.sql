--rdt_906ExtUpd01
execute rdt.rdtDropMsg 137051, 137100

execute rdt.rdtAddMsg 137051, 10, '37051^UPD PPA FAIL',     'us_english', 906
execute rdt.rdtAddMsg 137052, 10, '37052^UPD TASK FAIL',    'us_english', 906

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 137051 AND 137100
