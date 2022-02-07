--rdt_840GenLabelNo02
exec rdt.rdtDropMsg 132101 , 132150

execute rdt.rdtAddMsg 132101, 10, '32101^Setup Codelkup',   'us_english', 840
execute rdt.rdtAddMsg 132102, 10, '32102^No GS1 Prefix',    'us_english', 840
execute rdt.rdtAddMsg 132103, 10, '32103^Getkey Fail',      'us_english', 840
execute rdt.rdtAddMsg 132104, 10, '32104^Getkey Fail',      'us_english', 840
execute rdt.rdtAddMsg 132105, 10, '32105^Gen SSCC Fail',    'us_english', 840
execute rdt.rdtAddMsg 132106, 10, '32106^Gen SSCC Fail',    'us_english', 840
execute rdt.rdtAddMsg 132107, 10, '32107^UPD RunNo Fail',   'us_english', 840



select * from rdt.rdtmsg (nolock) where message_id between 132101 and 132150



