-- 6360 = ID
DELETE rdt.RDTScn WHERE Scn = 6360 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6360, 'ENG'
   ,@cLine01 = 'Pallet ID'
   ,@cLine02 = '%20i01' -- %20i01 (ID)
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 1157

-- 6361 = List of VAS Activities
DELETE rdt.RDTScn WHERE Scn = 6361 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6361, 'ENG'
   ,@cLine01 = 'List of VAS Activities'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = 'OPTION: %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 1157


-- 6362 = Scan VAS Code
DELETE rdt.RDTScn WHERE Scn = 6362 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6362, 'ENG'
   ,@cLine01 = 'Enter/Scan VAS Code'
   ,@cLine02 = '%20i01' -- %20i01 (VAS code)
   ,@cLine03 = ''
   ,@cLine04 = '%20d03' -- %20i03 (Create Success)
   ,@cLine05 = ''
   ,@cLine06 = 'Press 0 to Done'
   ,@cLine07 = 'OPTION: %01i02^DT:INT'
   ,@cLine08 = '%20d04' -- Vas Completed
   ,@cLine09 = '%20d05'
   ,@cLine10 = '%20d06'
   ,@cLine11 = '%20d07'
   ,@cLine12 = '%20d08'
   ,@cLine13 = '%20d09'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4"]}'
   ,@nFunc = 1157
