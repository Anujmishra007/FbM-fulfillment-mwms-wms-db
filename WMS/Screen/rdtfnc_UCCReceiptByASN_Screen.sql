--rdtfnc_UCCReceiptByASN
--984-994

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 554 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (554, 'ENG', 'FNC', 'UCC Receive By ASN', 'rdtfnc_UCCReceiptByASN', '1')


-- 984 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 984 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 984, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine03 = 'ASN#: %10i01'
   ,@cLine04 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 554

-- 985 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 985 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 985, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine03 = 'ToLoc: %10i01'
   ,@cLine04 = 'MUID#:'
   ,@cLine05 = '%18i02'
   ,@cLine07 = 'Total cartons: %05i03'
   ,@cLine14 = '%e'
   ,@nFunc = 554

-- 986 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 986 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 986, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine02 = 'UCC:'
   ,@cLine03 = '%20i01'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'DESCR: %10d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = 'PPK/DU: %30d06'
   ,@cLine09 = 'LOTTABLE02/04:'
   ,@cLine10 = '2: %18d07'
   ,@cLine11 = '4: %18d08'
   ,@cLine12 = 'UOM: %05d09 Qty: %05d10'
   ,@cLine13 = 'CTNS: %05d11'
   ,@cLine14 = '%e'
   ,@nFunc = 554

-- 987 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 987 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 987, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine02 = 'UCC:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'DESCR: %10d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = 'PPK/DU: %30d06'
   ,@cLine09 = 'LOTTABLE02/04:'
   ,@cLine10 = '2: %18d07'
   ,@cLine11 = '4: %18d08'
   ,@cLine12 = 'UOM: %05d09 Qty: %05i10'
   ,@cLine13 = 'CTNS: %05d11'
   ,@cLine14 = '%e'
   ,@nFunc = 554

-- 988 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 988 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 988, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine02 = 'UCC:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'DESCR: %10d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = 'PPK/DU: %30d06'
   ,@cLine09 = 'LOTTABLE02/04:'
   ,@cLine10 = '2: %18d07'
   ,@cLine11 = '4: %18d08'
   ,@cLine12 = 'UOM: %05d09 Qty: %05d10'
   ,@cLine13 = 'CTNS: %05d11'
   ,@cLine14 = '%e'
   ,@nFunc = 554

-- 989 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 989 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 989, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine03 = '< Max No. of CTNS'
   ,@cLine05 = 'Confirm ??: %01i01'
   ,@cLine06 = '1 = Yes 2 = No'
   ,@cLine14 = '%e'
   ,@nFunc = 554

-- 990 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 990 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 990, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine03 = 'Do you want to'
   ,@cLine04 = 'accept this UCC??'
   ,@cLine05 = '(Y/N) %01i01'
   ,@cLine06 = '1 = Yes 2 = No'
   ,@cLine14 = '%e'
   ,@nFunc = 554

-- 991 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 991 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 991, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine03 = 'ToLoc: %10d01'
   ,@cLine04 = 'MUID#:'
   ,@cLine05 = '%18d02'
   ,@cLine07 = 'Total cartons: %05i03'
   ,@cLine14 = '%e'
   ,@nFunc = 554

-- 992 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 992 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 992, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine02 = 'UCC:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20i03'
   ,@cLine06 = 'DESCR: %10d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = 'PPK/DU: %30d06'
   ,@cLine09 = 'LOTTABLE02/04:'
   ,@cLine10 = '2: %18d07'
   ,@cLine11 = '4: %18d08'
   ,@cLine12 = 'UOM: %05d09 Qty: %05d10'
   ,@cLine13 = 'CTNS: %05d11'
   ,@cLine14 = '%e'
   ,@nFunc = 554

-- 993 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 993 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 993, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine03 = 'UCC Qty is NOT valid'
   ,@cLine05 = 'Received By UPC'
   ,@nFunc = 554

-- 994 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 994 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 994, 'ENG'
   ,@cLine01 = 'UCC Receipt By ASN'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%18i02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%18i04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%18i06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20i08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20i10'
   ,@cLine14 = '%e'
   ,@nFunc = 554
 

