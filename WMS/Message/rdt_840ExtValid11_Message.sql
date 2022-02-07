--rdt_840ExtValid11
execute rdt.rdtDropMsg 164151 , 164200	

execute rdt.rdtAddMsg 164151, 10, '64151^Orders In Used',   'us_english', 840


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 164151 AND 164200	