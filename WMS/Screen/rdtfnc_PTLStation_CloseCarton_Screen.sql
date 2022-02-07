
-- PTLStation, method
DELETE rdt.RDTScn WHERE Scn = 4510 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4510, 'ENG'
   ,@cLine01 = 'PTL STATIONS:'
   ,@cLine02 = '1. %10i01'
   ,@cLine03 = '2. %10i02'
   ,@cLine04 = '3. %10i03'
   ,@cLine05 = '4. %10i04'
   ,@cLine06 = '5. %10i05'
   ,@cLine07 = ''
   ,@cLine08 = 'METHOD:   %01i06'
   ,@cLine14 = '%e'
   ,@nFunc = 804

-- Carton, LOC
DELETE rdt.RDTScn WHERE Scn = 4511 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4511, 'ENG'
   ,@cLine01 = 'CARTON ID:'
   ,@cLine02 = '%20i01' 
   ,@cLine03 = ''
   ,@cLine04 = 'OR'
   ,@cLine05 = ''
   ,@cLine06 = 'LOC: %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 804
   
-- Unassign station
DELETE rdt.RDTScn WHERE Scn = 4512 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4512, 'ENG'
   ,@cLine01 = 'FOUND OUTSTANDING'
   ,@cLine02 = 'CONFIRM CLOSE?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES' 
   ,@cLine05 = '9 = NO' 
   ,@cLine06 = '' 
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 804
   