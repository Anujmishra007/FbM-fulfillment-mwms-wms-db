-- 2380 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2380 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2380, 'ENG',
    @cLine01 = 'SCAN TO VAN'
   ,@cLine03 = 'MBOL#: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1643
 
-- 2381 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2381 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2381, 'ENG',
    @cLine01 = 'SCAN TO VAN'
   ,@cLine03 = 'MBOL#: %10d01'
   ,@cLine04 = 'ROUTE:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = 'TOTE NO/BAG NO:'
   ,@cLine07 = '%32i03'    -- (james14)
   ,@cLine08 = 'SCANNED: %05d04'
   ,@cLine10 = 'CLOSE PALLET ?'
   ,@cLine11 = '1 = YES'
   ,@cLine12 = 'Options %02i05 '    -- (james18)
   ,@cLine14 = '%e'
   ,@nFunc = 1643

-- 2382 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2382 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2382, 'ENG',
    @cLine01 = 'SCAN TO VAN'
   ,@cLine03 = 'PLACE BAG IN BIN FOR'
   ,@cLine04 = 'COLLECTION DAY :'
   ,@cLine05 = '%20d01'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1643


-- (ChewKP03)   
-- 2383 = ?? screen 
DELETE rdt.RDTScn WHERE Scn = 2383 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2383, 'ENG',
    @cLine01 = 'SCAN TO VAN'
   ,@cLine03 = 'PALLET ID / CAGE ID: '
   ,@cLine04 = '%20i01 '
   ,@cLine14 = '%e'
   ,@nFunc = 1643 
   
-- (ChewKP03)   
-- 2383 = ?? screen 
DELETE rdt.RDTScn WHERE Scn = 2384 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2384, 'ENG',
    @cLine01 = 'SCAN TO VAN'
   ,@cLine03 = 'STORE: %15i01 '
   ,@cLine14 = '%e'
   ,@nFunc = 1643   

-- SOS#329393
-- 2385 = ?? screen 
DELETE rdt.RDTScn WHERE Scn = 2385 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2385, 'ENG',
    @cLine01 = 'SCAN TO VAN'
   ,@cLine03 = 'MBOLKEY: %10d01 '
   ,@cLine04 = 'CARRIER: '
   ,@cLine05 = '%20i02 '
   ,@cLine14 = '%e'
   ,@nFunc = 1643   

select * from rdt.rdtscn (nolock) where scn between 2380 and 2389