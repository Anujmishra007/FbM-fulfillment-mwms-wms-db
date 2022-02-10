
-- 900 = Change PassWord screen
DELETE rdt.RDTScn WHERE Scn = 900 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 900, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Change PassWord'
   ,@cLine03 = 'User ID:'
   ,@cLine04 = '%15i01'
   ,@cLine05 = 'New PassWord:'
   ,@cLine06 = '%15p02'
   ,@cLine07 = 'Confirm PassWord:'
   ,@cLine08 = '%15p03'
   ,@cLine14 = '%e'
   ,@nFunc = 800
   
-- 901 = Change PassWord screen
DELETE rdt.RDTScn WHERE Scn = 901 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 901, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PassWord Changed Successfully'
   ,@cLine04 = 'Press Enter To Continue'
   ,@cLine14 = '%e'
   ,@nFunc = 800
 
