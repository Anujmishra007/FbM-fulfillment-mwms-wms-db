
-- PTLStation, method
DELETE rdt.RDTScn WHERE Scn = 4480 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4480, 'ENG'
   ,@cLine01 = 'PTL STATIONS:'
   ,@cLine02 = '1. %10i01'
   ,@cLine03 = '2. %10i02'
   ,@cLine04 = '3. %10i03'
   ,@cLine05 = '4. %10i04'
   ,@cLine06 = '5. %10i05'
   ,@cLine07 = ''
   ,@cLine08 = 'METHOD:   %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 805

-- Dynamic assign screens (4490 to 4499)

-- UCC/ID, SKU, QTY
DELETE rdt.RDTScn WHERE Scn = 4482 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4482, 'ENG'
   ,@cLine01 = 'UCC/ID: '
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%40i03' -- SKU barcode expanded to 40 char
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = ''
   ,@cLine10 = 'QTY: %05i06'
   ,@cLine11 = ''
   ,@cLine12 = '%20d07'
   ,@cLine14 = '%e'
   ,@nFunc = 805

-- Matrix
DELETE rdt.RDTScn WHERE Scn = 4483 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4483, 'ENG'
   ,@cLine01 = '%20d01' -- Result01
   ,@cLine02 = '%20d02' 
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20d10' -- Result10
   ,@cLine11 = '%20d12' -- ExtendedInfo 
   ,@cLine12 = 'OPTION: %01i11' 
   ,@cLine13 = '1-CLOSE 9-SHORT' 
   ,@cLine14 = '%e'
   ,@nFunc = 805

-- Confirm
DELETE rdt.RDTScn WHERE Scn = 4484 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4484, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM ALL TASKS?' 
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01' 
   ,@cLine14 = '%e'
   ,@nFunc = 805

-- Old carton
DELETE rdt.RDTScn WHERE Scn = 4485 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4485, 'ENG'
   ,@cLine01 = 'CARTON ID:'
   ,@cLine02 = '%20i01' 
   ,@cLine03 = ''
   ,@cLine04 = 'OR'
   ,@cLine05 = ''
   ,@cLine06 = 'LOC: %10i02'
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = 'QTY: %05i03'
   ,@cLine14 = '%e'
   ,@nFunc = 805
   
-- New carton
DELETE rdt.RDTScn WHERE Scn = 4486 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4486, 'ENG'
   ,@cLine01 = 'NEW CARTON ID:'
   ,@cLine02 = '%20i01' 
   ,@cLine14 = '%e'
   ,@nFunc = 805
   
-- Unassign station
DELETE rdt.RDTScn WHERE Scn = 4487 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4487, 'ENG'
   ,@cLine01 = 'UNASSIGN STATION?'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES' 
   ,@cLine04 = '9 = NO' 
   ,@cLine05 = '' 
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 805
   