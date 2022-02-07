-- rdtfnc_Replenish (range 63501 - 63550)

execute rdt.rdtAddMsg 63501, 10, '63501^LBL/UCC needed', 'us_english'
execute rdt.rdtAddMsg 63502, 10, '63502^Either LBL/UCC', 'us_english'
execute rdt.rdtAddMsg 63503, 10, '63503^Bad LABEL NO',   'us_english'
execute rdt.rdtAddMsg 63504, 10, '63504^Bad UCC NO',     'us_english'
execute rdt.rdtAddMsg 63505, 10, '63505^NoLoginPrinter', 'us_english'
execute rdt.rdtAddMsg 63506, 10, '63506^DWNotSetup',     'us_english'
execute rdt.rdtAddMsg 63507, 10, '63507^TgetDB Not Set', 'us_english'
execute rdt.rdtAddMsg 63508, 10, '63508^InsertPRTFail',  'us_english'
-- SOS119238
execute rdt.rdtAddMsg 63509, 10, '63509^Bad UCC Status', 'us_english'
execute rdt.rdtAddMsg 63510, 10, '63510^Bad UCC Status', 'us_english'

--execute rdt.rdtDropMsg 63501, 63550
