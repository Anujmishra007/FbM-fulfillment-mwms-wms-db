
-- rdt_840ExtValid01 
execute rdt.rdtDropMsg 57501 , 57550

execute rdt.rdtAddMsg 57501, 10, '57501^MOVE ORDER',     'us_english'
execute rdt.rdtAddMsg 57502, 10, '57502^COD ORDER',      'us_english'
execute rdt.rdtAddMsg 57503, 10, '57503^TIME SLOT ORD',  'us_english'
execute rdt.rdtAddMsg 57504, 10, '57504^> 1 CARTON',     'us_english'
execute rdt.rdtAddMsg 57505, 10, '57505^RELEASE # FAIL', 'us_english'
execute rdt.rdtAddMsg 57506, 10, '57506^GET TRK# FAIL',  'us_english'
execute rdt.rdtAddMsg 57507, 10, '57507^ASGN TRK# FAIL', 'us_english'
execute rdt.rdtAddMsg 57508, 10, '57508^ASGN TRK# FAIL', 'us_english'
execute rdt.rdtAddMsg 57509, 10, '57509^X FINISH PACK',  'us_english'
execute rdt.rdtAddMsg 57510, 10, '57510^SWAP TRK# FAIL', 'us_english'
execute rdt.rdtAddMsg 57511, 10, '57511^SWAP TRK# FAIL', 'us_english'

--WMS8270
execute rdt.rdtAddMsg 57512, 10, '57512^ORDER CANCEL,',  'us_english'
execute rdt.rdtAddMsg 57513, 10, '57513^HOSPITAL',       'us_english'

execute rdt.rdtAddMsg 57514, 10, 'ORDER HAS TRACKING #', 'us_english'
execute rdt.rdtAddMsg 57515, 10, 'CANNOT PROCEED',       'us_english'
execute rdt.rdtAddMsg 57516, 10, 'INVALID SOSTATUS',     'us_english'
execute rdt.rdtAddMsg 57517, 10, 'CANNOT PROCEED',       'us_english'

--WMS16580
execute rdt.rdtAddMsg 57518, 10, '57518^ONLY 1 CARTON',  'us_english'
