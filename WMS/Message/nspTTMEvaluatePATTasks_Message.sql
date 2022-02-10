--rdtfnc_TM_PutawayTo_Confirm_Messages
execute rdt.rdtDropMsg 83651, 83700

execute rdt.rdtAddMsg 83651, 10, '83651^PAT Code Fail ', 'us_english', 1796
execute rdt.rdtAddMsg 83652, 10, '83652^OpenCursorFail', 'us_english', 1796
execute rdt.rdtAddMsg 83653, 10, '83653^UpdTaskdetFail', 'us_english', 1796
