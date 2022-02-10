--2600-2609
--select * from rdt.rdtscn WHERE SCN BETWEEN 2600 AND 2609 
-- Screen 1
-- Scn = 2600. CCREF
DELETE rdt.RDTScn WHERE Scn = 2600 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2600, 'ENG', 
   @cLine01 = 'CCREF : %10i01',
   @cLine14 = '%e'

-- Screen 2
-- Scn = 2601. LOC
DELETE rdt.RDTScn WHERE Scn = 2601 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2601, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'CNT NO: %01d02',
   @cLine05 = 'LOC: %10i03',
   @cLine14 = '%e'
   
-- Screen 3
-- Scn = 2602. ID
DELETE rdt.RDTScn WHERE Scn = 2602 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2602, 'ENG', 
   @cLine01 = 'CCREF: %10d01',
   @cLine02 = 'CNT NO: %01d02',
   @cLine03 = 'LOC: %10d03',
   @cLine05 = 'ID:',
   @cLine06 = '%18i04',  
   @cLine14 = '%e'

-- Screen 4
-- Scn = 2603. Reset count
DELETE rdt.RDTScn WHERE Scn = 2603 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2603, 'ENG', 
   @cLine01 = 'CCREF: %10d01',
   @cLine02 = 'CNT NO: %01d02',
   @cLine03 = 'LOC: %10d03',
   @cLine04 = 'ID:',
   @cLine05 = '%18d04',  
   @cLine06 = 'SKU:',        -- (ChewKP01)
   @cLine07 = '%20d05',      -- (ChewKP01)
   @cLine08 = '%20d06',      -- (ChewKP01) 
   @cLine09 = '%20d07',      -- (ChewKP01)
   @cLine10 = 'Reset count Qty?', -- (ChewKP01)
   @cLine12 = 'OPT: %01i08 (1=Yes, 2=No)', -- (ChewKP01)
   @cLine14 = '%e'

-- (ChewKP01)
-- Screen 5
-- Scn = 2604. Reset count   
DELETE rdt.RDTScn WHERE Scn = 2604 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2604, 'ENG', 
   @cLine01 = 'CCREF: %10d01',
   @cLine02 = 'CNT NO: %01d02',
   @cLine03 = 'LOC: %10d03',
   @cLine05 = 'ID:',
   @cLine06 = '%18d04',  
   @cLine08 = 'SKU:',
   @cLine09 = '%40i05',  
   @cLine14 = '%e'


UPDATE RDT.RDTSCN WITH (ROWLOCK) SET FUNC = 612 WHERE SCN BETWEEN 2600 AND 2609 