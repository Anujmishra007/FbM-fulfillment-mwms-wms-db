--rdt_1764CfmExtUpd09
--FCR-12990

EXECUTE rdt.rdtdropmsg 270351, 270400

EXECUTE rdt.rdtAddMsg 270351, 10, '270351 HoldLocFail',           'us_english', 1764, 0, '270351 Hold loc fail'
EXECUTE rdt.rdtAddMsg 270352, 10, '270352 SubmitQCFail',          'us_english', 1764, 0, '270352 Submit QCommanderTask fail'
EXECUTE rdt.rdtAddMsg 270353, 10, '270353 ExecInvHoldFail',       'us_english', 1764, 0, '270353 Execute InvHold fail'
EXECUTE rdt.rdtAddMsg 270354, 10, '270354 DelShortFCPTaskFail',   'us_english', 1764, 0, '270354 Delete short FCP TaskDetails fail'
EXECUTE rdt.rdtAddMsg 270355, 10, '270355 UpdPkdFail',            'us_english', 1764, 0, '270355 Mark PickDetail as SHORT fail'
EXECUTE rdt.rdtAddMsg 270356, 10, '270356 NoQcommandConfig',      'us_english', 1764, 0, '270356 No reallocation QCommander Config'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id BETWEEN 270351 AND 270400