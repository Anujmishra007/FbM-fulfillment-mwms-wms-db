-- rdt_SerialNoCapture_Confirm
execute rdt.rdtDropMsg 63781, 63800

execute rdt.rdtAddMsg 63781, 10, '63781 GetKey Fail',    'us_english'
execute rdt.rdtAddMsg 63782, 10, '63782 InsSNOFail',     'us_english'
