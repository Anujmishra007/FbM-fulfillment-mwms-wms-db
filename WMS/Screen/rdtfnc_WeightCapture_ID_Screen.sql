
--5630=5639
-- 5630 = User ID screen
DELETE rdt.RDTScn WHERE Scn = 5630 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5630, 'ENG'
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1839

-- 5631 = Pick Method 
DELETE rdt.RDTScn WHERE Scn = 5631 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5631, 'ENG'
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'QTY: %05d02'
   ,@cLine05 = ''
   ,@cLine06 = 'WEIGHT (KG)'
   ,@cLine07 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1839
  
  