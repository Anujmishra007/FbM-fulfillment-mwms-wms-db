DELETE rdt.RDTScn WHERE Scn = 6818 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6818, 'ENG',
    @cLine01 = 'Print Packslip For'
   ,@cLine02 = 'The Order'
   ,@cLine03 = '%20d01' 
   ,@cLine05 = 'Option:%20i02'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '9 = NO'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["5","6","7"]}'
   ,@nFunc = 1837