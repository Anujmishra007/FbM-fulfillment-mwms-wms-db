--rdtfnc_DataCapture9
--5070 - 5079

-- 5070 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5070 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5070, 'ENG',
    @cLine01 = 'LOC:'
	,@cLine02 = '%10i01'
   ,@cLine03 = 'ID:'
   ,@cLine04 = '%20i02' 
   ,@cLine14 = '%e'
	,@nFunc = 625

-- 5071 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5071 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5071, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'UCC:'
   ,@cLine05 = '%40i03'
   ,@cLine06 = 'SKU/UPC:'
   ,@cLine07 = '%40i04'
   ,@cLine08 = 'QTY: %10i05'
   ,@cLine13 = 'Scan: %05d13'
   ,@cLine14 = '%e'