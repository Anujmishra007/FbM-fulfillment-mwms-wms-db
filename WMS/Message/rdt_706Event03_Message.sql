
-- rdt_706Event03
exec rdt.rdtdropmsg 159101, 159150	

execute rdt.rdtAddMsg 159101, 10, '591011TrackingNoNeed', 'us_english', 706
execute rdt.rdtAddMsg 159102, 10, '59102NoOrder', 'us_english', 706
execute rdt.rdtAddMsg 159103, 10, '59103GreenOrder', 'us_english', 706
execute rdt.rdtAddMsg 159104, 10, '59104Overdue', 'us_english', 706
execute rdt.rdtAddMsg 159105, 10, '59105BP1 SKU', 'us_english', 706
execute rdt.rdtAddMsg 159106, 10, '59106BP2 SKU', 'us_english', 706
execute rdt.rdtAddMsg 159107, 10, '59107RFID SKU', 'us_english', 706
execute rdt.rdtAddMsg 159108, 10, '59108InvalidSKU', 'us_english', 706
execute rdt.rdtAddMsg 159109, 10, '59109InvalidFormat', 'us_english', 706
execute rdt.rdtAddMsg 159110, 10, '59110SKUNeed', 'us_english', 706

--WMS-16587
execute rdt.rdtAddMsg 159111, 10, '59111Green Order', 'us_english', 706
execute rdt.rdtAddMsg 159112, 10, '59112Overdue', 'us_english', 706
execute rdt.rdtAddMsg 159113, 10, '59113BP1 SKU', 'us_english', 706
execute rdt.rdtAddMsg 159114, 10, '59114BP2 SKU ', 'us_english', 706
execute rdt.rdtAddMsg 159115, 10, '59115RFID SKU', 'us_english', 706
execute rdt.rdtAddMsg 159116, 10, '59116N', 'us_english', 706
execute rdt.rdtAddMsg 159117, 10, '59117Multiple ASN', 'us_english', 706
execute rdt.rdtAddMsg 159118, 10, '59118Multiple ASN', 'us_english', 706
execute rdt.rdtAddMsg 159119, 10, '59119Green Order', 'us_english', 706
execute rdt.rdtAddMsg 159120, 10, '59120Overdue', 'us_english', 706

--WMS-17102
execute rdt.rdtAddMsg 159121, 10, '59121Outlet Order', 'us_english', 706

--wms-17799
execute rdt.rdtAddMsg 159122, 10, '159122KeySKU', 'us_english', 706
execute rdt.rdtAddMsg 159123, 10, '159123One-Box SKU', 'us_english', 706

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 159101 and 159150
