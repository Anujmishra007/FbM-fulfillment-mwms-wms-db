-- 2190 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2190 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2190, 'ENG',
    @cLine01 = 'CONTAINERKEY:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = 'CONTAINER NO:'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1637

-- 2191 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2191 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2191, 'ENG',
    @cLine01 = 'CONTAINERKEY:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'MBOL #:'
   ,@cLine04 = '%10d02'
   ,@cLine05 = 'CONTAINER #:'
   ,@cLine06 = '%20d03'
   ,@cLine08 = 'SSCC:'
   ,@cLine09 = '%20i04'
   ,@cLine11 = '%05d05    %11d06'
   ,@cLine12 = '%20d07'       -- SOS246728
   ,@cLine14 = '%e'
   ,@nFunc = 1637

-- 2192 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2192 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2192, 'ENG',
    @cLine01 = 'CONTAINERKEY:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'MBOL #:'
   ,@cLine04 = '%10d02'
   ,@cLine05 = 'CONTAINER #:'
   ,@cLine06 = '%20d03'
   ,@cLine08 = 'Pallet ID:'
   ,@cLine09 = '%30i04'
   ,@cLine11 = 'Scanned: %05d05'
   ,@cLine13 = '%20d06'
   ,@cLine14 = '%e'
   ,@nFunc = 1637

-- 2193 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2193 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2193, 'ENG',
    @cLine01 = 'TRACKING NO:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1637

-- 2194 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2194 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2194, 'ENG',
    @cLine01 = 'PRINT BIG BOX LABEL?'
   ,@cLine03 = 'OPTION: %01i01'
   ,@cLine04 = '1 = YES    2 = NO'
   ,@cLine14 = '%e'
   ,@nFunc = 1637

-- 2195 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2195 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2195, 'ENG',
    @cLine01 = 'ALL PALLET SCANNED'
   ,@cLine02 = 'AND CLOSE CONTAINER?'
   ,@cLine04 = '1 = YES AND EXIT'
   ,@cLine05 = '2 = NO, EXIT ANYWAY'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1637
   
-- 2196 = Print Container manifest screen
DELETE rdt.RDTScn WHERE Scn = 2196 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2196, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'PRINT MANIFEST?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1637

-- 2197 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2197 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2197, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20i10'
   ,@cLine14 = '%e'
   ,@nFunc = 1637
  
--WMS-16476 Add capture info screen
-- 2198 = Capture info screen
DELETE rdt.RDTScn WHERE Scn = 2198 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2198, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20i10'
   ,@cLine14 = '%e'
   ,@nFunc = 1637
   