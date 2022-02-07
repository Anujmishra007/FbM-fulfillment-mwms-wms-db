--rdt_838ExtVal07
rdt.rdtDropMsg 146851 , 146900

execute rdt.rdtAddMsg 146851, 10, '46851^Doctype <> N',     'us_english', 838
execute rdt.rdtAddMsg 146852, 10, '46852^MBOLKey Blank',    'us_english', 838

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 146851 AND 146900