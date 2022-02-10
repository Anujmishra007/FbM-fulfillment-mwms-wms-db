-- rdtfnc_TM_CartPicking
-- 3740 - 3749
DELETE rdt.rdtscn Where Scn = 3740 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3740, 'ENG',
@cLine01 = 'PTL PICKING      %03d09',
@cLine03 = 'CART ID: %10d12', 
@cLine04 = 'FROM LOC:', 
@cLine05 = '%10d01', 
@cLine06 = '%10i13', 
@cLine14 = '%e',
@nFunc = 1806

DELETE rdt.rdtscn Where Scn = 3741 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3741, 'ENG',
@cLine01 = 'PTL PICKING      %03d05',
@cLine03 = 'CART ID:  %10d01', 
@cLine04 = 'FROM LOC: %10d02',
@cLine06 = 'SKU/UPC:',
@cLine07 = '%20d03',
@cLine08 = '%20i04',
@cLine14 = '%e',
@nFunc = 1806

DELETE rdt.rdtscn Where Scn = 3742 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3742, 'ENG',
@cLine01 = 'PTL PICKING      %03d07',
@cLine03 = 'CART ID:  %10d01', 
@cLine04 = 'FROM LOC: %10d02',
@cLine05 = 'SKU/UPC:',
@cLine06 = '%20d03',
@cLine07 = '%20d04',
@cLine08 = '%20d05',
@cLine10 = 'CHANGE TOTE ID',
@cLine11 = '%20i06',
@cLine14 = '%e',
@nFunc = 1806

DELETE rdt.rdtscn Where Scn = 3743 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3743, 'ENG',
@cLine01 = 'PTL PICKING      %03d03',
@cLine03 = 'OLD TOTE ID:', 
@cLine04 = '%20d01',
@cLine05 = 'NEW TOTE ID:',
@cLine06 = '%20i02',
@cLine14 = '%e',
@nFunc = 1806

DELETE rdt.rdtscn Where Scn = 3744 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3744, 'ENG',
@cLine01 = 'PTL PICKING      %03d01',
@cLine03 = 'ENTER = NEXT TASK', 
@cLine04 = 'ESC   = EXIT TM',
@cLine14 = '%e',
@nFunc = 1806

DELETE rdt.rdtscn Where Scn = 3745 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3745, 'ENG',
@cLine01 = 'PTL PICKING      %03d02',
@cLine03 = 'REASON CODE', 
@cLine04 = '%20i01',
@cLine14 = '%e',
@nFunc = 1806