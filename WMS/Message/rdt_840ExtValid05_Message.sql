-- rdt_840ExtValid05
execute rdt.rdtDropMsg 147001 , 147050

execute rdt.rdtAddMsg 147001, 10, '47001^INV LOC EXIST',     'us_english', 840
execute rdt.rdtAddMsg 147002, 10, '47002^NO TRACK NO',       'us_english', 840
execute rdt.rdtAddMsg 147003, 10, '47003^INV TRACK NO',      'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 147001 AND 147050