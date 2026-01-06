-- 6443 = SKU QTY with image
DELETE rdt.RDTScn WHERE Scn = 6443 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6443, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'ID:'
   ,@cLine03 = '%18d08'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20m10'
   ,@cLine09 = 'UCC:'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%2000iV_Barcode' --FCR-8676
   ,@cLine12 = 'TOTAL CASE: %05d06'
   ,@cLine13 = 'TOTAL SCAN: %05d07'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5","6","7","8"],"4":["9","10"],"5":["11","12"]}'
   ,@nFunc = 957

   /* 2025-03-26 NLT013   FCR-2704 Re-allocation if short happens    */
-- 6523 = Confirm Short 
DELETE rdt.RDTScn WHERE Scn = 6523 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6523, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Short the Pick by%05d02Cases?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '0 = NO'
   ,@cLine06 = '9 = Alternate PICK LOC'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 957