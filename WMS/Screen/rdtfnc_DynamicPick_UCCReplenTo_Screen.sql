-- Scn = 1620. UCC
DELETE rdt.RDTScn WHERE Scn = 1620 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1620, 'ENG', 
   @cLine01 = 'UCC NO:',
   @cLine02 = '%20i01',
   @cLine14 = '%e'

-- Scn = 1621. TO LOC
DELETE rdt.RDTScn WHERE Scn = 1621 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1621, 'ENG', 
   @cLine01 = 'UCC NO:',
   @cLine02 = '%20d01',
   @cLine04 = 'TO LOC:',
   @cLine05 = '%10d02',
   @cLine07 = 'TO LOC:',
   @cLine08 = '%10i03',
   @cLine14 = '%e'

-- Scn = 1622. Option
DELETE rdt.RDTScn WHERE Scn = 1622 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1622, 'ENG', 
   @cLine01 = 'Replenish to',
   @cLine02 = 'different LOC?',
   @cLine04 = '1=YES',
   @cLine05 = '2=NO',
   @cLine07 = 'OPTION: %01i01',
   @cLine14 = '%e'



