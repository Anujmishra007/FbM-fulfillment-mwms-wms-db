-- rdtfnc_DropID_Replen_To
--Screen Range 2860 - 2869

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('944', 'ENG', 'FNC', 'DropID Replen To', 'rdtfnc_DropID_Replen_To', '0')


-- 2860 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2860 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2860, 'ENG',
   @cLine01 = 'DROP ID:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'


-- 2861 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2861 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2861, 'ENG',
   @cLine01 = 'DROP ID:'
   ,@cLine02 = '%18d01'
   ,@cLine04 = 'TOLOC:'
   ,@cLine05 = '%10d02'
   ,@cLine06 = '%10i03'
   ,@cLine14 = '%e'


-- 2862 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2862 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2862, 'ENG',
    @cLine01 = 'DROP ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'TOLOC:'
   ,@cLine04 = '%10d02'
   ,@cLine05 = 'SKU'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = 'R QTY: %05d10 / %05d06'
   ,@cLine10 = 'QTY: %05i08'
   ,@cLine11 = 'SKU/UPC:'
   ,@cLine12 = '%20i07'
   ,@cLine14 = '%e'
 
 
   
   
   

-- 2863 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2863 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2863, 'ENG',
    @cLine01 = 'DROP ID:'
   ,@cLine02 = '%18d01'
   ,@cLine04 = 'Replenishment Done'
   ,@cLine06 = 'ENTER = NEXT DROPID'
   ,@cLine14 = '%e'   
   

-- 2864 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2864 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2864, 'ENG',
    @cLine01 = 'DROP ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'TOLOC:'
   ,@cLine04 = '%10d02'
   ,@cLine05 = 'SKU'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = 'QTY: %10d06'
   ,@cLine10 = 'SKIP THIS SKU ?'
   ,@cLine11 = '1 = YES'
   ,@cLine12 = '2 = NO'
   ,@cLine13 = 'OPTION %01i07'
   ,@cLine14 = '%e'   
   


-- 2865 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2865 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2865, 'ENG',
    @cLine01 = 'DROP ID:'
   ,@cLine02 = '%18d01'
   ,@cLine04 = 'NO MORE SKU FOR'
   ,@cLine05 = 'THIS LOCATION'
   ,@cLine07 = 'ENTER = NEXT LOC'
   ,@cLine08 = 'ESC   = NEW DROPID'
   ,@cLine14 = '%e'      

 


DELETE rdt.RDTScn WHERE Scn = 2866 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2866, 'ENG',
   @cLine01 = 'DROP ID:'
   ,@cLine02 = '%18d01'
   ,@cLine04 = 'NO MORE' 
   ,@cLine05 = 'REPLENISHMENT TASK'   
   ,@cLine07 = 'ENTER = NEXT LOAD' 
   ,@cLine14 = '%e'    