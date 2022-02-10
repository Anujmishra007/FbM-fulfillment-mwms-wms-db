--rdtfnc_ReplenTo_Inquiry
--execute rdt.rdtdropmsg 82801, 82850

execute rdt.rdtAddMsg 82801, 10, '82801^NEED LPN',       'us_english'
execute rdt.rdtAddMsg 82802, 10, '82802^INV LPN',        'us_english'
execute rdt.rdtAddMsg 82803, 10, '82803^RPF INCOMPLETE', 'us_english'
execute rdt.rdtAddMsg 82804, 10, '82804^RP1 NOT GEN',    'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 82801 AND 82850