-- 1480 = lottable02 screen
DELETE rdt.RDTScn WHERE Scn = 1480 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1480, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'

-- 1481 = loc screen
DELETE rdt.RDTScn WHERE Scn = 1481 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1481, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine04 = 'LOT: %10i02'
   ,@cLine05 = 'LOC: %10i03'
   ,@cLine06 = 'ID:'
   ,@cLine07 = '%18i04'
   ,@cLine09 = 'STATUS: %01i05'
   ,@cLine10 = 'QTY: %05i06'
   ,@cLine14 = '%e'
