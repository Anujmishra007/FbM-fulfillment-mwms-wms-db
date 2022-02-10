--rdt_1809ConfirmSP02
execute rdt.rdtDropMsg 163501 , 163550

execute rdt.rdtAddMsg 163501, 10, '163501OffSetPDtlFail', 'us_english', 1809
execute rdt.rdtAddMsg 163502, 10, '163502OffSetPDtlFail', 'us_english', 1809
execute rdt.rdtAddMsg 163503, 10, '163503GetDetKeyFail',  'us_english', 1809
execute rdt.rdtAddMsg 163504, 10, '163504Ins PDtl Fail',  'us_english', 1809
execute rdt.rdtAddMsg 163505, 10, '163505OffSetPDtlFail', 'us_english', 1809
execute rdt.rdtAddMsg 163506, 10, '163506OffSetPDtlFail', 'us_english', 1809
execute rdt.rdtAddMsg 163507, 10, '163507SEE_SUPERVISOR', 'us_english', 1809
execute rdt.rdtAddMsg 163508, 10, '163508SEE_SUPERVISOR', 'us_english', 1809
execute rdt.rdtAddMsg 163509, 10, '163509OffSetPDtlFail', 'us_english', 1809



SELECT * FROM rdt.rdtMsg (nolock) WHERE Message_Id BETWEEN 163501 AND 163550