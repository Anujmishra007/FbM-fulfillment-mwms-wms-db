--rdtfnc_Return_V7
--4270-4279

DELETE RDT.RDTMsg WHERE Message_ID = 607 AND Lang_Code = 'ENG' AND Message_Type = 'FNC'
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (607, 'ENG', 'FNC', 'RETURN V7', 'rdtfnc_Return_V7', '2')

-- Scn = 4270. ASN, PO
DELETE rdt.RDTScn WHERE Scn = 4270 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4270, 'ENG'
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine03 = ''
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 607
   
-- Scn = 4271. SKU
DELETE rdt.RDTScn WHERE Scn = 4271 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4271, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC: '
   ,@cLine05 = '%60i03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = ''
   ,@cLine09 = 'ASN QTY: %10d06'
   ,@cLine10 = 'RCV QTY: %10d07'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5","6","7"],"3":["9","10"]}'
   ,@nFunc = 607
   
-- Scn = 4272. QTY
DELETE rdt.RDTScn WHERE Scn = 4272 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4272, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'IVAS: '
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = '%08d05 %05d06 %05d07'
   ,@cLine09 = 'QTY RTN: %05i08^DT:INT %05i09^DT:INT'
   ,@cLine10 = ''
   ,@cLine11 = 'COND. CODE: %10i10'
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6"],"3":["8","9"],"4":["11"],"5":["13"]}'
   ,@nFunc = 607
   
-- Scn = 4273. Lottables
DELETE rdt.RDTScn WHERE Scn = 4273 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4273, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%18i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%60i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%18i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%10i08'
   ,@cLine14 = '%e'
   ,@nFunc = 607
 
-- Scn = 4274. ID, LOC
DELETE rdt.RDTScn WHERE Scn = 4274 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4274, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = '%18i02'
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = 'TO LOC:'
   ,@cLine07 = '%10d03'
   ,@cLine08 = '%10i04'
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["6","7","8"],"3":["13"]}'
   ,@nFunc = 607

--WMS-23005
-- 4275 = Capture info screen
DELETE rdt.RDTScn WHERE Scn = 4275 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4275, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20i10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"],"5":["9","10"]}'
   ,@nFunc = 607
   
-- 4276 = ToLoc Diff screen
DELETE rdt.RDTScn WHERE Scn = 4276 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4276, 'ENG'
   ,@cLine01 = 'TO LOC NOT MATCH.'
   ,@cLine02 = 'PROCEED ?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01d01'
   ,@cLine14 = '%e'
   ,@nFunc = 607   