
-- 3210 = LOC
DELETE rdt.RDTScn WHERE Scn = 3210 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3210, 'ENG'
   ,@cLine01 = 'FROM LOC: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 523

-- 3211 = SKU
DELETE rdt.RDTScn WHERE Scn = 3211 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3211, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'SKU/UPC:'
   ,@cLine03 = '%60i02'
   ,@cLine14 = '%e'
   ,@nFunc = 523

-- 3212 = To LOC
DELETE rdt.RDTScn WHERE Scn = 3212 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3212, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = 'TO LOC: %10i05'
   ,@cLine14 = '%e'
   ,@nFunc = 523

-- 3213 = Message screen
DELETE rdt.RDTScn WHERE Scn = 3213 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3213, 'ENG'
   ,@cLine02 = 'LOC SKU moved'
   ,@cLine03 = 'successfully'
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@nFunc = 523
