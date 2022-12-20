--rdtfnc_SplitUCC
-- 3820 - 3829

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 535)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('535', 'ENG', 'FNC', 'SPLIT UCC', 'rdtfnc_SplitUCC', '3')
END

-- 3820 = FROM UCC screen
DELETE rdt.RDTScn WHERE Scn = 3820 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3820, 'ENG'
   ,@cLine01 = 'SPLIT UCC'
   ,@cLine03 = 'FROM UCC:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 535
 
-- 3821 = TO UCC screen
DELETE rdt.RDTScn WHERE Scn = 3821 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3821, 'ENG'
   ,@cLine01 = 'SPLIT UCC'
   ,@cLine03 = 'FROM UCC:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'TO UCC:'
   ,@cLine07 = '%20i02'
   ,@cLine08 = '1 = FULL UCC'
   ,@cLine09 = '9 = PARTIAL UCC'
   ,@cLine11 = 'OPTIONS: %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 535
   
-- 3822 = SKU, QTY screen
DELETE rdt.RDTScn WHERE Scn = 3822 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3822, 'ENG'
   ,@cLine01 = 'SPLIT UCC'
   ,@cLine03 = 'TO UCC:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20i02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine10 = 'QTY: %05i05'
   ,@cLine11 = 'SCANNED: %05d06'
   ,@cLine12 = 'ABORT? (1=YES) %01i07'
   ,@cLine14 = '%e'
   ,@nFunc = 535
   
-- 3823 = TO ID screen
DELETE rdt.RDTScn WHERE Scn = 3823 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3823, 'ENG'
   ,@cLine01 = 'SPLIT UCC'
   ,@cLine03 = 'TO ID:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 535
   
-- 3824 = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 3824 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3824, 'ENG'
   ,@cLine01 = 'SPLIT UCC'
   ,@cLine03 = 'TO LOC:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 535

-- 3825 = MESSAGE screen
DELETE rdt.RDTScn WHERE Scn = 3825 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3825, 'ENG'
   ,@cLine01 = 'SPLIT UCC'
   ,@cLine02 = 'SUCCESSFULLY'
   ,@cLine04 = 'PRESS ENTER'
   ,@cLine05 = 'TO CONTINUE'
   ,@cLine14 = '%e'
   ,@nFunc = 535
