
IF NOT EXISTS ( SELECT 1 FROM rdt.rdtmsg (nolock) WHERE Message_ID = 905 AND Message_Type = 'FNC')
   INSERT INTO rdt.rdtmsg (Message_ID, Lang_Code, Message_Type, Message_Text, Storedprocname, EventType) VALUES 
   (905, 'ENG', 'FNC', 'PPA REFNO', 'rdtfnc_PostPickAudit_RefNo', 9)

-- 4730 = REFNO screen
DELETE rdt.RDTScn WHERE Scn = 4730 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4730, 'ENG' 
   ,@cLine01 = 'REFNO: '
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 905

-- 4731 = Info screen
DELETE rdt.RDTScn WHERE Scn = 4731 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4731, 'ENG'
   ,@cLine01 = 'REFNO: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SHIP TO : '
   ,@cLine04 = '%15d02'
   ,@cLine05 = ''
   ,@cLine06 = 'SKU CKD: %10d03' 
   ,@cLine07 = 'QTY CKD: %10d04' 
   ,@cLine08 = 'QTY SHP: %10d05' 
   ,@cLine14 = '%e'
   ,@nFunc = 905

-- 4732 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 4732 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4732, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%60i01'
   ,@cLine14 = '%e'
   ,@nFunc = 905   

-- 4733 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 4733 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4733, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = '%07d04   %05d05 %05d06'
   ,@cLine08 = 'QTY:     %05i07 %05i08'
   ,@cLine09 = ''
   ,@cLine10 = 'COUNTED: %05d09 %05d10'
   ,@cLine11 = 'TOTAL:   %05d11 %05d12'
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 905   
