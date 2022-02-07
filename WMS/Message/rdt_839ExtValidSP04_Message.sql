--rdt_839ExtValidSP04
exec rdt.rdtdropmsg 165351, 165400

execute rdt.rdtAddMsg 165351, 10, '65351^VP Picked', 'us_english', 839

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 165351 AND 165400


