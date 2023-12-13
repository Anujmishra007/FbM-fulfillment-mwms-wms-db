--rdtfnc_TM_CycleCount_UCC
-- 2930 - 2939

IF NOT EXISTS ( SELECT 1 FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID = 1767 AND Message_Type 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('1767', 'ENG', 'FNC', 'TM CycleCount UCC', 'rdtfnc_TM_CycleCount_UCC', '8')
END

DELETE rdt.RDTScn WHERE Scn = 2930 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2930, 'ENG', 
   --@cLine01 = 'TM CC - UCC    %05d05',			
   @cLine01 = 'TM CC - UCC    ',			
   @cLine02 = '%20i01',
   @cLine04 = '%20d02',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = 'LOTTABLE 1/2/3/4/5:',
   @cLine08 = '1 %18d06',
   @cLine09 = '2 %18d07',
   @cLine10 = '3 %18d08',
   @cLine11 = '4 %18d09',
   @cLine12 = '5 %18d10',   
   @cLine13 = '%20d15',  --WMS-16965
   @cLine14 = '%e',
   @nFunc = 1767        

DELETE rdt.RDTScn WHERE Scn = 2931 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2931, 'ENG', 
   @cLine01 = 'TM CC - UCC',
   @cLine04 = '1 = END OF ID',
   @cLine05 = '2 = END OF LOC',
   @cLine06 = '3 = RECOUNT LOC',
   @cLine07 = '4 = CONTINUE',
   @cLine09 = 'OPTION %01i01',
   @cLine14 = '%e',
   @nFunc = 1767        


DELETE rdt.RDTScn WHERE Scn = 2932 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2932, 'ENG', 
   @cLine01 = 'TM CC - UCC',
   @cLine03 = 'ALERT TO SUPERVISOR',
   @cLine04 = 'HAS BEEN SENT',
   @cLine14 = '%e',
   @nFunc = 1767               

--WMS-24279
DELETE rdt.RDTScn WHERE Scn = 2933 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2933, 'ENG',
    @cLine01 = 'TM CC - UCC'
   ,@cLine03 = 'UCC NOT EXISTS IN'
   ,@cLine04 = 'CURRENT LOC.'
   ,@cLine05 = 'CONTINUE?'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '2 = NO'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e',
   @nFunc = 1767  

UPDATE RDT.RDTScn SET Func = 1767 WHERE Scn Between 2930 AND 2939 
