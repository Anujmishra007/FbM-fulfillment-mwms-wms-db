
-- Screen 1
DELETE rdt.RDTScn WHERE Scn = 5520 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5520, 'ENG', 
   @cLine01 = 'PTS-DropID',
   @cLine03 = 'PTS Zone: %10i01',
   @cLine14 = '%e',
   @nFunc   = 1834

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 5521 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5521, 'ENG', 
   @cLine01 = 'PTS-DropID',
   @cLine03 = 'PTS Zone: %10d01',
   @cLine05 = 'User ID:',
   @cLine06 = '%18i02',
   @cLine07 = 'Device id:',
   @cLine08 = '%60i03',
   @cLine14 = '%e',
   @nFunc   = 1834

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 5522 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5522, 'ENG', 
   @cLine01 = 'PTS-DropID',
   @cLine03 = 'PTS Zone: %10d01',
   @cLine05 = 'User ID:',
   @cLine06 = '%18d02',
   @cLine07 = 'Device id:',
   @cLine08 = '%60d03',
   @cLine09 = 'DropID:',
   @cLine10 = '%20i04',
   @cLine11 = '%20d05',
   @cLine12 = 'DropID Scanned:',
   @cLine13 = '%05d06',
   @cLine14 = '%e',
   @nFunc   = 1834
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 5523 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5523, 'ENG', 
   @cLine01 = 'PTS - CARTON',
   @cLine03 = 'PTS Zone: %10d01',
   @cLine04 = 'User ID:',
   @cLine05 = '%18d02',
   @cLine07 = 'TOTAL DropID: %05d03',
   @cLine09 = 'CONFIRM WORKLOAD?',
   @cLine10 = '1 = YES ',
   @cLine11 = '9 = NO ',
   @cLine12 = '5 = RESET ',
   @cLine13 = 'OPTIONS: %01i04',
   @cLine14 = '%e',
   @nFunc   = 1834

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 5524 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5524, 'ENG', 
   @cLine01 = 'PTS - CARTON',
   @cLine03 = 'PTS Zone: %10d01',
   @cLine04 = 'User ID:',
   @cLine05 = '%18d02',
   @cLine06 = 'User Color: %09d03',
   @cLine09 = 'PLEASE PROCEED TO',
   @cLine11 = 'LOC: %10d04',
   @cLine14 = '%e',
   @nFunc   = 1834
      
