/*
   Move SKU
*/

-- 1530 = LOC
DELETE rdt.RDTScn WHERE Scn = 1530 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1530, 'ENG',
   @cLine01 = 'FROM LOC: %10i01',
   @cLine14 = '%e'

-- 1531 = ID
DELETE rdt.RDTScn WHERE Scn = 1531 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1531, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18i02',
   @cLine14 = '%e'

-- 1532 = SKU
DELETE rdt.RDTScn WHERE Scn = 1532 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1532, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%20i03',
   @cLine14 = '%e'

-- 1533 = QTY
DELETE rdt.RDTScn WHERE Scn = 1533 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1533, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '         %05d06 %05d09',
   @cLine09 = 'QTY AVL: %05d07 %05d10',
   @cLine10 = 'QTY MV:  %05i08 %05i11',
   @cLine14 = '%e'

-- 1534 = To ID
DELETE rdt.RDTScn WHERE Scn = 1534 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1534, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '         %05d06 %05d09',
   @cLine09 = 'QTY AVL: %05d07 %05d10',
   @cLine10 = 'QTY MV:  %05d08 %05d11',
   @cLine11 = 'TO ID:',
   @cLine12 = '%18i12',
   @cLine14 = '%e'

-- 1535 = To LOC
DELETE rdt.RDTScn WHERE Scn = 1535 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1535, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '         %05d06 %05d09',
   @cLine09 = 'QTY AVL: %05d07 %05d10',
   @cLine10 = 'QTY MV:  %05d08 %05d11',
   @cLine11 = 'TO ID:',
   @cLine12 = '%18d12',
   @cLine13 = 'TO LOC: %10i13',
   @cLine14 = '%e'

-- 1536 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1536 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1536, 'ENG',
   @cLine02 = 'SKU moved',
   @cLine03 = 'successfully',
   @cLine04 = '',
   @cLine05 = 'Press ENTER or ESC',
   @cLine06 = 'to continue',
   @cLine14 = '%e'
