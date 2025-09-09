
-- rdt_896DecodeSP01_Message
-- 246051 - 246100


execute rdt.rdtDropMsg 246051, 246100

execute rdt.rdtAddMsg 246051, 10, '246051^InvalidUCC,',     'us_english', 896, 0, '246051: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 246052, 10, '246052^InvalidUCC,',     'us_english', 896, 0, '246052: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 246053, 10, '246053^InvalidUCC,',     'us_english', 896, 0, '246053: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 246054, 10, '246054^InvalidUCC,',     'us_english', 896, 0, '246054: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 246055, 10, '246055^InvalidUCC,',     'us_english', 896, 0, '246055: Invalid UCC barcode'

select * from rdt.rdtmsg (nolock) where message_id between 246051 AND 246100

