--rdt_855ExtValid07
rdt.rdtDropMsg 217351, 217400

execute rdt.rdtAddMsg 217351, 10, '217351 InvalidOption',     'us_english', 855

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 217351 AND 217400