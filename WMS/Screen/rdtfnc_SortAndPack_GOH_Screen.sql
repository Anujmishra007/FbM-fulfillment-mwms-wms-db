-- 3310 = LoadKey screen
DELETE rdt.RDTScn WHERE Scn = 3310 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3310, 'ENG'
   ,@cLine01 = 'LOADKEY: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 542

-- 3311 = Store No screen
DELETE rdt.RDTScn WHERE Scn = 3311 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3311, 'ENG'
   ,@cLine01 = 'LOADKEY: %10d01'
   ,@cLine02 = 'STORE NO:'
   ,@cLine03 = '%15i02'
   ,@cLine14 = '%e'
   ,@nFunc = 542
   
-- 3312 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 3312 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3312, 'ENG'
   ,@cLine01 = 'STORE NO:'
   ,@cLine02 = '%15d01'
   ,@cLine03 = 'LABEL NO:'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 542

-- 3313 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 3313 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3313, 'ENG' 
   ,@cLine01 = 'STOR:%15d01'
   ,@cLine02 = 'ORDERKEY: %10d02'
   ,@cLine04 = 'LABEL NO:'
   ,@cLine05 = '%20d04'
   ,@cLine06 = 'SKU:'
   ,@cLine07 = '%20i05'
   ,@cLine08 = 'QTY: %05i06'
   --,@cLine09 = 'SCN QTY: %10d07'   -- SOS276422
   ,@cLine10 = 'CTN QTY: %10d11'     -- SOS276422
   ,@cLine11 = 'SKU BAL: %10d08'
   ,@cLine12 = 'ORD QTY: %10d09'     -- SOS276422
   ,@cLine13 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 542

-- 3314 = Option screen
DELETE rdt.RDTScn WHERE Scn = 3314 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3314, 'ENG'
   ,@cLine01 = 'STORE PACKING'
   ,@cLine02 = 'COMPLETED'
   ,@cLine03 = 'SUCCESSFULLY !!!!'             
   ,@cLine14 = '%e'
   ,@nFunc = 542
   
-- 3315 = Option screen
DELETE rdt.RDTScn WHERE Scn = 3315 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3315, 'ENG'
   ,@cLine01 = 'STORE PACKING'
   ,@cLine02 = 'NOT COMPLETED'
   ,@cLine04 = 'EXIT STORE?'
   ,@cLine05 = ''
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '0 = NO'
   ,@cLine08 = ''
   ,@cLine09 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 542

-- 3316 = Carton Type screen
DELETE rdt.RDTScn WHERE Scn = 3316 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3316, 'ENG'
   ,@cLine01 = 'LOADKEY : %10d01'
   ,@cLine02 = 'ORDERKEY: %10d02'
   ,@cLine03 = ''
   ,@cLine04 = 'LABEL NO:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = 'CARTON TYPE:'
   ,@cLine07 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 542

