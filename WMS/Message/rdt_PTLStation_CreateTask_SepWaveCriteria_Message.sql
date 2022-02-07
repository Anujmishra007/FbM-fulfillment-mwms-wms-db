--rdt_PTLStation_CreateTask_SepWaveCriteria
execute rdt.rdtdropmsg 157001 , 157050	

execute rdt.rdtAddMsg 157001, 10, '157001^AssignCartonID',  'us_english', 805
execute rdt.rdtAddMsg 157002, 10, '57002^No more task',     'us_english', 805
execute rdt.rdtAddMsg 157003, 10, '57003^INSPTLTranFail',   'us_english', 805
execute rdt.rdtAddMsg 157004, 10, '57004^No Task (PTL)',    'us_english', 805


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 157001 AND 157050	
