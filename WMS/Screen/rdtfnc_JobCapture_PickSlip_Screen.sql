--5620=5629
-- 5620 = User ID screen
DELETE rdt.RDTScn WHERE Scn = 5620 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5620, 'ENG'
   ,@cLine01 = 'USER ID:'
   ,@cLine02 = '%15i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1838

-- 5621 = Pick Method 
DELETE rdt.RDTScn WHERE Scn = 5621 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5621, 'ENG'
   ,@cLine01 = 'USER ID:'
   ,@cLine02 = '%15d01'
   ,@cLine03 = ''
   ,@cLine04 = 'PICK METHOD:'
   ,@cLine05 = ''
   ,@cLine06 = '1 = FULL PICK SLIP'
   ,@cLine07 = '2 = SPLIT PICK SLIP'
   ,@cLine08 = ''
   ,@cLine09 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1838

-- 5622 = Full Pick
DELETE rdt.RDTScn WHERE Scn = 5622 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5622, 'ENG'
   ,@cLine01 = 'USER ID:'
   ,@cLine02 = '%15d01'
   ,@cLine03 = ''
   ,@cLine04 = 'FULL PICK SLIP'
   ,@cLine05 = ''
   ,@cLine06 = 'PICK SLIP NO:'
   ,@cLine07 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1838
   
-- 5623 = Split Pick
DELETE rdt.RDTScn WHERE Scn = 5623 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5623, 'ENG'
   ,@cLine01 = 'USER ID:'
   ,@cLine02 = '%15d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SPLIT PICK SLIP'
   ,@cLine05 = ''
   ,@cLine06 = 'PICK SLIP NO:'
   ,@cLine07 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1838

-- 5624 = Split Pick Qty
DELETE rdt.RDTScn WHERE Scn = 5624 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5624, 'ENG'
   ,@cLine01 = 'SPLIT PICK SLIP'
   ,@cLine02 = ''
   ,@cLine03 = 'PICK SLIP NO:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'QTY: %05i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1838