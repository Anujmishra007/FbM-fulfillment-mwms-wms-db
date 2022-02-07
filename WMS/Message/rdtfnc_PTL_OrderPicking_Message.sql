
--rdtfnc_PTL_OrderPick
-- 79601 - 79650

exec rdt.rdtDropMsg 79601 , 79650
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 811

execute rdt.rdtAddMsg 79601 ,10, '79601^CartID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79602 ,10, '79602^CartNotAssign', 'us_english',@nFunc
execute rdt.rdtAddMsg 79603 ,10, '79603^SKU Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79604 ,10, '79604^Invalid SKU', 'us_english',@nFunc

execute rdt.rdtAddMsg 79605 ,10, '79605^Option Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79606 ,10, '79606^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 79607 ,10, '79607^PickNotComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 79608 ,10, '79608^Tote Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79609 ,10, '79609^InvalidTote', 'us_english',@nFunc
execute rdt.rdtAddMsg 79610 ,10, '79610^Tote Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79611 ,10, '79611^ToteAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79612 ,10, '79612^UpdDPLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 79613 ,10, '79613^InsLightLocFail', 'us_english',@nFunc

execute rdt.rdtAddMsg 79614 ,10, '79614^ReasonCode Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79615 ,10, '79615^Invalid Reason', 'us_english',@nFunc

execute rdt.rdtAddMsg 79616 ,10, '79616^UpdDPFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 79617 ,10, '79617^UpdDPLogFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 79618 ,10, '79618^ToteAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 79619 ,10, '79619^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 79620 ,10, '79620^Invalid SKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 79621 ,10, '79621^Invalid SKU', 'us_english',@nFunc

execute rdt.rdtAddMsg 79622 ,10, '79622^UpdDPFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 79623 ,10, '79623^UpdDPLogFailed', 'us_english',@nFunc

-- SOS303322
execute rdt.rdtAddMsg 79624 ,10, '79624^UPD PTLTR FAIL', 'us_english',  @nFunc
execute rdt.rdtAddMsg 79625 ,10, '79625^NO PICK TASK',   'us_english',  @nFunc
execute rdt.rdtAddMsg 79626 ,10, '79626^PICKZONE req',   'us_english',  @nFunc
execute rdt.rdtAddMsg 79627 ,10, '79627^INV PICKZONE',   'us_english',  @nFunc
execute rdt.rdtAddMsg 79628 ,10, '79628^CART X IN ZONE', 'us_english',  @nFunc
execute rdt.rdtAddMsg 79629 ,10, '79629^InvalidOption',  'us_english',  @nFunc
execute rdt.rdtAddMsg 79630 ,10, '79630^UPD PTLTR FAIL', 'us_english',  @nFunc
execute rdt.rdtAddMsg 79631 ,10, '79631^PickNotComplete','us_english',  @nFunc
execute rdt.rdtAddMsg 79632 ,10, '79632^UpdDPFailed',    'us_english',  @nFunc
execute rdt.rdtAddMsg 79633 ,10, '79633^UpdDPLogFailed', 'us_english',  @nFunc
execute rdt.rdtAddMsg 79634 ,10, '79634^UPD PTLTR FAIL', 'us_english',  @nFunc
















