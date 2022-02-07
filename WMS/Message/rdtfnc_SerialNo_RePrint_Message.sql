--rdtfnc_SerialNo_RePrint
execute rdt.rdtdropmsg 109701 , 109750
GO
DECLARE @nFunc INT

SET @nFunc = 1009

execute rdt.rdtAddMsg 109701, 10, '09701^WorkOrdeRNoReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 109702, 10, '09702^InvdWorkOrder',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109703, 10, '09703^SerialNoReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109704, 10, '09704^InvdWorkOrder',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109705, 10, '09705^InvdWorkOrder',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109706, 10, '09706^InvdWorkOrder',    'us_english',@nFunc 