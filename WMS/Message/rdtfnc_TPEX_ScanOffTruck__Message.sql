
--rdtfnc_TPEX_ScanOffTruck
-- 94501 - 94550

exec rdt.rdtDropMsg 94501 ,  94550
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1183

execute rdt.rdtAddMsg 94501 ,10, '94501^PalletID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 94502 ,10, '94502^PalletNotExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 94503 ,10, '94503^LOC req', 'us_english',@nFunc
execute rdt.rdtAddMsg 94504 ,10, '94504^LOC not Exist', 'us_english',@nFunc
execute rdt.rdtAddMsg 94505 ,10, '94505^Updated', 'us_english',@nFunc
execute rdt.rdtAddMsg 94506 ,10, '94506^Update Fail', 'us_english',@nFunc
execute rdt.rdtAddMsg 94507 ,10, '94507^UpdOTMFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 94508 ,10, '94508^PltOffScanned', 'us_english',@nFunc
execute rdt.rdtAddMsg 94509 ,10, '94509^TruckID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 94510 ,10, '94510^Invalid TruckID', 'us_english',@nFunc
execute rdt.rdtAddMsg 94511 ,10, '94511^UpdOTMTrackFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 94512 ,10, '94512^InvalidPallet', 'us_english',@nFunc
execute rdt.rdtAddMsg 94513 ,10, '94513^TruckRecordNotFound', 'us_english',@nFunc




