-- 3380 = Lane screen
DELETE rdt.RDTScn WHERE Scn = 3380 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3380, 'ENG',
    @cLine01 = 'LANE: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 545
 
-- 3381 = LabelNo screen
DELETE rdt.RDTScn WHERE Scn = 3381 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3381, 'ENG',
    @cLine01 = 'LANE: %10d01'
   ,@cLine02 = 'LABELNO:'
   ,@cLine03 = '%20i02'
   ,@cLine04 = ''
   ,@cLine05 = 'OR'
   ,@cLine06 = ''
   ,@cLine07 = 'ID:'
   ,@cLine08 = '%18i03'
   ,@cLine09 = ''
   ,@cLine10 = 'OR'
   ,@cLine11 = ''
   ,@cLine12 = 'REFNO:' -- WMS6789
   ,@cLine13 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 545

-- 3382 = LOC, ID screen
DELETE rdt.RDTScn WHERE Scn = 3382 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3382, 'ENG',
    @cLine01 = 'LANE: %10d01'
   ,@cLine02 = 'LABELNO:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = ''
   ,@cLine05 = 'LOC: %10d03'
   ,@cLine06 = 'ID:'
   ,@cLine07 = '%18d04'
   ,@cLine08 = '%18i05'
   ,@cLine14 = '%e'
   ,@nFunc = 545

 -- 3383 = Discrepency screen
DELETE rdt.RDTScn WHERE Scn = 3383 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3383, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'CLOSE PALLET?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 545
