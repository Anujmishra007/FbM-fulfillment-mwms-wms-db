
--rdtfnc_TMS_ScanToPallet
-- 94351 - 94400

exec rdt.rdtDropMsg 108601 , 108650
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1187

execute rdt.rdtAddMsg 108601 ,10, '08601^TruckID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 108602 ,10, '08602^ShipmentNo req', 'us_english',@nFunc
execute rdt.rdtAddMsg 108603 ,10, '08603^ToWHS Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 108604 ,10, '08604^InvalidToWHS', 'us_english',@nFunc
execute rdt.rdtAddMsg 108605 ,10, '08605^GetKeyFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 108606 ,10, '08606^PalletKeyNotExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 108607 ,10, '08607^EitherInputReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 108608 ,10, '08608^PalletNotClosed', 'us_english',@nFunc
execute rdt.rdtAddMsg 108609 ,10, '08609^PalletIDScanned', 'us_english',@nFunc
execute rdt.rdtAddMsg 108610 ,10, '08610^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 108611 ,10, '08611^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 108612 ,10, '08612^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 108613 ,10, '08613^PrinterReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 108614 ,10, '08614^UpdPalletFail', 'us_english',@nFunc




