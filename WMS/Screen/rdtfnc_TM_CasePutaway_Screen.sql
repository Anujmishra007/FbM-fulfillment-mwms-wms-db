

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1762', 'ENG', 'FNC', 'TM - Putaway', 'rdtfnc_TM_CasePutaway', '0')

-- 2450 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2450 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2450, 'ENG',
    @cLine01 = 'CASE PUTAWAY     VPA'
   ,@cLine03 = 'CASE ID:'
   ,@cLine04 = '%20d03' -- (ChewKP10)
   ,@cLine05 = '%20i04' -- (ChewKP10)
   ,@cLine14 = '%e'
   ,@nFunc = 1762
   
-- 2451 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2451 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2451, 'ENG',
    @cLine01 = 'CASE PUTAWAY     VPA'
   ,@cLine03 = 'CASE ID:'
   ,@cLine04 = '%20d01' -- (ChewKP10)
   ,@cLine05 = 'BOM SKU:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%20i05'
   ,@cLine14 = '%e'
   ,@nFunc = 1762
   
-- 2452 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2452 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2452, 'ENG',
    @cLine01 = 'CASE PUTAWAY     VPA'
   ,@cLine03 = 'CASE ID:'
   ,@cLine04 = '%20d01' -- (ChewKP10)
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = 'UOM: %10d05'
   ,@cLine10 = 'QTY: %05d06'
   ,@cLine11 = 'TO LOC:'
   ,@cLine12 = '%10d07'
   ,@cLine13 = '%10i08'
   ,@cLine14 = '%e'
   ,@nFunc = 1762
   
-- 2453 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2453 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2453, 'ENG',
    @cLine01 = 'CASE PUTAWAY     VPA'
   ,@cLine03 = 'Putaway is'
   ,@cLine04 = 'successful'
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc = 1762
   
-- 2454 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2454 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2454, 'ENG',
    @cLine01 = 'CASE PUTAWAY     VPA'
   ,@cLine04 = 'ENTER = Next Task'
   ,@cLine05 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc = 1762
    
-- 2454 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2454 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2454, 'ENG',
    @cLine01 = 'CASE PUTAWAY     VPA'
   ,@cLine04 = 'ENTER = Next Task'
   ,@cLine05 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc = 1762