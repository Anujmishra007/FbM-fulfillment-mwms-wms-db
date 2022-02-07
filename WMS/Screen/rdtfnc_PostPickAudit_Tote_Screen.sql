--rdtfnc_PostPickAudit_Tote
-- 3190 - 3199


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('847', 'ENG', 'FNC', 'Tote PPA', 'rdtfnc_PostPickAudit_Tote', '9')


-- Screen 1
-- Scn = 3190 
DELETE rdt.RDTScn WHERE Scn = 3190 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3190, 'ENG', 
   @cLine01 = 'TOTE PPA',
   @cLine03 = 'TOTE:',
   @cLine04 = '%18i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3191 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3191, 'ENG', 
   @cLine01 = 'TOTE PPA',
   @cLine03 = 'TOTE:',
   @cLine04 = '%18d01',
   @cLine05 = 'SKU:',
   @cLine06 = '%20i02',
   @cLine08 = 'TO COMPLETE PPA',
   @cLine09 = 'ENTER 9 : %01i03 ',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3192 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3192, 'ENG', 
   @cLine01 = 'TOTE PPA',
   @cLine03 = 'TOTE:',
   @cLine04 = '%18d01',
   @cLine06 = 'RDT PPA COMPLETED',
   @cLine07 = '%20d02',
   @cLine14 = '%e'   


UPDATE RDT.RDTScnDetail SET Func = 847 WHERE Scn Between 3190 AND 3199 