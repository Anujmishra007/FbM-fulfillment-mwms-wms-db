IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 652)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('652', 'ENG', 'FNC', 'Activity Tracker', 'rdtfnc_ActivityTrack', '0')
END

-- 5450 = Label, value screen
DELETE rdt.RDTScn WHERE Scn = 6050 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6050, 'ENG'
   ,@cLine01 = 'Activity Tracking:'
   ,@cLine02 = ''
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine13 = 'Option: %01i10'
   ,@cLine14 = '%e'
   ,@nFunc   = 652

DELETE rdt.RDTScn WHERE Scn = 6051 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6051, 'ENG', 
   @cLine01 = '%20d01',
   @cLine03 = 'CONTAINER NO:',
   @cLine04 = '%20i02',
   @cLine05 = 'OR',       
   @cLine06 = 'APPT NO:', 
   @cLine07 = '%20i03',   
   @cLine09 = '%20d04',  
   @cLine10 = '%20d05',  
   @cLine11 = 'OPTION: %01i06', 
   @cLine14 = '%e',
   @nFunc   = 652
   
DELETE rdt.RDTScn WHERE Scn = 6052 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6052, 'ENG', 
   @cLine01 = '%20d11',
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
   @cLine14 = '%e',
   @nFunc   = 652 
      
DELETE rdt.RDTScn WHERE Scn = 6053 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6053, 'ENG', 
   @cLine01 = '%20d11',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%20i04',
   @cLine06 = '%20d05',
   @cLine07 = '%20i06',
   @cLine08 = '%20d07',
   @cLine09 = '%20d08',
   @cLine10 = '%20d09',
   @cLine11 = '%20d10',
   @cLine12 = 'CONFIRM? 1=YES|9=NO',
   @cLine13 = 'OPTION: %01i12',
   @cLine14 = '%e',
   @nFunc   = 652 
   
 
   

