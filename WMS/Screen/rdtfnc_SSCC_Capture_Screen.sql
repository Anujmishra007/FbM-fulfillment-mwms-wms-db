-- 2720 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2720 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2720, 'ENG',
    @cLine01 = 'SSCC CAPTURE'
   ,@cLine03 = 'LOADKEY: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 873
 
-- 2721 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2721 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2721, 'ENG',
    @cLine01 = 'SSCC CAPTURE'
   ,@cLine03 = 'LOADKEY: %10d01'
   ,@cLine05 = 'NEW SSCC LABEL? %01i02'
   ,@cLine06 = '(1 = YES, 2 = NO)'
   ,@cLine09 = '# of SSCC: %10d03'
	,@cLine10 = '# of ORD : %10d04'
	,@cLine11 = '# of SKU : %10d05'
	,@cLine12 = 'T.QTY: %13d06'
   ,@cLine14 = '%e'
   ,@nFunc = 873

-- 2722 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2722 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2722, 'ENG',
    @cLine01 = 'SSCC CAPTURE'
   ,@cLine03 = 'LOADKEY: %10d01'
   ,@cLine05 = 'SSCC:'
   ,@cLine06 = '%20i02'
   ,@cLine09 = '# of SSCC: %10d03'
	,@cLine10 = '# of ORD : %10d04'
	,@cLine11 = '# of SKU : %10d05'
	,@cLine12 = 'T.QTY: %13d06'
   ,@cLine14 = '%e'
   ,@nFunc = 873
   
-- 2723 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2723 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2723, 'ENG',
    @cLine01 = 'LOADKEY: %10d01'
   ,@cLine02 = 'SSCC:'
   ,@cLine03 = '%10d02'
	,@cLine04 = 'GS1 BARCODE:'   
	,@cLine05 = '%55i03'
	,@cLine06 = 'LAST SCANNED:'
	,@cLine07 = '%20d04'
	,@cLine08 = '%20d05'
	,@cLine09 = '%20d06'
	,@cLine10 = 'L2:%18d07'
	,@cLine11 = 'L4:%18d08'
	,@cLine12 = 'QTY: %05d09'
	,@cLine13 = 'T.QTY: %13d10'
   ,@cLine14 = '%e'
   ,@nFunc = 873
   
-- 2724 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2724 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2724, 'ENG',
    @cLine01 = 'SCAN COMPLETED'
   ,@cLine03 = 'LOADKEY: %10d01'
   ,@cLine05 = '# of SSCC: %10d02'
	,@cLine06 = '# of ORD : %10d03'
	,@cLine07 = '# of SKU : %10d04'
	,@cLine08 = 'T.QTY: %13d05'
	,@cLine10 = 'CONFIRM? %01i06'
	,@cLine11 = '(1 = Yes, 2 = No)'
   ,@cLine14 = '%e'
   ,@nFunc = 873
   
-- 2725 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2725 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2725, 'ENG',
    @cLine01 = 'SSCC CAPTURE'
   ,@cLine03 = 'LOADKEY: %10d01'
	,@cLine05 = 'T.QTY: %13d02'
	,@cLine07 = 'SCANNING NOT YET'
	,@cLine08 = 'COMPLETE'
	,@cLine10 = 'OPTION: %01i03'
	,@cLine11 = '1 = Abort'
	,@cLine12 = '2 = Back to Scanning'
	,@cLine13 = '3 = Delete all SSCC'
   ,@cLine14 = '%e'
   ,@nFunc = 873