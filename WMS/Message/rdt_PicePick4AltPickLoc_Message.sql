--rdt_PicePick4AltPickLoc
--execute rdt.rdtdropmsg 50951, 51000

execute rdt.rdtAddMsg '50951', 10, '50951^OffSetPDtlFail',  'us_english'
execute rdt.rdtAddMsg '50952', 10, '50952^GetDetKeyFail',   'us_english'
execute rdt.rdtAddMsg '50953', 10, '50953^Ins PDtl Fail',   'us_english'
execute rdt.rdtAddMsg '50954', 10, '50954^No Twilight LOC', 'us_english'
execute rdt.rdtAddMsg '50955', 10, '50955^Move Qty Fail',   'us_english'
execute rdt.rdtAddMsg '50956', 10, '50956^No ALT LOC',      'us_english'

--SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 50151 AND 50200
--rdt.rdtdropmsg 50161, 50164



