-- 3230 = LoadKey screen
DELETE rdt.RDTScn WHERE Scn = 3230 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3230, 'ENG'
   ,@cLine01 = 'LOADKEY: %10i01'
   ,@cLine03 = 'LAST LOADKEY:'
   ,@cLine04 = '%10d02'
   ,@cLine12 = 'LOADKEY SCANNED: %03d03'
   ,@cLine14 = '%e'
   ,@nFunc = 540
   
-- 3231 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 3231 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3231, 'ENG'
   ,@cLine01 = 'LOADKEY: %10d01'
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20i02'
   ,@cLine04 = 'UCC:'   -- (Chee01)
   ,@cLine05 = '%20i03' -- (Chee01)
   ,@cLine14 = '%e'
   ,@nFunc = 540

-- 3232 = LabelNo screen
DELETE rdt.RDTScn WHERE Scn = 3232 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3232, 'ENG' 
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'STOR:%15d04'
   ,@cLine06 = 'ORDERKEY: %10d05'
   ,@cLine07 = 'LABEL NO:'
   ,@cLine08 = '%20i06'
   ,@cLine09 = '%20d10'    -- (james09)
   ,@cLine10 = '%20d07'    -- (james09)
   ,@cLine11 = '%20d08'    -- (james09)
   ,@cLine12 = '%20d09'
   ,@cLine13 = '%20d11'             
   ,@cLine14 = '%e'
   ,@nFunc = 540

-- 3233 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 3233 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3233, 'ENG' 
   ,@cLine01 = 'STOR:%15d01'
   ,@cLine02 = 'ORDERKEY: %10d02'
   ,@cLine03 = 'LABEL NO:'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20d11' -- (james12)
   ,@cLine07 = '%20i04'
   ,@cLine08 = 'EXP QTY: %05d05'
   ,@cLine09 = 'PCK QTY: %05i06'
-- ,@cLine11 = 'STOR QTY: %10d07'   -- (james01)
   ,@cLine11 = 'SKU QTY: %10d08'
   ,@cLine12 = '%20d09'
   ,@cLine13 = '%20d10'             -- (james03)
   ,@cLine14 = '%e'
   ,@nFunc = 540

-- 3234 = Option screen
DELETE rdt.RDTScn WHERE Scn = 3234 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3234, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PACKING COMPLETED'
   ,@cLine03 = '%20d01'             -- (james03)
   ,@cLine05 = 'PRESS ESC for next' 
   ,@cLine06 = 'SKU packing.'
   ,@cLine14 = '%e'
   ,@nFunc = 540
   
-- 3235 = Option screen
DELETE rdt.RDTScn WHERE Scn = 3235 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3235, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'EXIT PACKING?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = '%20d02' -- (Chee01)
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 540

-- SOS262231
-- 3236 = Carton Type screen
DELETE rdt.RDTScn WHERE Scn = 3236 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3236, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ORDERKEY: %10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'LABEL NO:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = 'CARTON TYPE:'
   ,@cLine07 = '%20i03'
   ,@cLine12 = '%20d04'    -- ExtendedInfo01(WMS907)
   ,@cLine13 = '%20d05'    -- ExtendedInfo02(WMS907)
   ,@cLine14 = '%e'
   ,@nFunc = 540

-- 3237 = Option screen (For ANF)
DELETE rdt.RDTScn WHERE Scn = 3237 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3237, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PACKING COMPLETED'
   ,@cLine03 = '%20d01'             -- (james03)
   ,@cLine05 = 'PRESS ESC for next' 
   ,@cLine06 = 'SKU packing.'
   ,@cLine08 = 'CLOSE CARTON?' -- (Chee01)
   ,@cLine09 = '1 = YES'
   ,@cLine10 = '2 = NO'
   ,@cLine12 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 540
   