
-- PFLStation, method
DELETE rdt.RDTScn WHERE Scn = 5500 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5500, 'ENG'
   ,@cLine01 = 'PFL STATIONS:'
   ,@cLine02 = '1. %10i01'
   ,@cLine03 = '2. %10i02'
   ,@cLine04 = '3. %10i03'
   ,@cLine05 = '4. %10i04'
   ,@cLine06 = '5. %10i05'
   ,@cLine07 = ''
   ,@cLine08 = 'METHOD: %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 801

-- Dynamic assign screens (5510 to 5519)

-- Matrix
DELETE rdt.RDTScn WHERE Scn = 5502 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5502, 'ENG'
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
   ,@cLine13 = '1-CLOSE' 
   ,@cLine14 = '%e'
   ,@nFunc = 801
   
-- New drop ID
DELETE rdt.RDTScn WHERE Scn = 5503 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5503, 'ENG'
   ,@cLine01 = 'NEW DROP ID:'
   ,@cLine02 = '%20i01' 
   ,@cLine14 = '%e'
   ,@nFunc = 801
   