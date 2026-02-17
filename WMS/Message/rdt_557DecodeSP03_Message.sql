-- 250801 - 250850


execute rdt.rdtDropMsg 250801, 250850

execute rdt.rdtAddMsg 250801, 10, '250801^InvalidUCC,',     'us_english', 896, 0, '250801: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 250802, 10, '250802^InvalidUCC,',     'us_english', 896, 0, '250802: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 250803, 10, '250803^InvalidUCC,',     'us_english', 896, 0, '250803: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 250804, 10, '250804^InvalidUCC,',     'us_english', 896, 0, '250804: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 250805, 10, '250805^InvalidUCC,',     'us_english', 896, 0, '250805: Invalid UCC barcode'
execute rdt.rdtAddMsg 250806, 10, '250806^InvalidUCC,',     'us_english', 896, 0, '250806: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 250807, 10, '250807^InvalidUCC,',     'us_english', 896, 0, '250807: Invalid UCC barcode(SKU)'

select * from rdt.rdtmsg (nolock) where message_id between 250801 AND 250850

