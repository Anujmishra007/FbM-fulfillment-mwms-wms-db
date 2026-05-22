--rdt_523ExtValidSP23
--FCR-12892

execute rdt.rdtdropmsg 267351, 267400

execute rdt.rdtAddMsg 267351, 10, '267351 WrongPutZone',             'us_english', 523, 0, '267351 Wrong Putaway Zone'
execute rdt.rdtAddMsg 267352, 10, '267352 WrongProductDivision',     'us_english', 523, 0, '267352 Product Division mismatch'
execute rdt.rdtAddMsg 267353, 10, '267353 WrongPutawayZone',         'us_english', 523, 0, '267353 Putaway Zone shoud be AEOMX_MEZ'

select * from rdt.rdtmsg with (nolock) where message_id between 267351 and 267400