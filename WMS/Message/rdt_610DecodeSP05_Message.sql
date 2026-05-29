--250701 - 250750


execute rdt.rdtDropMsg 250701, 250750

execute rdt.rdtAddMsg 250701, 10, '250701^InvalidUCC,',     'us_english', 896, 0, '250701: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 250702, 10, '250702^InvalidUCC,',     'us_english', 896, 0, '250702: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 250703, 10, '250703^InvalidUCC,',     'us_english', 896, 0, '250703: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 250704, 10, '250704^InvalidUCC,',     'us_english', 896, 0, '250704: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 250705, 10, '250705^InvalidUCC,',     'us_english', 896, 0, '250705: Invalid UCC barcode'
execute rdt.rdtAddMsg 250706, 10, '250706^InvalidUCC,',     'us_english', 896, 0, '250706: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 250707, 10, '250707^InvalidUCC,',     'us_english', 896, 0, '250707: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 250708, 10, '250708^InvalidID,',      'us_english', 896, 0, '250708: Invalid Pallet ID'

select * from rdt.rdtmsg (nolock) where message_id between 250701 AND 250750

