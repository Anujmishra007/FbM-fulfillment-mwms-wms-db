--5820- 5829

-- 5820 = Tote # screen
DELETE rdt.RDTScn WHERE Scn = 5820 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5820, 'ENG',
    @cLine01 = 'TOTE #:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1846
 
-- 5821 = Result
DELETE rdt.RDTScn WHERE Scn = 5821 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5821, 'ENG',
    @cLine01 = 'TOTE #: %18d01'
   ,@cLine02 = 'Wavekey: %20d02'
   ,@cLine03 = 'ORDER COUNT: %5d03'
   ,@cLine04 = 'PICKED QTY: %5d04'
   ,@cLine05 = 'BALANCE QTY: %05d05'
   ,@cLine14 = '%e'
   ,@nFunc = 1846
 
