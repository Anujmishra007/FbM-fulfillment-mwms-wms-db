-- rdtfnc_NMVPalletMove
exec rdt.rdtDropMsg 78401, 78450
 
execute rdt.rdtAddMsg 78401, 10, '78401^Need ID       ', 'us_english', 1721
execute rdt.rdtAddMsg 78402, 10, '78402^Invalid ID    ', 'us_english', 1721
execute rdt.rdtAddMsg 78403, 10, '78403^ID had shipped', 'us_english', 1721
execute rdt.rdtAddMsg 78404, 10, '78404^Need TO LOC   ', 'us_english', 1721
execute rdt.rdtAddMsg 78405, 10, '78405^Invalid LOC   ', 'us_english', 1721
execute rdt.rdtAddMsg 78406, 10, '78406^Diff facility ', 'us_english', 1721
execute rdt.rdtAddMsg 78407, 10, '78407^UPD TOLOC FAIL', 'us_english', 1721

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 78401 AND 78450
