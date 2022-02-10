
--rdtfnc_PTL_OrderAssignment
-- 79551 - 79600

exec rdt.rdtDropMsg 79551 , 79600
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 810

execute rdt.rdtAddMsg 79551 ,10, '79551^CartID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79552 ,10, '79552^Invalid CartID', 'us_english',@nFunc
execute rdt.rdtAddMsg 79553 ,10, '79553^OrderKey Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79554 ,10, '79554^Bad Order Status', 'us_english',@nFunc
execute rdt.rdtAddMsg 79555 ,10, '79555^PKSLIPNotPrinted', 'us_english',@nFunc
execute rdt.rdtAddMsg 79556 ,10, '79556^PS Scanned Out', 'us_english',@nFunc
execute rdt.rdtAddMsg 79557 ,10, '79557^Position Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79558 ,10, '79558^Invalid Position', 'us_english',@nFunc
execute rdt.rdtAddMsg 79559 ,10, '79559^Position Assigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79560 ,10, '79560^ToteID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79561 ,10, '79561^Tote Assigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79562 ,10, '79562^InsLightLocFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 79563 ,10, '79563^UpdLightLocFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 79564 ,10, '79564^OrderAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79565 ,10, '79565^Tote Assigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79566 ,10, '79566^OrderAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79567 ,10, '79567^Position Assigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79568 ,10, '79568^Position Assigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79569 ,10, '79569^SetupDone', 'us_english',@nFunc
execute rdt.rdtAddMsg 79570 ,10, '79570^OrderAssigned', 'us_english',@nFunc

-- SOS314306
execute rdt.rdtAddMsg 79571 ,10, '79571^PickZone req',      'us_english',  @nFunc 
execute rdt.rdtAddMsg 79572 ,10, '79572^Invalid PKZone',    'us_english',  @nFunc
execute rdt.rdtAddMsg 79573 ,10, '79573^OrdNotInPKZone',    'us_english',  @nFunc
execute rdt.rdtAddMsg 79574 ,10, '79574^Invalid PKZone',    'us_english',  @nFunc










