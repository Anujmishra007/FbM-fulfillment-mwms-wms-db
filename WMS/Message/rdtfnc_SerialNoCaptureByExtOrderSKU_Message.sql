-- rdtfnc_SerialNoCaptureByExtOrderSKU 
execute rdt.rdtDropMsg 97551 , 97600

execute rdt.rdtAddMsg 97551, 10, '97551^EXT ORDKEY REQ', 'us_english', 878
execute rdt.rdtAddMsg 97552, 10, '97552^INV EXT ORDKEY', 'us_english', 878
execute rdt.rdtAddMsg 97553, 10, '97553^SKU REQUIRED',   'us_english', 878
execute rdt.rdtAddMsg 97554, 10, '97554^INVALID SKU',    'us_english', 878
execute rdt.rdtAddMsg 97555, 10, '97555^MULTIBARCODSKU', 'us_english', 878
execute rdt.rdtAddMsg 97556, 10, '97556^NO RECORD',      'us_english', 878
execute rdt.rdtAddMsg 97557, 10, '97557^EXP > ACT QTY',  'us_english', 878
execute rdt.rdtAddMsg 97558, 10, '97558^SERIAL NO REQ',  'us_english', 878
execute rdt.rdtAddMsg 97559, 10, '97559^DUPLICATE REC',  'us_english', 878
execute rdt.rdtAddMsg 97560, 10, '97560^GETKEY FAIL',    'us_english', 878
execute rdt.rdtAddMsg 97561, 10, '97561^INS REC FAIL',   'us_english', 878
execute rdt.rdtAddMsg 97562, 10, '97562^INV SERIAL NO',  'us_english', 878
