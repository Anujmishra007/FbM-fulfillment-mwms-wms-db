-- rdt_ToteConsolidation_Confirm                                     
-- execute rdt.rdtDropMsg 71016 - 71065                  


execute rdt.rdtAddMsg '71016', 10, '71016^UpdDropIDFail',    'us_english'
execute rdt.rdtAddMsg '71017', 10, '71017^UpdPackDetFail',   'us_english'
execute rdt.rdtAddMsg '71018', 10, '71018^UpdDropIDDetFail', 'us_english'
execute rdt.rdtAddMsg '71019', 10, '71019^DelDropIDFail',    'us_english'
execute rdt.rdtAddMsg '71020', 10, '71020^InsDropIDFail',    'us_english'
execute rdt.rdtAddMsg '71021', 10, '71021^UpdDropIDFail',    'us_english'
execute rdt.rdtAddMsg '71022', 10, '71022^InsDropIDDetFail', 'us_english'
execute rdt.rdtAddMsg '71023', 10, '71023^UpdPackDetFail',   'us_english'
execute rdt.rdtAddMsg '71024', 10, '71024^UpdPackDetFail',   'us_english'
execute rdt.rdtAddMsg '71025', 10, '71025^InsPackDetFail',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 71016 and 71065