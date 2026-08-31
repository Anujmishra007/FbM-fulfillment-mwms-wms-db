--rdt_523ExtValidSP23
--FCR-12892

execute rdt.rdtdropmsg 267351, 267400

execute rdt.rdtAddMsg 267351, 10, '267351 WrongPutZone',             'us_english', 523, 0, '267351 Wrong Putaway Zone'
execute rdt.rdtAddMsg 267352, 10, '267352 WrongProductDivision',     'us_english', 523, 0, '267352 Product Division mismatch'
execute rdt.rdtAddMsg 267353, 10, '267353 WrongPutawayZone',         'us_english', 523, 0, '267353 Location Category should be AEOMX_MEZ'
execute rdt.rdtAddMsg 267354, 10, '267354 NoMixSKU',                 'us_english', 523, 0, '267354 No Mix SKU allowed in the location'
execute rdt.rdtAddMsg 267355, 10, '267355 NoMixLottable02',          'us_english', 523, 0, '267355 No Mix Lottable02 allowed in the location'
execute rdt.rdtAddMsg 267356, 10, '267356 NoAvailableSpace',         'us_english', 523, 0, '267356 No enough available space in the location'

select * from rdt.rdtmsg with (nolock) where message_id between 267351 and 267400