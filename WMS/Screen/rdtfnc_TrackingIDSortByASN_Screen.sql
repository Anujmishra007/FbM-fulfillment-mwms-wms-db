--rdtfnc_TrackingIDSortByASN
--5720-5729

IF NOT EXISTS ( SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 644)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (644, 'ENG', 'FNC', 'TrackingID Sort By ASN', 'rdtfnc_TrackingIDSortByASN', '9')
END

-- 5720 = ASN, PO, REF NO screen
DELETE rdt.RDTScn WHERE Scn = 5720 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5720, 'ENG'
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine03 = ''
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i03'
   ,@cLine12 = 'RELEASE LOC: %02i04'
   ,@cLine14 = '%e'
   ,@nFunc = 644

-- 5721 = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 5721 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5721, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine03 = 'TO LOC: %10i03'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 644
   
-- 5722 = SKU, Child ID screen
DELETE rdt.RDTScn WHERE Scn = 5722 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5722, 'ENG'
   ,@cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'SKU/UPC:'
   ,@cLine03 = '%60i02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine07 = 'CHILD TRACKING ID:'
   ,@cLine08 = '%60iV_MAX'
   ,@cLine10 = 'PACK QTY: %05d06'
   ,@cLine11 = 'CASE QTY: %10d07'
   ,@cLine12 = 'SKU QTY:  %10d08'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 644

-- 5723 = TO ID, PARENT TRACKING ID screen
DELETE rdt.RDTScn WHERE Scn = 5723 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5723, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18i01'
   ,@cLine03 = ''
   ,@cLine04 = 'PARENT TRACKING ID:'
   ,@cLine05 = '%20i02'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 644

-- 5724 = RefNo Selection screen
DELETE rdt.RDTScn WHERE Scn = 4040 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4040, 'ENG'
   ,@cLine01 = 'SELECT ASN:'
   ,@cLine02 = ''
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = ''
   ,@cLine13 = 'OPTION: %01i10'
   ,@cLine14 = '%e'
   ,@nFunc = 644

