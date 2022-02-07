
--rdtfnc_TPEX_OrderToPallet
-- 94451 - 94500

exec rdt.rdtDropMsg 94451 , 94500
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1182

execute rdt.rdtAddMsg 94451 ,10, '94451^StorerKey Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 94452 ,10, '94452^InvalidStorerKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 94453 ,10, '94453^OrderKey Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 94454 ,10, '94454^Invalid OrderKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 94455 ,10, '94455^Invalid QTY', 'us_english',@nFunc
execute rdt.rdtAddMsg 94456 ,10, '94456^PalletKeyReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 94457 ,10, '94457^InvalidPalletKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 94458 ,10, '94458^DropLocReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 94459 ,10, '94459^InvalidDropLoc', 'us_english',@nFunc
execute rdt.rdtAddMsg 94460 ,10, '94460^PalletKeyExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 94461 ,10, '94461^MUTypeNotSetup', 'us_english',@nFunc
execute rdt.rdtAddMsg 94462 ,10, '94462^InsPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 94463 ,10, '94463^PalletTypeNoSetup', 'us_english',@nFunc
execute rdt.rdtAddMsg 94464 ,10, '94464^Invalid QTY', 'us_english',@nFunc