--rdtfnc_PTS_SortAndPack
-- 4500 - 4509

IF NOT EXISTS (SELECT 1 from RDT.RDTMsg (NOLOCK) where message_id=762)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('762', 'ENG', 'FNC', 'PTS Sort And Pack', 'rdtfnc_PTS_SortAndPack2', '0')
END

-- Screen 1
-- Scn = 4500 
DELETE rdt.RDTScn WHERE Scn = 6010 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6010, 'ENG', 
   @cLine01 = 'PTS - SORT AND PACK',
   @cLine03 = 'DROPID:',
   @cLine04 = '%20i01',
   @cLine06 = 'DROPID SCANNED: ',
   @cLine07 = '%05d02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 6011 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6011, 'ENG'
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
   
-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 6012 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6012, 'ENG', 
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
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 6013 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6013, 'ENG', 
   @cLine01 = 'PTS - SORT AND PACK',
   @cLine03 = 'SHORT PACK ?',
   @cLine09 = '1 = YES | 9 = NO',
   @cLine10 = 'OPTIONS: %01i01',
   @cLine14 = '%e'   
   
-- Screen 5 
DELETE rdt.RDTScn WHERE Scn = 6014 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6014, 'ENG', 
   @cLine01 = 'PTS - SORT AND PACK',
   @cLine03 = 'SORTATION COMPLETED',
   @cLine09 = 'PRESS ENTER TO',
   @cLine10 = 'CONTINUE',
   @cLine14 = '%e'   
      
      