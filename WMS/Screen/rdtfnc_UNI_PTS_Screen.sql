--rdtfnc_UNI_PTS
-- 4720 - 4729


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('761', 'ENG', 'FNC', 'PTS Sort And Pack', 'rdtfnc_UNI_PTS', '0')

-- Screen 1
-- Scn = 4500 
DELETE rdt.RDTScn WHERE Scn = 4720 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4720, 'ENG', 
   @cLine01 = 'PTS - UNI',
   @cLine03 = 'DROPID:',
   @cLine04 = '%20i01',
   @cLine06 = 'DROPID SCANNED: ',
   @cLine07 = '%05d02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4721 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4721, 'ENG', 
   @cLine01 = 'PTS - UNI',
   @cLine03 = 'POSITION:',
   @cLine04 = '%20d01',
   @cLine05 = '%20i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4722 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4722, 'ENG'
   ,@cLine01 = 'DROPID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02' -- Consignee / Others Combination
   ,@cLine04 = '%20d03' -- Consignee / Others Combination
   ,@cLine05 = '%20d04' -- SKU
   ,@cLine06 = '%20d05' -- Lottable02 -- SKU DESCR
   ,@cLine07 = '%20d06' -- Lottable02 -- SKU DESCR
   ,@cLine08 = '%20i07' -- SKU Input 
   ,@cLine09 = 'TOTENO:' -- (ChewKP01) 
   ,@cLine10 = '%20d08'  -- (CheWKP01) 
   ,@cLine11 = '%20d09'
   ,@cLine12 = 'ESP QTY: %05d10 %05d11'
   ,@cLine13 = 'ACT QTY: %05i12 %05i13'
   ,@cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4723 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4723, 'ENG', 
   @cLine01 = 'PTS - UNI',
   @cLine03 = 'POSITION IS FULL',
   @cLine04 = '',
   @cLine05 = 'PRESS ENTER TO',
   @cLine07 = 'CONTINUE',
   @cLine08 = '',
   @cLine14 = '%e'

 
   
DELETE rdt.RDTScn WHERE Scn = 4724 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4724, 'ENG', 
   @cLine01 = 'PTS - UNI',
   @cLine03 = 'SORTATION COMPLETED',
   @cLine09 = 'PRESS ENTER TO',
   @cLine10 = 'CONTINUE',
   @cLine14 = '%e'   
      
      
UPDATE RDT.RDTScn SET Func = 761 WHERE Scn Between 4720 AND 4729
UPDATE RDT.RDTScnDetail SET Func = 761 WHERE Scn Between 4720 AND 4729 