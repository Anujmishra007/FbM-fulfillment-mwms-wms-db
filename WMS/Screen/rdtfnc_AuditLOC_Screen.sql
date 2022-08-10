IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG WITH (NOLOCK) WHERE MESSAGE_ID = 653 AND LANG_CODE = 'ENG' AND MESSAGE_TYPE = 'FNC')   
BEGIN
   INSERT INTO RDT.RDTMSG (MESSAGE_ID, LANG_CODE, MESSAGE_TYPE, MESSAGE_TEXT, STOREDPROCNAME, EVENTTYPE)
   VALUES (653, 'ENG', 'FNC', 'AUDIT LOC', 'rdtfnc_AuditLOC', 8)
END

-- 6090 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 6090 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6090, 'ENG'
   ,@cLine01 = 'LOC: %10i01'
   ,@cLine14 = '%e' 
   ,@nFunc = 653

-- 6091 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 6091 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6091, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%30i02'   
   ,@cLine05 = ''   
   ,@cLine06 = 'QTY SCAN: %05d03'      
   ,@cLine14 = '%e' 
   ,@nFunc = 653

-- 6092 = Varinace screen
DELETE rdt.RDTScn WHERE Scn = 6092 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6092, 'ENG'
   ,@cLine01 = 'SKU:           %05d07'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'   
   ,@cLine05 = ''   
   ,@cLine06 = 'QTY SCAN:  %05d04'      
   ,@cLine07 = 'QTY AVAIL: %05d05'      
   ,@cLine08 = ''   
   ,@cLine09 = 'VARIANCE:  %05d06'      
   ,@cLine14 = '%e' 
   ,@nFunc = 653
