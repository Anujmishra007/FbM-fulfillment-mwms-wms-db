--rdtfnc_Pallet_QC
-- 3140 - 3149

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1715', 'ENG', 'FNC', 'Pallet QC (NON TM)', 'rdtfnc_Pallet_QC', '9')


-- 3140 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3140 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3140, 'ENG',
    @cLine01 = 'CHOOSE OPTION'
   ,@cLine03 = '1 = GET PLT STATUS'
   ,@cLine04 = '2 = CONDUCT AUDIT'
   ,@cLine05 = '3 = AUDIT INQUIRY'
   ,@cLine06 = 'OPT: %01i01'
   ,@cLine14 = '%e'
   
-- 3141 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3141 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3141, 'ENG',
    @cLine01 = 'PALLET ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = '%18i02'
   ,@cLine14 = '%e'

-- 3142 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3142 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3142, 'ENG',
    @cLine01 = 'PALLET ID:'
   ,@cLine02 = '%18i01'
   ,@cLine04 = '1 = MOVE TO TRIAGE'
   ,@cLine06 = 'OPT: %01i02'
   ,@cLine14 = '%e'

-- 3143 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3143 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3143, 'ENG',
    @cLine01 = 'PALLET ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'CARTON ID'
   ,@cLine04 = '%20i02'
   ,@cLine06 = '1 = MOVE TO TRIAGE'
   ,@cLine08 = 'OPT: %01i03'
   ,@cLine14 = '%e'

-- 3144 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3144 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3144, 'ENG',
    @cLine01 = 'AUDIT COMPLETE ??'
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine06 = 'OPT: %01i01'
   ,@cLine14 = '%e'
      
-- 3145 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3145 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3145, 'ENG',
    @cLine01 = 'AUDIT IS SUCCESSFUL'
   ,@cLine03 = 'PRESS ENTER'
   ,@cLine04 = 'TO CONTINUE'
   ,@cLine14 = '%e'   

-- 3146 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3146 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3146, 'ENG',
    @cLine01 = 'AUDIT FAILED ! %05d01'
   ,@cLine02 = '%20d08'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine10 = '1 = MOVE TO TRIAGE'
   ,@cLine11 = 'ENTER = NEXT PAGE'
   ,@cLine12 = 'ESC = EXIT'
   ,@cLine13 = 'OPT: %01i07'
   ,@cLine14 = '%e'

-- 3147 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3147 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3147, 'ENG',
    @cLine01 = 'MOVE PALLET TO'
   ,@cLine02 = 'TRIAGE'
   ,@cLine04 = 'TRIAGE LOC:'
   ,@cLine05 = '%10i01'
   ,@cLine14 = '%e'   
   
-- 3148 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3148 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3148, 'ENG',
    @cLine01 = '               %05d01'
   ,@cLine02 = 'CARTON IDs NOT FOUND'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = 'ENTER = NEXT PAGE'
   ,@cLine13 = 'ESC = EXIT'
   ,@cLine14 = '%e'
   
-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 1715 WHERE SCN BETWEEN 3140 AND 3149
   
