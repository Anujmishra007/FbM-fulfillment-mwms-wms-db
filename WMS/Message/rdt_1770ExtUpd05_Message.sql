-- rdt_1770ExtUpd05
--RITM7939100
EXECUTE rdt.rdtDropMsg 239053, 239100

EXECUTE rdt.rdtAddMsg 239053, 10, '239053^Need qty is ZERO',         'us_english', 1770, 4, '239053^Need qty is ZERO'


SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 239053 AND 239100

