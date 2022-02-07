--rdtfnc_GeneralInquiry
-- 4710 - 4719

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('727', 'ENG', 'FNC', 'General Inquiry', 'rdtfnc_GeneralInquiry', '0')

-- 3580 = Option screen
DELETE rdt.RDTScn WHERE Scn = 4710 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4710, 'ENG'
   ,@cLine01 = 'GENERAL INQUIRY'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine13 = 'OPTIONS: %01i10'
   ,@cLine14 = '%e'
   ,@nFunc = 727
 
-- 4711 = Param screen
DELETE rdt.RDTScn WHERE Scn = 4711 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4711, 'ENG'
   ,@cLine01 = '%20d11'
   ,@cLine02 = ''
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20i02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20i04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20i06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20i08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20i10'
   ,@cLine14 = '%e'
   ,@nFunc = 727

-- 4712 = Param screen
DELETE rdt.RDTScn WHERE Scn = 4712 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4712, 'ENG'
   ,@cLine01 = '%20d11'
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
   ,@cLine12 = '%20d10'
   ,@cLine13 = '%20i12' -- WMS-17819
   ,@cLine14 = '%e'
   ,@nFunc = 727

-- 4713 = Param screen
DELETE rdt.RDTScn WHERE Scn = 4713 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4713, 'ENG'
   ,@cLine01 = '%20d11'
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
   ,@cLine12 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 727