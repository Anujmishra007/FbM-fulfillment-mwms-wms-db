-- Scn = 1610. Replen Group
DELETE rdt.RDTScn WHERE Scn = 1610 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1610, 'ENG', 
   @cLine01 = 'REPLEN GROUP:',
   @cLine02 = '%20i01',
   @cLine14 = '%e'

-- Scn = 1611. Replen Group, LoadKey
DELETE rdt.RDTScn WHERE Scn = 1611 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1611, 'ENG', 
   @cLine01 = 'REPLEN GROUP:',
   @cLine02 = '%20d01',
   @cLine04 = 'LOADKEY:',
   @cLine05 = '%10i02',
   @cLine14 = '%e'

-- Scn = 1612. Replen Group, LoadKey, From Loc
DELETE rdt.RDTScn WHERE Scn = 1612 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1612, 'ENG', 
   @cLine01 = 'REPLEN GROUP:',
   @cLine02 = '%20d01',
   @cLine04 = 'LOADKEY:',
   @cLine05 = '%10d02',
   @cLine07 = 'FROM LOC:',
   @cLine08 = '%10i03',
   @cLine14 = '%e'

-- Scn = 1613. From Loc, UCC, Consignee, Company, OrderKey, CartonNo
DELETE rdt.RDTScn WHERE Scn = 1613 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1613, 'ENG', 
   @cLine01 = 'FROM LOC: %20d01',
   @cLine02 = 'UCC:',
   @cLine03 = '%20i02',
   @cLine05 = 'TO LOC: %10d03',
   @cLine06 = 'PKSLIPNO: %10d04',
   @cLine07 = 'ORDERKEY: %10d05',
   @cLine08 = 'CARTONNO: %05d06',
   @cLine10 = 'CONSIGNEE/COMPANY:',
   @cLine11 = '%15d07',
   @cLine12 = '%20d08',
   @cLine13 = '%20d15', -- WMS-15412 Extendedinfosp
   @cLine14 = '%e'


