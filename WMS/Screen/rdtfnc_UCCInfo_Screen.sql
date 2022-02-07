


--rdtfnc_OTMPalletConsolidation
-- 4550 - 4559


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('726', 'ENG', 'FNC', 'UCC Info', 'rdtfnc_UCCInfo', '0')

-- 1770 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4550 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4550, 'ENG',
    @cLine01 = 'REF NO:'
   ,@cLine02 = '%20i01' 
   ,@cLine03 = 'UCC' 
   ,@cLine04 = '%20i02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20d10'
   ,@cLine13 = '%20d11'
   ,@cLine14 = '%e'
 

