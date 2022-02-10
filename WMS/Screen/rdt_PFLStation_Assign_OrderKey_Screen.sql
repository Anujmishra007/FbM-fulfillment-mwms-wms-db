-- orderkey
DELETE rdt.RDTScn WHERE Scn = 5513 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5513, 'ENG'
   ,@cLine01 = 'orderkey:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 801