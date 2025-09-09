-- rdt_861DecodeSP01
--246151 - 246200


execute rdt.rdtDropMsg 246151, 246200

execute rdt.rdtAddMsg 246151, 10, '246151^InvalidUCC,',     'us_english', 861, 0, '246151: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 246152, 10, '246152^InvalidUCC,',     'us_english', 861, 0, '246152: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 246153, 10, '246153^InvalidUCC,',     'us_english', 861, 0, '246153: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 246154, 10, '246154^InvalidUCC,',     'us_english', 861, 0, '246154: Invalid UCC barcode(SKU)'

select * from rdt.rdtmsg (nolock) where message_id between 246151 and 246200