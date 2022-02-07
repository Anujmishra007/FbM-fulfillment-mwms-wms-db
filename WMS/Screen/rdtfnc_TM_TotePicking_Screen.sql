
Insert into rdt.rdtTaskManagerConfig (TaskType, TaskDesc, Function_ID, Step)
Values ( 'SPK', 'Tote Picking', 1809 , '1' ) 

Insert into rdt.rdtTaskManagerConfig (TaskType, TaskDesc, Function_ID, Step)
Values ( 'PK', 'Tote Picking', 1809 , '1' ) 

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1809', 'ENG', 'FNC', 'TM - Tote Picking', 'rdtfnc_TM_TotePicking', '0')

-- 3880 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3880 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3880, 'ENG',
    @cLine01 = 'PICKING        %03d09'
   ,@cLine03 = 'PICKTYPE: %10d04'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%08i05'
   ,@cLine14 = '%e'
   ,@nFunc   = 1809

-- 3881 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3881 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3881, 'ENG',
    @cLine01 = 'PICKING        %03d05'
   ,@cLine03 = 'PICKTYPE: %10d01'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%18d02'
   ,@cLine06 = 'FROM LOC'
   ,@cLine07 = '%10d03'
   ,@cLine08 = '%10i04'
   ,@cLine14 = '%e'
   ,@nFunc   = 1809

-- 3882 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3882 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3882, 'ENG',
    @cLine01 = 'PICKING        %10d10'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'FROMLOC:'
   ,@cLine06 = '%10d09'
   ,@cLine07 = 'SKU/UPC'
   ,@cLine08 = '%20d02'
   ,@cLine09 = '%20d03'
   ,@cLine10 = '%20d04'
   ,@cLine11 = '%20i05'
   ,@cLine12 = '%10d06'
   ,@cLine13 = '%05d07 / %05d08'
   ,@cLine14 = '%e'
   ,@nFunc   = 1809

-- 3883 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3883 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3883, 'ENG',
    @cLine01 = 'PICKING        %03d02'
   ,@cLine03 = '1 = SHORT PICK'
   ,@cLine04 = '9 = CLOSE TOTE'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc   = 1809

-- 3884 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3884 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3884, 'ENG',
    @cLine01 = 'PICKING        %03d02'
   ,@cLine03 = 'Tote is Closed'
   ,@cLine05 = 'ENTER = Next Task'
   ,@cLine06 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc   = 1809

-- 3885 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3885 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3885, 'ENG',
    @cLine01 = 'PICKING        %03d01'
   ,@cLine03 = 'Order needs to be'
   ,@cLine04 = 'fulfilled by Other'
   ,@cLine05 = 'Pickers'
   ,@cLine07 = 'ENTER = Next Task'
   ,@cLine08 = 'ESC   = Exit TM'
   ,@cLine10 = '%20d02' -- (ChewKP06)
   ,@cLine11 = '%20d03' -- (ChewKP06)
   ,@cLine14 = '%e'
   ,@nFunc   = 1809

-- 3886 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3886 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3886, 'ENG',
    @cLine01 = 'PICKING        %03d09'
   ,@cLine03 = 'PICKTYPE: %10d04'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%18d03'
   ,@cLine06 = '%08i05'
   ,@cLine14 = '%e'
   ,@nFunc   = 1809

-- 3887 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3887 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3887, 'ENG',
    @cLine01 = 'PICKING        %03d02'
   ,@cLine03 = 'No More Task'
   ,@cLine04 = 'For This Tote'
   ,@cLine05 = '%20d01'
   ,@cLine07 = 'ENTER = Next Task'
   ,@cLine08 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc   = 1809

-- 3888 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3888 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3888, 'ENG',
    @cLine01 = 'PICKING        %03d01'
   ,@cLine04 = 'ENTER = Next Task'
   ,@cLine05 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc   = 1809

-- 3889 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3889 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3889, 'ENG',
    @cLine01 = 'PICKING        %03d03'
   ,@cLine03 = 'Different Tote?'
   ,@cLine04 = 'Old Tote: %08d01'
   ,@cLine05 = 'New Tote: %08d02'
   ,@cLine08 = 'ENTER = Confirm'
   ,@cLine09 = 'ESC   = Cancel'
   ,@cLine14 = '%e'
   ,@nFunc   = 1809 

-- 3890 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3890 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3890, 'ENG',
    @cLine01 = 'PICKING        %03d09'
   ,@cLine03 = 'TOTE : %08d01'
   ,@cLine04 = 'SAME WITH '
   ,@cLine05 = 'SKU:   %08d02'
   ,@cLine07 = 'PROCEED ??'
   ,@cLine08 = '1 = YES'
   ,@cLine09 = '9 = NO'
   ,@cLine10 = 'Option: %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1809 
