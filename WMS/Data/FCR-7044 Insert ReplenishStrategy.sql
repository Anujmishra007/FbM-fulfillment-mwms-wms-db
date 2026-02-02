
IF NOT EXISTS(SELECT TOP 1 1 FROM REPLENISHSTRATEGY(NOLOCK) WHERE ReplenishStrategykey='Gen-FP+UCC')
   INSERT INTO REPLENISHSTRATEGY (ReplenishStrategykey, Descr, Type)
   VALUES('Gen-FP+UCC','Generate Replenishment - FP+UCC', 'StoredProc')

IF NOT EXISTS(SELECT TOP 1 1 FROM REPLENISHSTRATEGYDETAIL(NOLOCK) WHERE ReplenishStrategykey='Gen-FP+UCC')
   INSERT INTO REPLENISHSTRATEGYDETAIL (ReplenishStrategykey, ReplenishStrategyLineNumber, Descr, UOM, ReplenCode)
   VALUES('Gen-FP+UCC', '00001', 'Generate Replenishment - FP', '', 'isp_GenReplenishment @c_facility, @c_Zone02, @c_Zone03, @c_Zone04, @c_Zone05, @c_Zone06, @c_Zone07, @c_Zone08, @c_Zone09, @c_Zone10, @c_Zone11, @c_Zone12, ''FP+UCC'', @c_Storerkey')

IF     EXISTS(SELECT TOP 1 1 FROM CODELIST(NOLOCK) WHERE LISTNAME='STORERCFG') AND
   NOT EXISTS(sELECT TOP 1 1 FROM CODELKUP(NOLOCK) WHERE LISTNAME='STORERCFG' AND Code='CustomReplen_LocType')
   INSERT INTO CODELKUP (LISTNAME, Code, Description)
   VALUES('STORERCFG', 'CustomReplen_LocType', 'Relenishment Location Type (@OPTION5=''@c_BulkLocType=LocType1,LocType2,...'')')
