-- rdt_840ExtUpd23 
execute rdt.rdtDropMsg 193851 , 193900	

execute rdt.rdtAddMsg 193851, 10, '193851 NO PKSLIP    ',   'us_english', 840
execute rdt.rdtAddMsg 193852, 10, '193852 NO ORDERKEY  ',   'us_english', 840
execute rdt.rdtAddMsg 193853, 10, '193853 Upd OdHdr Err',   'us_english', 840
execute rdt.rdtAddMsg 193854, 10, '193854 Upd OdDtl Err',   'us_english', 840
execute rdt.rdtAddMsg 193855, 10, '193855 Upd LpDtl Err',   'us_english', 840
execute rdt.rdtAddMsg 193856, 10, '193856nspGetRightErr',   'us_english', 840
execute rdt.rdtAddMsg 193857, 10, '193857 GenTLog3 Fail',   'us_english', 840
execute rdt.rdtAddMsg 193858, 10, '193858Assign Lbl Err',   'us_english', 840
execute rdt.rdtAddMsg 193859, 10, '193859 UPD YTC3 Err ',   'us_english', 840
execute rdt.rdtAddMsg 193860, 10, '193860TriggerTL2 Err',   'us_english', 840
execute rdt.rdtAddMsg 193861, 10, '193861 UPD PGET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 193862, 10, '193862 DelTLog2 Err ',   'us_english', 840
execute rdt.rdtAddMsg 193863, 10, '193863 GenTLog2 Fail',   'us_english', 840
execute rdt.rdtAddMsg 193864, 10, '193864NoPaperPrinter',   'us_english', 840
execute rdt.rdtAddMsg 193865, 10, '193865 DWNOTSetup   ',   'us_english', 840
execute rdt.rdtAddMsg 193866, 10, '193866TgetDB Not Set',   'us_english', 840
execute rdt.rdtAddMsg 193867, 10, '193867 NoLblPrinter ',   'us_english', 840
execute rdt.rdtAddMsg 193868, 10, '193868 DWNOTSetup   ',   'us_english', 840
execute rdt.rdtAddMsg 193869, 10, '193869TgetDB Not Set',   'us_english', 840
execute rdt.rdtAddMsg 193870, 10, '193870 NoLblPrinter ',   'us_english', 840
execute rdt.rdtAddMsg 193871, 10, '193871 DWNOTSetup   ',   'us_english', 840
execute rdt.rdtAddMsg 193872, 10, '193872TgetDB Not Set',   'us_english', 840
execute rdt.rdtAddMsg 193873, 10, '193873Upd Track# Err',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 193851 AND 193900	
