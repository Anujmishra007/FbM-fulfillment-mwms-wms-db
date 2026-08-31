--rdt_521ExtValid12
--FCR-12181
exec rdt.rdtDropMsg 267201 , 267250

execute rdt.rdtAddMsg 267201, 10, '267201^WrongPutZone',          'us_english', 521, 0, '267201 Wrong Putaway Zone'
execute rdt.rdtAddMsg 267202, 10, '267202^WrongPutZone',          'us_english', 521, 0, '267202 Wrong Putaway Zone'
execute rdt.rdtAddMsg 267203, 10, '267203 NoMixSKU',              'us_english', 521, 0, '267203 No Mix SKU allowed in the location'
execute rdt.rdtAddMsg 267204, 10, '267204 NoMixLottable02',       'us_english', 521, 0, '267204 No Mix Lottable02 allowed in the location'
execute rdt.rdtAddMsg 267205, 10, '267205 NoAvailableSpace',      'us_english', 521, 0, '267205 No enough available space in the location'
execute rdt.rdtAddMsg 267206, 10, '267206 MixLottable02',         'us_english', 521, 0, '267206 Multiple Lottable02 values found for the same UCC'
execute rdt.rdtAddMsg 267207, 10, '267207 InvLottable02',         'us_english', 521, 0, '267207 Lottable02 must be DAM or GOO for the UCC'
execute rdt.rdtAddMsg 267208, 10, '267208 MixSKU',                'us_english', 521, 0, '267208 Cannot mix SKU for GOO UCC'
execute rdt.rdtAddMsg 267209, 10, '267209 NoMixSKU',              'us_english', 521, 0, '267209 No Mix SKU allowed in the location'
execute rdt.rdtAddMsg 267210, 10, '267210 NoMixSKU',              'us_english', 521, 0, '267210 No Mix SKU allowed in the location'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 267201 AND 267250
