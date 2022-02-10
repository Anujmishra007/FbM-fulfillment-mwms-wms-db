--rdt_PTLStation_Assign_OrderPos
execute rdt.rdtDropMsg 159501, 159550

execute rdt.rdtAddMsg 159501, 10, '159501BadOrderKey', 'us_english', 805
execute rdt.rdtAddMsg 159502, 10, '159502DiffStorer', 'us_english', 805
execute rdt.rdtAddMsg 159503, 10, '159503DiffFacility', 'us_english', 805
execute rdt.rdtAddMsg 159504, 10, '159504OrderCanc', 'us_english', 805
execute rdt.rdtAddMsg 159505, 10, '159505OrderNotAlloc', 'us_english', 805
execute rdt.rdtAddMsg 159506, 10, '159506OrderPicked', 'us_english', 805
execute rdt.rdtAddMsg 159507, 10, '159507OrderAssigned', 'us_english', 805
execute rdt.rdtAddMsg 159508, 10, '159508OrderNoTask', 'us_english', 805
execute rdt.rdtAddMsg 159509, 10, '159509NoMorePosition', 'us_english', 805
execute rdt.rdtAddMsg 159510, 10, '159510InsLogFail', 'us_english', 805
execute rdt.rdtAddMsg 159511, 10, '159511UpdDPFail', 'us_english', 805

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 159501 AND 159550
