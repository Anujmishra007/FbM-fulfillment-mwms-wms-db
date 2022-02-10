-- rdt_1809ConfirmSP01
-- execute rdt.rdtDropMsg 95551 - 95600

DECLARE @nFunc INT

SET @nFunc = 1809

execute rdt.rdtAddMsg 95551, 10, '95551^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95552, 10, '95552^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95553, 10, '95553^GetDetKeyFail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95554, 10, '95554^Ins PDtl Fail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95555, 10, '95555^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95556, 10, '95556^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95557, 10, '95557^SEE_SUPERVISOR', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95558, 10, '95558^SEE_SUPERVISOR', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95559, 10, '95559^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95560, 10, '95560^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95561, 10, '95561^GetDetKeyFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95562, 10, '95562^Ins PDtl Fail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95563, 10, '95563^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95564, 10, '95564^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95565, 10, '95565^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95566, 10, '95566^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95567, 10, '95567^GetDetKeyFail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95568, 10, '95568^Ins PDtl Fail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95569, 10, '95569^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95570, 10, '95570^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95571, 10, '95571^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95572, 10, '95572^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95573, 10, '95573^GetDetKeyFail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95574, 10, '95574^Ins PDtl Fail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95575, 10, '95575^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95576, 10, '95576^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 95577, 10, '95577^UpdPickDetFail', 'us_english'    ,@nFunc









select * from rdt.rdtmsg (nolock) where message_id between 95551 and 95600