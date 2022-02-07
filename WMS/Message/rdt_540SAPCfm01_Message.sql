-- rdt_540SAPCfm01
exec rdt.rdtDropMsg 107451, 107500

execute rdt.rdtAddMsg 107451, 10, '07451^UPD PKDtl FAIL',   'us_english', 540
execute rdt.rdtAddMsg 107452, 10, '07452^UPD PKDtl FAIL',   'us_english', 540
execute rdt.rdtAddMsg 107453, 10, '07453^GETKEY FAIL',      'us_english', 540
execute rdt.rdtAddMsg 107454, 10, '07454^INS PKDtl FAIL',   'us_english', 540
execute rdt.rdtAddMsg 107455, 10, '07455^INS RefKeyFail',   'us_english', 540
execute rdt.rdtAddMsg 107456, 10, '07456^UPD PKDtl FAIL',   'us_english', 540
execute rdt.rdtAddMsg 107457, 10, '07457^UPD PKDtl FAIL',   'us_english', 540
execute rdt.rdtAddMsg 107458, 10, '07458^Offset FAIL',      'us_english', 540
execute rdt.rdtAddMsg 107459, 10, '07459^GETKEY FAIL',      'us_english', 540
execute rdt.rdtAddMsg 107460, 10, '07460^INSPackHdrFail',   'us_english', 540
execute rdt.rdtAddMsg 107461, 10, '07461^UPDPackDtlFail',   'us_english', 540
execute rdt.rdtAddMsg 107462, 10, '07462^INSPackDtlFail',   'us_english', 540
execute rdt.rdtAddMsg 107463, 10, '07463^INSPackDtlFail',   'us_english', 540
execute rdt.rdtAddMsg 107464, 10, '07464^SCAN IN FAIL',     'us_english', 540
execute rdt.rdtAddMsg 107465, 10, '07465^PackCfm FAIL',     'us_english', 540
execute rdt.rdtAddMsg 107466, 10, '07466^SCAN OUT FAIL',    'us_english', 540
execute rdt.rdtAddMsg 107467, 10, '07467^INS PINFO FAIL',   'us_english', 540
execute rdt.rdtAddMsg 107468, 10, '07468^OPEN CTN FAIL',    'us_english', 540
execute rdt.rdtAddMsg 107469, 10, '07469^OPEN CTN FAIL',    'us_english', 540

select * from rdt.rdtmsg (nolock) where message_id between 107451 and 107500


