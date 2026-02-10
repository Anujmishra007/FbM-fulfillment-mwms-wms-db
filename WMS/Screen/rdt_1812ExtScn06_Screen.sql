-- rdt_1812ExtScn06
DELETE rdt.RDTScn WHERE Scn = 6672 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6672, 'ENG',
    @cLine01 = 'SKU:  BU:%07d01'
   ,@cLine02 = '%20d09'
   ,@cLine03 = '%20d11'
   ,@cLine04 = '%20d12'
   ,@cLine05 = 'Suggested Locs/IDs'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%20d06'
   ,@cLine10 = '%20d07'
   ,@cLine11 = '%20d08'
   ,@cLine12 = 'Scan ID:'
   ,@cLine13 = '%20i05'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],,"3":["3"]}'
   ,@nFunc = 1812