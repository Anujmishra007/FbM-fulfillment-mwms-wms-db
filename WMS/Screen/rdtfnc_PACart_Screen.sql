
-- CartID, Col, Row
DELETE rdt.RDTScn WHERE Scn = 4290 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4290, 'ENG'
   ,@cLine01 = 'CART ID: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'COL: %02i02'
   ,@cLine04 = ''
   ,@cLine05 = 'ROW: %02i03'
   ,@cLine06 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 807

-- Assign
DELETE rdt.RDTScn WHERE Scn = 4291 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4291, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = ''
   ,@cLine07 = 'ID:'
   ,@cLine08 = '%18i06'
   ,@cLine09 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 807

-- LOC
DELETE rdt.RDTScn WHERE Scn = 4292 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4292, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'LOC: %10i02' 
   ,@cLine03 = '' 
   ,@cLine14 = '%e'
   ,@nFunc = 807

-- SKU Matrix
DELETE rdt.RDTScn WHERE Scn = 4293 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4293, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20i11' -- SKU input (WMS5639)
   ,@cLine03 = '%20d01' -- SKU
   ,@cLine04 = '%20d02' -- Desc1
   ,@cLine05 = '%20d03' -- Desc2
   ,@cLine06 = '%20d04' -- Result01
   ,@cLine07 = '%20d05' 
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = 'EXP QTY: %05d09' 
   ,@cLine12 = 'ACT QTY: %05i10' 
   ,@cLine13 = '%20d12'       -- Add ExtendedInfo (WMS5639)
   ,@cLine14 = '%e'
   ,@nFunc = 807
