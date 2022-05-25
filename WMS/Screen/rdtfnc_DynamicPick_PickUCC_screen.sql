

IF NOT EXISTS(SELECT 1 FROM RDT.rdtmsg (nolock) where message_id=958)
BEGIN
   INSERT INTO rdt.rdtmsg(message_id,lang_code,message_type,message_text,StoredProcName)
   values('958','ENG','FNC','Pick Pack UCC','rdtfnc_DynamicPick_PickUCC')
END

-- 6030 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 6030 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6030, 'ENG'
   ,@cLine01 = N'PSNO : %10i01'
   ,@cLine14 = N'%e'
   ,@nFunc = 958

-- 6031 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 6031 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6031, 'ENG'
   ,@cLine01 = N'PSNO : %10d01'
   ,@cLine02 = N'LOC  : %10d02'
   ,@cLine03 = N'LOC  : %10i03'
   ,@cLine14 = N'%e'
   ,@nFunc = 958

-- 6032 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 6032 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6032, 'ENG'
   ,@cLine01 = N'SKU : %10d01'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'%20d02'
   ,@cLine04 = N'%20d03'
   ,@cLine05 = N'%20d04'
   ,@cLine06 = N'%20i05'
   ,@cLine07 = N'QTY: %05d06'
   ,@cLine14 = N'%e'
   ,@nFunc = 958

-- 6033 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 6033 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6033, 'ENG'
   ,@cLine01 = N'Confirm Short?'
   ,@cLine03 = N'1 = Yes'
   ,@cLine04 = N'2 = No'
   ,@cLine06 = N'Option:%01i01'
   ,@cLine14 = N'%e'
   ,@nFunc = 958

-- 6034 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 6034 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6034, 'ENG'
   ,@cLine01 = N'UCCNo'
   ,@cLine02 = N'%20d01'
   ,@cLine04 = N'DropID:'
   ,@cLine05 = N'%20i02'
   ,@cLine14 = N'%e'
   ,@nFunc = 958