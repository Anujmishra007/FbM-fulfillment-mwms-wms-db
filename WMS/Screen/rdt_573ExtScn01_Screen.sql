-- 6863
DELETE rdt.RDTScn WHERE Scn = 6863 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6863, 'ENG',
        @cLine01 = 'ASN: %10d01',
        @cLine02 = '     %10d02',
        @cLine03 = '     %10d03',
        @cLine04 = '     %10d04',
        @cLine05 = '     %10d05',
        @cLine06 = 'EXTPO:',
        @cLine07 = '%20d06',
        @cLine08 = 'REF NO:',
        @cLine09 = '%20d09',
        @cLine11 = 'LOC: %10d07',
        @cLine12 = 'ID: %20i08',
        @cLine13 = 'COND CODE: %10i09',
        @cLine14 = '%e',
        @nFunc = 573


-- 6864 = Print pallet label screen
DELETE rdt.RDTScn WHERE Scn = 6864 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6864, 'ENG',
        @cLine01 = ''
   ,@cLine02 = 'Print pallet label?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 573
