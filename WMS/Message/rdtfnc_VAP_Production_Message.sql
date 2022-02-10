-- rdtfnc_VAP_Uncasing
exec rdt.rdtDropMsg 58701 , 58750

execute rdt.rdtAddMsg 58701 ,10, '58701^WRKSTATION REQ',       'us_english',1152
execute rdt.rdtAddMsg 58702 ,10, '58702^INVALID WORKSTATION',  'us_english',1152
execute rdt.rdtAddMsg 58704 ,10, '58704^INVALID JOBID',        'us_english',1152
execute rdt.rdtAddMsg 58707 ,10, '58707^INVALID WORKORDER',    'us_english',1152
execute rdt.rdtAddMsg 58710 ,10, '58710^JOB STARTED',          'us_english',1152
execute rdt.rdtAddMsg 58711 ,10, '58711^BEGIN PROD ERR',       'us_english',1152
execute rdt.rdtAddMsg 58712 ,10, '58712^INLOC REQ',            'us_english',1152
execute rdt.rdtAddMsg 58713 ,10, '58713^INVALID INLOC',        'us_english',1152
execute rdt.rdtAddMsg 58714 ,10, '58714^OUTLOC REQ',           'us_english',1152
execute rdt.rdtAddMsg 58715 ,10, '58715^INVALID OUTLOC',       'us_english',1152
execute rdt.rdtAddMsg 58716 ,10, '58716^END PROD ERR',         'us_english',1152

-- Long Msg (Msg queue)
--58703 EITHER JOB ID OR WORKORDER#
--58705 JOB ID CONTAIN > 1 WORKORDER#. KEY IN BOTH VALUE TO PROCEED
--58706 INVALID JOB ID + WORKORDER#
--58708 WORKORDER# CONTAIN > 1 JOB ID. KEY IN BOTH VALUE TO PROCEED
--58709 INVALID JOB ID + WORKORDER#