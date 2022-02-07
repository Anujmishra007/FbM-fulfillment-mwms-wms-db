--rdt_1650ExtValid01
rdt.rdtdropmsg 92901, 92950

execute rdt.rdtAddMsg 92901, 10, '92901^NO ORDER FOUND',      'us_english', 1650
execute rdt.rdtAddMsg 92902, 10, '92902^NO MBOL CREATE',      'us_english', 1650
execute rdt.rdtAddMsg 92903, 10, '92903^PARTIAL PICKED',      'us_english', 1650
execute rdt.rdtAddMsg 92904, 10, '92904^ORD NOT ALL PA',      'us_english', 1650
execute rdt.rdtAddMsg 92905, 10, '92905^PL HAS AVL QTY',      'us_english', 1650
execute rdt.rdtAddMsg 92906, 10, '92906^THERE ARE PALLETS',   'us_english', 1650
execute rdt.rdtAddMsg 92907, 10, '92907^NOT SCAN TO DOOR.',   'us_english', 1650
execute rdt.rdtAddMsg 92908, 10, '92908^CANNOT CLOSE.',       'us_english', 1650
execute rdt.rdtAddMsg 92909, 10, '92909^Invalid Door',        'us_english', 1650
execute rdt.rdtAddMsg 92910, 10, '92910^CANNOTSCAN2TRK',      'us_english', 1650
execute rdt.rdtAddMsg 92911, 10, '92911^PLT SCN 2 DOOR',      'us_english', 1650
execute rdt.rdtAddMsg 92912, 10, '92912^PLT NOT AT STG',      'us_english', 1650



select * from rdt.rdtmsg (nolock) where message_id between 92901 and 92950


