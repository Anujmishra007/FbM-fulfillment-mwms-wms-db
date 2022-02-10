-- rdt_PalletBuild_SerialNo_Confirm
rdt.rdtDropMsg 133751 , 133800

execute rdt.rdtAddMsg 133751, 10, '33751^Casecnt = 0',      'us_english', 1644
execute rdt.rdtAddMsg 133752, 10, '33752^OffSetPDtlFail',   'us_english', 1644
execute rdt.rdtAddMsg 133753, 10, '33753^OffSetPDtlFail',   'us_english', 1644
execute rdt.rdtAddMsg 133754, 10, '33754^GetDetKeyFail',    'us_english', 1644
execute rdt.rdtAddMsg 133755, 10, '33755^Ins PDtl Fail',    'us_english', 1644
execute rdt.rdtAddMsg 133756, 10, '33756^OffSetPDtlFail',   'us_english', 1644
execute rdt.rdtAddMsg 133757, 10, '33757^INS RefKeyFail',   'us_english', 1644
execute rdt.rdtAddMsg 133758, 10, '33758^OffSetPDtlFail',   'us_english', 1644


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 133751 AND 133800