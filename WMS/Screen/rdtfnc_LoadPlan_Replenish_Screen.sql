-- Scn = 1027. Replen Group
DELETE rdt.RDTScn WHERE Scn = 1027 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1027, 'ENG', 
   @cLine01 = 'REPLEN GROUP:',
   @cLine02 = '%10i01',
   @cLine14 = '%e'

-- Scn = 1028. Replen Group, From Loc
DELETE rdt.RDTScn WHERE Scn = 1028 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1028, 'ENG', 
   @cLine01 = 'REPLEN GROUP:',
   @cLine02 = '%10d01',
   @cLine04 = 'UCC:',
   @cLine05 = '%20i02',
   @cLine07 = 'SCAN: %10d03', 
   @cLine14 = '%e'

