-- rdt_600RcvCfm08
exec rdt.rdtDropMsg 160901 , 160950

execute rdt.rdtAddMsg 160901, 10, '160901 nspGetRight', 'us_english', 600
execute rdt.rdtAddMsg 160902, 10, '160902 DiffRcvGroup', 'us_english', 600

SELECT TOP 100 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 160901 and 160950