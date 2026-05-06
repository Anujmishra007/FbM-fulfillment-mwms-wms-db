-- 250651 - 250700


execute rdt.rdtDropMsg 256051, 246100

execute rdt.rdtAddMsg 256051, 10, '256051^InvalidUCC,',     'us_english', 896, 0, '256051: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 256052, 10, '256052^InvalidUCC,',     'us_english', 896, 0, '256052: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 256053, 10, '256053^InvalidUCC,',     'us_english', 896, 0, '256053: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 256054, 10, '256054^InvalidUCC,',     'us_english', 896, 0, '256054: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 256055, 10, '256055^InvalidUCC,',     'us_english', 896, 0, '256055: Invalid UCC barcode'
execute rdt.rdtAddMsg 256056, 10, '256056^InvalidUCC,',     'us_english', 896, 0, '256056: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 256057, 10, '256057^InvalidUCC,',     'us_english', 896, 0, '256057: Invalid UCC barcode(SKU)'

select * from rdt.rdtmsg (nolock) where message_id between 256051 AND 256100

