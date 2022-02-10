--ispCycleCount_Wrapper
execute rdt.rdtDropMsg 126501 , 125650

execute rdt.rdtAddMsg 126501, 10, '26501^SProc NotSetup',   'us_english', 0
execute rdt.rdtAddMsg 126502, 10, '26502^Count Finalized',  'us_english', 0
execute rdt.rdtAddMsg 126503, 10, '26503^Count Finalized',  'us_english', 0
execute rdt.rdtAddMsg 126504, 10, '26504^Count Finalized',  'us_english', 0


select * from rdt.rdtmsg (nolock) where message_id between 125601 and 125650