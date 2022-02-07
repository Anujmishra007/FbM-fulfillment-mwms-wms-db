-- rdt_Pick_SwapLot01
execute rdt.rdtDropMsg 104951, 105000

execute rdt.rdtAddMsg 104951, 10, '04951^UpdPickDtlFail', 'us_english', 1640
execute rdt.rdtAddMsg 104952, 10, '04952^GetDetKey Fail', 'us_english', 1640
execute rdt.rdtAddMsg 104953, 10, '04953^Ins PDtl Fail ', 'us_english', 1640
execute rdt.rdtAddMsg 104954, 10, '04954^InsRefKLupFail', 'us_english', 1640
execute rdt.rdtAddMsg 104955, 10, '04955^UpdPickDtlFail', 'us_english', 1640
execute rdt.rdtAddMsg 104956, 10, '04956^GetDetKey Fail', 'us_english', 1640
execute rdt.rdtAddMsg 104957, 10, '04957^Ins PDtl Fail ', 'us_english', 1640
execute rdt.rdtAddMsg 104958, 10, '04958^InsRefKLupFail', 'us_english', 1640
execute rdt.rdtAddMsg 104959, 10, '04959^UpdPickDtlFail', 'us_english', 1640
execute rdt.rdtAddMsg 104960, 10, '04960^UpdPickDtlFail', 'us_english', 1640
execute rdt.rdtAddMsg 104961, 10, '04961^No Rec Found  ', 'us_english', 1640
execute rdt.rdtAddMsg 104962, 10, '04962^Swap Fail     ', 'us_english', 1640
execute rdt.rdtAddMsg 104963, 10, '04963^GetDetKey Fail', 'us_english', 1640
execute rdt.rdtAddMsg 104964, 10, '04964^Ins PDtl Fail ', 'us_english', 1640
execute rdt.rdtAddMsg 104965, 10, '04965^InsRefKLupFail', 'us_english', 1640
execute rdt.rdtAddMsg 104966, 10, '04966^UpdPickDtlFail', 'us_english', 1640
execute rdt.rdtAddMsg 104967, 10, '04967^GetDetKey Fail', 'us_english', 1640
execute rdt.rdtAddMsg 104968, 10, '04968^Ins PDtl Fail ', 'us_english', 1640
execute rdt.rdtAddMsg 104969, 10, '04969^InsRefKLupFail', 'us_english', 1640
execute rdt.rdtAddMsg 104970, 10, '04960^UpdPickDtlFail', 'us_english', 1640
execute rdt.rdtAddMsg 104961, 10, '04961^UpdPickDtlFail', 'us_english', 1640
execute rdt.rdtAddMsg 104963, 10, '04963^UpdPickDtlFail', 'us_english', 1640


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 104951 AND 105000