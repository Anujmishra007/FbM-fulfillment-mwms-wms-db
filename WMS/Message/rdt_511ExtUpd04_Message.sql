--rdt_511ExtUpd04
execute rdt.rdtdropmsg 152801 , 152850

execute rdt.rdtAddMsg 152801, 10, '52801^AGV API Error',    'us_english', 511

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 152801 AND 152850

