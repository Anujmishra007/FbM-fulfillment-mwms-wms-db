
IF NOT EXISTS ( SELECT 1 FROM rdt.rdtmsg (nolock) WHERE Message_ID = 609 AND Message_Type = 'FNC')
   INSERT INTO rdt.rdtmsg (Message_ID, Lang_Code, Message_Type, Message_Text, Storedprocname, Eventtype) VALUES 
   (609, 'ENG', 'FNC', 'RECEIPT (2D) BARCODE', 'rdtfnc_Receipt_2DBarcode', 1)

-- 4700 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 4700 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4700, 'ENG' 
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine03 = ''
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 609

-- 4701 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 4701 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4701, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%60i03' -- SKU extend to 60 chars
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine14 = '%e'
   ,@nFunc = 609

-- 4702 = QTY, COND screen
DELETE rdt.RDTScn WHERE Scn = 4702 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4702, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'IVAS:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = '%07d05 %05d06   %05d07'
   ,@cLine09 = 'QTY: %07i08 %07i09'
   ,@cLine10 = ''
   ,@cLine11 = 'COND CODE:%10i10'
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 609   

-- 4703 = Message screen
DELETE rdt.RDTScn WHERE Scn = 4703 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4703, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful received'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@nFunc = 609