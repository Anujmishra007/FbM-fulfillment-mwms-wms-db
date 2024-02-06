
-- Scn = 4340. ASN, PO
DELETE rdt.RDTScn WHERE Scn = 4340 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4340, 'ENG'
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine03 = ''
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%60i03'
   ,@cLine13 = '%20d04'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"],"3":["13"]}'
   ,@nFunc = 608
 
-- Scn = 4341. ID, LOC
DELETE rdt.RDTScn WHERE Scn = 4341 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4341, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine03 = ''
   ,@cLine04 = 'TO ID:'
   ,@cLine05 = '%18i03'
   ,@cLine06 = ''
   ,@cLine07 = 'TO LOC:'
   ,@cLine08 = '%10i04'
   ,@cLine09 = ''
   ,@cLine10 = 'METHOD: %01i05'
   ,@cLine11 = '1=LOTTABLE BEFORE'
   ,@cLine12 = '2=LOTTABLE AFTER'
   ,@cLine13 = '%20d06'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"],"3":["7","8"],"4":["10","11","12"],"5":["13"]}'
   ,@nFunc = 608
   
-- Scn = 4342. SKU, QTY
-- 4342 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4342 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4342, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'TO LOC: %10d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%60i03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = 'RCV: %15d07'
   ,@cLine10 = 'QTY: %10i08^DT:INT %05d09'
   ,@cLine11 = 'TOID QTY: %10d10'
   ,@cLine12 = 'COND CODE:%10i12'
   ,@cLine13 = '%20d11'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3"],"3":["4","5","6","7","8"],"4":["9","10"],"5":["11"],"6":["12"],"7":["13"]}'
   ,@nFunc = 608

-- Scn = 4343. Finalize ASN
DELETE rdt.RDTScn WHERE Scn = 4343 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4343, 'ENG'
   ,@cLine01 = 'FINALIZE ASN?'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '9 = NO'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %10i10'
   ,@cLine14 = '%e'
 
 

