-- Scn = 1571. LOADKEY
DELETE rdt.RDTScn WHERE Scn = 1571 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1571, 'ENG', 
   @cLine01 = 'LOADKEY: %10i01',
   @cLine14 = '%e'

-- Scn = 1572. SKU/UPC, SKUDesc, ORDERKEY, CONSIGNEE, COMPANY, QTY ALLOC, QTY SCAN
DELETE rdt.RDTScn WHERE Scn = 1572 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1572, 'ENG', 
   @cLine01 = 'SKU/UPC:',
   @cLine02 = '%20i01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = 'QTY IN LOAD',
   @cLine06 = 'QTY ALLOC+PK: %05d04',
   @cLine07 = 'QTY SCAN    : %05d05',
   @cLine09 = 'DISTRIBUTE TO',
   @cLine10 = 'ORDERKEY: %10d06',
   @cLine11 = 'CONSIGNEE/COMPANY:',
   @cLine12 = '%15d07', 
   @cLine13 = '%20d08',
   @cLine14 = '%e'
