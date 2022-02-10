--rdt_840ExtUpd05
exec rdt.rdtDropMsg 116651 , 116700

execute rdt.rdtAddMsg 116651, 10, '16651^DEL INVOICE ER',   'us_english', 840
execute rdt.rdtAddMsg 116652, 10, '16652^DEL INVOICE ER',   'us_english', 840
execute rdt.rdtAddMsg 116653, 10, '16653^UPD PGET FAIL',    'us_english', 840
execute rdt.rdtAddMsg 116654, 10, '16654^PACKCFM FAIL',     'us_english', 840
execute rdt.rdtAddMsg 116655, 10, 'NO INVOICE.',            'us_english', 840
execute rdt.rdtAddMsg 116656, 10, 'PROCEED TO HOSPITAL',    'us_english', 840
execute rdt.rdtAddMsg 116657, 10, 'NO INVOICE DATA',        'us_english', 840
execute rdt.rdtAddMsg 116658, 10, 'TO PROCEED PRINTING',    'us_english', 840
execute rdt.rdtAddMsg 116659, 10, '16659^NO PRINTER',       'us_english', 840
execute rdt.rdtAddMsg 116660, 10, '16660^SETUP CODEKLP',    'us_english', 840
execute rdt.rdtAddMsg 116661, 10, '16661^ENCODE64 FAIL',    'us_english', 840
execute rdt.rdtAddMsg 116662, 10, '16662^PRINT FAIL',       'us_english', 840
execute rdt.rdtAddMsg 116663, 10, '16663^INS JOB FAIL',     'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 116651 and 116700



