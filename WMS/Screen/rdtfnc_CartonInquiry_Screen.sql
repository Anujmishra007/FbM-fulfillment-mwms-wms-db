-- 3800 = Scan Carton ID screen
DELETE rdt.RDTScn WHERE Scn = 3800 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3800, 'ENG',
    @cLine01 = 'CARTON INQUIRY'
   ,@cLine03 = 'CARTON ID:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1807

-- 3801 = Show Details screen
DELETE rdt.RDTScn WHERE Scn = 3801 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3801, 'ENG',
    @cLine01 = 'CARTON INQUIRY'
   ,@cLine03 = 'WAVEKEY: %10d01'
   ,@cLine04 = 'LOADKEY: %10d02'
   ,@cLine05 = 'STORE:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = 'CARTON STATUS:'
   ,@cLine08 = '%20d04'
   ,@cLine09 = 'LAST LOC: %10d05'
   ,@cLine10 = 'ORDER GROUP:'
   ,@cLine11 = '%20d06'
   ,@cLine12 = 'SECTION KEY:'
   ,@cLine13 = '%10d07'
   ,@cLine14 = '%e'
   ,@nFunc = 1807

-- 3802 = SKU Info screen
DELETE rdt.RDTScn WHERE Scn = 3802 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3802, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'STATUS:'
   ,@cLine06 = '%20d05'
   ,@cLine07 = 'QTY: %20d04'
   ,@cLine08 = 'ORDER GROUP:'
   ,@cLine09 = '%20d06'
   ,@cLine14 = '%e'
   ,@nFunc = 1807

-- (ChewKP05) 
-- 3801 = Show Details screen
DELETE rdt.RDTScn WHERE Scn = 3803 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3803, 'ENG',
    @cLine01 = 'CARTON INQUIRY'
   ,@cLine02 = 'WAVEKEY: %10d01'
   ,@cLine03 = 'LOADKEY: %10d02'
   ,@cLine04 = 'STORE:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'CARTON STATUS:'
   ,@cLine07 = '%20d04'
   ,@cLine08 = 'SHIP TO COUNTRY:'
   ,@cLine09 = '%20d05'
   ,@cLine10 = 'SHIP TO COMPANY:'
   ,@cLine11 = '%20d06'
   ,@cLine12 = 'CONSIGNEEKEY:'
   ,@cLine13 = '%15d07'
   ,@cLine14 = '%e'
   ,@nFunc = 1807   