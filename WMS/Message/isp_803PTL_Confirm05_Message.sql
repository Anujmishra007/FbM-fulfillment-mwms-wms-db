-- isp_803PTL_Confirm05
execute rdt.rdtDropMsg 171751, 171800

execute rdt.rdtAddMsg 171751, 10, '171751DEL Log Fail  ', 'us_english', 803
execute rdt.rdtAddMsg 171752, 10, '171752No order      ', 'us_english', 803
execute rdt.rdtAddMsg 171753, 10, '171753UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 171754, 10, '171754nspg_GetKey   ', 'us_english', 803
execute rdt.rdtAddMsg 171755, 10, '171755INS PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 171756, 10, '171756INS RefKeyFail', 'us_english', 803
execute rdt.rdtAddMsg 171757, 10, '171757UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 171758, 10, '171758UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 171759, 10, '171759UPD PKDtl Fail', 'us_english', 803
execute rdt.rdtAddMsg 171760, 10, '171760 INS PTL Fail ', 'us_english', 803

select * from rdt.rdtmsg (nolock) where message_id between 171751 and 171800
