INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('857', 'ENG', 'FNC', 'Driver Check In/Out', 'rdtfnc_Driver_CheckIn', '0')

DELETE rdt.RDTScn WHERE Scn = 2134 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2134, 'ENG', 
   @cLine01 = 'DRIVER CHECK IN',
   @cLine03 = 'CONTAINER NO:',
   @cLine04 = '%20i01',
   @cLine05 = 'OR',        -- (ChewKP01) 
   @cLine06 = 'APPT NO:',  -- (ChewKP01) 
   @cLine07 = '%20i02',    -- (ChewKP01) 
   @cLine09 = '1 = CHECK-IN ',  -- (ChewKP01) 
   @cLine10 = '9 = CHECK-OUT',  -- (ChewKP01) 
   @cLine11 = 'OPTION: %01i03',    -- (ChewKP01) 
   --@cLine12 = 'ENTER = Confirm', -- (ChewKP01) 
   @cLine14 = '%e'
   
DELETE rdt.RDTScn WHERE Scn = 2135 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2135, 'ENG', 
   @cLine01 = 'DRIVER CHECK IN',
   @cLine03 = '%20d01',
   @cLine04 = '%20d02',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '%20d06',
   @cLine09 = '%20d07',
   @cLine10 = '%20d08',
   @cLine11 = '%20d09',
   @cLine12 = '%20d10',
   @cLine14 = '%e' 
      
DELETE rdt.RDTScn WHERE Scn = 2136 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2136, 'ENG', 
   @cLine01 = 'DRIVER CHECK IN',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%20i04',
   @cLine06 = '%20d05',
   @cLine07 = '%20i06',
   @cLine08 = '%20d07',
   @cLine09 = '%20i08',
   @cLine10 = '%20d09',
   @cLine11 = '%20i10',
   @cLine12 = 'CONFIRM? 1=YES|9=NO',
   @cLine13 = 'OPTION: %01i11',
   @cLine14 = '%e'
   
 
   

