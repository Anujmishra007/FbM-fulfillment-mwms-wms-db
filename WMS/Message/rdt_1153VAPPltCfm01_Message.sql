-- rdt_1153VAPPltCfm01
exec rdt.rdtDropMsg 100501 , 100550

execute rdt.rdtAddMsg 100501 ,10, '00501^INS PALLET FAIL',   'us_english',1153
execute rdt.rdtAddMsg 100502 ,10, '00502^UPD PALLET FAIL',   'us_english',1153
execute rdt.rdtAddMsg 100504 ,10, '00504^UPD JOBDT FAIL',    'us_english',1153
execute rdt.rdtAddMsg 100505 ,10, '00505^UPD WOJOB FAIL',    'us_english',1153
execute rdt.rdtAddMsg 100506 ,10, '00506^UPD WJOPS FAIL',    'us_english',1153
execute rdt.rdtAddMsg 100507 ,10, '00507^UPD WJR FAIL',      'us_english',1153
execute rdt.rdtAddMsg 100508 ,10, '00508^INV BAL X ENUF',    'us_english',1153
execute rdt.rdtAddMsg 100509 ,10, '00509^WITHDRAW FAIL',     'us_english',1153
execute rdt.rdtAddMsg 100510 ,10, '00510^DEPOSIT FAIL',      'us_english',1153
execute rdt.rdtAddMsg 100511 ,10, '00511^END PALLET FAIL',   'us_english',1153
execute rdt.rdtAddMsg 100512 ,10, '00512^UPD WORI FAIL',     'us_english',1153
execute rdt.rdtAddMsg 100513 ,10, '00513^UPD WORO FAIL',     'us_english',1153
execute rdt.rdtAddMsg 100514 ,10, '00514^END PALLET FAIL',   'us_english',1153
execute rdt.rdtAddMsg 100515 ,10, '00515^UPD UNCASE FAIL',   'us_english',1153
execute rdt.rdtAddMsg 100516 ,10, '00516^GETCONFIG FAIL',    'us_english',1153
execute rdt.rdtAddMsg 100517 ,10, '00517^INS PLTLBL ERR',    'us_english',1153
execute rdt.rdtAddMsg 100518 ,10, '00518^DEPOSIT ERROR',     'us_english',1153
execute rdt.rdtAddMsg 100519 ,10, '00519^WITHDRAW ERROR',    'us_english',1153

-- Long Msg (Msg queue)
--00503 THE QTY UNCASED NOT ENOUGH TO DO PALLETIZING

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 100501 AND 100550