--rdt_1620ExtValid13
execute rdt.rdtdropmsg 209601 , 209650

execute rdt.rdtAddMsg 209601, 10, '209601OtherWavInTote', 'us_english', 1620

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 209601 AND 209650
