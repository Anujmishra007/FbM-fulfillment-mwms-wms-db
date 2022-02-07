--rdt_TM_PutawayFrom_SwapTask
execute rdt.rdtDropMsg 80101, 80150


execute rdt.rdtAddMsg 80101, 10, '80101^NoTaskOnThisID', 'us_english', 1797
execute rdt.rdtAddMsg 80102, 10, '80102^UpdTaskdetFail', 'us_english', 1797
execute rdt.rdtAddMsg 80103, 10, '80103^UpdTaskdetFail', 'us_english', 1797
execute rdt.rdtAddMsg 80104, 10, '80104^LCK:          ', 'us_english', 1797
