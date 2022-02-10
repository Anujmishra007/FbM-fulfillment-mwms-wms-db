-- 4200 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 4200 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4200, 'ENG',
    @cLine01 = 'SCAN TO DOOR'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1650
 
-- 4201 = TO DOOR screen
DELETE rdt.RDTScn WHERE Scn = 4201 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4201, 'ENG',
    @cLine01 = 'SCAN TO DOOR'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'TO DOOR:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20i03'
   ,@cLine14 = '%e'
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
   
