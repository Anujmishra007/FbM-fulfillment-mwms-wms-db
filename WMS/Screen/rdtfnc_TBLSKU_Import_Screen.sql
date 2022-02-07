-- 1650 = Screen for scan Retail SKU Barcode
DELETE rdt.RDTScn WHERE Scn = 1650 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1650, 'ENG', 
   @cLine01 = 'Retail SKU Barcode:',   
   @cLine02 = '%20i01',   
   @cLine14 = '%e'

-- 1651 = Message
DELETE rdt.RDTScn WHERE Scn = 1651 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1651, 'ENG', 
   @cLine01 = 'SKU imported',   
   @cLine02 = 'successfully',   
   @cLine04 = 'Press ENTER or ESC',   
   @cLine05 = 'to continue',   
   @cLine14 = '%e'