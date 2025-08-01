
-- rdt_521Decode04_Message
-- 243101 - 243150

execute rdt.rdtDropMsg 243101, 243150

execute rdt.rdtAddMsg 243101, 10, '243101 Invalid ID',      'us_english', 523, 0, '243101 Invalid ID(25 digit)'
execute rdt.rdtAddMsg 243102, 10, '243102 Invalid UCC',     'us_english', 523, 0, '243102 Invalid UCC(40 digit)'
execute rdt.rdtAddMsg 243103, 10, '243103^InvalidUCC,',     'us_english', 523, 0, '243103: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 243104, 10, '243104^InvalidUCC,',     'us_english', 523, 0, '243104: Invalid UCC barcode(SKU)'
execute rdt.rdtAddMsg 243105, 10, '243105^InvalidUCC,',     'us_english', 523, 0, '243105: Invalid UCC barcode(SKU Prefix)'
execute rdt.rdtAddMsg 243106, 10, '243106^InvalidUCC,',     'us_english', 523, 0, '243106: Invalid UCC barcode(SKU)'

select * from rdt.rdtmsg (nolock) where message_id between 243101 AND 243150

