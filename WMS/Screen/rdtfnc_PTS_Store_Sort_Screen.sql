-- 2390 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2390 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2390, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'CASE ID:'
   ,@cLine04 = '%10i01'    -- SOS316219
   ,@cLine06 = 'OR'
   ,@cLine08 = 'TOTE NO:'
   ,@cLine09 = '%10i02'    -- SOS316219
   ,@cLine11 = '%20d03'
   ,@cLine14 = '%e'
   ,@nFunc = 1711
 
-- 2391 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2391 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2391, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'LOC    : %10d07'
   ,@cLine04 = 'CASE ID:'
   ,@cLine05 = '%08d01'
   ,@cLine06 = 'SKU:'
   ,@cLine07 = '%20d02'
   ,@cLine08 = '%20d03'
   ,@cLine09 = '%20d04'
   ,@cLine10 = '%20i05'
   ,@cLine11 = 'SORT QTY:'
   ,@cLine12 = '%20d06'
   ,@cLine14 = '%e'
   ,@nFunc = 1711

-- 2392 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2392 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2392, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'STORE:'
   ,@cLine04 = '%15d01'
   ,@cLine05 = 'TO LOC:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1711

-- 2393 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2393 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2393, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'STORE:'
   ,@cLine04 = '%15d01'
   ,@cLine05 = 'TO LOC:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'UOM: %05d03'
   ,@cLine08 = 'QTY: %05d04'
   ,@cLine09 = 'QTY: %05i05'
   ,@cLine14 = '%e'
   ,@nFunc = 1711

-- 2394 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2394 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2394, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'STORE:'
   ,@cLine04 = '%15d01'
   ,@cLine05 = 'TO LOC:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'UOM: %05d03'
   ,@cLine08 = 'QTY: %05d04'
   ,@cLine09 = 'TO TOTE:'
   ,@cLine10 = '%18i05'       -- SOS312211
   ,@cLine12 = 'TOTE FULL?'
   ,@cLine13 = '1 = YES 9 = NO %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 1711

-- 2395 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2395 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2395, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'CLOSE TOTE?'
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '9 = NO'
   ,@cLine08 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1711
 
-- 2396 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2396 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2396, 'ENG',
    @cLine01 = 'PRINT LABEL AND'
   ,@cLine02 = 'MANIFEST?'
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine07 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1711

-- 2397 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2397 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2397, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'ENTER ZONE:'
   ,@cLine04 = '%10i01'
   ,@cLine06 = 'Label Printer:'
   ,@cLine07 = '%10i02'
   ,@cLine09 = 'Paper Printer:'
   ,@cLine10 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1711
 
-- 2398 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2398 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2398, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'PLS PUT TOTE TO'
   ,@cLine04 = 'STORE:'
   ,@cLine05 = '%15d01'
   ,@cLine07 = 'TO LOC:'
   ,@cLine08 = '%10d02'
   ,@cLine14 = '%e'
   ,@nFunc = 1711
 
-- 2399 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2399 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2399, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'TOTE OPEN IN LOC'
   ,@cLine04 = '%10d02'
   ,@cLine05 = 'PROCEED OPEN TOTE??'
   ,@cLine07 = '1 = YES'
   ,@cLine08 = '9 = NO'
   ,@cLine09 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1711 

-- 2700 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2700 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2700, 'ENG',
    @cLine01 = 'PTS STORE SORT'
   ,@cLine03 = 'TOTE : %10d01'      -- SOS312211
   ,@cLine04 = 'SAME WITH '
   ,@cLine05 = 'SKU:   %13d02'      -- SOS312211
   ,@cLine07 = 'PROCEED ??'
   ,@cLine08 = '1 = YES'
   ,@cLine09 = '9 = NO'
   ,@cLine10 = 'Option: %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1711 