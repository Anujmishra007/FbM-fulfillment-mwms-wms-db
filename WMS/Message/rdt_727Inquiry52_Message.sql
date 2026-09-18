-- 282051 - 282100
execute rdt.rdtdropmsg 282051, 282100

execute rdt.rdtAddMsg 282051, 10, '282051:ToteID Req',  'us_english',  727, 0,  '282051: ToteID Req'
execute rdt.rdtAddMsg 282052, 10, '282052:ToteID Inv',  'us_english',  727, 0,  '282052: ToteID Inv'
execute rdt.rdtAddMsg 282053, 10, '282053:ToteID Inv',  'us_english',  727, 0,  '282053: ToteID Inv'


SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 282051 AND 282100