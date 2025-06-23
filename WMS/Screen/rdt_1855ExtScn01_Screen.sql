--rdt_1855ExtScn01
--6414
--FCR-652
-- 6414 = CART ID screen w/ Pick slip no
DELETE rdt.RDTScn WHERE Scn = 6414 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6414, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = 'PICKZONE: %10i01'
   ,@cLine04 = 'CART ID:  %10i02'
   ,@cLine06 = 'METHOD:   %01i03'
   ,@cLine08 = 'PSNO:   %18i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1855
 

 -- 6416 = New CART MATRIX screen
 --FCR-1755
DELETE rdt.RDTScn WHERE Scn = 6416 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6416, 'ENG'
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
   ,@cLine12 = 'REQUIRED: %03d10'
   ,@cLine13 = 'ASSIGNED: %03d09'
   ,@cLine14 = '%e'
   ,@nFunc = 1855
