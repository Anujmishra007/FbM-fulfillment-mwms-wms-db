

-- rdt_922DecodeSP01_Message
execute rdt.rdtDropMsg 227001, 227050

execute rdt.rdtAddMsg 227001, 10, '227001 Invalid UCC',     'us_english',  922, 0, '227001 Invalid UCC(40 digit)'
execute rdt.rdtAddMsg 227002, 10, '227002^InvalidUCC,',     'us_english',  922, 0, '227002: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 227003, 10, '227003^InvalidUCC,',     'us_english',  922, 0, '227003: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 227004, 10, '227004^InvalidUCC,',     'us_english',  922, 0, '227004: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 227005, 10, '227005^InvalidUCC,',     'us_english',  922, 0, '227005: Invalid UCC barcode(SKU)'



select * from rdt.rdtmsg (nolock) where message_id between 227001 AND 227050

