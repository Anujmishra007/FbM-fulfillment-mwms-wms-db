
-- rdt_840ExtUpd01 
execute rdt.rdtDropMsg 57651 , 57700

execute rdt.rdtAddMsg 57651, 10, '57651^UPD PGET FAIL',     'us_english'
execute rdt.rdtAddMsg 57652, 10, '57652^NoPaperPrinter',    'us_english'
execute rdt.rdtAddMsg 57653, 10, '57653^DWNOTSetup',        'us_english'
execute rdt.rdtAddMsg 57654, 10, '57654^TgetDB Not Set',    'us_english'
execute rdt.rdtAddMsg 57655, 10, '57655^NoLabelPrinter',    'us_english'
execute rdt.rdtAddMsg 57656, 10, '57656^DWNOTSetup',        'us_english'
execute rdt.rdtAddMsg 57657, 10, '57657^TgetDB Not Set',    'us_english'
execute rdt.rdtAddMsg 57658, 10, '57658^NoLabelPrinter',    'us_english'
execute rdt.rdtAddMsg 57659, 10, '57659^DWNOTSetup',        'us_english'
execute rdt.rdtAddMsg 57660, 10, '57660^TgetDB Not Set',    'us_english'

--WMS3352
execute rdt.rdtAddMsg 57661, 10, '57661^Assign Lbl Err',    'us_english'

-- WMS13919
execute rdt.rdtAddMsg 57662, 10, '57662^TriggerTL2 Err',    'us_english'
execute rdt.rdtAddMsg 57663, 10, 'Orders Short Pick !!',    'us_english'
execute rdt.rdtAddMsg 57664, 10, '57664^UpdTrackNo Err',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 57651 and 57700
