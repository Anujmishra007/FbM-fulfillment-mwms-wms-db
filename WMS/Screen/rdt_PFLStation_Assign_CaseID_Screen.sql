
-- CaseID
DELETE rdt.RDTScn WHERE Scn = 5511 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5511, 'ENG'
   ,@cLine01 = 'CaseID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 801
