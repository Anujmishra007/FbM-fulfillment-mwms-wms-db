-- 271001 - 271050

execute rdt.rdtDropMsg 271001 , 271050

execute rdt.rdtAddMsg 271001, 10, '271001Invalid Plt ID',         'us_english'
execute rdt.rdtAddMsg 271002, 10, '271002RPTypeNotSetup',         'us_english'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 271001 AND 271050