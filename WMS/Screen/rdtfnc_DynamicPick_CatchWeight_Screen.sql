-- 1580 = Screen for scan Label No/Ucc No
DELETE rdt.RDTScn WHERE Scn = 1580 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1580, 'ENG', 
   @cLine01 = 'LABEL NO:',   
   @cLine02 = '%20i01',   
   @cLine04 = 'OR',   
   @cLine06 = 'UCC NO:',   
   @cLine07 = '%20i02',   
   @cLine14 = '%e'

-- 1581 = Screen for scan Weight &Cube
DELETE rdt.RDTScn WHERE Scn = 1581 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1581, 'ENG', 
   @cLine01 = 'PKSLIPNO: %10d01',   
   @cLine02 = 'CARTONNO: %04d02',   
   @cLine03 = 'QTY: %04d03',   
   @cLine05 = 'WEIGHT:',   
   @cLine06 = '%20i04',   
   @cLine07 = 'CUBE:',   
   @cLine08 = '%20i05',   
   @cLine11 = 'SCAN/TOTAL:',   
   @cLine12 = '%04d06 / %04d07',   
   @cLine14 = '%e'

-- 1582 = Message
DELETE rdt.RDTScn WHERE Scn = 1582 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1582, 'ENG', 
   @cLine01 = 'Catch weight',   
   @cLine02 = 'successfully',   
   @cLine04 = 'Press ENTER or ESC',   
   @cLine05 = 'to continue',   
   @cLine14 = '%e'