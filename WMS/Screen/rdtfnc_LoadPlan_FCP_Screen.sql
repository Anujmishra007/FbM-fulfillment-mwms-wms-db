-- Scn = 1760. LoadKey
DELETE rdt.RDTScn WHERE Scn = 1760 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1760, 'ENG', 
   @cLine01 = 'LOADKEY:',
   @cLine02 = '%10i01',
   @cLine14 = '%e'

-- Scn = 1761. LoadKey, From Loc
DELETE rdt.RDTScn WHERE Scn = 1761 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1761, 'ENG', 
   @cLine01 = 'LOADKEY:',
   @cLine02 = '%10d01',
   @cLine04 = 'FROM LOC: %10i02',
   @cLine14 = '%e'

-- Scn = 1762. From Loc, UCC, Consignee, Company, OrderKey, CartonNo
DELETE rdt.RDTScn WHERE Scn = 1762 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1762, 'ENG', 
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'UCC:',
   @cLine03 = '%20i02',
   @cLine05 = 'TO LOC: %10d03',
   @cLine06 = 'PKSLIPNO: %10d04',
   @cLine07 = 'ORDERKEY: %10d05',
   @cLine08 = 'CARTONNO: %05d06',
   @cLine10 = 'CONSIGNEE/COMPANY:',
   @cLine11 = '%15d07',
   @cLine12 = '%20d08',
   @cLine14 = '%e'


