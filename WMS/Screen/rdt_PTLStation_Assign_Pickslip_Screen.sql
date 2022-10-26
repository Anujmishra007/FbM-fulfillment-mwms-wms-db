
-- PickSlipNo
DELETE rdt.RDTScn WHERE Scn = 4494 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4494, 'ENG'
   ,@cLine01 = 'PSNO:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine04 = 'ORDERS:'
   ,@cLine05 = '%05d02'
   ,@cLine14 = '%e'
   ,@nFunc = 805
