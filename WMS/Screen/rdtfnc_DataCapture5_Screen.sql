-- Scn = 1950. LOC
DELETE rdt.RDTScn WHERE Scn = 1950 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1950, 'ENG', 
   @cLine01 = 'LOC: %10i01',
   @cLine14 = '%e'

-- Scn = 1951. LOC
DELETE rdt.RDTScn WHERE Scn = 1951 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1951, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'CARTON NO:',
   @cLine03 = '%20i02',
   @cLine14 = '%e'

-- Scn = 1952. UCC
DELETE rdt.RDTScn WHERE Scn = 1952 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1952, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'CARTON NO:',
   @cLine03 = '%20d02',
   @cLine04 = 'SKU:',
   @cLine05 = '%20i03',
   @cLine06 = 'SCAN: %05d04', 
   @cLine14 = '%e'

