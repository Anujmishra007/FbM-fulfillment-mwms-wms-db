--rdt_593Print31
--execute rdt.rdtDropMsg 164401, 164450

execute rdt.rdtAddMsg 164401, 10, '64401^LabelPrnterReq', 'us_english', 593
execute rdt.rdtAddMsg 164402, 10, '64402^PaperPrnterReq', 'us_english', 593
execute rdt.rdtAddMsg 164403, 10, '64403GenLblSPNoFound', 'us_english', 593
execute rdt.rdtAddMsg 164404, 10, '64404^UCCorDropIDReq', 'us_english', 593
execute rdt.rdtAddMsg 164405, 10, '64405^InvalidValue  ', 'us_english', 593
execute rdt.rdtAddMsg 164406, 10, '64406^InsPackHdFail ', 'us_english', 593
execute rdt.rdtAddMsg 164407, 10, '64407^InsPickHdrFail', 'us_english', 593
execute rdt.rdtAddMsg 164408, 10, '64408InsPickInfoFail', 'us_english', 593
execute rdt.rdtAddMsg 164409, 10, '64409^InsPackHdFail ', 'us_english', 593
execute rdt.rdtAddMsg 164410, 10, '64410^NoLabelNoGen  ', 'us_english', 593
execute rdt.rdtAddMsg 164411, 10, '64411^UpdPickDetFail', 'us_english', 593
execute rdt.rdtAddMsg 164412, 10, '64412InsPackInfoFail', 'us_english', 593
execute rdt.rdtAddMsg 164413, 10, '64413^UpdPackDetFail', 'us_english', 593
execute rdt.rdtAddMsg 164414, 10, '64414^UpdPickDetFail', 'us_english', 593
execute rdt.rdtAddMsg 164415, 10, '64415^NoRecFound    ', 'us_english', 593
execute rdt.rdtAddMsg 164416, 10, '64416^UpdPackDetFail', 'us_english', 593
execute rdt.rdtAddMsg 164417, 10, '64417TemplateNoFound', 'us_english', 593
execute rdt.rdtAddMsg 164418, 10, '64418TemplateNoFound', 'us_english', 593
execute rdt.rdtAddMsg 164419, 10, '64419^nspg_GetKey   ', 'us_english', 593
execute rdt.rdtAddMsg 164420, 10, '64420^NoRecFound    ', 'us_english', 593

select * from rdt.rdtMsg (nolock) where message_id between 164401 and 164450