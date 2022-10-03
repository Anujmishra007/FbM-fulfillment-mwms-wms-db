
IF NOT EXISTS (SELECT 1 FROM rdt.rdtmsg (nolock) where message_id=806)
BEGIN
   INSERT INTO rdt.rdtmsg (message_id,lang_code,message_type,Message_text,storedprocname)
   values('806','ENG','FNC','PTLPiece Inquiry','rdtfnc_PTLPiece_Inquiry')
END

-- 3390 = TO ID
DELETE rdt.RDTScn WHERE Scn = 6100 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6100, 'ENG'
   ,@cLine01 = 'Station:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 806

-- 3391 = FROM LOC
DELETE rdt.RDTScn WHERE Scn = 6101 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6101, 'ENG'
   ,@cLine01 = 'Wave: %20d01'
   ,@cLine02 = 'Orders: %20d02'
   ,@cLine03 = 'LOC: %10d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'   
   ,@cLine06 = '%20d06'   
   ,@cLine07 = '%20d07'   
   ,@cLine08 = '%20d08'   
   ,@cLine09 = '%20d09'   
   ,@cLine10 = '%20d10'
   ,@cLine11 = '%20d11'   
   ,@cLine12 = '%20d12'
   ,@cLine13 = '%20d13'
   ,@cLine14 = '%e'
   ,@nFunc = 806

