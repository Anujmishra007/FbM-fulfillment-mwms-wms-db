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
 
