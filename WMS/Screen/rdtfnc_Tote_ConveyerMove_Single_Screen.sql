
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1810', 'ENG', 'FNC', 'Tote ConveyorMove', 'rdtfnc_Tote_ConveyerMove_Single', '0')

   
DELETE rdt.RDTScn WHERE Scn = 3900 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3900, 'ENG',
    @cLine01 = 'TOTE - CONVEYOR MOVE'
   ,@cLine03 = 'TOTE / CARTON ID:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1810   

   
   -- 2531 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3901 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3901, 'ENG',
    @cLine01 = 'TOTE - CONVEYOR MOVE'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%18d02'
   ,@cLine05 = 'STATION: %10i03'
   ,@cLine07 = '1 = INSERT'
   ,@cLine08 = '9 = DELETE'
   ,@cLine09 = 'OPTIONS: %01i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1810

