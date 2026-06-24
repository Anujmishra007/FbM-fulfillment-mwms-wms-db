
/****** Object:  StoredProcedure [dbo].[mspRLWAVARLA]    Script Date: 6/23/2026 4:14:24 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************************************/
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : ARLA Wave Release     UWP-59504                         */
/*                                                                           */
/* Called By: Report mspRLWAVARLA                 */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 01-04-2026   KMS043   1.0  Initial version created                        */
/*****************************************************************************/


CREATE OR ALTER       PROCEDURE [dbo].[mspRLWAVARLA]
      @c_Wavekey      NVARCHAR(10)
    , @b_Success      INT        OUTPUT
    , @n_Err          INT        OUTPUT
    , @c_Errmsg       NVARCHAR(250)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue INT,
           @n_starttcnt INT,         -- Holds the current transaction count
           @n_debug INT,
           @n_cnt INT

   SELECT @n_debug = @n_Err
   SELECT @n_starttcnt = @@TRANCOUNT, @n_Continue = 1, @b_Success = 0, @n_Err = 0, @c_Errmsg = '', @n_cnt = 0

   DECLARE
      @c_Storerkey          NVARCHAR(15)
    , @c_Facility           NVARCHAR(5)
    , @c_TaskType           NVARCHAR(10)
    , @c_SourceType         NVARCHAR(30)
    , @c_Priority           NVARCHAR(10)
    , @c_PickMethod         NVARCHAR(10)
    , @c_LinkTaskToPick_SQL NVARCHAR(4000)
    , @c_Sku                NVARCHAR(20)
    , @c_Lot                NVARCHAR(10)
    , @c_FromLoc            NVARCHAR(10)
    , @c_ID                 NVARCHAR(18)
    , @n_Qty                INT
    , @c_UOM                NVARCHAR(10)
    , @c_SourcePriority     NVARCHAR(10)
    , @c_WaveStatus         NVARCHAR(10) = ''
    , @c_TMReleaseFlag      NVARCHAR(1)  = ''
    , @c_ToLoc              NVARCHAR(10) = ''
    , @c_Orderkey           NVARCHAR(10) = ''
    , @n_UOMQty             INT
    , @c_UserKey            NVARCHAR(18) = 'REACHTRUCK'
    , @c_Message01          NVARCHAR(20) = ''
    , @c_Message02          NVARCHAR(20) = ''
    , @c_WStatus            NVARCHAR(20) = '';

   SET @c_SourceType = 'mspRLWAVARLA'
   
   -----Wave Validation-----
   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      SELECT @c_WaveStatus = W.[Status]
           , @c_TMReleaseFlag = W.TMReleaseFlag
           , @c_ToLoc = TRIM(ISNULL(W.UserDefine01, ''))
           , @c_Storerkey = O.StorerKey
           , @c_Facility = O.Facility
      FROM WAVE W WITH (NOLOCK)
      JOIN WAVEDETAIL WD WITH (NOLOCK) ON W.Wavekey = WD.Wavekey
      JOIN ORDERS O WITH (NOLOCK) ON WD.Orderkey = O.Orderkey
      WHERE W.Wavekey = @c_Wavekey

     IF  EXISTS ( SELECT 1 
                  FROM TASKDETAIL TD WITH (NOLOCK)
                  WHERE TD.Wavekey = @c_Wavekey
                  AND TD.Sourcetype = @c_SourceType
                  AND TD.Tasktype = 'FPK'  )
				  --AND TD.Tasktype = 'FPK' AND TD.Status>0 )
      AND @c_TMReleaseFlag <> 'N'                  
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83000
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Wave has been released. (mspRLWAVARLA)'
      END

  /*    IF @c_WaveStatus < '2'
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83005
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Wave is not fully allocated. (mspRLWAVARLA)'
      END*/

      IF ISNULL(@c_ToLoc, '') = ''
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83010
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': ToLoc (Wave.Userdefine01) not assigned. (mspRLWAVARLA)'
      END



	  --LOAD & SHIP REFERENCE CHECK & PICKSLIPNO GENERATION CHECK--
	  IF  EXISTS(SELECT  1 FROM ORDERS WITH (NOLOCK) WHERE USERDEFINE09=@c_Wavekey AND (LOADKEY IS  NULL OR LOADKEY =''))
	   BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83020
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + 'Load does not Exists ' + @c_Wavekey+ '. (mspRLWAVARLA)'
      END

	    IF  EXISTS(SELECT  1 FROM ORDERS WITH (NOLOCK) WHERE USERDEFINE09=@c_Wavekey AND( MBOLKEY IS  NULL OR MBOLKEY =''))
	   BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83025
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + 'Ship Reference does not Exists ' +@c_Wavekey + '. (mspRLWAVARLA)'
      END

	   IF  EXISTS(SELECT  1 FROM PICKDETAIL PD WITH (NOLOCK) JOIN ORDERS O WITH (NOLOCK)  ON O.ORDERKEY=PD.ORDERKEY AND TRY_CAST(PD.UOM AS INT)=6 WHERE O.USERDEFINE09=@c_Wavekey AND (PD.PICKSLIPNO IS  NULL OR PD.PICKSLIPNO =''))
	   BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83030
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + 'Pick Slip does not Exists ' +@c_Wavekey+ '. (mspRLWAVARLA)'
      END
	  --END  OF LOAD & SHIP REFERENCE CHECK & PICKSLIPNO GENERATION CHECK--
      IF NOT EXISTS ( SELECT 1
                      FROM LOC L WITH (NOLOCK)
                      WHERE L.Facility = @c_Facility
                      AND L.Loc = @c_ToLoc )
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 83015
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) + ': Invalid ToLoc: ' + @c_ToLoc + '. (mspRLWAVARLA)'
      END
   END

   IF @n_debug = 0
   BEGIN
      WHILE @@TRANCOUNT > 0
         COMMIT TRAN

      IF @@TRANCOUNT = 0
         BEGIN TRAN
   END
   
   --Create pickdetail Work in progress temporary table
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      CREATE TABLE #PickDetail_WIP(
         [PickDetailKey] [nvarchar](18) NOT NULL PRIMARY KEY,
         [CaseID] [nvarchar](20) NOT NULL DEFAULT (' '),
         [PickHeaderKey] [nvarchar](18) NOT NULL,
         [OrderKey] [nvarchar](10) NOT NULL,
         [OrderLineNumber] [nvarchar](5) NOT NULL,
         [Lot] [nvarchar](10) NOT NULL,
         [Storerkey] [nvarchar](15) NOT NULL,
         [Sku] [nvarchar](20) NOT NULL,
         [AltSku] [nvarchar](20) NOT NULL DEFAULT (' '),
         [UOM] [nvarchar](10) NOT NULL DEFAULT (' '),
         [UOMQty] [int] NOT NULL DEFAULT ((0)),
         [Qty] [int] NOT NULL DEFAULT ((0)),
         [QtyMoved] [int] NOT NULL DEFAULT ((0)),
         [Status] [nvarchar](10) NOT NULL DEFAULT ('0'),
         [DropID] [nvarchar](20) NOT NULL DEFAULT (''),
         [Loc] [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN'),
         [ID] [nvarchar](18) NOT NULL DEFAULT (' '),
         [PackKey] [nvarchar](10) NULL DEFAULT (' '),
         [UpdateSource] [nvarchar](10) NULL DEFAULT ('0'),
         [CartonGroup] [nvarchar](10) NULL,
         [CartonType] [nvarchar](10) NULL,
         [ToLoc] [nvarchar](10) NULL  DEFAULT (' '),
         [DoReplenish] [nvarchar](1) NULL DEFAULT ('N'),
         [ReplenishZone] [nvarchar](10) NULL DEFAULT (' '),
         [DoCartonize] [nvarchar](1) NULL DEFAULT ('N'),
         [PickMethod] [nvarchar](1) NOT NULL DEFAULT (' '),
         [WaveKey] [nvarchar](10) NOT NULL DEFAULT (' '),
         [EffectiveDate] [datetime] NOT NULL DEFAULT (getdate()),
         [AddDate] [datetime] NOT NULL DEFAULT (getdate()),
         [AddWho] [nvarchar](128) NOT NULL DEFAULT (suser_sname()),
         [EditDate] [datetime] NOT NULL DEFAULT (getdate()),
         [EditWho] [nvarchar](128) NOT NULL DEFAULT (suser_sname()),
         [TrafficCop] [nvarchar](1) NULL,
         [ArchiveCop] [nvarchar](1) NULL,
         [OptimizeCop] [nvarchar](1) NULL,
         [ShipFlag] [nvarchar](1) NULL DEFAULT ('0'),
         [PickSlipNo] [nvarchar](10) NULL,
         [TaskDetailKey] [nvarchar](10) NULL,
         [TaskManagerReasonKey] [nvarchar](10) NULL,
         [Notes] [nvarchar](4000) NULL,
         [MoveRefKey] [nvarchar](10) NULL DEFAULT (''),
         [WIP_Refno] [nvarchar](30) NULL DEFAULT (''),
         [Channel_ID] [bigint] NULL DEFAULT ((0)))

      CREATE INDEX PDWIP_Pickdetailkey ON #PickDetail_WIP (Pickdetailkey)
      CREATE INDEX PDWIP_SKU ON #PickDetail_WIP (Storerkey, Sku)
      CREATE INDEX PDWIP_UOM ON #PickDetail_WIP (UOM)
      CREATE INDEX PDWIP_LLI ON #PickDetail_WIP (Lot, Loc, ID)
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
CREATE TABLE #CODELKUPS
(
      LISTNAME    NVARCHAR(10)   NOT NULL
    , Code        NVARCHAR(30)   NOT NULL
    , Description NVARCHAR(250)  NULL
    , Short       NVARCHAR(10)   NULL
    , Long        NVARCHAR(250)  NULL
    , Notes       NVARCHAR(4000) NULL
    , Storerkey   NVARCHAR(15)   NOT NULL DEFAULT (' ')
    , code2       NVARCHAR(30)   NOT NULL DEFAULT ('')
);

