
--rdtfnc_TPEX_ScanToPallet
-- 94351 - 94400

exec rdt.rdtDropMsg 94351 ,  94400
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 608

execute rdt.rdtAddMsg 94351 ,10, '94351^TruckID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 94352 ,10, '94352^ShipmentNo req', 'us_english',@nFunc
execute rdt.rdtAddMsg 94353 ,10, '94353^PalletID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 94354 ,10, '94354^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 94355 ,10, '94355^InsError', 'us_english',@nFunc
execute rdt.rdtAddMsg 94356 ,10, '94356^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 94357 ,10, '94357^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 94358 ,10, '94358^PalletIDScanned', 'us_english',@nFunc




