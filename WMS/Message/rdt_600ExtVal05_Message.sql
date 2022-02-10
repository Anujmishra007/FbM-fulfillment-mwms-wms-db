--rdt_600ExtVal05
execute rdt.rdtdropmsg 107701 , 107750
GO
DECLARE @nFunc INT

SET @nFunc = 600

execute rdt.rdtAddMsg 107701, 10, '07701^PalletQtyNotSetup',    'us_english',@nFunc
execute rdt.rdtAddMsg 107702, 10, '07702^Qty>APIQty',    'us_english',@nFunc 