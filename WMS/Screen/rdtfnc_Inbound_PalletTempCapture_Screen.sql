--rdtfnc_Inbound_PalletTempCapture
--6530-6539

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1869)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1869, 'ENG', 'FNC', 'Inbound Pallet Temp Capture', 'rdtfnc_Inbound_PalletTempCapture', '3')
END


-- 6530 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 6530 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6530, 'ENG'
   ,@cLine01 = 'ASN:%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1869



-- 6531 = ASN/ID screen
DELETE rdt.RDTScn WHERE Scn = 6531 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6531, 'ENG'
   ,@cLine01 = 'ASN:%10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'ID:%18i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1869



-- 6532 = ASN/ID/Temprature screen
DELETE rdt.RDTScn WHERE Scn = 6532 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6532, 'ENG'
   ,@cLine01 = 'ASN:%10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'ID:%18d02'
   ,@cLine04 = ''
   ,@cLine05 = 'Temp:%10i03%10d04'
   ,@cLine14 = '%e'
   ,@nFunc = 1869


-- 6533 = confirm option screen
DELETE rdt.RDTScn WHERE Scn = 6533 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6533, 'ENG'
   ,@cLine01 = '%50d01'
   ,@cLine02 = ''
   ,@cLine03 = 'Option'
   ,@cLine04 = ''
   ,@cLine05 = '1 YES'
   ,@cLine06 = '9 NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPT%01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1869