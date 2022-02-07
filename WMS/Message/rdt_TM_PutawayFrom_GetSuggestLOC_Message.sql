--rdt_TM_PutawayFrom_GetSuggestLOC
execute rdt.rdtDropMsg 80201, 80250

execute rdt.rdtAddMsg 80201, 10, '80201^NoSuitableLOC ', 'us_english', 1797
execute rdt.rdtAddMsg 80202, 10, '80202^UPDTaskDtlFail', 'us_english', 1797
