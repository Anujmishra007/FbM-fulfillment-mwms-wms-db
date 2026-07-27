/*
   KitMovement -- 1881
*/

IF NOT EXISTS( SELECT 1 FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID = 1881 AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType)
   VALUES (1881, 'ENG', 'FNC', 'Kit Movement', 'rdtfnc_KitMovement', 0)
GO

-- 6930-6939

-- 6930 = KIT Ticket #
DELETE rdt.RDTScn WHERE Scn = 6930 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6930, 'ENG'
   ,@cLine01 = 'KIT Ticket #:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 1881

-- 6931 = LOC
DELETE rdt.RDTScn WHERE Scn = 6931 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6931, 'ENG'
   ,@cLine01 = 'KIT Ticket #:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"]}'
   ,@nFunc = 1881

-- 6932 = PALLET ID (scan pallet in LOC)
DELETE rdt.RDTScn WHERE Scn = 6932 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6932, 'ENG'
   ,@cLine01 = 'KIT Ticket #:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'PALLET ID:'
   ,@cLine06 = '%20i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"]}'
   ,@nFunc = 1881

-- 6933 = SKU
DELETE rdt.RDTScn WHERE Scn = 6933 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6933, 'ENG'
   ,@cLine01 = 'KIT Ticket #:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'PALLET ID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'LOC:'
   ,@cLine08 = '%20d03'
   ,@cLine09 = ''
   ,@cLine10 = 'SKU:'
   ,@cLine11 = '%20i04'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"],"3":["7","8"],"4":["10","11"]}'
   ,@nFunc = 1881

-- 6934 = QTY
DELETE rdt.RDTScn WHERE Scn = 6934 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6934, 'ENG'
   ,@cLine01 = 'KIT Ticket #:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'PALLET ID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'LOC:'
   ,@cLine08 = '%20d03'
   ,@cLine09 = ''
   ,@cLine10 = 'SKU:'
   ,@cLine11 = '%20d04'
   ,@cLine12 = 'QTY:'
   ,@cLine13 = '%20i05'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"],"3":["7","8"],"4":["10","11"],"5":["12","13"]}'
   ,@nFunc = 1881

-- 6935 = TO PALLET ID
DELETE rdt.RDTScn WHERE Scn = 6935 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6935, 'ENG'
   ,@cLine01 = 'KIT Ticket #:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'TO PALLET ID:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 1881

-- 6936 = TO LOC
DELETE rdt.RDTScn WHERE Scn = 6936 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6936, 'ENG'
   ,@cLine01 = 'KIT Ticket #:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 1881

-- 6937 = Success
DELETE rdt.RDTScn WHERE Scn = 6937 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6937, 'ENG'
   ,@cLine01 = 'KIT MOVEMENT'
   ,@cLine02 = ''
   ,@cLine03 = 'KIT Ticket #:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'Successfully moved.'
   ,@cLine07 = ''
   ,@cLine08 = 'Press ENTER or ESC to'
   ,@cLine09 = 'continue.'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"]}'
   ,@nFunc = 1881
