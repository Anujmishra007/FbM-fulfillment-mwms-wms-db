--FCR-12576

-- 6895 = Pallet Type screen
DELETE rdt.RDTScn WHERE Scn = 6895 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6895, 'ENG'
   ,@cLine01 = 'Enter/Scan Pallet Type'
   ,@cLine02 = '%10l01'
   ,@cLine03 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"], "2":["2"]}'
   ,@nFunc = 513
