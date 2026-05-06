--rdt_1855ExtScn02
--FCR-10824
-- 6844 = CART ID screen
DELETE rdt.RDTScn WHERE Scn = 6844 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6844, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = 'PICKZONE: %10i01'
   ,@cLine04 = 'CART ID:  %10i02'
   ,@cLine06 = 'METHOD:   %01i03'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1855
 
-- 6845 = CART MATRIX screen
DELETE rdt.RDTScn WHERE Scn = 6845 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6845, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CART ID: %10d02'
   ,@cLine04 = ''
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = 'TOTE ID:'
   ,@cLine11 = '%20i08'
   ,@cLine12 = 'ASSIGNED: %03d09'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1855
