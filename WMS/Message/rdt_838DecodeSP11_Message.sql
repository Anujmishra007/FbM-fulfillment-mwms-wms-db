-- rdt_838DecodeSP11
--246101 - 246150

execute rdt.rdtDropMsg 246101, 246150

execute rdt.rdtAddMsg 246101, 10, '246101^InvalidUCC,',     'us_english', 838, 0, '246101: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 246102, 10, '246102^InvalidUCC,',     'us_english', 838, 0, '246102: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 246103, 10, '246103^InvalidUCC,',     'us_english', 838, 0, '246103: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 246104, 10, '246104^InvalidUCC,',     'us_english', 838, 0, '246104: Invalid UCC barcode(SKU)'

select * from rdt.rdtmsg (nolock) where message_id between 246101 and 246150