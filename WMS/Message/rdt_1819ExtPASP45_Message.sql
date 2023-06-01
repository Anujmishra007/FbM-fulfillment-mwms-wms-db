--rdt_1819ExtPASP45
rdt.rdtDropMsg 198601 , 198650

execute rdt.rdtAddMsg 198601, 10, '198601 ID No Record ',   'us_english', 1819
execute rdt.rdtAddMsg 198602, 10, '198602No Suggest Loc',   'us_english', 1819


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 198601 AND 198650