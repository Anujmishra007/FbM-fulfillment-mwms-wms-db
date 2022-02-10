--rdtfnc_ASRS_CycleCount
execute rdt.rdtdropmsg 53501 , 53550

execute rdt.rdtAddMsg 53501, 10, '53501^PALLET ID REQ',     'us_english', 733
execute rdt.rdtAddMsg 53502, 10, '53502^INVALID PLT ID',    'us_english', 733
execute rdt.rdtAddMsg 53503, 10, '53503^FINALIZED CNT3',    'us_english', 733
execute rdt.rdtAddMsg 53504, 10, '53504^WRONG CNT NO',      'us_english', 733
execute rdt.rdtAddMsg 53505, 10, '53505^NO TASK',           'us_english', 733
execute rdt.rdtAddMsg 53506, 10, '53506^NO MORE TASK',      'us_english', 733
execute rdt.rdtAddMsg 53507, 10, '53507^INVALID OPTION',    'us_english', 733
execute rdt.rdtAddMsg 53508, 10, '53508^QTY COUNTED=0',     'us_english', 733
execute rdt.rdtAddMsg 53509, 10, '53509^NO TASK',           'us_english', 733
execute rdt.rdtAddMsg 53510, 10, '53510^INVALID QTY',       'us_english', 733
execute rdt.rdtAddMsg 53511, 10, '53511^INVALID QTY',       'us_english', 733
execute rdt.rdtAddMsg 53512, 10, '53512^INVALID QTY',       'us_english', 733
execute rdt.rdtAddMsg 53513, 10, '53513^Zero CaseCnt',      'us_english', 733
execute rdt.rdtAddMsg 53514, 10, '53514^SKU/UPC req',       'us_english', 733
execute rdt.rdtAddMsg 53515, 10, '53515^Invalid SKU',       'us_english', 733
execute rdt.rdtAddMsg 53516, 10, '53516^SameBarCodeSKU',    'us_english', 733
execute rdt.rdtAddMsg 53517, 10, '53517^INVALID QTY',       'us_english', 733
execute rdt.rdtAddMsg 53518, 10, '53518^INVALID QTY',       'us_english', 733
execute rdt.rdtAddMsg 53519, 10, '53519^INVALID QTY',       'us_english', 733
execute rdt.rdtAddMsg 53520, 10, '53520^Zero CaseCnt',      'us_english', 733
execute rdt.rdtAddMsg 53521, 10, '53521^REC COUNTED',       'us_english', 733
execute rdt.rdtAddMsg 53522, 10, '53522^NotInStorerGrp',    'us_english', 733
execute rdt.rdtAddMsg 53523, 10, '53523^PL>1OPEN CCKEY',    'us_english', 733

--select * from rdt.rdtmsg (nolock) where message_id between 53501 and 53550