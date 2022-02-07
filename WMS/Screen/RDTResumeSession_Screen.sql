

-- 5390 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5390 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5390, 'ENG'
   ,@cLine01 = N'LAST SESSION NOT LOG'
   ,@cLine02 = N'OUT. CONT WITH LAST'
   ,@cLine03 = N'SESSION?'
   ,@cLine05 = N'1 = YES'
   ,@cLine06 = N'9 = NO'
   ,@cLine08 = N'OPTION: %01i01'
   ,@cLine14 = N'%e'

