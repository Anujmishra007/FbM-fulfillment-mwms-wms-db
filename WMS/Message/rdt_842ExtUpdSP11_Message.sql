--rdt_842ExtUpdSP11
exec rdt.rdtDropMsg 177101 , 177150	
	
execute rdt.rdtAddMsg 177101, 10, '177101 Inv DropID   ', 'us_english', 842
execute rdt.rdtAddMsg 177102, 10, '177102 PickXComplete', 'us_english', 842
execute rdt.rdtAddMsg 177103, 10, '177103 UpdEcommFail ', 'us_english', 842
execute rdt.rdtAddMsg 177104, 10, '177104NoRecToProcess', 'us_english', 842
execute rdt.rdtAddMsg 177105, 10, '177105 SKuNotIntote ', 'us_english', 842
execute rdt.rdtAddMsg 177106, 10, '177106 Qty Exceeded ', 'us_english', 842
execute rdt.rdtAddMsg 177107, 10, '177107InsPickHdrFail', 'us_english', 842
execute rdt.rdtAddMsg 177108, 10, '177108UpdPickDetFail', 'us_english', 842
execute rdt.rdtAddMsg 177109, 10, '177109InsPickInfoErr', 'us_english', 842
execute rdt.rdtAddMsg 177110, 10, '177110CreatePHdrFail', 'us_english', 842
execute rdt.rdtAddMsg 177111, 10, '177111 NoLabelNoGen ', 'us_english', 842
execute rdt.rdtAddMsg 177112, 10, '177112 NoLabelNoGen ', 'us_english', 842
execute rdt.rdtAddMsg 177113, 10, '177113InsPackDetFail', 'us_english', 842
execute rdt.rdtAddMsg 177114, 10, '177114UpdPackDetFail', 'us_english', 842
execute rdt.rdtAddMsg 177115, 10, '177115 UpdEcommFail ', 'us_english', 842
execute rdt.rdtAddMsg 177116, 10, '177116UpdPickDetFull', 'us_english', 842
execute rdt.rdtAddMsg 177117, 10, '177117UpdPickDetFull', 'us_english', 842
execute rdt.rdtAddMsg 177118, 10, '177118 nspg_GetKeyEr', 'us_english', 842
execute rdt.rdtAddMsg 177119, 10, '177119INS PKDtl Fail', 'us_english', 842
execute rdt.rdtAddMsg 177120, 10, '177120UpdPickDtFaill', 'us_english', 842
execute rdt.rdtAddMsg 177121, 10, '177121 PackCfm Fail ', 'us_english', 842
execute rdt.rdtAddMsg 177122, 10, '177122 UpdEcommFail ', 'us_english', 842
execute rdt.rdtAddMsg 177123, 10, '177123 UpdDropIDFail', 'us_english', 842
execute rdt.rdtAddMsg 177124, 10, '177124 UpdEcommFail ', 'us_english', 842
execute rdt.rdtAddMsg 177125, 10, '177125 UpdDropIDFail', 'us_english', 842
execute rdt.rdtAddMsg 177126, 10, '177126 InsPackInfoEr', 'us_english', 842
execute rdt.rdtAddMsg 177127, 10, '177127 UpdEcommFail ', 'us_english', 842
execute rdt.rdtAddMsg 177128, 10, '177128 PackCfm Fail ', 'us_english', 842
execute rdt.rdtAddMsg 177129, 10, '177129 UpdEcommFail ', 'us_english', 842
execute rdt.rdtAddMsg 177130, 10, '177130 InsTL2Log Err', 'us_english', 842
execute rdt.rdtAddMsg 177131, 10, '177131 QCmdLog Err  ', 'us_english', 842
execute rdt.rdtAddMsg 177132, 10, '177132 InsTL2Log Err', 'us_english', 842
execute rdt.rdtAddMsg 177133, 10, '177133 QCmdLog Err  ', 'us_english', 842
execute rdt.rdtAddMsg 177134, 10, '177134 InvalidOption', 'us_english', 842
execute rdt.rdtAddMsg 177135, 10, '177135 InsEcommFail ', 'us_english', 842
execute rdt.rdtAddMsg 177136, 10, '177136 UpdEcommFail ', 'us_english', 842
execute rdt.rdtAddMsg 177137, 10, '177137 UpdEcommFail ', 'us_english', 842
execute rdt.rdtAddMsg 177138, 10, '177138 PickNotDone  ', 'us_english', 842
execute rdt.rdtAddMsg 177139, 10, '177139PickNotComplet', 'us_english', 842
execute rdt.rdtAddMsg 177140, 10, '177139NoRecToProcess', 'us_english', 842

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 177101 AND 177150	