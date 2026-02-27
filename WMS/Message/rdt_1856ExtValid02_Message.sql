
execute rdt.rdtdropmsg 257581, 257600

execute rdt.rdtAddMsg 257581, 10, '257581:Inv Pallet No',  'us_english',  1856, 0,  '257581: Inv Pallet No'



SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 257581 AND 257600