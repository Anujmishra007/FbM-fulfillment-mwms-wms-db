
-- CaseID
DELETE rdt.RDTScn WHERE Scn = 5044 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5044, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02' 
   ,@cLine03 = ''
   ,@cLine04 = 'CASEID:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 808
