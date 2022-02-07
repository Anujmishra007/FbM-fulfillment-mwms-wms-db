

select * from rdt.rdtmsg (nolock) where message_id between '149001' and 149050

--rdt_TM_ClusterPick_ConfirmTask
exec rdt.rdtDropMsg 149001, 149050

execute rdt.rdtAddMsg 149001, 10, '49001^Pick Not Found',  'us_english', 610
execute rdt.rdtAddMsg 149002, 10, '49002^No PickSlip   ',  'us_english', 610
execute rdt.rdtAddMsg 149003, 10, '49003^UPD PKDtl Fail',  'us_english', 610
execute rdt.rdtAddMsg 149004, 10, '49004^UPD PKDtl Fail',  'us_english', 610
execute rdt.rdtAddMsg 149005, 10, '49005^UPD PKDtl Fail',  'us_english', 610
execute rdt.rdtAddMsg 149006, 10, '49006^nspg_GetKey   ',  'us_english', 610
execute rdt.rdtAddMsg 149007, 10, '49007^INS PKDtl Fail',  'us_english', 610
execute rdt.rdtAddMsg 149008, 10, '49008^INS RefKeyFail',  'us_english', 610
execute rdt.rdtAddMsg 149009, 10, '49009^UPD PKDtl Fail',  'us_english', 610
execute rdt.rdtAddMsg 149010, 10, '49010^UPD PKDtl Fail',  'us_english', 610
execute rdt.rdtAddMsg 149011, 10, '49011^UPD PKDtl Fail',  'us_english', 610
execute rdt.rdtAddMsg 149012, 10, '49012^UPD Task  Fail',  'us_english', 610
execute rdt.rdtAddMsg 149013, 10, '49013^PackCfm Fail  ',  'us_english', 610




