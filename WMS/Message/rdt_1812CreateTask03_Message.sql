--rdt_1812CreateTask03
--240951 - 241000

execute rdt.rdtdropmsg 240951, 241000

execute rdt.rdtAddMsg 240951, 10, '240951^InvalidMarshalling',  'us_english', 1812, 0, '240951: Cannot Find a valid marshalling lane'
execute rdt.rdtAddMsg 240952, 10, '240952^GetKey Fail   ',      'us_english', 1812
execute rdt.rdtAddMsg 240953, 10, '240953^InvalidKittingLOC',   'us_english', 1812, 0, '240953: Cannot Find a valid Kitting LOC'
execute rdt.rdtAddMsg 240954, 10, '240954^GetKey Fail   ',      'us_english', 1812
execute rdt.rdtAddMsg 240955, 10, '240955^InvalidMarshalling',  'us_english', 1812, 0, '240955: Cannot Find a valid marshalling lane'
execute rdt.rdtAddMsg 240956, 10, '240956^GetKey Fail   ',      'us_english', 1812
execute rdt.rdtAddMsg 240957, 10, '240957^InvalidMarshalling',  'us_english', 1812, 0, '240957: Cannot Find a valid marshalling lane'
execute rdt.rdtAddMsg 240958, 10, '240958^GetKey Fail   ',      'us_english', 1812
execute rdt.rdtAddMsg 240959, 10, '240959^InvalidMarshalling',  'us_english', 1812, 0, '240959: Cannot Find a valid marshalling lane'
execute rdt.rdtAddMsg 240960, 10, '240960^GetKey Fail   ',      'us_english', 1812
execute rdt.rdtAddMsg 240961, 10, '240961^UpdPickDetail Fail',  'us_english', 1812, 0, '240961: Update PickDetail Fail'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 240951 AND 241000
