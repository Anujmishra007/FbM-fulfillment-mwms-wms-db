-- 4690 = PickSlipNo
DELETE rdt.RDTScn WHERE Scn = 4690 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4690, 'ENG',
   @cLine01 = 'PSNO: %10i01',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"]}', 
   @nFunc = 830

-- 4691 = LOC, Option
DELETE rdt.RDTScn WHERE Scn = 4691 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4691, 'ENG',
   @cLine01 = 'PSNO: %10d01',
   @cLine02 = '', 
   @cLine03 = 'PKZONE: %10i05',--wms-15995
   @cLine04 = '',
   @cLine05 = 'LOC: %10d02',
   @cLine06 = 'LOC: %10i03',
   @cLine07 = '', 
   @cLine08 = 'DROP ID:',
   @cLine09 = '%20i04',
   @cLine10 = '', 
   @cLine11 = '', 
   @cLine12 = '%20d20', 
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"],"2":["3"],"3":["5","6"],"4":["8","9"],"5":["12"]}', 
   @nFunc = 830

-- 4692 = SKU/UPC
DELETE rdt.RDTScn WHERE Scn = 4692 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4692, 'ENG',
   @cLine01 = 'LOC: %10d01',
   @cLine02 = '%20d02', 
   @cLine03 = 'SKU:',
   @cLine04 = '%20d03',
   @cLine05 = '%60i04',
   @cLine06 = '%20d05',
   @cLine07 = '%20d06',
   @cLine08 = 'LOTTABLES:',
   @cLine09 = '%20d07',
   @cLine10 = '%20d08',
   @cLine11 = '%20d09',
   @cLine12 = '%20d10',
   @cLine13 = '%20d20',  
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"],"2":["3","4","5","6","7"],"3":["8","9","10","11","12","13"]}', 
   @nFunc = 830

-- 4693 = QTY
DELETE rdt.RDTScn WHERE Scn = 4693 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4693, 'ENG',
   @cLine01 = 'SKU:        PPK: %03d01',
   @cLine02 = '%20d02',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine05 = 'LOTTABLES:',
   @cLine06 = '%20d05',
   @cLine07 = '%20d06',
   @cLine08 = '%20d07',
   @cLine09 = '%20d08',
   @cLine10 = '%08d09 %05d10 %05d11', 
   @cLine11 = 'PK  QTY: %05d12 %05d13', 
   @cLine12 = 'ACT QTY: %05i14^DT:INT %05i15^DT:INT', 
   @cLine13 = '%20d20', 
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2","3","4"],"2":["5","6","7","8","9"],"3":["10","11","12"],"4":["10"]}', 
   @nFunc = 830

-- 4694 = TO LOC
DELETE rdt.RDTScn WHERE Scn = 4694 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4694, 'ENG',
   @cLine01 = 'TOLOC:',
   @cLine02 = '%10i01',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"]}', 
   @nFunc = 830

-- 4695 = skip task screen
DELETE rdt.RDTScn WHERE Scn = 4695 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4695, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Skip current task?',
   @cLine03 = '',
   @cLine04 = '1 = YES',
   @cLine05 = '2 = NO',
   @cLine06 = '',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e'

-- 4696 = short pick screen
DELETE rdt.RDTScn WHERE Scn = 4696 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4696, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Confirm short pick?',
   @cLine03 = '',
   @cLine04 = '1 = YES',
   @cLine05 = '2 = NO',
   @cLine06 = '',
   @cLine07 = 'OPTION: %01i01',
   @cLine14 = '%e'

-- 4697 = ID screen
DELETE rdt.RDTScn WHERE Scn = 4697 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4697, 'ENG',
   @cLine01 = 'LOC: %10d01',
   @cLine02 = '',
   @cLine03 = 'ID:',
   @cLine04 = '%18d02',
   @cLine05 = '%18i03',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"],"2":["3","4","5"]}', 
   @nFunc = 830

-- 6528 = short pick screen (reallocation)
DELETE rdt.RDTScn WHERE Scn = 6528 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6528, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Confirm short pick?',
   @cLine03 = '',
   @cLine04 = '1 = YES',
   @cLine05 = '2 = NO',
   @cLine06 = '9 = Alternate PICK LOC',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e'
