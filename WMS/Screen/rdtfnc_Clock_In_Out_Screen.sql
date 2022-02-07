-- rdtfnc_Clock_In_Out
-- 704 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 704 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 704, 'ENG',
    @cLine01 = 'LOCATION:'
   ,@cLine02 = '%10i01'
   ,@cLine12 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
   ,@nFunc = 701

-- 705 = USER ID screen
DELETE rdt.RDTScn WHERE Scn = 705 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 705, 'ENG',
    @cLine01 = 'USER ID:'
   ,@cLine02 = '%18i01'
   ,@cLine11 = 'ENTER = Next Page'
   ,@cLine12 = '%20d02'   -- (james02)
   ,@cLine14 = '%e'
   ,@nFunc = 701
 
