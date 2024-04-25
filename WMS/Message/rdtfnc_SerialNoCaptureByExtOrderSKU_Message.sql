-- rdtfnc_SerialNoCaptureByExtOrderSKU 
execute rdt.rdtDropMsg 97551, 97600

execute rdt.rdtAddMsg 97551, 10, '97551 EXT ORDKEY REQ', 'us_english', 878
execute rdt.rdtAddMsg 97552, 10, '97552 INV EXT ORDKEY', 'us_english', 878
execute rdt.rdtAddMsg 97553, 10, '97553 BadOrderStatus', 'us_english', 878
execute rdt.rdtAddMsg 97554, 10, '97554 Need SKU/UPC  ', 'us_english', 878
execute rdt.rdtAddMsg 97555, 10, '97555 Invalid SKU   ', 'us_english', 878
execute rdt.rdtAddMsg 97556, 10, '97556 MultiSKUBarcod', 'us_english', 878
execute rdt.rdtAddMsg 97557, 10, '97557 Not SNO SKU   ', 'us_english', 878
execute rdt.rdtAddMsg 97558, 10, '97558 NO RECORD     ', 'us_english', 878
execute rdt.rdtAddMsg 97559, 10, '97559 Fully captured', 'us_english', 878
execute rdt.rdtAddMsg 97560, 10, '97560 Need SerialNo ', 'us_english', 878
execute rdt.rdtAddMsg 97561, 10, '97561 OptionRequired', 'us_english', 878
execute rdt.rdtAddMsg 97562, 10, '97562 Invalid Option', 'us_english', 878
