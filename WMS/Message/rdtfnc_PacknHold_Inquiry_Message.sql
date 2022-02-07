--rdtfnc_PacknHold_Inquiry
--execute rdt.rdtdropmsg 76801, 76850


execute rdt.rdtAddMsg '76801', 10, '76801^LOC NEEDED',      'us_english'
execute rdt.rdtAddMsg '76802', 10, '76802^LOC NOT EXISTS',  'us_english'
execute rdt.rdtAddMsg '76803', 10, '76803^DIFF FACILITY',   'us_english'
execute rdt.rdtAddMsg '76804', 10, '76804^NOT P&H LOC',     'us_english'
execute rdt.rdtAddMsg '76805', 10, '76805^LOC NO ID',       'us_english'
execute rdt.rdtAddMsg '76806', 10, '76806^NO MORE REC',     'us_english'


select * from rdt.rdtmsg (nolock) where message_id between 76801 and 76850 

