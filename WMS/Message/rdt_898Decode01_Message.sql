-- rdt_855ExtUpd03
exec rdt.rdtDropMsg 226801, 226850

execute rdt.rdtAddMsg 226801, 10, '226801^Invalid ID(25 digit)', 'us_english',  898, 0, '226801: Invalid ID(25 digit)'
execute rdt.rdtAddMsg 226802, 10, '226802^Invalid UCC',          'us_english',  898, 0, '226802: Invalid UCC'
execute rdt.rdtAddMsg 226803, 10, '226803^InvalidUCC,',          'us_english',  898, 0, '226803: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 226804, 10, '226804^InvalidUCC,',          'us_english',  898, 0, '226804: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 226805, 10, '226805^InvalidUCC,',          'us_english',  898, 0, '226805: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 226806, 10, '226806^InvalidUCC,',          'us_english',  898, 0, '226806: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 226807, 10, '226807^InvalidUCC,',          'us_english',  898, 0, '226807: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 226808, 10, '226808^InvalidUCC,',          'us_english',  898, 0, '226808: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 226809, 10, '226809^Failed,', 'us_english'
execute rdt.rdtAddMsg 226810, 10, '226810^,', 'us_english',898,0,'No Receipt Line For Scanned UCC'
select * from rdt.rdtmsg (nolock) where message_id between 226801 and 226850
