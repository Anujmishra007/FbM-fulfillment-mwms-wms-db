-- rdtfnc_Wave_Replen_To

-- 2080 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2080 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2080, 'ENG',
    @cLine01 = 'WAVE:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'

-- 2081 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2081 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2081, 'ENG',
    @cLine01 = 'WAVE:'
   ,@cLine02 = '%10d01'
   ,@cLine04 = 'Scan Pallet ID'
   ,@cLine05 = 'DROP ID:'
   ,@cLine06 = '%18i02'
   ,@cLine14 = '%e'

