
-- Batch, cart
DELETE rdt.RDTScn WHERE Scn = 6165 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6165, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'BATCH: '
   ,@cLine03 = '%20i01'
   ,@cLine04 = ''
   ,@cLine05 = 'CART: '
   ,@cLine06 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 803
