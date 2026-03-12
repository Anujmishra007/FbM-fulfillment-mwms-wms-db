--rdt_1720ExtUpdSP02
--FCR-8808
EXECUTE rdt.rdtDropMsg 253451, 253500

EXECUTE rdt.rdtAddMsg 253451, 10, '253451^UpdPalletDetFail',      'us_english', 1720, 0, '253451 Update Pallet Detail Failed'
EXECUTE rdt.rdtAddMsg 253452, 10, '253452^DelPalletFail',         'us_english', 1720, 0, '253452 Delete Pallet Failed'
EXECUTE rdt.rdtAddMsg 253453, 10, '253453^UpdPalletDetFail',      'us_english', 1720, 0, '253453 Update Pallet Detail Failed'
EXECUTE rdt.rdtAddMsg 253454, 10, '253454^DelPalletFail',         'us_english', 1720, 0, '253454 Delete Pallet Failed'

--UWP-46879
EXECUTE rdt.rdtAddMsg 253455, 10, '253455^InvalidToPallet',       'us_english', 1720, 0, '253455 Invalid To Pallet'
EXECUTE rdt.rdtAddMsg 253456, 10, '253456^InvalidToPallet',       'us_english', 1720, 0, '253456 Invalid To Pallet'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 253451 AND 253500