-- 271101 - 271150

execute rdt.rdtDropMsg 271101 , 271150

execute rdt.rdtAddMsg 271101, 10, '271101Invalid Plt ID',         'us_english'
execute rdt.rdtAddMsg 271102, 10, '271102RPTypeNotSetup',         'us_english'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 271101 AND 271150