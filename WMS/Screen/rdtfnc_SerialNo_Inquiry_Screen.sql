-- 5090 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5090 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5090, 'ENG',
     @cLine01 = 'SERIALNO:'
	 ,@cLine02 = '%30i01'
    ,@cLine14 = '%e'
	 ,@nfunc   = 627


-- 5091 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5091 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5091, 'ENG',
     @cLine01 = 'SERIALNO:'
	 ,@cLine02 = '%30d01'
	 ,@cLine03 = 'SKU: %20d02'
    ,@cLine04 = 'SKU DESC:'
    ,@cLine05 = '%20d03'
	 ,@cLine06 = '%20d04'
	 ,@cLine07 = 'ID: %20d05'
	 ,@cLine08 = 'STATUS: %20d06'
    ,@cLine09 = '%20d07'
    ,@cLine10 = '%20d08'
    ,@cLine11 = '%20d09'
    ,@cLine12 = '%20d10'
    ,@cLine13 = '%20d11'
    ,@cLine14 = '%e'
	 ,@nfunc   = 627
 