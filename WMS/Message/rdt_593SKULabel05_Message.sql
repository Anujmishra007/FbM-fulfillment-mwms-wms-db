-- rdt_593SKULabel05
exec rdt.rdtDropMsg 133451 , 133500

execute rdt.rdtAddMsg 133451, 10, '33451^Need PAZone',      'us_english', 593
execute rdt.rdtAddMsg 133452, 10, '33452^Need LOC',         'us_english', 593
execute rdt.rdtAddMsg 133453, 10, '33453^Invalid LOC',      'us_english', 593
execute rdt.rdtAddMsg 133454, 10, '33454^Diff facility',    'us_english', 593
execute rdt.rdtAddMsg 133455, 10, '33455^Need SKU/UPC',     'us_english', 593
execute rdt.rdtAddMsg 133456, 10, '33456^Invalid SKU',      'us_english', 593
execute rdt.rdtAddMsg 133457, 10, '33457^MultiSKUBarCod',   'us_english', 593
execute rdt.rdtAddMsg 133458, 10, '33458^SKU Is FTW',       'us_english', 593
execute rdt.rdtAddMsg 133459, 10, '33459^No Qty',           'us_english', 593
execute rdt.rdtAddMsg 133460, 10, '33460^Over Scan',        'us_english', 593
execute rdt.rdtAddMsg 133461, 10, '33461^No Suggest LOC',   'us_english', 593
execute rdt.rdtAddMsg 133462, 10, 'Suggest LOC:',           'us_english', 593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 133451 AND 133500