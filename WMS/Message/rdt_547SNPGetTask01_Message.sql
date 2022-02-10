--rdt_547SNPGetTask01
rdt.rdtDropMsg 166751 , 166800	

execute rdt.rdtAddMsg 166751, 10, '166751Invalid UCCUOM',   'us_english', 847
execute rdt.rdtAddMsg 166752, 10, '166752Invalid UCC',      'us_english', 847
execute rdt.rdtAddMsg 166753, 10, '166753No more task',     'us_english', 847

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 166751 AND 166800