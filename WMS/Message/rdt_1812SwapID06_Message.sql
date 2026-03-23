--rdt_1812SwapID06
--261851 - 261900


exec rdt.rdtDropMsg 261851 , 261900

execute rdt.rdtAddMsg 261851, 10, '261851^NewIDRequired',        'us_english', 1812, 0, '261851: NewID is required'
execute rdt.rdtAddMsg 261852, 10, '261852^BadTaskKey',           'us_english', 1812, 0, '261852: Task Not Found'
execute rdt.rdtAddMsg 261853, 10, '261853^InvalidID',            'us_english', 1812, 0, '261853: Invalid New ID'
execute rdt.rdtAddMsg 261854, 10, '261854^IDMultiRec',           'us_english', 1812, 0, '261854: New ID must have one lot'
execute rdt.rdtAddMsg 261855, 10, '261855^IDOnHold',             'us_english', 1812, 0, '261855: New ID is on hold'
execute rdt.rdtAddMsg 261856, 10, '261856^LocNotMatch',          'us_english', 1812, 0, '261856: Loc Not Match'
execute rdt.rdtAddMsg 261857, 10, '261857^SKUNotMatch',          'us_english', 1812, 0, '261857: SKU Not Match'
execute rdt.rdtAddMsg 261858, 10, '261858^QtyNotMatch',          'us_english', 1812, 0, '261858: QTY Not Match'
execute rdt.rdtAddMsg 261859, 10, '261859^IDTaskListEmpty',      'us_english', 1812, 0, '261859: ID task list is empty'
execute rdt.rdtAddMsg 261860, 10, '261860^TaskIsTaken',          'us_english', 1812, 0, '261860: Executed task exits on new ID'
execute rdt.rdtAddMsg 261861, 10, '261861^IDHasOpenTask',        'us_english', 1812, 0, '261861: NewID has open tasks'
execute rdt.rdtAddMsg 261862 ,10, '261862^IDLocked',             'us_english', 1812, 0, '261862: ID locked'
execute rdt.rdtAddMsg 261863 ,10, '261863^UpdTaskFail',          'us_english', 1812, 0, '261863: Update ID tasks fail'
execute rdt.rdtAddMsg 261864 ,10, '261864^UpdTaskFail',          'us_english', 1812, 0, '261864: Update ID tasks fail'
execute rdt.rdtAddMsg 261865 ,10, '261865^UpdTaskFail',          'us_english', 1812, 0, '261865: Update New ID tasks fail'
execute rdt.rdtAddMsg 261866 ,10, '261866^UpdTaskFail',          'us_english', 1812, 0, '261866: Update New ID tasks fail'
execute rdt.rdtAddMsg 261867 ,10, '261867^UnalloIDFail',         'us_english', 1812, 0, '261867: Unallocate ID pickdetail fail'
execute rdt.rdtAddMsg 261868 ,10, '261868^UnalloNewIDFail',      'us_english', 1812, 0, '261868: Unallocate NewID pickdetail fail'
execute rdt.rdtAddMsg 261869 ,10, '261869^RealloFail',           'us_english', 1812, 0, '261869: Reallocation fail'


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 261851 AND 261900

