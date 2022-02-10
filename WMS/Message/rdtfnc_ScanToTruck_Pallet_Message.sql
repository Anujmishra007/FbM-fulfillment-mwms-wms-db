
--rdtfnc_ScanToTruck_Pallet
-- 78251 - 78300

exec rdt.rdtDropMsg 78251 , 78300
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1718

execute rdt.rdtAddMsg 78251 ,10, '78251^TruckID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78252 ,10, '78252^Invalid TruckID', 'us_english',@nFunc
execute rdt.rdtAddMsg 78253 ,10, '78253^TruckIDClosed', 'us_english',@nFunc
execute rdt.rdtAddMsg 78254 ,10, '78254^Option needed', 'us_english',@nFunc
execute rdt.rdtAddMsg 78255 ,10, '78255^Invalid Option', 'us_english',@nFunc
execute rdt.rdtAddMsg 78256 ,10, '78256^SealNo Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78257 ,10, '78257^UpdContainerFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78258 ,10, '78258^UpdContainerDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78259 ,10, '78259^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78260 ,10, '78260^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78261 ,10, '78261^Truck Closed', 'us_english',@nFunc
execute rdt.rdtAddMsg 78262 ,10, '78262^PalletID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78263 ,10, '78263^DelContDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78264 ,10, '78264^DelPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78265 ,10, '78265^DelPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78266 ,10, '78266^PalletID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78267 ,10, '78267^InsContainerFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78268 ,10, '78268^InsPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78269 ,10, '78269^Invalid PalletID', 'us_english',@nFunc
execute rdt.rdtAddMsg 78270 ,10, '78270^TruckIDNotMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 78271 ,10, '78271^InsContainerDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78272 ,10, '78272^TruckIDNotMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 78273 ,10, '78273^PalletScannedB4', 'us_english',@nFunc
execute rdt.rdtAddMsg 78274 ,10, '78274^InvalidPalletID', 'us_english',@nFunc
execute rdt.rdtAddMsg 78275 ,10, '78275^TruckNotExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 78276 ,10, '78276^InvalidContainerKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 78277 ,10, '78277^Option needed', 'us_english',@nFunc
execute rdt.rdtAddMsg 78278 ,10, '78278^Invalid Option', 'us_english',@nFunc







