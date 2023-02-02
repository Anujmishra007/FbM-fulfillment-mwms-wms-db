--rdt_840ExtValid15
execute rdt.rdtdropmsg 194451 , 194500

execute rdt.rdtAddMsg 194451, 10, '194451 PENDING CANC ',   'us_english', 840
execute rdt.rdtAddMsg 194452, 10, '194452 PARTIAL CANC ',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 194451 AND 194500