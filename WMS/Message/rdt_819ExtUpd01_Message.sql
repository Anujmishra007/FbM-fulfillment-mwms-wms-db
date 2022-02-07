--rdt_819ExtUpd01
execute rdt.rdtdropmsg 104301 , 104350


execute rdt.rdtAddMsg '104301', 10, '04301^InsDropIDFail',  'us_english', 819
execute rdt.rdtAddMsg '104302', 10, '04302^InsDropIDFail',  'us_english', 819
execute rdt.rdtAddMsg '104303', 10, '04303^InsDropIDFail',  'us_english', 819
execute rdt.rdtAddMsg '104304', 10, '04304^InsDropIDFail',  'us_english', 819
execute rdt.rdtAddMsg '104305', 10, '04305^ResetToteFail',  'us_english', 819
execute rdt.rdtAddMsg '104306', 10, '04306^ResetToteFail',  'us_english', 819

select * from rdt.rdtmsg (nolock) where message_id between 104301 AND 104350

