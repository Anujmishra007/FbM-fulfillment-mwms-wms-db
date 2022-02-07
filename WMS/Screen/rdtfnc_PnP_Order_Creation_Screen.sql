-- rdtfnc_PnP_Order_Creation
-- 3610 - 3619
DELETE rdt.rdtscn Where Scn = 3610 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3610, 'ENG',
@cLine01 = '1. ORDER PACKING', 
@cLine03 = '2. PACK CONFIRM', 
@cLine05 = 'OPTION: %01i01', 
@cLine14 = '%e',
@nFunc = 1798

DELETE rdt.rdtscn Where Scn = 3611 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3611, 'ENG',
@cLine01 = 'STORE:', 
@cLine02 = '%15i01', 
@cLine04 = '1. PCS',
@cLine05 = '2. LOTS',
@cLine07 = 'OPTION: %01i02',
@cLine14 = '%e',
@nFunc = 1798

DELETE rdt.rdtscn Where Scn = 3612 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3612, 'ENG',
@cLine01 = 'STORE:', 
@cLine02 = '%15d01', 
@cLine03 = '%20d02',
@cLine04 = 'LABEL NO:',
@cLine05 = '%20i03',
@cLine14 = '%e',
@nFunc = 1798

DELETE rdt.rdtscn Where Scn = 3613 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3613, 'ENG',
@cLine01 = 'STORE:', 
@cLine02 = '%15d01', 
@cLine03 = '%20d02',
@cLine04 = 'LABEL NO:',
@cLine05 = '%20d03',
@cLine06 = 'CARTON TYPE:',
@cLine07 = '%10i04',
@cLine14 = '%e',
@nFunc = 1798

DELETE rdt.rdtscn Where Scn = 3614 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3614, 'ENG',
@cLine01 = 'STORE:', 
@cLine02 = '%15d01', 
@cLine03 = '%20d02',
@cLine04 = 'LABEL NO:',
@cLine05 = '%20d03',
@cLine06 = 'SKU/UPC:',
@cLine07 = '%20i04',
@cLine08 = '%20d05',
@cLine09 = '%20d06',
@cLine10 = 'QTY:%05i07',
@cLine11 = 'CARTON QTY:%05d08',
@cLine12 = 'UxL:%05d09',
@cLine14 = '%e',
@nFunc = 1798

DELETE rdt.rdtscn Where Scn = 3615 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3615, 'ENG',
@cLine01 = 'PACKING CONFIRM',
@cLine03 = 'LABEL NO:',
@cLine04 = '%20i01',
@cLine14 = '%e',
@nFunc = 1798

DELETE rdt.rdtscn Where Scn = 3616 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3616, 'ENG',
@cLine01 = 'PACKING CONFIRM',
@cLine02 = 'SUCCESSFULLY.',
@cLine14 = '%e',
@nFunc = 1798