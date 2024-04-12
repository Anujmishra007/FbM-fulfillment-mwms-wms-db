-- 6360 = ID
DELETE rdt.RDTScn WHERE Scn = 6360 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6360, 'ENG'
   ,@cLine01 = 'Pallet ID'
   ,@cLine02 = '%20i01' -- %20i01 (ID)
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 1157

-- 6361 = Scan VAS Code
DELETE rdt.RDTScn WHERE Scn = 6361 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6361, 'ENG'
   ,@cLine01 = 'Enter/Scan VAS Code'
   ,@cLine02 = '%20i01' -- %20i01 (VAS code)
   ,@cLine03 = ''
   ,@cLine04 = '%20d03' -- %20i03 (Create Success)
   ,@cLine05 = ''
   ,@cLine06 = 'Press 0 to Done'
   ,@cLine07 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4"]}'
   ,@nFunc = 1157
