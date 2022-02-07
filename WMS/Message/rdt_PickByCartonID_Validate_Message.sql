-- rdt_PickByCartonID_Validate
execute rdt.rdtDropMsg 136351, 136400

execute rdt.rdtAddMsg 136351, 10, '136351CTNIDNotInWave', 'us_english', 831
execute rdt.rdtAddMsg 136352, 10, '136352No QTY To Pick', 'us_english', 831
execute rdt.rdtAddMsg 136353, 10, '136353No QTY To Pick', 'us_english', 831
execute rdt.rdtAddMsg 136354, 10, '136354ReplenNotDone ', 'us_english', 831
