--rdtfnc_VAP_EndUncasing
--4440 - 4409

IF NOT EXISTS ( SELECT 1 FROM rdt.rdtmsg (nolock) where message_id = 1154 and message_type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1154, 'ENG', 'FNC', 'END UNCASING', 'rdtfnc_VAP_EndUncasing', '9')
END

-- Screen 1
-- Scn = 4440 
DELETE rdt.RDTScn WHERE Scn = 4440 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4440, 'ENG', 
   @cLine01 = 'END UNCASING',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20i01',
   @cLine12 = 'END TIME:',
   @cLine13 = '%20d02',
   @cLine14 = '%e',
   @nFunc = 1154

DELETE rdt.RDTScn WHERE Scn = 4441 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4441, 'ENG', 
   @cLine01 = 'END UNCASING',
   @cLine02 = 'SUCCESSFUL !',
   @cLine04 = 'PRESS ENTER',
   @cLine05 = 'TO CONTINUE.',
   @cLine14 = '%e',
   @nFunc = 1154
