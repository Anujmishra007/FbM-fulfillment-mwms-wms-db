-- 5090 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5090 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5090, 'ENG',
     @cLine01 = 'SERIALNO:'
	 ,@cLine02 = '%200iV_Barcode' --FCR-9890
    ,@cLine14 = '%e'
    ,@cWebGroup = '{"1":["1","2"]}'
	 ,@nfunc   = 627


-- 5091 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5091 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5091, 'ENG',
     @cLine01 = 'SERIALNO:'
	 ,@cLine02 = '%20d01'
	 ,@cLine03 = '%20d02'
	 ,@cLine04 = 'SKU:'
	 ,@cLine05 = '%20d03'
    ,@cLine06 = '%20d04'
	 ,@cLine07 = '%20d05'
	 ,@cLine08 = 'LOC: %10d06'
	 ,@cLine09 = 'ID%18d07'
	 ,@cLine10 = 'STATUS: %20d08'
    ,@cLine11 = '%20d09'
    ,@cLine12 = '%20d10'
    ,@cLine13 = '%20d11'
    ,@cLine14 = '%e'
    ,@cWebGroup = '{"1":["1","2","3"],"2":["4","5","6","7"],"3":["8"],"4":["9"],"5":["10"],"6":["11","12","13"]}'
	 ,@nfunc   = 627