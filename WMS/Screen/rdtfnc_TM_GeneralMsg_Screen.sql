--Screen# 2550 - 2559


-- 2550 = GM screen
DELETE rdt.RDTScn WHERE Scn = 2550 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2550, 'ENG',
    @cLine01 = 'MESSAGE           GM'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d09'
   ,@cLine09 = '%20d10'
   ,@cLine10 = '%20d11'
   ,@cLine11 = '%20d12'
   ,@cLine12 = '%20d13'
   ,@cLine13 = 'ENTER to CONFIRM'
   ,@cLine14 = '%e'

 -- 2551 = Msg screen
DELETE rdt.RDTScn WHERE Scn = 2551 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2551, 'ENG',
    @cLine01 = 'MESSAGE           GM'
   ,@cLine03 = 'ENTER = Next Task'
   ,@cLine04 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'

-- For task manager, need to update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 1763 WHERE SCN BETWEEN 2550 AND 2551
   
   