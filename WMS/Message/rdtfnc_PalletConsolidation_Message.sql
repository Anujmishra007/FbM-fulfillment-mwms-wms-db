
-- rdtfnc_PalletConsolidation 78351 - 78400

exec rdt.rdtDropMsg 78351 , 78400
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1720

execute rdt.rdtAddMsg 78351 ,10, '78351^PalletID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78352 ,10, '78352^PalletScanToTruck', 'us_english',@nFunc
execute rdt.rdtAddMsg 78353 ,10, '78353^PalletShipped', 'us_english',@nFunc
execute rdt.rdtAddMsg 78354 ,10, '78354^Option Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78355 ,10, '78355^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 78356 ,10, '78356^ToPallet Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78357 ,10, '78357^PalletScanToTruck', 'us_english',@nFunc
execute rdt.rdtAddMsg 78358 ,10, '78358^PalletShipped', 'us_english',@nFunc
execute rdt.rdtAddMsg 78359 ,10, '78359^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78360 ,10, '78360^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78361 ,10, '78361^ToteNo Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78362 ,10, '78362^ToteScanToTruck', 'us_english',@nFunc
execute rdt.rdtAddMsg 78363 ,10, '78363^ToteShipped', 'us_english',@nFunc
execute rdt.rdtAddMsg 78364 ,10, '78364^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78365 ,10, '78365^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78366 ,10, '78366^InvalidPalletID', 'us_english',@nFunc
execute rdt.rdtAddMsg 78367 ,10, '78367^InvalidPalletID', 'us_english',@nFunc
execute rdt.rdtAddMsg 78368 ,10, '78368^InvalidToteNo', 'us_english',@nFunc
execute rdt.rdtAddMsg 78369 ,10, '78369^PalletNotClose', 'us_english',@nFunc




