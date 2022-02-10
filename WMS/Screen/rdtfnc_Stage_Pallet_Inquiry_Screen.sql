-- 2630 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2630 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2630, 'ENG',
    @cLine01 = 'STAGING PLT INQUIRY'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18i01'
   ,@cLine06 = 'OR'
   ,@cLine08 = 'LABEL NO:'
   ,@cLine09 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1647
 
-- 2631 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2631 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2631, 'ENG',
    @cLine01 = 'DROP ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'NO. LABEL: %05d02'
   ,@cLine04 = 'PICKUP#:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'LOC : %10d04'
   ,@cLine07 = 'DOOR: %10d05'
   ,@cLine08 = 'USER: %14d06'
   ,@cLine09 = 'DATE:'
   ,@cLine10 = '%20d07'
   ,@cLine12 = 'OPT %01i08'
   ,@cLine13 = '1 = LOC HISTORY'
   ,@cLine14 = '%e'
   ,@nFunc = 1647

-- 2632 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2632 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2632, 'ENG',
    @cLine01 = 'DROP ID:       %05d01'
   ,@cLine02 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine12 = '%20d11'
   ,@cLine13 = '%20d12'
   ,@cLine14 = '%e'
   ,@nFunc = 1647