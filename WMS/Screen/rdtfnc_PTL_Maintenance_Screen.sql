--rdtfnc_PTL_Maintenance
-- 3600 - 3609


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('814', 'ENG', 'FNC', 'SC-Maintenance', 'rdtfnc_PTL_Maintenance', '0')

-- Screen 1
-- Scn = 3600 
DELETE rdt.RDTScn WHERE Scn = 3600 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn2 3600, 'ENG', 
   @cLine01 = 'SC - MAINTENANCE',
   @cLine03 = 'CART ID/PTS ZONE:',
   @cLine04 = '%i`01`10````white',
   @cLine06 = 'CART/PTS ADDRESS:',
   @cLine07 = '%i`02`10````white',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3601 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn2 3601, 'ENG', 
   @cLine01 = 'SC - MAINTENANCE',
   @cLine02 = 'CART ID/PTS ZONE:',
   @cLine03 = '%d`01`10`white',
   @cLine05 = 'Maintenance Type:',
   @cLine06 = '%ddlb`02`20`RDT.v_LookUp_PTLMT``Please Select`White', 
   @cLine14 = '%e'


      
UPDATE RDT.RDTScn SET Func = 814 WHERE Scn Between 3600 AND 3609 