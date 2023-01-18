
-- Pickslip, load
DELETE rdt.RDTScn WHERE Scn = 6160 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6160, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PSNO:'
   ,@cLine03 = '%20i01'
   ,@cLine04 = ''
   ,@cLine05 = 'TOTAL LOAD:'
   ,@cLine06 = '%05d02'
   ,@cLine07 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 803
