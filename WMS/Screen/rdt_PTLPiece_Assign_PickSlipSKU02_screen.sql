
-- Pickslip
DELETE rdt.RDTScn WHERE Scn = 6163 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6163, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PSNO:'
   ,@cLine03 = '%20i01'
   ,@cLine04 = ''
   ,@cLine05 = 'TOTAL SKU:'
   ,@cLine06 = '%05d02'
   ,@cLine14 = '%e'
   ,@nFunc = 803
