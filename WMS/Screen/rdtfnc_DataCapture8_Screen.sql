-- Data Capture 8
-- 4460-4469
-- 4460 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4460 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4460, 'ENG',
    @cLine01 = 'COUNT NUMBER:'
   ,@cLine02 = '%02i01'
   ,@cLine14 = '%e'
 
-- 4461 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4461 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4461, 'ENG',
    @cLine01 = 'COUNT NUMBER: %02d01'
   ,@cLine02 = 'LOC: '
   ,@cLine03 = '%10i02'
   ,@cLine14 = '%e' 

-- 4462 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4462 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4462, 'ENG',
    @cLine01 = 'COUNT NUMBER: %02d01'
   ,@cLine02 = 'LOC: %10d02'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20i03'   
   ,@cLine05 = '%20d04'   
   ,@cLine06 = '%20d05'      
   ,@cLine13 = 'ITEM COUNT: %10d06'      
   ,@cLine14 = '%e' 

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG WITH (NOLOCK) WHERE MESSAGE_ID = 823 AND MESSAGE_TYPE = 'FNC')   
BEGIN
   INSERT INTO RDT.RDTMSG (MESSAGE_ID, LANG_CODE, MESSAGE_TYPE, MESSAGE_TEXT, STOREDPROCNAME, EVENTTYPE)
   VALUES (823, 'ENG', 'FNC', 'STOCK TAKE', 'rdtfnc_DataCapture8', 8)
END

--UPDATE RDT.RDTMenu SET OP5 = 823 WHERE MENUNO = 303
