
-- 3810 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 3810 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3810, 'ENG'
   ,@cLine01 = N''
   ,@cLine02 = N'ReceiptKey: %10i01'
   ,@cLine14 = N'%e'
   ,@nFunc = 546
 
