

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('975', 'ENG', 'FNC', 'Print KIMBALL LABEL', 'rdtfnc_Print_Kimball_Label', '0')

-- 3200 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3200 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3200, 'ENG',
    @cLine01 = 'PRINT KIMBALL LABEL'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine13 = 'OPTION: %01i10'
   ,@cLine14 = '%e'
   ,@nFunc = 975
 
-- 3201 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3201 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3201, 'ENG',
    @cLine01 = 'PRINT KIMBALL LABEL'
   ,@cLine03 = '%20d01'
   ,@cLine05 = 'SCAN SKU/UPC'
   ,@cLine06 = '%30i02' -- (ChewKP01)
   ,@cLine08 = 'PRESS ENTER TO'
   ,@cLine09 = 'CONTINUE OR'
   ,@cLine10 = 'PRESS ESC TO RETURN'
   ,@cLine14 = '%e'
   ,@nFunc = 975

-- 3202 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3202 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3202, 'ENG',
    @cLine01 = 'PRINT KIMBALL LABEL'
   ,@cLine03 = '%20d01'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine09 = 'ENTER QTY OF'
   ,@cLine10 = 'LABELS REQUIRED'
   ,@cLine11 = '%05i05'
   ,@cLine14 = '%e'
   ,@nFunc = 975

-- 3203 = ?? screen  (SOS289765)
DELETE rdt.RDTScn WHERE Scn = 3203 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3203, 'ENG',
    @cLine01 = 'PRINT KIMBALL LABEL'
   ,@cLine03 = 'SKU LABEL'
   ,@cLine05 = 'ENTER LENGTH NEED'
   ,@cLine06 = 'TO CUT FROM RIGHT'
   ,@cLine07 = 'OF THE LABEL NO'
   ,@cLine08 = '%02i01'
   ,@cLine14 = '%e'
   ,@nFunc = 975
   
select * from rdt.rdtscn (nolock) where scn between 3200 and 3209