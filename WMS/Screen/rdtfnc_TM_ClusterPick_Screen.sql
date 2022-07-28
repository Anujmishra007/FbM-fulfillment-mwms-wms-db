--rdtfnc_TM_ClusterPick
--5680-5689

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 640)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (640, 'ENG', 'FNC', 'TM Cluster Pick', 'rdtfnc_TM_ClusterPick', '3')
END

-- 5680 = CART ID screen
DELETE rdt.RDTScn WHERE Scn = 5680 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5680, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = '%20d03' -- WMS-17429
   ,@cLine03 = 'CART ID:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 640
 
-- 5681 = CART MATRIX screen
DELETE rdt.RDTScn WHERE Scn = 5681 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5681, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = '%20d10' -- WMS-17429
   ,@cLine03 = 'CART ID: %10d01'
   ,@cLine04 = ''
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = '%20d06'
   ,@cLine10 = '%20d07'
   ,@cLine11 = '%20d08'
   ,@cLine12 = '%20d09'
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 640

-- 5682 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 5682 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5682, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = '%20d03' -- WMS-17429
   ,@cLine03 = 'LOC: %10d01'
   ,@cLine04 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 640

-- 5683 = CARTON ID screen
DELETE rdt.RDTScn WHERE Scn = 5683 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5683, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = '%20d05' -- WMS-17429
   ,@cLine03 = 'LOC: %10d01'
   ,@cLine04 = 'CARTON ID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20i03'
   ,@cLine07 = '%20d04' -- WMS-17429
   ,@cLine14 = '%e'
   ,@nFunc = 640

-- 5684 = SKU/UPC, Qty screen
DELETE rdt.RDTScn WHERE Scn = 5684 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5684, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = '%20d09' -- WMS-17429
   ,@cLine03 = 'CARTON ID:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = 'SKU/UPC'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%20i05'
   ,@cLine10 = ''
   ,@cLine11 = 'PICK QTY: %03i06'
   ,@cLine12 = 'PICKED/TOTAL: %03d07 / %03d08'
   ,@cLine14 = '%e'
   ,@nFunc = 640

-- 5685 = OPTION screen
DELETE rdt.RDTScn WHERE Scn = 5685 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5685, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = '%20d02' -- WMS-17429
   ,@cLine03 = 'CONFIRM OPTION'
   ,@cLine04 = ''
   ,@cLine05 = '1 = SHORT PICK'
   --,@cLine06 = '2 = BAL PICK LATER'
   ,@cLine07 = '2 = CLOSE CARTON'
   ,@cLine08 = ''
   ,@cLine09 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 640   

-- 5686 = CLOSE CARTON ID screen
DELETE rdt.RDTScn WHERE Scn = 5686 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5686, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = '%20d03' -- WMS-17429
   ,@cLine03 = 'CARTON ID TO CLOSE'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine06 = 'NEW CARTON ID'
   ,@cLine07 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 640 

-- 5687 = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 5687 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5687, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = '%20d03' -- WMS-17429
   ,@cLine03 = 'TO LOC: %10d01'
   ,@cLine04 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 640 

-- 5688 = NEXT TASK/ EXIT TM screen
DELETE rdt.RDTScn WHERE Scn = 5688 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5688, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = ''
   ,@cLine03 = 'PICKING COMPLETED'
   ,@cLine04 = 'FOR CART: %10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit to TM'
   ,@cLine14 = '%e'
   ,@nFunc = 640

-- WMS-17429
-- 5689 = RE-CONFIRM CARTON ID screen
DELETE rdt.RDTScn WHERE Scn = 5689 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5689, 'ENG'
   ,@cLine01 = 'CLUSTER PICKING  CPK'
   ,@cLine02 = '%20d05'
   ,@cLine03 = 'LOC: %10d01'
   ,@cLine04 = 'CONFIRM CARTON ID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20i03'
   ,@cLine07 = '%20d04' 
   ,@cLine14 = '%e'
   ,@nFunc = 640   