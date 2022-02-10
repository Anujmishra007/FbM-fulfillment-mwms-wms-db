--rdtfnc_SortationByTrackingID
rdt.rdtDropMsg 149351 , 149400

execute rdt.rdtAddMsg 149351, 10, '49351^Value req',        'us_english', 641
execute rdt.rdtAddMsg 149352, 10, '49352^Invalid Format',   'us_english', 641
execute rdt.rdtAddMsg 149353, 10, '49353^Pallet Closed',    'us_english', 641
execute rdt.rdtAddMsg 149354, 10, '49354^Need SKU',         'us_english', 641
execute rdt.rdtAddMsg 149355, 10, '49355^Invalid SKU',      'us_english', 641
execute rdt.rdtAddMsg 149356, 10, '49356^MultiBarcodSKU',   'us_english', 641
execute rdt.rdtAddMsg 149357, 10, '49357^Need Track ID',    'us_english', 641
execute rdt.rdtAddMsg 149358, 10, '49358^Invalid Format',   'us_english', 641
execute rdt.rdtAddMsg 149359, 10, '49359^TrackID Scanned',  'us_english', 641
execute rdt.rdtAddMsg 149360, 10, '49360^OptionRequired',   'us_english', 641
execute rdt.rdtAddMsg 149361, 10, '49361^Invalid Option',   'us_english', 641


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 149351 AND 149400