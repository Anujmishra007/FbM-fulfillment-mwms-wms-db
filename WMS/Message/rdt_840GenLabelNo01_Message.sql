--rdt_840GenLabelNo01
exec rdt.rdtDropMsg 118551 , 118600

execute rdt.rdtAddMsg 118551, 10, '18551^Setup Codelkup',   'us_english', 840
execute rdt.rdtAddMsg 118552, 10, '18552^No GS1 Prefix',    'us_english', 840
execute rdt.rdtAddMsg 118553, 10, '18553^Getkey Fail',      'us_english', 840
execute rdt.rdtAddMsg 118554, 10, '18554^Gen SSCC Fail',    'us_english', 840
execute rdt.rdtAddMsg 118555, 10, '18555^Gen SSCC Fail',    'us_english', 840
execute rdt.rdtAddMsg 118556, 10, '18556^UPD RunNo Fail',   'us_english', 840



select * from rdt.rdtmsg (nolock) where message_id between 118551 and 118600



