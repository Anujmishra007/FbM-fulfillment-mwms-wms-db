--rdt_521ExtPA27
--FCR-12181
exec rdt.rdtDropMsg 267051 , 267100

execute rdt.rdtAddMsg 267051, 10, '267051^NoPutawayZone',         'us_english', 521, 0, '267051 Missing SKU Putaway Zone'
execute rdt.rdtAddMsg 267052, 10, '267052^ExecPAStrategyFail',    'us_english', 521, 0, '267052 Execute Putaway Strategy Failed'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 267051 AND 267100
