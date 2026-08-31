/*
   Move by UCC
*/

-- 808 = Move from
DELETE rdt.RDTScn WHERE Scn = 808 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 808, 'ENG', 
   @cLine01 = 'UCC:             %03d13', 
   @cLine02 = '%20i01', -- UCC1
   @cLine03 = '%20i02', 
   @cLine04 = '%20i03', 
   @cLine05 = '%20i04', 
   @cLine06 = '%20i05', 
   @cLine07 = '%20i06', 
   @cLine08 = '%20i07', 
   @cLine09 = '%20i08', 
   @cLine10 = '%20i09', -- UCC9
   @cLine11 = '%20d10', -- SKU
   @cLine12 = '%20d11', -- Desc1
   @cLine13 = '%20d12', -- Desc2
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2","3","4","5","6","7","8","9","10"],"2":["11","12","13"]}',
   @nFunc = 514

-- 809 = Move from
DELETE rdt.RDTScn WHERE Scn = 809 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 809, 'ENG', 
   @cLine01 = 'MOVE TO', 
   @cLine02 = '', 
   @cLine03 = 'TO ID:', 
   @cLine04 = '%18i01', 
   @cLine05 = '', 
   @cLine06 = 'TO LOC:', 
   @cLine07 = '%10i02', 
   @cLine08 = '', 
   @cLine09 = '', 
   @cLine10 = '', 
   @cLine11 = '', 
   @cLine12 = '', 
   @cLine13 = '', 
   @cLine14 = '%e',
   @cWebGroup = '{"1":["3","4"],"2":["6","7"]}',
   @nFunc = 514

-- 810 = Message
DELETE rdt.RDTScn WHERE Scn = 810 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 810, 'ENG', 
   @cLine01 = '', 
   @cLine02 = 'UCC successfully', 
   @cLine03 = 'moved', 
   @cLine04 = '', 
   @cLine05 = 'Press ENTER or ESC', 
   @cLine06 = 'to continue', 
   @cLine14 = '%e',
   @cAutoDisappear = '1',
   @nFunc = 514

-- 811 = From LOC, ID
DELETE rdt.RDTScn WHERE Scn = 811 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 811, 'ENG'
   ,@cLine01 = 'FROM LOC:'
   ,@cLine02 = '%10i01'
   ,@cLine04 = 'FROM ID:'  -- WMS-8352
   ,@cLine05 = '%18i02'    -- WMS-8352
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 514

-- 812 = Move from
DELETE rdt.RDTScn WHERE Scn = 812 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 812, 'ENG', 
   @cLine01 = 'UCC:             %03d13', 
   @cLine02 = '%20d01', -- UCC1
   @cLine03 = '%20d02', 
   @cLine04 = '%20d03', 
   @cLine05 = '%20d04', 
   @cLine06 = '%20d05', 
   @cLine07 = '%20d06', 
   @cLine08 = '%20d07', 
   @cLine09 = '%20d08', 
   @cLine10 = '%200iV_Barcode', -- UCC9
   @cLine11 = '%20d10', -- SKU
   @cLine12 = '%20d11', -- Desc1
   @cLine13 = '%20d12', -- Desc2
   @cLine14 = '%e'