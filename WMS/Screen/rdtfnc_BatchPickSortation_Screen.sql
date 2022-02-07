-- rdtfnc_BatchPickSortation
-- 3590 - 3599
DELETE rdt.rdtscn Where Scn = 3590 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3590, 'ENG',
@cLine01 = 'LOADKEY: %10i01', 
@cLine14 = '%e',
@nFunc = 1709

DELETE rdt.RDTScn WHERE Scn = 3591 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3591, 'ENG',
@cLine01 = 'LOADKEY: %10d01',
@cLine03 = 'SKU/UPC:',
@cLine04 = '%20i02',
@cLine05 = '%20d03',
@cLine06 = '%20d04',
@cLine08 = 'QTY: %05i05',
@cLine11 = 'TTL QTY: %11d06',
@cLine13 = 'ENTER TO CONTINUE',
@cLine14 = '%e',
@nFunc = 1709

DELETE rdt.RDTScn WHERE Scn = 3592 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3592, 'ENG',
@cLine01 = 'SEQ: %10d01',
@cLine03 = 'SKU/UPC:',
@cLine04 = '%20d02',
@cLine05 = '%20d03',
@cLine06 = '%20d04',
@cLine08 = 'LOC: %10d05',
@cLine10 = 'QTY: %05d06',
@cLine13 = 'ENTER TO CONTINUE',
@cLine14 = '%e',
@nFunc = 1709

DELETE rdt.rdtscn Where Scn = 3593 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3593, 'ENG',
@cLine01 = 'SORTING',
@cLine02 = 'COMPLETED.',
@cLine04 = 'PRESS ENTER FOR', 
@cLine05 = 'NEXT LOADKEY',
@cLine14 = '%e',
@nFunc = 1709
