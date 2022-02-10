-- rdtfnc_VAP_Palletize
exec rdt.rdtDropMsg 58751 , 58800

execute rdt.rdtAddMsg 58751 ,10, '58751^PALLET ID REQ',     'us_english',1153
execute rdt.rdtAddMsg 58752 ,10, '58752^INV PALLET ID',     'us_english',1153
execute rdt.rdtAddMsg 58754, 10, '58754^INV JOB ID',        'us_english', 1150
execute rdt.rdtAddMsg 58757, 10, '58757^INV WORKORDER#',    'us_english', 1150

execute rdt.rdtAddMsg 58760 ,10, '58760^NO TASK !!',        'us_english',1153
execute rdt.rdtAddMsg 58761 ,10, '58761^NO MORE TASK !!',   'us_english',1153
execute rdt.rdtAddMsg 58762 ,10, '58762^INVALID OPTION',    'us_english',1153
execute rdt.rdtAddMsg 58763 ,10, '58763^INVALID QTY',       'us_english',1153
execute rdt.rdtAddMsg 58764 ,10, '58764^QTY > EXPECTED',    'us_english',1153
execute rdt.rdtAddMsg 58765 ,10, '58765^INV PRINT OPT',     'us_english',1153
execute rdt.rdtAddMsg 58766 ,10, '58766^INV END OPT',       'us_english',1153

execute rdt.rdtAddMsg 58767 ,10, '58767^PALLET ID REQ',     'us_english',1153
execute rdt.rdtAddMsg 58768 ,10, '58768^INV PALLET ID',     'us_english',1153
execute rdt.rdtAddMsg 58769 ,10, '58769^INV LOTTABLE04',    'us_english',1153
execute rdt.rdtAddMsg 58770 ,10, '58770^NO LBL PRINTER',    'us_english',1153
execute rdt.rdtAddMsg 58771 ,10, '58771^DW NOT SETUP',      'us_english',1153
execute rdt.rdtAddMsg 58772 ,10, '58772^TGETDB NOT SET',    'us_english',1153

-- SOS364044
execute rdt.rdtAddMsg 58775 ,10, '58773^INVALID QTY',       'us_english',1153
execute rdt.rdtAddMsg 58776 ,10, '58774^NO TASK !!',        'us_english',1153

-- Long Msg (Msg queue)
--58753 EITHER JOB ID OR WORKORDER#
--58755 JOB ID CONTAIN > 1 WORKORDER#. KEY IN BOTH VALUE TO PROCEED
--58756 INVALID JOB ID + WORKORDER#
--58758 WORKORDER# CONTAIN > 1 JOB ID. KEY IN BOTH VALUE TO PROCEED
--58759 INVALID JOB ID + WORKORDER#
--58773 NOT ALL INPUT COMPONENTS UNCASED
--58774 WORKORDER FINISHED PALLETIZE