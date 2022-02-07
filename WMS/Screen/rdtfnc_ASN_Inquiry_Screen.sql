INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1631', 'ENG', 'FNC', 'ASN Inquiry', 'rdtfnc_ASN_Inquiry', '0')

-- 2000  = ASN screen
DELETE rdt.RDTScn WHERE Scn = 2000 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2000, 'ENG',
    @cLine01 = 'ASN:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = 'OR'
   ,@cLine04 = 'REFNO:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'

-- 2001 = ASN, TTL SCN Qty, TTL EXP Qty screen
DELETE rdt.RDTScn WHERE Scn = 2001 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2001, 'ENG',
    @cLine01 = 'ASN:'        
   ,@cLine02 = '%10d01'
   ,@cLine03 = '             %05d02'
   ,@cLine04 = 'TTL SCN QTY: %05d03'
   ,@cLine05 = 'TTL EXP QTY: %05d04'
   ,@cLine14 = '%e'
 
-- 2002 = ASN, TTL SCN Qty, TTL EXP Qty... screen
DELETE rdt.RDTScn WHERE Scn = 2002 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2002, 'ENG',
    @cLine01 = 'ASN:     %11d10'        
   ,@cLine02 = '%10d01   %05d02'
   ,@cLine03 = 'TTL SCN QTY: %05d03'
   ,@cLine04 = 'TTL EXP QTY: %05d04'
   ,@cLine05 = '%20d11' -- (ChewKP01)
   ,@cLine06 = 'SKU:'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '         %05d07'
   ,@cLine10 = 'SCN QTY: %05d08'
   ,@cLine11 = 'EXP QTY: %05d09'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
   
 -- 2003. Lookup -- (ChewKP01) 
DELETE rdt.RDTScn WHERE Scn = 2003 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2003, 'ENG'
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
   ,@nFunc = 1631