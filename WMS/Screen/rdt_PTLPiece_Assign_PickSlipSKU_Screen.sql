
-- Pickslip, SKU, drop ID
DELETE rdt.RDTScn WHERE Scn = 6161 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6161, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PSNO:'
   ,@cLine03 = '%20i01'
   ,@cLine04 = ''
   ,@cLine05 = 'TOTAL SKU:'
   ,@cLine06 = '%05d02'
   ,@cLine07 = ''
   ,@cLine08 = 'DROP ID:'
   ,@cLine09 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 803
