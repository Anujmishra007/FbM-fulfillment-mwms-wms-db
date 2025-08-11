-- rdt_1770ExtUpd05
--RITM7939100
EXECUTE rdt.rdtDropMsg 244101, 244150

EXECUTE rdt.rdtAddMsg 244101, 10, '244101^Need qty is ZERO',         'us_english', 1770, 0, '244101^Need qty is ZERO'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 244101 AND 244150

