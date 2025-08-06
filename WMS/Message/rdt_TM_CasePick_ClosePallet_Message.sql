--rdt_TM_CasePick_ClosePallet
execute rdt.rdtdropmsg 51151, 51200

execute rdt.rdtAddMsg 51151, 10, '51151^DelRPFLogFail ', 'us_english', 1812
execute rdt.rdtAddMsg 51152, 10, '51152^UpdTaskdetFail', 'us_english', 1812
execute rdt.rdtAddMsg 51153, 10, '51153^IncorrectSetup', 'us_english', 1812
execute rdt.rdtAddMsg 51154, 10, '51154^IncorrectSetup', 'us_english', 1812
execute rdt.rdtAddMsg 51155, 10, '51155^RDTMoveFailure', 'us_english', 1812, 0 , '51155: rdt_move SQL error'

