-- 4200 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 4200 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4200, 'ENG',
    @cLine01 = 'PALLET ID:'
   ,@cLine02 = '%18i01'
   ,@cLine03 = ''
   ,@cLine05 = '%20d06'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 1650

-- 4201 = TO DOOR screen
DELETE rdt.RDTScn WHERE Scn = 4201 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4201, 'ENG',
    @cLine01 = 'PALLET ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'TO DOOR:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20i03'
   ,@cLine06 = '%20d06'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4","5"]}'
   ,@nFunc = 1650
   
-- 4202 = Close truck screen
DELETE rdt.RDTScn WHERE Scn = 4202 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4202, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ALL PALLET COMPLETED'
   ,@cLine03 = 'AND CLOSE TRUCK?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES AND EXIT'
   ,@cLine06 = '2 = NO, EXIT ANYWAY'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e' 
   ,@nFunc = 1650
   
