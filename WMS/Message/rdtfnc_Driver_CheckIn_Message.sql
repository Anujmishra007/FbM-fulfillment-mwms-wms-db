-- rdtfnc_Driver_CheckIn
--execute rdt.rdtDropMsg 67941, 67965

execute rdt.rdtAddMsg 67941, 10, '67941^Container Req',   'us_english'
execute rdt.rdtAddMsg 67942, 10, '67942^CheckIn Done',  'us_english'
execute rdt.rdtAddMsg 67943, 10, '67943^Container Exists',  'us_english'
execute rdt.rdtAddMsg 67944, 10, '67944^Atleast1InputReq',  'us_english'
execute rdt.rdtAddMsg 67945, 10, '67945^OptionReq',  'us_english'
execute rdt.rdtAddMsg 67946, 10, '67946^InvalidOption',  'us_english'
execute rdt.rdtAddMsg 67947, 10, '67947^OptionReq',  'us_english'
execute rdt.rdtAddMsg 67948, 10, '67948^InvalidOption',  'us_english'
execute rdt.rdtAddMsg 67949, 10, '67949^CheckInDoneBefore',  'us_english'

--WMS-15680 (cc01)
execute rdt.rdtAddMsg 67950, 10, '67950^GenOTMLogFail ',  'us_english'
execute rdt.rdtAddMsg 67951, 10, '67951^GenOTMLogFail ',  'us_english'

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE message_id BETWEEN 67941 and  67965
