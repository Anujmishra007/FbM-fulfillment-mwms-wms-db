--rdtfnc_IkeaIkeaReturn
--6270-6279

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 657 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (657, 'ENG', 'FNC', 'IKEA ECOM RETURN', 'rdtfnc_IkeaEcomReturn', '2')
END

-- Scn = 6270. TO ID, TO LOC, TYPE
DELETE rdt.RDTScn WHERE Scn = 6270 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6270, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%10i02'
   ,@cLine06 = ''
   ,@cLine07 = 'TYPE:'
   ,@cLine08 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 657

-- 6271 = METHOD, REF NO
DELETE rdt.RDTScn WHERE Scn = 6271 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6271, 'ENG'
   ,@cLine01 = 'METHOD:'
   ,@cLine02 = '%01i01'
   ,@cLine03 = ''
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 657

-- Scn = 6272. SKU, QTY
DELETE rdt.RDTScn WHERE Scn = 6272 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6272, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'REF NO:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = ''
   ,@cLine05 = 'SKU/UPC: '
   ,@cLine06 = '%60i03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = 'RCV: %10d06'
   ,@cLine10 = 'QTY: %10i07'
   ,@cLine11 = 'ASN QTY: %10d08'
   ,@cLine12 = 'REF QTY: %10d09'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 657

-- Scn = 6273. SKU DAMAGE
DELETE rdt.RDTScn WHERE Scn = 6273 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6273, 'ENG'
   ,@cLine01 = 'SKU DAMAGE:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 657

-- Scn = 6274. REF NO, PARCEL DMG
DELETE rdt.RDTScn WHERE Scn = 6274 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6274, 'ENG'
   ,@cLine01 = 'REF NO:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'PARCEL DMG:'
   ,@cLine05 = '%01i02'
   ,@cLine06 = ''
   ,@cLine07 = 'PARCEL COUNT: %05d03'
   ,@cLine14 = '%e'
   ,@nFunc = 657

-- Scn = 6275. SKU, LINE#, QTYEXP
DELETE rdt.RDTScn WHERE Scn = 6275 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6275, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = 'LINE#      QTYEXP'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = 'OPTION: %03i11'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 657   