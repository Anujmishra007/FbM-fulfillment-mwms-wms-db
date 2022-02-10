--rdt_Replenish_MovePickDetail
exec rdt.rdtDropMsg 148001, 148050

execute rdt.rdtAddMsg 148001, 10, '48001^GetKey Fail',      'us_english', 510
execute rdt.rdtAddMsg 148002, 10, '48002^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 148003, 10, '48003^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 148004, 10, '48004^GetKey Fail',      'us_english', 510
execute rdt.rdtAddMsg 148005, 10, '48005^INS PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 148006, 10, '48006^INS RefKeyFail',   'us_english', 510
execute rdt.rdtAddMsg 148007, 10, '48007^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 148008, 10, '48008^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 148009, 10, '48009^UPD PKDtl Fail',   'us_english', 510
execute rdt.rdtAddMsg 148010, 10, '48000^UPD PKDtl Fail',   'us_english', 510

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 148001 AND 148050