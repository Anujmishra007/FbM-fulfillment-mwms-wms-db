--rdt_PTLCart_Confirm_Order_JW
execute rdt.rdtdropmsg 104251 , 104300

execute rdt.rdtAddMsg '104251', 10, '04251^UPD PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104252', 10, '04252^PKDtl changed',  'us_english', 819
execute rdt.rdtAddMsg '104253', 10, '04253^UPD PKDtl Fail', 'us_english', 819
execute rdt.rdtAddMsg '104254', 10, '04254^UPD PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104255', 10, '04255^UPD PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104256', 10, '04256^UPD PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104257', 10, '04257^INS PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104258', 10, '04258^UPD PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104259', 10, '04259^PKDtl changed',  'us_english', 819
execute rdt.rdtAddMsg '104260', 10, '04260^UPD PKDtl Fail', 'us_english', 819
execute rdt.rdtAddMsg '104261', 10, '04261^UPD PKDtl Fail', 'us_english', 819
execute rdt.rdtAddMsg '104262', 10, '04262^UPD PKDtl Fail', 'us_english', 819
execute rdt.rdtAddMsg '104263', 10, '04263^nspg_GetKey',    'us_english', 819
execute rdt.rdtAddMsg '104264', 10, '04264^INS RefKeyFail', 'us_english', 819
execute rdt.rdtAddMsg '104265', 10, '04265^UPD PKDtl Fail', 'us_english', 819
execute rdt.rdtAddMsg '104266', 10, '04266^UPD PKDtl Fail', 'us_english', 819
execute rdt.rdtAddMsg '104267', 10, '04267^UPD PKDtl Fail', 'us_english', 819
execute rdt.rdtAddMsg '104268', 10, '04268^UPD Log Fail',   'us_english', 819
execute rdt.rdtAddMsg '104269', 10, '04269^UPD PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104270', 10, '04270^PKDtl changed',  'us_english', 819
execute rdt.rdtAddMsg '104271', 10, '04271^UPD PKDtl Fail', 'us_english', 819
execute rdt.rdtAddMsg '104272', 10, '04272^InsDropID Fail', 'us_english', 819
execute rdt.rdtAddMsg '104273', 10, '04273^InsDropID Fail', 'us_english', 819
execute rdt.rdtAddMsg '104274', 10, '04274^UPD PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104275', 10, '04275^UPD PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104276', 10, '04276^INS PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104277', 10, '04277^UPD PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '104278', 10, '04278^UPD PKDtl Fail', 'us_english', 819


select * from rdt.rdtmsg (nolock) where message_id between 104251 AND 104300

