--rdt_SplitUCC
exec rdt.rdtDropMsg 87301 , 87350

execute rdt.rdtAddMsg 87301 ,10, '87301 Upd UCC Fail  ', 'us_english', 535
execute rdt.rdtAddMsg 87302 ,10, '87302 Ins UCC Fail  ', 'us_english', 535
execute rdt.rdtAddMsg 87303 ,10, '87303 Upd UCC Fail  ', 'us_english', 535
execute rdt.rdtAddMsg 87304 ,10, '87304 Upd UCC Fail  ', 'us_english', 535
execute rdt.rdtAddMsg 87305 ,10, '87305 Add Log Err   ', 'us_english', 535
execute rdt.rdtAddMsg 87306 ,10, '87306 Upd Log Err   ', 'us_english', 535
execute rdt.rdtAddMsg 87307 ,10, '87307 Clear Log Err ', 'us_english', 535
execute rdt.rdtAddMsg 87308 ,10, '87308 UCCInOtherPlt ', 'us_english', 535

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 87301 AND 87350

