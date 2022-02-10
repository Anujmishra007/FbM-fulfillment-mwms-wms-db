-- 4260 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 4260 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4260, 'ENG' 
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'OR'
   ,@cLine03 = 'REF NO:'
   ,@cLine04 = '%20i02'
   ,@cLine05 = ''
   ,@cLine06 = 'CARRIER:'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%20d05'
   ,@cLine10 = ''
   ,@cLine11 = 'CASE: %05i06'
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 600

-- 4261 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 4261 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4261, 'ENG'
   ,@cLine01 = 'PALLET:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 600

