--rdt_1720ExtUpdSP02
--FCR-8808
execute rdt.rdtDropMsg 253451, 253500

execute rdt.rdtAddMsg 253451, 10, '253451^UpdPalletDetFail',      'us_english', 1720, 0, '253451 Update Pallet Detail Failed'
execute rdt.rdtAddMsg 253452, 10, '253452^DelPalletFail',         'us_english', 1720, 0, '253452 Delete Pallet Failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 253451 AND 253500