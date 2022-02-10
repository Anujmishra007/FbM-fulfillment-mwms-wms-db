--rdt_839ExtValidSP06
exec rdt.rdtdropmsg 169451, 169500

execute rdt.rdtAddMsg 169451, 10, '169451^Dup DropID', 'us_english', 839

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 169451 AND 169500


