-- rdtfnc_OTMPalletConsolidation 95051 - 95100

exec rdt.rdtDropMsg 95051 ,  95100
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1722

execute rdt.rdtAddMsg 95051 ,10, '95051^PalletID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 95052 ,10, '95052^PltScanToTruck', 'us_english',@nFunc
execute rdt.rdtAddMsg 95053 ,10, '95053^PalletShipped', 'us_english',@nFunc
execute rdt.rdtAddMsg 95054 ,10, '95054^Option Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 95055 ,10, '95055^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 95056 ,10, '95056^ToPallet Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 95057 ,10, '95057^PltScanToTruck', 'us_english',@nFunc
execute rdt.rdtAddMsg 95058 ,10, '95058^PalletShipped', 'us_english',@nFunc
execute rdt.rdtAddMsg 95059 ,10, '95059^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95060 ,10, '95060^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95061 ,10, '95061^OrderNo Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 95062 ,10, '95062^ToteScanToTruck', 'us_english',@nFunc
execute rdt.rdtAddMsg 95063 ,10, '95063^ToteShipped', 'us_english',@nFunc
execute rdt.rdtAddMsg 95064 ,10, '95064^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95065 ,10, '95065^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95066 ,10, '95066^InvalidPalletID', 'us_english',@nFunc
execute rdt.rdtAddMsg 95067 ,10, '95067^InvalidPalletID', 'us_english',@nFunc
execute rdt.rdtAddMsg 95068 ,10, '95068^InvalidToteNo', 'us_english',@nFunc
execute rdt.rdtAddMsg 95069 ,10, '95069^PalletNotClose', 'us_english',@nFunc
execute rdt.rdtAddMsg 95070 ,10, '95070^DiffDropLoc', 'us_english',@nFunc
execute rdt.rdtAddMsg 95071 ,10, '95071^InvalidPLTStatus', 'us_english',@nFunc
execute rdt.rdtAddMsg 95072 ,10, '95072^InvalidOrderNo', 'us_english',@nFunc
execute rdt.rdtAddMsg 95073 ,10, '95073^PltClosedTruck', 'us_english',@nFunc
execute rdt.rdtAddMsg 95074 ,10, '95074^PltClosedTruck', 'us_english',@nFunc
execute rdt.rdtAddMsg 95075 ,10, '95075^SamePalletID', 'us_english',@nFunc
