-- 4470 = UCC
DELETE rdt.RDTScn WHERE Scn = 4470 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4470, 'ENG'
   ,@cLine01 = 'UCC:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 539
   
-- 4471 = SKU
DELETE rdt.RDTScn WHERE Scn = 4471 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4471, 'ENG'
   ,@cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'LOC: %10d02'
   ,@cLine04 = 'ID:'
   ,@cLine05 = '%18d03'
   ,@cLine06 = 'STATUS: %10d04'
   ,@cLine07 = ''
   ,@cLine08 = 'SKU/UPC:'
   ,@cLine09 = '%20i05'   
   ,@cLine10 = '%20d06'   
   ,@cLine11 = '%20d07'   
   ,@cLine12 = '%20d08'   
   ,@cLine13 = 'QTY: %05d09'
   ,@cLine14 = '%e'
   ,@nFunc = 539