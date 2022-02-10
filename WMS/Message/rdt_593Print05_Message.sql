--rdt_593Print05
--execute rdt.rdtDropMsg 97801 - 97850

GO
DECLARE @nFunc INT

SET @nFunc = 593

execute rdt.rdtAddMsg 97801 ,10, '97801^LabelPrnterReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97802 ,10, '97802^UCCReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97803 ,10, '97803^UCCNotFound', 'us_english',@nFunc
execute rdt.rdtAddMsg 97804 ,10, '97804^InvalidSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 97805 ,10, '97805^MultiSKUBarCod', 'us_english',@nFunc
execute rdt.rdtAddMsg 97806 ,10, '97806^InvalidSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 97807 ,10, '97807^SKUNotInUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 97808 ,10, '97808^LabelNoReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97809 ,10, '97809^InvalidLabelNo', 'us_english',@nFunc
execute rdt.rdtAddMsg 97810 ,10, '97810^UpdPackDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 97811 ,10, '97811^EitherInputReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97812 ,10, '97812^PaperPrinterReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97813 ,10, '97813^IDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97814 ,10, '97814^IDNotExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 97815 ,10, '97815^Lot02NoMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 97816 ,10, '97816^NoOfCopyExceed', 'us_english',@nFunc
execute rdt.rdtAddMsg 97817 ,10, '97817^ReceiptKeyReq', 'us_english',@nFunc   --INC0801347