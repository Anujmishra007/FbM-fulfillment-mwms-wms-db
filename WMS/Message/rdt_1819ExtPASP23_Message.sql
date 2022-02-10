--rdt_1819ExtPASP23
rdt.rdtDropMsg 138451 , 138500

execute rdt.rdtAddMsg 138451, 10, '38451^No Lottable08',    'us_english', 1819
execute rdt.rdtAddMsg 138452, 10, '38452^No PA Zone',       'us_english', 1819
execute rdt.rdtAddMsg 138453, 10, '38453^No Suggest Loc',   'us_english', 1819


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 138451 AND 138500