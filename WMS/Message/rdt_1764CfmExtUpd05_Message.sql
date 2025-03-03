--rdt_1764CfmExtUpd05
--231251 - 231300

execute rdt.rdtdropmsg 231251, 231300

execute rdt.rdtAddMsg 231251, 10, '231251UPD PKDtl Fail', 'us_english', 1764, 0, '231251UPD PKDtl Fail'
execute rdt.rdtAddMsg 231252, 10, '231252GetKey Fail   ', 'us_english', 1764, 0, '231252GetKey Fail'
execute rdt.rdtAddMsg 231253, 10, '231253INS PKDtl Fail', 'us_english', 1764, 0, '231253INS PKDtl Fail'
execute rdt.rdtAddMsg 231254, 10, '231254UPD PKDtl Fail', 'us_english', 1764, 0, '231254UPD PKDtl Fail'
execute rdt.rdtAddMsg 231255, 10, '231255NotFullyOffset', 'us_english', 1764, 0, '231255NotFullyOffset'
execute rdt.rdtAddMsg 231256, 10, '231256UPD LLI Fail  ', 'us_english', 1764, 0, '231256UPD LLI Fail'
execute rdt.rdtAddMsg 231257, 10, '231257UPD PKDtl Fail', 'us_english', 1764, 0, '231257UPD PKDtl Fail'

select * from rdt.rdtmsg (nolock) where message_id between 231251 and 231300
