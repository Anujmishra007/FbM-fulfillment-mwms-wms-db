-- rdt_PACart_Confirm
execute rdt.rdtDropMsg 57451, 57500

execute rdt.rdtAddMsg 57451, 10, '57451^QTYAvlNotEnuf ', 'us_english', 807
execute rdt.rdtAddMsg 57452, 10, '57452^QTYAvlNotEnuf ', 'us_english', 807
execute rdt.rdtAddMsg 57453, 10, '57453^Offset error  ', 'us_english', 807
execute rdt.rdtAddMsg 57454, 10, '57454^SetupOvrFlwLOC', 'us_english', 807
