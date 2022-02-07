
-- Screen 1
DELETE rdt.RDTScn WHERE Scn = 5550 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5550, 'ENG', 
   @cLine01 = 'PTS-DropID',
   @cLine03 = 'PTS Zone: %10i01',
   @cLine14 = '%e',
   @nFunc   = 1835

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 5551 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5551, 'ENG', 
   @cLine01 = 'PTS-DropID',
   @cLine03 = 'PTS Zone: %10d01',
   @cLine05 = 'User ID:',
   @cLine06 = '%18i02',
   @cLine14 = '%e',
   @nFunc   = 1835

DELETE rdt.RDTScn WHERE Scn = 5552 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5552, 'ENG', 
   @cLine01 = 'PTS-DropID',
   @cLine03 = 'PTS Zone: %10d01',
   @cLine05 = 'User ID:',
   @cLine06 = '%18d02',
   @cLine07 = 'DropID:',
   @cLine08 = '%20i03',
   @cLine09 = '%20d04',
   @cLine10 = 'DropID Scanned:',
   @cLine11 = '%05d05',
   @cLine12 = '%e',
   @nFunc   = 1835

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 5553 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5553, 'ENG', 
   @cLine01 = 'PTS-DropID',
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
   @nFunc   = 1835

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 5554 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5554, 'ENG', 
   @cLine01 = 'PTS-DropID',
   @cLine03 = 'PTS Zone: %10d01',
   @cLine04 = 'User ID:',
   @cLine05 = '%18d02',
   @cLine07 = 'PLEASE PROCEED TO',
   @cLine08 = 'LOC: %10d03',
   @cLine09 = 'ToteID: %10d04',
   @cLine10 = 'ToteID: %10i05',
   @cLine14 = '%e',
   @nFunc   = 1835

-- Screen 6
DELETE rdt.RDTScn WHERE Scn = 5555 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5555, 'ENG', 
   @cLine01 = 'PTS Zone: %10d01',
   @cLine02 = 'User ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'PLEASE PROCEED TO',
   @cLine05 = 'LOC: %10d03',
   @cLine06 = 'ToteID: %10d04',
   @cLine08 = 'SKU:', 
   @cLine09 = '%20d05',
   @cLine10 = '%20d06',
   @cLine11 = '%20d07',
   @cLine12 = '%20d08',
   @cLine13 = 'Qty: %10d09',
   @cLine14 = '%e',
   @nFunc   = 1835

-- Screen 7
DELETE rdt.RDTScn WHERE Scn = 5556 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5556, 'ENG', 
   @cLine02 = 'LOC: %10d01',
   @cLine03 = 'ToteID: %10d02',
   @cLine05 = '%20d03',
   @cLine14 = '%e',
   @nFunc   = 1835
      
