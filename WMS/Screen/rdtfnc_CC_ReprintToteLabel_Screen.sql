-- 2480 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2650 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2650, 'ENG',
    @cLine01 = 'CC: REPRINT TOTE'
   ,@cLine02 = 'MANIFEST/LABEL'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1781
 
-- 2481 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2651 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2651, 'ENG',
    @cLine01 = 'CC: REPRINT TOTE'
   ,@cLine02 = 'MANIFEST/LABEL'
   ,@cLine04 = '1 = MANIFEST'
   ,@cLine05 = '9 = LABEL'
   ,@cLine08 = 'Option: %01i01'
   ,@cLine10 = 'PRESS ESC TO GO BACK'
   ,@cLine14 = '%e'
   ,@nFunc = 1781
