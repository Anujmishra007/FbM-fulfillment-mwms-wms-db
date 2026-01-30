
execute rdt.rdtdropmsg 257641, 257660

execute rdt.rdtAddMsg 257641, 10, '257641:ToteID Req',  'us_english',  727, 0,  '257641: ToteID Req'
execute rdt.rdtAddMsg 257642, 10, '257642:ToteID Inv',  'us_english',  727, 0,  '257642: ToteID Inv'
execute rdt.rdtAddMsg 257643, 10, '257643:ToteID Inv',  'us_english',  727, 0,  '257643: ToteID Inv'



SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 257641 AND 257660