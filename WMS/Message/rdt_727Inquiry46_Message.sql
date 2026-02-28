
execute rdt.rdtdropmsg 258351, 258400

execute rdt.rdtAddMsg 258351, 10, '258351:ToteID Req',  'us_english',  727, 0,  '258351: ToteID Req'
execute rdt.rdtAddMsg 258352, 10, '258352:ToteID Inv',  'us_english',  727, 0,  '258352: ToteID Inv'
execute rdt.rdtAddMsg 258353, 10, '258353:ToteID Inv',  'us_english',  727, 0,  '258353: ToteID Inv'


SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 258351 AND 258400