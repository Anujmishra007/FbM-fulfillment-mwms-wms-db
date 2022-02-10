--rdtfnc_TM_CycleCount_SKU
-- 2940  - 2949

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1768 AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('1768', 'ENG', 'FNC', 'TM CycleCount SKU', 'rdtfnc_TM_CycleCount_SKU', '8')
END


-- 2940 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2940 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2940, 'ENG',
    @cLine01 = 'TM CC - SKU'
   ,@cLine03 = 'LOC: %10d01'
   ,@cLine04 = 'ID :'
   ,@cLine05 = '%20d02'
   ,@cLine06 = 'SKU / UPC:'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%60i03' -- WMS4614 Change from 20->60
   ,@cLine09 = '%20d04'
   ,@cLine10 = '%15i05'
   ,@cLine13 = '%20d15' -- WMS-11550 ExtendedInfoSP
   ,@cLine14 = '%e'
 
-- 2941 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2941 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2941, 'ENG',
    @cLine01 = 'LOC: %10d14  %19d13'   -- WMS-16634
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%60i12' -- WMS4614 Change from 20->60
   ,@cLine05 = '%20d02'   
   ,@cLine06 = '%20d03'
   ,@cLine07 = 'UOM: %05d04 %05d05'
   ,@cLine08 = 'QTY: %05i06 %05i07'
   ,@cLine09 = '1 %18i08'
   ,@cLine10 = '2 %18i09'
   ,@cLine11 = '3 %18i10'
   ,@cLine12 = '4 %16i11'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
 
-- 2942 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2942 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2942, 'ENG',
    @cLine01 = 'TM CC - SKU'
   ,@cLine04 = '1 = END OF ID'
   ,@cLine05 = '2 = END OF LOC'
   ,@cLine06 = '3 = RECOUNT LOC'
   ,@cLine07 = '4 = CONTINUE'
   ,@cLine08 = '5 = NEW LOTTABLES'
   ,@cLine10 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
 
-- 2943 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2943 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2943, 'ENG',
    @cLine01 = 'TM CC - SKU'
   ,@cLine03 = 'ALERT TO SUPERVISOR'
   ,@cLine04 = 'HAS BEEN SENT'
   ,@cLine14 = '%e'

--WMS-16634
-- 2944 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2944 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2944, 'ENG',
    @cLine01 = 'TM CC - SKU'
   ,@cLine03 = 'SKU NOT EXISTS IN'
   ,@cLine04 = 'CURRENT LOC.'
   ,@cLine05 = 'CONTINUE?'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '2 = NO'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   
UPDATE RDT.RDTScn SET Func = 1768 WHERE Scn Between 2940 AND 2949 