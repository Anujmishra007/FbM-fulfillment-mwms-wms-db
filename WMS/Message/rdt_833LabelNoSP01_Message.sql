--rdt_833LabelNoSP01
execute rdt.rdtdropmsg 137301, 137350	

execute rdt.rdtAddMsg 137301, 10, '37301^No UDF04',         'us_english', 833
execute rdt.rdtAddMsg 137302, 10, '37302^Gen Label Fail',   'us_english', 833
execute rdt.rdtAddMsg 137303, 10, '37303^Gen Label Fail',   'us_english', 833

select * from rdt.rdtmsg (nolock) where message_id between 137301 AND 137350	
