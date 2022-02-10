
-- Station, position, carton
DELETE rdt.RDTScn WHERE Scn = 4493 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4493, 'ENG'
   ,@cLine01 = 'CRITERIA 1:'
   ,@cLine02 = '%30d01'
   ,@cLine03 = 'CRITERIA 2:    %05d06'
   ,@cLine04 = '%30d02'
   ,@cLine05 = ''
   ,@cLine06 = 'PTL STATION:'
   ,@cLine07 = '%10d03'
   ,@cLine08 = 'POSITION:      '
   ,@cLine09 = '%10d04'
   ,@cLine10 = 'CARTON ID:     %05d07'
   ,@cLine11 = '%20i05'
   ,@cLine14 = '%e'
   ,@nFunc = 805
