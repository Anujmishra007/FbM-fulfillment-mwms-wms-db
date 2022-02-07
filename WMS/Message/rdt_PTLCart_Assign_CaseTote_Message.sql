-- rdt_PTLCart_Assign_CaseTote
execute rdt.rdtDropMsg 59651, 59700

execute rdt.rdtAddMsg 59651, 10, '59651^Need CaseID   ', 'us_english', 808
execute rdt.rdtAddMsg 59652, 10, '59652^Bad CaseID    ', 'us_english', 808
execute rdt.rdtAddMsg 59653, 10, '59653^Order CANCEL  ', 'us_english', 808
execute rdt.rdtAddMsg 59654, 10, '59654^CaseIDAssigned', 'us_english', 808
execute rdt.rdtAddMsg 59655, 10, '59655^CaseNotInZone ', 'us_english', 808
execute rdt.rdtAddMsg 59656, 10, '59656^NoMorePosition', 'us_english', 808
execute rdt.rdtAddMsg 59657, 10, '59657^Need ToteID   ', 'us_english', 808
execute rdt.rdtAddMsg 59658, 10, '59658^Tote Assigned ', 'us_english', 808
execute rdt.rdtAddMsg 59659, 10, '59659^UPD Log fail  ', 'us_english', 808
execute rdt.rdtAddMsg 59660, 10, '59660^INS PTL Fail  ', 'us_english', 808
execute rdt.rdtAddMsg 59661, 10, '59661^CaseID used   ', 'us_english', 808

--wms18487
execute rdt.rdtAddMsg 59662, 10, '59662^PickingFinish  ', 'us_english', 808

SELECT * FROM rdt.rdtmsg(NOLOCK) WHERE message_id BETWEEN 59651 and 59700