CREATE NONCLUSTERED INDEX IX_CODELKUPS_STORERKEY ON #CODELKUPS (Storerkey, LISTNAME, Short, Description)


CREATE NONCLUSTERED INDEX IX_CODELKUPS_SHORT ON #CODELKUPS (Short, LISTNAME)


INSERT INTO #CODELKUPS
SELECT LISTNAME,CODE,DESCRIPTION,SHORT,LONG,NOTES,STORERKEY,CODE2
FROM CODELKUP WITH (NOLOCK)
WHERE LISTNAME IN ('ARLAPALTYP','ARLAUSR') AND STORERKEY=@c_Storerkey;

END 

   --Initialize Pickdetail work in progress staging table
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      EXEC isp_CreatePickdetail_WIP
           @c_Loadkey               = ''
          ,@c_Wavekey               = @c_Wavekey
          ,@c_WIP_RefNo             = @c_SourceType
          ,@c_PickCondition_SQL     = ''
          ,@c_Action                = 'I'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
          ,@c_RemoveTaskdetailkey   = 'Y'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
          ,@b_Success               = @b_Success OUTPUT
          ,@n_Err                   = @n_Err     OUTPUT
          ,@c_Errmsg                = @c_Errmsg  OUTPUT

       IF @b_Success <> 1
       BEGIN
          SET @n_Continue = 3
       END
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      DECLARE CUR_ID CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    /*  SELECT PD.Storerkey, PD.Sku, MAX(PD.Lot) AS Lot, PD.Loc, PD.ID, SUM(PD.Qty) AS Qty
           , PD.UOM, PD.OrderKey
      FROM #PICKDETAIL_WIP PD
      JOIN LOC L (NOLOCK) ON L.Loc = PD.Loc
      WHERE PD.Wavekey = @c_Wavekey
      AND PD.[Status] = '0'
      AND PD.ID <> '' AND PD.ID IS NOT NULL
      AND PD.WIP_RefNo = @c_SourceType
	  AND PD.UOM=1
      GROUP BY PD.Storerkey, PD.Sku, PD.Loc, PD.ID, PD.UOM, L.LogicalLocation, PD.OrderKey
      ORDER BY L.LogicalLocation, PD.Loc*/
	  SELECT PD.Storerkey, PD.Sku, MAX(PD.Lot) AS Lot, PD.Loc, PD.ID, SUM(PD.Qty) AS Qty
           , PD.UOM, PD.OrderKey,

		/*  CASE WHEN ((S.ITEMCLASS='Extra Chil') OR(O.Type='RUSH')) THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN 'AGV'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN 'AGV'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'REACHTRUCK' ELSE 'REACHTRUCK' END AS '@c_UserKey',

		    CASE WHEN ((S.ITEMCLASS='Extra Chil') OR(O.Type='RUSH')) THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN 'AGV'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN 'AGV'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'REACHTRUCK' ELSE 'MANUAL' END AS '@c_Message01',

		    CASE WHEN ((S.ITEMCLASS='Extra Chil') OR(O.Type='RUSH')) THEN ''
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN 'CUSTOMS'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'CUSTOMS'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN 'NEW'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN '' ELSE 'NEW' END AS 'c_Message02',*/

		    /*CASE WHEN ((S.ITEMCLASS='Extra Chil') OR(O.Type='RUSH')) THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN (SELECT LONG FROM CODELKUP WHERE STORERKEY='ARLA' AND LISTNAME='ARLAUSR' AND SHORT='1')
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN (SELECT LONG FROM CODELKUP WHERE STORERKEY='ARLA' AND LISTNAME='ARLAUSR' AND SHORT='1')
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'REACHTRUCK' ELSE 'REACHTRUCK' END AS '@c_UserKey',

		    CASE WHEN ((S.ITEMCLASS='Extra Chil') OR(O.Type='RUSH')) THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN (SELECT LONG FROM CODELKUP WHERE STORERKEY='ARLA' AND LISTNAME='ARLAUSR' AND SHORT='1')
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN (SELECT LONG FROM CODELKUP WHERE STORERKEY='ARLA' AND LISTNAME='ARLAUSR' AND SHORT='1')
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'REACHTRUCK' ELSE 'MANUAL' END AS '@c_Message01',

		    CASE WHEN ((S.ITEMCLASS='Extra Chil') OR(O.Type='RUSH')) THEN ''
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN 'CUSTOMS'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN 'CUSTOMS'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08='4600125') THEN 'NEW'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08<>'4600125') THEN '' ELSE 'NEW' END AS 'c_Message02',
		    CASE WHEN (O.TYPE='CUSTOMS') THEN 'S' ELSE '0' END AS '@c_WStatus'*/
		   CASE WHEN ((S.ITEMCLASS='Extra Chil') OR(O.Type='RUSH')) THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM #CODELKUPS WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='AGV')) THEN (SELECT LONG FROM #CODELKUPS WHERE STORERKEY='ARLA' AND LISTNAME='ARLAUSR' AND SHORT='1')
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM #CODELKUPS WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='MANUAL')) THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM #CODELKUPS WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='AGV') ) THEN (SELECT LONG FROM #CODELKUPS WHERE STORERKEY='ARLA' AND LISTNAME='ARLAUSR' AND SHORT='1')
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM #CODELKUPS WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='MANUAL')) THEN 'REACHTRUCK' ELSE 'REACHTRUCK' END AS '@c_UserKey',

		   CASE WHEN ((S.ITEMCLASS='Extra Chil') OR(O.Type='RUSH')) THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM #CODELKUPS WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='AGV')) THEN (SELECT LONG FROM #CODELKUPS WHERE STORERKEY='ARLA' AND LISTNAME='ARLAUSR' AND SHORT='1')
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08  IN (SELECT DISTINCT CODE FROM #CODELKUPS WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='MANUAL')) THEN 'REACHTRUCK'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM #CODELKUPS WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='AGV')) THEN (SELECT LONG FROM #CODELKUPS WHERE STORERKEY='ARLA' AND LISTNAME='ARLAUSR' AND SHORT='1')
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM #CODELKUPS WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='MANUAL')) THEN 'REACHTRUCK' ELSE 'REACHTRUCK' END AS '@c_Message01',

		  /*  CASE WHEN ((S.ITEMCLASS='Extra Chil') OR(O.Type='RUSH')) THEN 'NEW'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM CODELKUP WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='AGV')) THEN 'CUSTOMS'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE='CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM CODELKUP WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='MANUAL')) THEN 'CUSTOMS'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)<=1500) AND (LA.Lottable08 IN  (SELECT DISTINCT CODE FROM CODELKUP WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='AGV')) THEN 'NEW'
		   WHEN (S.ITEMCLASS='Chilled') AND (O.TYPE<>'CUSTOMS') AND (TRY_CAST(LA.Lottable09 as float)>1500) AND (LA.Lottable08 IN (SELECT DISTINCT CODE FROM CODELKUP WHERE listname='ARLAPALTYP' AND STORERKEY=ISNULL(@c_Storerkey,'ARLA') AND SHORT='MANUAL')) THEN 'NEW' ELSE 'NEW' END AS 'c_Message02',*/
		   CASE WHEN (O.TYPE='CUSTOMS') THEN 'CUSTOMS' ELSE 'NEW' END AS 'c_Message02',
		   CASE WHEN (O.TYPE='CUSTOMS') THEN 'S' ELSE '0' END AS '@c_WStatus'

      FROM #PICKDETAIL_WIP PD WITH (NOLOCK)
      JOIN LOC L WITH (NOLOCK) ON L.Loc = PD.Loc
	  JOIN SKU S WITH (NOLOCK) ON S.SKU=PD.SKU AND S.StorerKey = PD.Storerkey
	  JOIN ORDERS O WITH (NOLOCK) ON O.ORDERKEY=PD.ORDERKEY
	  JOIN LOTATTRIBUTE  LA WITH (NOLOCK) ON LA.LOT=PD.LOT AND LA.SKU=PD.SKU AND LA.StorerKey = PD.Storerkey
      WHERE PD.Wavekey = @c_Wavekey
      AND PD.[Status] = '0'
      AND PD.ID <> '' AND PD.ID IS NOT NULL
      AND PD.WIP_RefNo = @c_SourceType
	  AND TRY_CAST(PD.UOM AS INT)=1
      GROUP BY PD.Storerkey, PD.Sku, PD.Loc, PD.ID, PD.UOM, L.LogicalLocation, PD.OrderKey,S.ITEMCLASS,O.TYPE,LA.Lottable08,LA.LOTTABLE09
      ORDER BY L.LogicalLocation, PD.Loc

      OPEN CUR_ID

      FETCH NEXT FROM CUR_ID INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @c_Orderkey,@c_Userkey,@c_Message01,@c_Message02,@c_WStatus

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         SET @c_TaskType = 'FPK'
         SET @c_PickMethod = 'FP'
         SET @c_LinkTaskToPick_SQL = 'AND PICKDETAIL.UOM = ''' +'1' + ''''   -- Get the original UOM
         SET @c_Priority = '5'
         SET @c_SourcePriority = '5'
         SET @n_UOMQty = 0

         --Full LPN allocated (UOM = 1)
         IF @c_UOM = '1'
         BEGIN
            SET @n_UOMQty = @n_Qty
         END
         ELSE   --Partial LPN allocated (UOM <> 1)
         BEGIN
            SELECT @n_UOMQty = Qty
            FROM ID (NOLOCK)
            WHERE ID.ID = @c_ID
         END
         
         EXEC isp_InsertTaskDetail
              @c_TaskType              = @c_TaskType
            , @c_Storerkey             = @c_Storerkey
            , @c_Sku                   = @c_Sku
            , @c_Lot                   = @c_Lot
            , @c_UOM                   = '1'
            , @n_UOMQty                = @n_UOMQty
            , @n_Qty                   = @n_Qty
			
            , @c_FromLoc               = @c_FromLoc
            , @c_LogicalFromLoc        = @c_FromLoc
            , @c_FromID                = @c_ID
            , @c_ToLoc                 = @c_ToLoc
            , @c_LogicalToLoc          = @c_ToLoc
            , @c_ToID                  = @c_ID
			,@c_Status=@c_WStatus
            , @c_PickMethod            = @c_PickMethod
            , @c_Priority              = @c_Priority
            , @c_SourcePriority        = @c_SourcePriority
            , @c_SourceType            = @c_SourceType
            , @c_SourceKey             = @c_Wavekey
            , @c_OrderKey              = @c_Orderkey
            , @c_Wavekey               = @c_Wavekey
            , @n_SystemQty             = @n_UOMQty
            , @c_FinalLOC              = @c_ToLoc
            , @c_FinalID               = @c_ID
            , @n_QtyReplen             = @n_UOMQty
			,@c_UserKey                 = @c_UserKey
			,@c_Message01              = @c_Message01      
			,@c_Message02              = @c_Message02
            , @c_AreaKey               = '?F'  -- ?F=Get from location areakey
            , @c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip
            , @c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL
            , @c_SplitTaskByCase       = 'N'   -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0.
            , @c_WIP_RefNo             = @c_SourceType
            , @b_Success               = @b_Success OUTPUT
            , @n_Err                   = @n_Err OUTPUT
            , @c_Errmsg                = @c_Errmsg OUTPUT
         
         IF @b_Success <> 1
         BEGIN
            SELECT @n_Continue = 3
         END

         FETCH NEXT FROM CUR_ID INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_UOM, @c_Orderkey,@c_Userkey,@c_Message01,@c_Message02,@c_WStatus
      END
      CLOSE CUR_ID
      DEALLOCATE CUR_ID
   END

   -----Update pickdetail_WIP work in progress staging table back to pickdetail
   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
      EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
           ,@c_Wavekey               = @c_Wavekey
           ,@c_WIP_RefNo             = @c_SourceType
           ,@c_PickCondition_SQL     = ''
           ,@c_Action                = 'U'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
           ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
           ,@b_Success               = @b_Success OUTPUT
           ,@n_Err                   = @n_Err     OUTPUT
           ,@c_Errmsg                = @c_Errmsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END

   -----Update Wave Status-----
   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
      UPDATE WAVE WITH (ROWLOCK)
         SET TMReleaseFlag = 'Y'               
          ,  TrafficCop = NULL                 
          ,  EditWho = dbo.fnc_GetUserName()
          ,  EditDate= dbo.fnc_GetDate()
      WHERE WaveKey = @c_Wavekey

      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 83040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update on Wave Failed (mspRLWAVARLA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END
   END


  /* ---UPDATE TOLOC IN PICKDETAIL WHERE UOM=6
    IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
      UPDATE PICKDETAIL WITH (ROWLOCK) SET TOLOC=@c_ToLoc ,CASEID=ID      WHERE WaveKey = @c_Wavekey 
	  --UPDATE PICKDETAIL WITH (ROWLOCK) SET TOLOC=@c_ToLoc ,CASEID=ID      WHERE WaveKey = @c_Wavekey AND UOM IN('2','6')

      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 83040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update on Wave Failed (mspRLWAVARLA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END
   END
   --END OF UPDATE*/

   ---GENERATE CARTON SEQUENCE IN 
   /* IF @n_Continue = 1 or @n_Continue = 2
	IF  EXISTS(SELECT  1 FROM PICKDETAIL WITH (NOLOCK) WHERE WAVEKEY=@c_Wavekey )
	BEGIN
   BEGIN
     WITH CTE AS
(
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ORDERKEY ORDER BY (SELECT NULL)) AS RN
    FROM PICKDETAIL
    WHERE UOM = '1'
      AND ORDERKEY IN (
            SELECT ORDERKEY
            FROM WAVEDETAIL
            WHERE WaveKey = @c_WaveKey
      )
)
UPDATE CTE
SET NOTES = RN;

      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 83040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update on Wave Failed (mspRLWAVARLA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END
   END
   END*/
  -- END OF CARTON SEQ
 /*   -----RESERVER LPN FOR PALLETS-----
   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
      WITH CTE AS (
    SELECT 
        LA.LOT,
        LA.SKU,
        LA.STORERKEY,
        MAX(PD.ORDERKEY) AS ORDERKEY
    FROM PICKDETAIL PD
    JOIN LOTXLOCXID LLI 
        ON LLI.ID = PD.ID
        AND LLI.SKU = PD.SKU
        AND LLI.LOT = PD.LOT
        AND LLI.STORERKEY = PD.STORERKEY
    JOIN LOTATTRIBUTE LA
        ON LA.LOT = LLI.LOT
        AND LA.SKU = LLI.SKU
        AND LA.STORERKEY = LLI.STORERKEY
    WHERE PD.UOM = 1
      AND PD.WAVEKEY =  @c_Wavekey --AND STATUS>0
    GROUP BY LA.LOT, LA.SKU, LA.STORERKEY
)
UPDATE LA
SET LA.LOTTABLE07 = CTE.ORDERKEY
FROM LOTATTRIBUTE LA
JOIN CTE
    ON LA.LOT = CTE.LOT
    AND LA.SKU = CTE.SKU
    AND LA.STORERKEY = CTE.STORERKEY

      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 83040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update on Wave Failed (mspRLWAVARLA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END
   END
   --END OF RESERVER LPN*/

   
   --START OF CHANGING STATUS FOR UOM=1 IN PICKDETAIL TO AVOID PICKING IN 830 FUNCTION
   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
     -- UPDATE PD SET   PD.STATUS=6,PD.PickSlipNo='' FROM PICKDETAIL PD JOIN ORDERS O ON O.ORDERKEY=PD.ORDERKEY WHERE PD.WAVEKEY= @c_Wavekey AND PD.UOM=1 --AND O.TYPE='CUSTOMS'
	 IF EXISTS (
    SELECT 1
    FROM WAVEDETAIL WD WITH (NOLOCK)
    JOIN ORDERS O WITH (NOLOCK) ON O.ORDERKEY = WD.ORDERKEY
    WHERE WD.WAVEKEY = @c_Wavekey
      AND O.TYPE = 'CUSTOMS'
)
BEGIN
    UPDATE PD WITH (ROWLOCK)
    SET 
        PD.STATUS = '6',
        PD.PickSlipNo = ''
    FROM PICKDETAIL PD
    JOIN ORDERS O  WITH (NOLOCK)
        ON O.ORDERKEY = PD.ORDERKEY
    WHERE 
        PD.WAVEKEY = @c_Wavekey 
        AND TRY_CAST(PD.UOM AS INT) = 1 AND PD.STATUS IN ('0','4') 
        AND O.TYPE = 'CUSTOMS';
END
ELSE
BEGIN
    UPDATE PD WITH (ROWLOCK)
    SET PD.STATUS='4',
        PD.PickSlipNo = ''
    FROM PICKDETAIL PD 
    JOIN ORDERS O  WITH (NOLOCK)
        ON O.ORDERKEY = PD.ORDERKEY
    WHERE 
        PD.WAVEKEY = @c_Wavekey 
        AND TRY_CAST(PD.UOM AS INT) = 1 AND PD.STATUS ='0'
        AND O.TYPE <> 'CUSTOMS';
END




      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 83040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update on Wave Failed (mspRLWAVARLA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END
   END
   --END OF CHANGING STATUS FOR UOM=1 IN PICKDETAIL TO AVOID PICKING IN 830 FUNCTION

   --INSERT TRANSMITLOG2 

    -----Update Wave Status-----
  
  /*   INSERT INTO TRANSMITLOG2
(
    TRANSMITLOGKEY,
    TABLENAME,
    KEY1,              -- TASKDETAILKEY FROM PICKDETAIL
    KEY3,
    ADDDATE,
    ADDWHO,
    EDITDATE,
    EDITWHO
)
SELECT
    ROW_NUMBER() OVER (ORDER BY PD.TASKDETAILKEY)
        + ISNULL((SELECT MAX(TRANSMITLOGKEY) FROM TRANSMITLOG2), 0) AS TRANSMITLOGKEY,
    'WSTASKMCS',
    PD.TASKDETAILKEY,
    'ARLA',
    GETDATE(),
    'ARLA_ALLOC_FOR_AGV',
    GETDATE(),
    'ARLA_ALLOC_FOR_AGV'
FROM PICKDETAIL PD 
INNER JOIN ORDERS O ON O.ORDERKEY=PD.ORDERKEY 
INNER JOIN TASKDETAIL TD ON TD.TaskDetailKey=PD.TaskDetailKey AND TD.Message01='AGV'
LEFT JOIN TRANSMITLOG2 TL    ON TL.KEY1 = PD.TASKDETAILKEY    AND TL.TABLENAME = 'WSTASKMCS'
WHERE PD.TASKDETAILKEY IS NOT NULL AND PD.TASKDETAILKEY<>''  AND TL.KEY1 IS NULL AND PD.WAVEKEY=@c_Wavekey AND PD.STATUS<=5  AND O.TYPE<>'CUSTOMS'
  


      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 83040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err) + ': Update on Wave Failed (mspRLWAVARLA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
      END*/
	 IF @n_Continue IN (1, 2)
BEGIN
    DECLARE 
          @TASKDETAILKEY NVARCHAR(50)
      


    
    DECLARE CUR_TRANSMIT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR

    SELECT 
        PD.TASKDETAILKEY
    FROM PICKDETAIL PD  WITH (NOLOCK)
    INNER JOIN ORDERS O  WITH (NOLOCK)
        ON O.ORDERKEY = PD.ORDERKEY
    INNER JOIN TASKDETAIL TD   WITH (NOLOCK)
        ON TD.TaskDetailKey = PD.TaskDetailKey
       AND TD.Message01 = 'AGV'
    LEFT JOIN TRANSMITLOG2 TL     WITH (NOLOCK) 
        ON TL.KEY1 = PD.TASKDETAILKEY    
       AND TL.TABLENAME = 'WSTASKMCS'
    WHERE 
          PD.TASKDETAILKEY IS NOT NULL 
      AND PD.TASKDETAILKEY <> ''
      AND TL.KEY1 IS NULL
      AND PD.WAVEKEY = @c_Wavekey
      AND PD.STATUS <= 5
      AND O.TYPE <> 'CUSTOMS';

    OPEN CUR_TRANSMIT;

    FETCH NEXT FROM CUR_TRANSMIT INTO @TASKDETAILKEY;

    WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
    BEGIN
      
        EXEC dbo.ispGenTransmitLog2
              @c_TableName     = 'WSTASKMCS'
            , @c_Key1          = @TASKDETAILKEY
            , @c_Key2          = ''             
            , @c_Key3          = 'ARLA'
            , @c_TransmitBatch = ''             
            , @b_Success       = @b_Success OUTPUT
            , @n_err           = @n_err OUTPUT
            , @c_errmsg        = @c_errmsg OUTPUT;

      
        IF @b_Success <> 1
        BEGIN
            SET @n_Continue = 3;
            BREAK;
        END

        FETCH NEXT FROM CUR_TRANSMIT INTO @TASKDETAILKEY;
    END;

    CLOSE CUR_TRANSMIT;
    DEALLOCATE CUR_TRANSMIT;
END
   --END OF TRANSMIT LOG2


   

   IF @n_Continue = 1 or @n_Continue = 2
   BEGIN
   
    UPDATE #PickDetail_WIP WITH (ROWLOCK) SET TOLOC=@c_ToLoc ,CASEID=ID      WHERE WaveKey = @c_Wavekey 
      -----Delete pickdetail_WIP work in progress staging table
      EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
           ,@c_Wavekey               = @c_Wavekey
           ,@c_WIP_RefNo             = @c_SourceType
           ,@c_PickCondition_SQL     = ''
           ,@c_Action                = 'U'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
           ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
           ,@b_Success               = @b_Success OUTPUT
           ,@n_Err                   = @n_Err     OUTPUT
           ,@c_Errmsg                = @c_Errmsg  OUTPUT
   
      IF @b_Success <> 1
      BEGIN
         SET @n_Continue = 3
      END
   END


   IF (XACT_STATE()) = -1
   BEGIN
      IF @@TRANCOUNT > 0 
      BEGIN
         ROLLBACK TRAN
      END
   END

   WHILE @@TRANCOUNT < @n_starttcnt
      BEGIN TRAN

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
      DROP TABLE #PICKDETAIL_WIP

   IF CURSOR_STATUS('LOCAL', 'CUR_ID') IN (0 , 1)
   BEGIN
      CLOSE CUR_ID
      DEALLOCATE CUR_ID   

   END
 IF CURSOR_STATUS('LOCAL', 'CUR_TRANSMIT') IN (0 , 1)
   BEGIN
      CLOSE CUR_TRANSMIT
      DEALLOCATE CUR_TRANSMIT  

   END

   IF @n_Continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'mspRLWAVARLA'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END --sp end
