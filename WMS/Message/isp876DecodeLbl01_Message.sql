-- isp876DecodeLBL01
execute rdt.rdtDropMsg 82101, 82150

execute rdt.rdtAddMsg 82101, 10, '82101^SKUNotFound', 'us_english'
execute rdt.rdtAddMsg 82102, 10, '82102^InvalidSKU', 'us_english'
execute rdt.rdtAddMsg 82103, 10, '82103^InvalidSerialNo', 'us_english'
execute rdt.rdtAddMsg 82104, 10, '82104^SKUNotAllowed', 'us_english'
execute rdt.rdtAddMsg 82105, 10, '82105^InvalidQRCode', 'us_english'
execute rdt.rdtAddMsg 82106, 10, '82106^SKUNotInOrder', 'us_english'
execute rdt.rdtAddMsg 82107, 10, '82107^InvalidSerialNo', 'us_english'

--WMS10007
execute rdt.rdtAddMsg 82108, 10, '82108^No Need ScanQR', 'us_english'
execute rdt.rdtAddMsg 82109, 10, '82109^ScanCntNoMatch', 'us_english'
execute rdt.rdtAddMsg 82110, 10, '82110^ScanQty<>Alloc', 'us_english'
execute rdt.rdtAddMsg 82111, 10, '82111^Need SKU',       'us_english'

