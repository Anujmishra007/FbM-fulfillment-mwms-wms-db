
   
-- 4492 = ?? screen
--DELETE rdt.RDTScn WHERE Scn = 4495 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 4495, 'ENG'
--   ,@cLine01 = N'WaveKey:       %05d05'
--   ,@cLine02 = N'%10i01'
--   ,@cLine03 = N''
--   ,@cLine04 = N'STATION:'
--   ,@cLine05 = N'%10d02'
--   ,@cLine06 = N''
--   ,@cLine07 = N'LOCATION:      '
--   ,@cLine08 = N'%10i03'
--   ,@cLine09 = N''
--   ,@cLine10 = N'CARTON ID:     %05d06'
--   ,@cLine11 = N'%20i04'
--   ,@cLine14 = N'%e'
   
-- 4496 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4496 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4496, 'ENG'
   ,@cLine01 = N''
   ,@cLine02 = N''
   ,@cLine03 = N'PRESS ENTER'
   ,@cLine04 = N'TO CONTINUE'
   ,@cLine05 = N''
   ,@cLine06 = N''
   ,@cLine07 = N''
   ,@cLine08 = N''
   ,@cLine09 = N''
   ,@cLine10 = N''
   ,@cLine11 = N''
   ,@cLine14 = N'%e'   
 
   