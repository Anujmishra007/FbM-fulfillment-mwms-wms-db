INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1805', 'ENG', 'FNC', 'CLOSE PTS TOTE', 'rdtfnc_Close_PTS_Tote', '0')

-- 2480 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2480 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2480, 'ENG',
    @cLine01 = '%20d02'
   ,@cLine02 = '%20d03'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%20i01'
   ,@cLine14 = '%e'
   
 
-- 2481 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2481 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2481, 'ENG',
    @cLine01 = '%20d02'
   ,@cLine02 = '%20d03'
   ,@cLine03 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine08 = 'Option: %01i01'
   ,@cLine10 = '%20d07'
   ,@cLine14 = '%e'

-- (ChewKP01)    
-- 2482 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2482 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2482, 'ENG',
    @cLine01 = 'CLOSE TOTE'
   ,@cLine02 = '%20d01'
   ,@cLine04 = 'NEW TOTE'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'  

-- (ChewKP01)    
-- 2482 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2483 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2483, 'ENG',
    @cLine03 = 'NO MORE TASK'
   ,@cLine04 = 'FOR THIS CONSIGNEE'
   ,@cLine14 = '%e' 
   
-- Note: This module no need set function no as it is shared across multi function