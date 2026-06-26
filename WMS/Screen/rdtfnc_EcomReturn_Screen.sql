--rdtfnc_EcomReturn
--5640-5649

DELETE RDT.RDTMsg WHERE Message_ID = 638 AND Lang_Code = 'ENG' AND Message_Type = 'FNC'
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (638, 'ENG', 'FNC', 'ECOM RETURN', 'rdtfnc_EcomReturn', '2')

-- Scn = 5640. REF NO, ASN
DELETE rdt.RDTScn WHERE Scn = 5640 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5640, 'ENG'
   ,@cLine01 = 'REF NO:'
   ,@cLine02 = '%60i01'  --(yeekung02)
   ,@cLine03 = ''
   ,@cLine04 = 'ASN: %10i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4"]}'
   ,@nFunc = 638

-- 5641 = Capture info screen
DELETE rdt.RDTScn WHERE Scn = 5641 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5641, 'ENG'
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
   ,@nFunc = 638

-- Scn = 5642. SKU
DELETE rdt.RDTScn WHERE Scn = 5642 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5642, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'REF NO:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = ''
   ,@cLine05 = 'SKU/UPC: '
   ,@cLine06 = '%60i03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = ''
   ,@cLine10 = 'ASN QTY: %10d06'
   ,@cLine11 = 'RCV QTY: %10d07'
   ,@cLine13 = '%20d15'          -- WMS-16668
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["5","6","7","8"],"3":["10","11"],"4":["13"]}'
   ,@nFunc = 638

-- Scn = 3990. Lottables
 
-- Scn = 5644. ID, LOC
DELETE rdt.RDTScn WHERE Scn = 5644 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5644, 'ENG'
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
   ,@nFunc = 638

-- Scn = 5645. Option
DELETE rdt.RDTScn WHERE Scn = 5645 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5645, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'FINALIZE ASN?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 638

-- Scn = 5646. Pre ID, LOC
DELETE rdt.RDTScn WHERE Scn = 5646 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5646, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18i01'
   ,@cLine03 = ''
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%10i02'
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = 'STOCK ARRIVE DATE:'
   ,@cLine10 = '%10i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"],"3":["9","10"]}'
   ,@nFunc = 638
   
-- Scn = 5647. ConditionCode, SubReasonCode
DELETE rdt.RDTScn WHERE Scn = 5647 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5647, 'ENG'
   ,@cLine01 = 'CONDITION CODE:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine04 = 'SUB REASON CODE:'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 638

--WMS-16735
-- 5648 = Capture ReceiptDetail info screen
DELETE rdt.RDTScn WHERE Scn = 5648 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5648, 'ENG'
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
   ,@nFunc = 638   