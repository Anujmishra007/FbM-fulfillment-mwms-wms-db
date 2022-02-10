--rdtfnc_VAP_StartProduction
execute rdt.rdtdropmsg 100551 , 100600

execute rdt.rdtAddMsg 100551, 10, '00551^WRKSTATION REQ',    'us_english', 1156
execute rdt.rdtAddMsg 100552, 10, '00552^INV WRKSTATION',    'us_english', 1156
execute rdt.rdtAddMsg 100553, 10, '00553^INV JOB ID',        'us_english', 1156
execute rdt.rdtAddMsg 100554, 10, '00554^WORKORDER# REQ',    'us_english', 1156
execute rdt.rdtAddMsg 100555, 10, '00555^INV WORKORDER#',    'us_english', 1156
execute rdt.rdtAddMsg 100556, 10, '00556^OPTION REQUIRE',    'us_english', 1156
execute rdt.rdtAddMsg 100557, 10, '00557^INVALID OPTION',    'us_english', 1156
execute rdt.rdtAddMsg 100558, 10, '00558^WORKORDER',         'us_english', 1156
execute rdt.rdtAddMsg 100559, 10, '00559^ACTIVE ALREADY',    'us_english', 1156
execute rdt.rdtAddMsg 100560, 10, '00560^WORKORDER',         'us_english', 1156
execute rdt.rdtAddMsg 100561, 10, '00561^COMPLETED',         'us_english', 1156
execute rdt.rdtAddMsg 100562, 10, '00562^INV NO Of USER',    'us_english', 1156
execute rdt.rdtAddMsg 100563, 10, '00563^INVALID QTY',       'us_english', 1156
execute rdt.rdtAddMsg 100564, 10, '00564^INVALID QTY',       'us_english', 1156
execute rdt.rdtAddMsg 100565, 10, '00565^INVALID QTY',       'us_english', 1156
execute rdt.rdtAddMsg 100566, 10, '00566^QTY > EXP QTY',     'us_english', 1156
execute rdt.rdtAddMsg 100567, 10, '00567^WORKORDER',         'us_english', 1156
execute rdt.rdtAddMsg 100568, 10, '00568^COMPLETED',         'us_english', 1156
execute rdt.rdtAddMsg 100569, 10, '00569^WORKORDER',         'us_english', 1156
execute rdt.rdtAddMsg 100570, 10, '00570^NOT ACTIVE',        'us_english', 1156
execute rdt.rdtAddMsg 100571, 10, '00571^WORKORDER',         'us_english', 1156
execute rdt.rdtAddMsg 100572, 10, '00572^ACTIVE ALREADY',    'us_english', 1156
execute rdt.rdtAddMsg 100573, 10, '00573^WORKORDER',         'us_english', 1156
execute rdt.rdtAddMsg 100574, 10, '00574^IS PAUSED',         'us_english', 1156
execute rdt.rdtAddMsg 100575, 10, '00575^WRK COMPLETED',     'us_english', 1156
execute rdt.rdtAddMsg 100576, 10, '00576^INVALID REASON',    'us_english', 1156

-- WMS-16844
execute rdt.rdtAddMsg 100577, 10, '00577^INV WORKORDER#',    'us_english', 1156

select * from rdt.rdtmsg (nolock) where message_id between 100551 and 100600
