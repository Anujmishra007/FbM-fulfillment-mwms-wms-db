
-- rdtfnc_OpenTruck 78201 - 78250

exec rdt.rdtDropMsg 78201 , 78250
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1717

execute rdt.rdtAddMsg 78201 ,10, '78201^TruckID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78202 ,10, '78202^Truck Shipped', 'us_english',@nFunc
execute rdt.rdtAddMsg 78203 ,10, '78203^Option needed', 'us_english',@nFunc
execute rdt.rdtAddMsg 78204 ,10, '78204^Invalid Option', 'us_english',@nFunc
execute rdt.rdtAddMsg 78205 ,10, '78205^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78206 ,10, '78206^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78207 ,10, '78207^UpdContainerFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 78208 ,10, '78208^TruckAlreadyOpen', 'us_english',@nFunc
execute rdt.rdtAddMsg 78209 ,10, '78209^SealNo Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 78210 ,10, '78210^Invalid SealNo', 'us_english',@nFunc



