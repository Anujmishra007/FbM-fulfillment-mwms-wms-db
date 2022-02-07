--rdtfnc_ReceivingByPalletID
--5890-5899

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 647 AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (647, 'ENG', 'FNC', 'PALLET RECEIVE', 'rdtfnc_ReceivingByPalletID', '2')
END

-- Scn = 5890. ASN, PO
DELETE rdt.RDTScn WHERE Scn = 5890 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5890, 'ENG'
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine03 = ''
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%30i03' 
   ,@cLine14 = '%e'
   ,@nFunc = 647
   
-- Scn = 5891. ID, LOC
DELETE rdt.RDTScn WHERE Scn = 5891 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5891, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine03 = ''
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 647
   
-- Scn = 5892. SKU, QTY
DELETE rdt.RDTScn WHERE Scn = 5892 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5892, 'ENG'
   ,@cLine01 = 'TO LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%60i02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = 'RCV: %10d06'
   ,@cLine10 = 'QTY: %10i07 %05d08'
   ,@cLine14 = '%e'
   ,@nFunc = 647
   
-- Scn = 5893. ID
DELETE rdt.RDTScn WHERE Scn = 5893 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5893, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine03 = 'TO LOC: %10d03'
   ,@cLine04 = 'TO ID:'
   ,@cLine05 = '%18i04'
   ,@cLine06 = 'ID QTY: %10d05'
   ,@cLine07 = 'RCV:    %10d06'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 647
   

 
 

