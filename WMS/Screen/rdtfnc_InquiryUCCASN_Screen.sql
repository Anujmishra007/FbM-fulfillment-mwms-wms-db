--rdtfnc_InquiryUCCASN
-- 4010 - 4019


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('595', 'ENG', 'FNC', 'UCC ASN Inquiry', 'rdtfnc_InquiryUCCASN', '0')

-- Screen 1
-- Scn = 4010 
DELETE rdt.RDTScn WHERE Scn = 4010 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4010, 'ENG', 
   @cLine01 = 'UCC ASN Inquiry',
   @cLine03 = 'UCC:',
   @cLine04 = '%20i01',
   @cLine05 = '%20d02',
   @cLine06 = '%20d03',
   @cLine07 = '%20d04',
   @cLine08 = '%20d05',
   @cLine09 = '%20d06',
   @cLine10 = '%20d07',
   @cLine11 = '%20d08',
   @cLine12 = '%20d09',
   @cLine13 = '%20d10',
   @cLine14 = '%e'

---- Screen 2
--DELETE rdt.RDTScn WHERE Scn = 4011 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 4011, 'ENG', 
--   @cLine01 = 'UCC ASN Inquiry',
--   @cLine03 = 'UCC:',
--   @cLine04 = '%20d01',
--   @cLine05 = '%20d02',
--   @cLine06 = '%20d03',
--   @cLine07 = '%20d04',
--   @cLine08 = '%20d05',
--   @cLine09 = '%20d06',
--   @cLine10 = '%20d07',
--   @cLine11 = '%20d08',
--   @cLine12 = '%20d09',
--   @cLine13 = '%20d10',
--   @cLine14 = '%e'



      
UPDATE RDT.RDTScn SET Func = 595 WHERE Scn Between 4010 AND 4019 