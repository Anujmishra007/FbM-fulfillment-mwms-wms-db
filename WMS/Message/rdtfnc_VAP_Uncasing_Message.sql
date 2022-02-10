-- rdtfnc_VAP_Uncasing
exec rdt.rdtDropMsg 58601 , 58650

-- Note: Pls reuse this error # 58605, 58608 & 58623

execute rdt.rdtAddMsg 58601, 10, '58601^WRKSTATION REQ',    'us_english', 1151
execute rdt.rdtAddMsg 58602, 10, '58602^INV WRKSTATION',    'us_english', 1151
execute rdt.rdtAddMsg 58604, 10, '58604^INV JOB ID',        'us_english', 1151
execute rdt.rdtAddMsg 58607, 10, '58607^INV WORKORDER#',    'us_english', 1151
execute rdt.rdtAddMsg 58610 ,10, '58610^NO TASK!!',         'us_english', 1151
execute rdt.rdtAddMsg 58611 ,10, '58611^NO MORE TASK!!',    'us_english', 1151
execute rdt.rdtAddMsg 58612 ,10, '58612^INVALID OPTION',    'us_english', 1151
execute rdt.rdtAddMsg 58613 ,10, '58613^PALLET ID REQ',     'us_english', 1151
execute rdt.rdtAddMsg 58614 ,10, '58614^INV PALLET ID',     'us_english', 1151
execute rdt.rdtAddMsg 58616 ,10, '58616^NotInStorerGrp',    'us_english', 1151
execute rdt.rdtAddMsg 58617 ,10, '58617^NotInStorerGrp',    'us_english', 1151
execute rdt.rdtAddMsg 58618 ,10, '58618^INV PALLET ID',     'us_english', 1151
execute rdt.rdtAddMsg 58619 ,10, '58619^NO RECORD',         'us_english', 1151
execute rdt.rdtAddMsg 58620 ,10, '58620^QTY REQUIRED',      'us_english', 1151
execute rdt.rdtAddMsg 58621 ,10, '58621^INVALID QTY',       'us_english', 1151
execute rdt.rdtAddMsg 58622 ,10, '58622^OVER UNCASING',     'us_english', 1151
execute rdt.rdtAddMsg 58624 ,10, '58624^PALLET ID REQ',     'us_english', 1151
execute rdt.rdtAddMsg 58625 ,10, '58625^PLT X UNCASED',     'us_english', 1151
execute rdt.rdtAddMsg 58626 ,10, '58626^END UNCASE ERR',    'us_english', 1151
execute rdt.rdtAddMsg 58627 ,10, '58627^NO MORE RECORD',    'us_english', 1151
execute rdt.rdtAddMsg 58628 ,10, '58628^QTY SP X SETUP',    'us_english', 1151
execute rdt.rdtAddMsg 58629 ,10, '58629^QTY SP X SETUP',    'us_english', 1151

-- Long Msg (Msg queue)
--58603 EITHER JOB ID OR WORKORDER#
--58606 INVALID JOB ID + WORKORDER#
--58609 INVALID JOB ID + WORKORDER#
--58615 ID LOCATED IN > 1 LOCATION