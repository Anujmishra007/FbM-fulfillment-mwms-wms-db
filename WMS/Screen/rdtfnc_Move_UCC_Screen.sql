/*
   Move by UCC
*/

-- 808 = Move from
DELETE rdt.RDTScn WHERE Scn = 808 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 808, 'ENG', 
   @cLine01 = 'UCC 1-9:', 
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
   @cLine14 = '%e'

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
   @cLine14 = '%e'

-- 810 = Message
DELETE rdt.RDTScn WHERE Scn = 810 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 810, 'ENG', 
   @cLine01 = '', 
   @cLine02 = 'UCC successfully', 
   @cLine03 = 'moved', 
   @cLine04 = '', 
   @cLine05 = 'Press ENTER or ESC', 
   @cLine06 = 'to continue', 
   @cLine14 = '%e'

-- 811 = From Loc
DELETE rdt.RDTScn WHERE Scn = 811 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 811, 'ENG'
   ,@cLine01 = 'FROM LOC:'
   ,@cLine02 = '%10i01'
   ,@cLine04 = 'FROM ID:'  -- WMS-8352
   ,@cLine05 = '%18i02'    -- WMS-8352
   ,@cLine14 = '%e'
