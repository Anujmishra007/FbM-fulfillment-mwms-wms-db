IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1027)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('1027', 'ENG', 'FNC', 'UCCNo Update', 'rdtfnc_UCCNo_Update', '0')
END

-- 5450 = Label, value screen
DELETE rdt.RDTScn WHERE Scn = 6210 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6210, 'ENG'
   ,@cLine01 = 'UCCNo:'
   ,@cLine02 = '%60i01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20i03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20i05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20i07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20i09'
   ,@cLine11 = '%20d10'
   ,@cLine12 = '%20i11'
   ,@cLine14 = '%e'
   ,@nFunc   = 1027

