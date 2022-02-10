--rdtfnc_TM_CycleCount
-- 2870 - 2979

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1766', 'ENG', 'FNC', 'TM CycleCount', 'rdtfnc_TM_CycleCount', '8')

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1794', 'ENG', 'FNC', 'TM CycleCount SV', 'rdtfnc_TM_CycleCount', '8')

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1795', 'ENG', 'FNC', 'TM CycleCount SUP ', 'rdtfnc_TM_CycleCount', '8')

Insert Into rdt.rdtTaskManagerconfig (TaskType , TaskDesc, Function_ID)
Values ( 'CC', 'CycleCount' , 1766 )

Insert into rdt.rdtTaskManagerConfig ( TaskType , TaskDesc, Function_ID)
Values ( 'CCSV', 'CycleCount SV', 1794 )

Insert into rdt.rdtTaskManagerConfig ( TaskType , TaskDesc, Function_ID)
Values ( 'CCSUP', 'CycleCount SUP', 1795)



-- Screen 1
-- Scn = 2870 
DELETE rdt.RDTScn WHERE Scn = 2870 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2870, 'ENG', 
   @cLine01 = 'TM CC - MAIN',
   @cLine03 = 'LOC:',
   @cLine04 = '%10d10     %05d11',
   @cLine05 = '%10i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 2871 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2871, 'ENG', 
   @cLine01 = 'TM CC - MAIN',
   @cLine03 = 'LOC:',
   @cLine04 = '%10d01',
   @cLine05 = 'ID:',
   @cLine06 = '%18i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 2872 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2872, 'ENG', 
   @cLine01 = 'TM CC - MAIN',
   @cLine03 = 'LOC:',
   @cLine04 = '%10d01',
   @cLine05 = 'ID:',
   @cLine06 = '%10d02',
   @cLine08 = '1 = UCC',
   @cLine09 = '2 = SKU',
   --@cLine10 = '3 = SINGLE SCAN',
   @cLine11 = 'Option: %01i03',
   @cLine14 = '%e'  

DELETE rdt.RDTScn WHERE Scn = 2873 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2873, 'ENG', 
   @cLine01 = 'TM CC - MAIN',
   @cLine03 = 'Is This Location',
   @cLine04 = 'LOC: %10d01',
   @cLine06 = 'EMPTY ? ',
   @cLine08 = '1 = YES',
   @cLine09 = '2 = NO',
   @cLine10 = 'Option: %01i02',
   @cLine14 = '%e'       

DELETE rdt.RDTScn WHERE Scn = 2874 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2874, 'ENG', 
   @cLine01 = 'TM CC - MAIN',
   @cLine03 = 'ALERT TO SUPERVISOR',
   @cLine04 = 'HAS BEEN SENT',
   @cLine14 = '%e'     

DELETE rdt.RDTScn WHERE Scn = 2875 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2875, 'ENG', 
   @cLine01 = 'TM CC - MAIN',
   --@cLine03 = 'NO MORE TASK',
   @cLine05 = 'ENTER = NEXT TASK',
   @cLine06 = 'ESC   = EXIT TM',
   @cLine14 = '%e'       

--DELETE rdt.RDTScn WHERE Scn = 2876 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 2876, 'ENG', 
--   @cLine01 = 'TM CC - MAIN',
--   @cLine04 = '1 = END OF ID',
--   @cLine05 = '2 = END OF LOC',
--   @cLine06 = '3 = RECOUNT LOC',
--   --@cLine07 = '4 = CONTINUE',
--   @cLine09 = 'OPTION: %01i01',
--   @cLine14 = '%e'   
   
-- Screen 4
--DELETE rdt.RDTScn WHERE Scn = 2872 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 2872, 'ENG', 
--   @cLine01 = 'TM CC - MAIN',
--   @cLine03 = 'LOC:',
--   @cLine04 = '%10d01',
--   @cLine05 = 'ID:',
--   @cLine06 = '%10d02',
--   @cLine07 = 'SKU/UCC:',
--   @cLine08 = '%20i03',
--   @cLine14 = '%e'   

UPDATE RDT.RDTScn SET Func = 1766 WHERE Scn Between 2870 AND 2879 
