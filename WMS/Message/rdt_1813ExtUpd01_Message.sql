
--rdt_1813ExtUpd01
-- 111001 , 111050

exec rdt.rdtDropMsg 111001 , 111050
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1813

execute rdt.rdtAddMsg 111001 ,10, '11001^InsPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 111002 ,10, '11002^DelPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 111003 ,10, '11003^DelPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 111004 ,10, '11004^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 111005 ,10, '11005^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 111006 ,10, '11006^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 111007 ,10, '11007^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 111008 ,10, '11008^UpdPalletDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 111009 ,10, '11009^UpdPalletFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 111010 ,10, '11010^InsPalletFail', 'us_english',@nFunc

--WMS-8638
execute rdt.rdtAddMsg 111011 ,10, '11011^DelContainFail', 'us_english',@nFunc