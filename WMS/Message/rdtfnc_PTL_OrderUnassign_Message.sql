
--rdtfnc_PTL_OrderUnassign
-- 79651 - 79700

exec rdt.rdtDropMsg 79651 , 79700
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 812

execute rdt.rdtAddMsg 79651 ,10, '79651^CartID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79652 ,10, '79652^Invalid CartID', 'us_english',@nFunc
execute rdt.rdtAddMsg 79653 ,10, '79653^NoFieldScanned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79654 ,10, '79654^Bad Order Status', 'us_english',@nFunc
execute rdt.rdtAddMsg 79655 ,10, '79655^PKSLIPNotPrinted', 'us_english',@nFunc
execute rdt.rdtAddMsg 79656 ,10, '79656^PS Scanned Out', 'us_english',@nFunc
execute rdt.rdtAddMsg 79657 ,10, '79657^Invalid Position', 'us_english',@nFunc
execute rdt.rdtAddMsg 79658 ,10, '79658^NotExistInCart', 'us_english',@nFunc
execute rdt.rdtAddMsg 79659 ,10, '79659^NoOrderToUnAssign', 'us_english',@nFunc
execute rdt.rdtAddMsg 79660 ,10, '79660^InvalidOrderOnCart', 'us_english',@nFunc
execute rdt.rdtAddMsg 79661 ,10, '79661^PositionNotAssign', 'us_english',@nFunc

--SOS315448
execute rdt.rdtAddMsg 79662 ,10, '79662^PICKZONE REQ', 'us_english',@nFunc










