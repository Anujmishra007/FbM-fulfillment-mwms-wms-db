-- 4280 = Data Capture 7 screen
DELETE rdt.RDTScn WHERE Scn = 4280 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4280, 'ENG',
    @cLine01 = 'SEAL NO:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'

-- 4281 = Data Capture 7 screen
DELETE rdt.RDTScn WHERE Scn = 4281 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4281, 'ENG',
    @cLine01 = 'SEAL NO:'
   ,@cLine02 = '%20d01'
   ,@cLine04 = 'PALLET ID:'
   ,@cLine05 = '%20i02'
   ,@cLine13 = 'TOTAL SCANNED: %05d03'
   ,@cLine14 = '%e'