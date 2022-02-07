-- 5450 = Label, value screen
DELETE rdt.RDTScn WHERE Scn = 5450 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5450, 'ENG'
   ,@cLine01 = 'EVENT CAPTURE'
   ,@cLine02 = ''
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine13 = 'Option: %01i10'
   ,@cLine14 = '%e'
   ,@nFunc = 706

-- 5450 = Label, value screen
DELETE rdt.RDTScn WHERE Scn = 5451 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5451, 'ENG'
   ,@cLine01 = 'EVENT CAPTURE'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%60i02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%60i04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%60i06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%60i08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%60i10'
   ,@cLine12 = 'Total Cap: %05d11'  -- WMS-17359 Extend length
   ,@cLine13 = '%20d12' --(WMS-16782)
   ,@cLine14 = '%e'
   ,@nFunc = 706

-- 5451 Close Pallet
DELETE rdt.RDTScn WHERE Scn = 5452 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5452, 'ENG'
   ,@cLine01 = 'Close Pallet? '
   ,@cLine03 = '1. Yes'
   ,@cLine04 = '2. No'
   ,@cLine06 = 'Option: %01i13'
   ,@cLine14 = '%e'
   ,@nFunc = 706

-- 5452 Print List
DELETE rdt.RDTScn WHERE Scn = 5453 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5453, 'ENG'
   ,@cLine01 = 'PRINT LIST? '
   ,@cLine03 = '1. Yes'
   ,@cLine04 = '2. No'
   ,@cLine06 = 'Option: %01i13'
   ,@cLine14 = '%e'
   ,@nFunc = 706

-- 5453 Quit
DELETE rdt.RDTScn WHERE Scn = 5454 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5454, 'ENG'
   ,@cLine01 = 'Quit? '
   ,@cLine03 = '1. Yes'
   ,@cLine04 = '2. No'
   ,@cLine06 = 'Option: %01i13'
   ,@nFunc = 706