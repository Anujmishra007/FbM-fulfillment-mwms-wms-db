
-- rdtfnc_PalletReceiving 78301 - 78350

exec rdt.rdtDropMsg 78301 , 78350
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1719

execute rdt.rdtAddMsg 78301 ,10, '78301^TruckID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78302 ,10, '78302^Invalid TruckID', 'us_english',@nFunc
execute rdt.rdtAddMsg 78303 ,10, '78303^SealNo Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78304 ,10, '78304^TruckIDNotExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 78305 ,10, '78305^UpdContainerFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78306 ,10, '78306^PalletID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78307 ,10, '78307^Invalid PalletID', 'us_english',@nFunc
execute rdt.rdtAddMsg 78308 ,10, '78308^AllPalletReceived', 'us_english',@nFunc
execute rdt.rdtAddMsg 78309 ,10, '78309^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78310 ,10, '78310^UpdContainerDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78311 ,10, '78311^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78312 ,10, '78312^AllPalletReceived', 'us_english',@nFunc
execute rdt.rdtAddMsg 78313 ,10, '78313^ReceiveCompleted', 'us_english',@nFunc
execute rdt.rdtAddMsg 78314 ,10, '78314^TruckNotClosed', 'us_english',@nFunc
execute rdt.rdtAddMsg 78315 ,10, '78315^Invalid PalletID', 'us_english',@nFunc
execute rdt.rdtAddMsg 78316 ,10, '78316^Qty Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78317 ,10, '78317^Invalid Qty', 'us_english',@nFunc
execute rdt.rdtAddMsg 78318 ,10, '78318^ToteNo Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78319 ,10, '78319^Invalid Tote', 'us_english',@nFunc
execute rdt.rdtAddMsg 78320 ,10, '78320^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78321 ,10, '78321^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78322 ,10, '78322^UpdContainerFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78323 ,10, '78323^ReceiveCompleted', 'us_english',@nFunc
execute rdt.rdtAddMsg 78324 ,10, '78324^Option Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78325 ,10, '78325^Invalid Option', 'us_english',@nFunc
execute rdt.rdtAddMsg 78326 ,10, '78326^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78327 ,10, '78327^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78328 ,10, '78328^UpdContainerFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78329 ,10, '78329^ReceiveCompleted', 'us_english',@nFunc