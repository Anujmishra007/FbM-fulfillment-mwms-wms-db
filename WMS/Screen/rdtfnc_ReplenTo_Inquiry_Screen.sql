-- 3670 = Scan LPN screen
DELETE rdt.RDTScn WHERE Scn = 3670 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3670, 'ENG',
    @cLine01 = 'REPLEN TO INQUIRY'
   ,@cLine03 = 'LPN:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1802

-- 3671 =  ReplenTo Info screen
DELETE rdt.RDTScn WHERE Scn = 3671 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3671, 'ENG',
    @cLine01 = 'REPLEN TO INQUIRY'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'LPN:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = 'UOM:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = 'Final LOC:'
   ,@cLine10 = '%10d04'
   ,@cLine11 = '%10d05'
   ,@cLine12 = '%10d06'
   ,@cLine14 = '%e'
   ,@nFunc = 1802