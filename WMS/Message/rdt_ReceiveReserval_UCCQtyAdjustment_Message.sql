--rdt_ReceiveReserval_UCCQtyAdjustment
execute rdt.rdtDropMsg 191851 , 191900	

execute rdt.rdtAddMsg 191851, 10, '191851Upd UCCQty Err',     'us_english', 888
execute rdt.rdtAddMsg 191852, 10, '191852Upd RCVQty Err',     'us_english', 888
execute rdt.rdtAddMsg 191853, 10, '191853Upd LogQty Err',     'us_english', 888
execute rdt.rdtAddMsg 191854, 10, '191854Rev Rcvdt Fail',     'us_english', 888
execute rdt.rdtAddMsg 191855, 10, '191855 UPD UCC Fail ',     'us_english', 888
execute rdt.rdtAddMsg 191856, 10, '191856 Del Log Err  ',     'us_english', 888
execute rdt.rdtAddMsg 191857, 10, '191857UpdOpenQty Err',     'us_english', 888
execute rdt.rdtAddMsg 191858, 10, '191858No Stock Found',     'us_english', 888
execute rdt.rdtAddMsg 191856, 10, '191859No Stock Found',     'us_english', 888
execute rdt.rdtAddMsg 191860, 10, '191860No Stock Found',     'us_english', 888


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 191851 AND 191900	

