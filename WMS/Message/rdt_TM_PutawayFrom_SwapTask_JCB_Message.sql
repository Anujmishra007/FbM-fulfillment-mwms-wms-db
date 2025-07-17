--FCR-3954
--rdt_TM_PutawayFrom_SwapTask
execute rdt.rdtDropMsg 237551, 237600


execute rdt.rdtAddMsg 237551, 10, '237551^NoTaskOnThisID', 'us_english', 1797, 0, '237551 No Task On The Scanned ID'
execute rdt.rdtAddMsg 237552, 10, '237552^UpdTaskdetFail', 'us_english', 1797, 0, '237552 Update Task Detail Failed'
execute rdt.rdtAddMsg 237553, 10, '237553^UpdTaskdetFail', 'us_english', 1797, 0, '237553 Update Task Detail Failed'
execute rdt.rdtAddMsg 237554, 10, '237554^LCK:          ', 'us_english', 1797, 0, '237554 The Task Is Locked By Another User'
execute rdt.rdtAddMsg 237555, 10, '237555^LocAisleInUsed', 'us_english', 1797, 0, '237555 LocAisleInUsed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 237551 AND 237600