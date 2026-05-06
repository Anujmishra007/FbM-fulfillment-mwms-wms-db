-- rdt_646ExtPrint01
rdt.rdtDropMsg 180051 , 180060

execute rdt.rdtAddMsg 180051, 10, '180051^GroupKey Missing',      'us_english', 646
execute rdt.rdtAddMsg 180052, 10, '180052^NoLabelPrintForEcom orders',      'us_english', 646, 0,'180052^NoLabelPrintForEcomOrders'
execute rdt.rdtAddMsg 180053, 10, '180053^ ',      'us_english', 646, 0,'180053 NoLabelPrintFor C9 Orders'

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 180051 AND 180060	
