-- 2470 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2470 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2470, 'ENG',
    @cLine01 = 'LABEL PRINTING'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%18i01'
   ,@cLine06 = '1 = KIMBALL'
   ,@cLine07 = '5 = KIMBALL T3'
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
 
-- 2471 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2471 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2471, 'ENG',
    @cLine02 = 'PRINTING DONE'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%18d01'
   ,@cLine07 = '# OF LABEL:'
   ,@cLine08 = '%05d02'
   ,@cLine10 = 'Press ENTER or ESC'
   ,@cLine11 = 'to continue'
   ,@cLine14 = '%e'
 


