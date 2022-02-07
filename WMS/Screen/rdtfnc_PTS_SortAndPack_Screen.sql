--rdtfnc_PTS_SortAndPack
-- 4500 - 4509


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('760', 'ENG', 'FNC', 'PTS Sort And Pack', 'rdtfnc_PTS_SortAndPack', '0')

-- Screen 1
-- Scn = 4500 
DELETE rdt.RDTScn WHERE Scn = 4500 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4500, 'ENG', 
   @cLine01 = 'PTS - SORT AND PACK',
   @cLine03 = 'DROPID:',
   @cLine04 = '%20i01',
   @cLine06 = 'DROPID SCANNED: ',
   @cLine07 = '%05d02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4501 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4501, 'ENG', 
   @cLine01 = 'PTS - SORT AND PACK',
   @cLine03 = 'POSITION:',
   @cLine04 = '%20d01',
   @cLine05 = '%20i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4502 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4502, 'ENG'
   ,@cLine01 = 'DROPID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02' -- Consignee / Others Combination
   ,@cLine04 = '%20d03' -- Consignee / Others Combination
   ,@cLine05 = '%20d04' -- SKU
   ,@cLine06 = '%20d05' -- Lottable02 -- SKU DESCR
   ,@cLine07 = '%20d06' -- Lottable02 -- SKU DESCR
   ,@cLine08 = '%20i07' -- SKU Input 
--   ,@cLine09 = '%20d08'
--   ,@cLine10 = '%20d14'
   ,@cLine11 = '%20d09'
   ,@cLine12 = 'ESP QTY: %05d10 %05d11'
   ,@cLine13 = 'ACT QTY: %05i12 %05i13'
   ,@cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4503 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4503, 'ENG', 
   @cLine01 = 'PTS - SORT AND PACK',
   @cLine03 = 'TO LABELNO:',
   @cLine04 = '%20d01',
   @cLine05 = '%20i02',
   @cLine07 = '%20d03',
   @cLine08 = '%20d04',
   @cLine14 = '%e'

-- Screen 5
--DELETE rdt.RDTScn WHERE Scn = 4504 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 4504, 'ENG', 
--   @cLine01 = 'PTS - SORT AND PACK',
--   @cLine03 = 'LABELNO:',
--   @cLine04 = '%20d01',
--   @cLine05 = 'NEW LABELNO:',
--   @cLine06 = '%20d02',
--   @cLine08 = 'CHANGE LABELNO ? ',
--   @cLine09 = '1 = YES | 9 = NO',
--   @cLine10 = 'OPTIONS: %01i03',
--   @cLine14 = '%e'   
   
-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 4504 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4504, 'ENG', 
   @cLine01 = 'PTS - SORT AND PACK',
   @cLine03 = 'SHORT PACK ?',
   @cLine09 = '1 = YES | 9 = NO',
   @cLine10 = 'OPTIONS: %01i01',
   @cLine14 = '%e'   
   
   
DELETE rdt.RDTScn WHERE Scn = 4505 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4505, 'ENG', 
   @cLine01 = 'PTS - SORT AND PACK',
   @cLine03 = 'SORTATION COMPLETED',
   @cLine09 = 'PRESS ENTER TO',
   @cLine10 = 'CONTINUE',
   @cLine14 = '%e'   
      
      
UPDATE RDT.RDTScn SET Func = 760 WHERE Scn Between 4500 AND 4509
UPDATE RDT.RDTScnDetail SET Func = 760 WHERE Scn Between 4500 AND 4509 