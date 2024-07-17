SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: mspRLWAV03                                         */
/* Creation Date: 08-MAY-2024                                           */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: UWP-18747 - Levis US MPOC and Cartonization                 */
/*                                                                      */
/* Called By: Wave                                                      */
/*                                                                      */
/* GitHub Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 28-May-2024  NJOW     1.0  DevOps Combine Script                     */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[mspRLWAV03]
   @c_WaveKey NVARCHAR(10)
 , @b_Success INT           OUTPUT
 , @n_Err     INT           OUTPUT
 , @c_ErrMsg  NVARCHAR(250) OUTPUT
 , @b_debug   INT = 0
AS
BEGIN
   SET NOCOUNT ON                     
   SET ANSI_NULLS OFF                 
   SET QUOTED_IDENTIFIER OFF          
   SET CONCAT_NULL_YIELDS_NULL OFF    
                                      
   DECLARE @c_SourceType              NVARCHAR(30)            
          ,@n_StartTCnt               INT          = 0
          ,@n_Continue                INT          = 1
          ,@c_Storerkey               NVARCHAR(15) 
          ,@c_Facility                NVARCHAR(5)          
          ,@c_CartonGroup             NVARCHAR(10) = ''          
          ,@c_RLWAV_Opt5              NVARCHAR(4000)
          ,@c_CartonItemOptimize      NVARCHAR(30) = 'Y'
          ,@c_NewCarton               NVARCHAR(1)
          ,@n_CartonNo                INT
          ,@c_CartonType              NVARCHAR(10)
          ,@n_CartonMaxCube           DECIMAL(15,7)
          ,@n_CartonMaxWeight         DECIMAL(20,7)           
          ,@n_CartonMaxCount          INT
          ,@n_CartonMaxSku            INT
          ,@c_Orderkey                NVARCHAR(10)
          ,@n_OrderCube               DECIMAL(15,7)
          ,@n_OrderWeight             DECIMAL(15,7)                         
          ,@n_RowID                   INT
          ,@n_OrderQty                INT
          ,@c_Sku                     NVARCHAR(20)
          ,@n_StdCube                 DECIMAL(15,7)
          ,@n_CartonLength            DECIMAL(15,7)      
          ,@n_CartonWidth             DECIMAL(15,7)      
          ,@n_CartonHeight            DECIMAL(15,7)
          ,@n_SKULength               DECIMAL(15,7) 
          ,@n_SKUWidth                DECIMAL(15,7)
          ,@n_SKUHeight               DECIMAL(15,7)
          ,@n_QtyCanPackByCube        INT
          ,@n_QtyCanPackByCount       INT
          ,@n_QtyCanPack              INT
          ,@c_PickslipNo              NVARCHAR(10)
          ,@c_LabelNo                 NVARCHAR(20)
          ,@n_TotCartonCube           DECIMAL(15,7)
          ,@n_TotCartonWeight         DECIMAL(15,7)
          ,@n_TotCartonQty            INT
          ,@n_PackQty                 INT      
          ,@n_PickdetQty              INT
          ,@c_PickDetailKey           NVARCHAR(10)
          ,@c_NewPickDetailKey        NVARCHAR(10)
          ,@n_SplitQty                INT
          ,@c_KeyName                 NVARCHAR(18)
          ,@c_UCCNo                   NVARCHAR(20)
          ,@c_SkuGroup                NVARCHAR(10)
          ,@n_MPOCFlag                INT = 0 
          ,@c_OrderGroup              NVARCHAR(10) = '' 
          ,@c_PreOrderGroup           NVARCHAR(10) = ''
          ,@n_SortSeq                 INT
          ,@n_CTNRowID                INT = 0

   DECLARE @n_VAS_LineCount INT = 0,
           @n_VAS_QtyCanPack INT = 0,
           @c_VAS_CartonType NVARCHAR(12);

   SELECT @n_StartTCnt = @@TRANCOUNT, @n_Continue = 1, @b_Success = 1, @n_err = 0, @c_errmsg = '', @c_SourceType = 'mspRLWAV03'

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @@TRANCOUNT = 0
      BEGIN TRAN

   --Create pickdetail Work in progress temporary table
   IF @n_continue IN(1,2)
   BEGIN
      CREATE TABLE #PickDetail_WIP(
         [PickDetailKey] [NVARCHAR](18) NOT NULL PRIMARY KEY,
         [CaseID] [NVARCHAR](20) NOT NULL DEFAULT (' '),
         [PickHeaderKey] [NVARCHAR](18) NOT NULL,
         [OrderKey] [NVARCHAR](10) NOT NULL,
         [OrderLineNumber] [NVARCHAR](5) NOT NULL,
         [Lot] [NVARCHAR](10) NOT NULL,
         [Storerkey] [NVARCHAR](15) NOT NULL,
         [Sku] [NVARCHAR](20) NOT NULL,
         [AltSku] [NVARCHAR](20) NOT NULL DEFAULT (' '),
         [UOM] [NVARCHAR](10) NOT NULL DEFAULT (' '),
         [UOMQty] [INT] NOT NULL DEFAULT ((0)),
         [Qty] [INT] NOT NULL DEFAULT ((0)),
         [QtyMoved] [INT] NOT NULL DEFAULT ((0)),
         [Status] [NVARCHAR](10) NOT NULL DEFAULT ('0'),
         [DropID] [NVARCHAR](20) NOT NULL DEFAULT (''),
         [Loc] [NVARCHAR](10) NOT NULL DEFAULT ('UNKNOWN'),
         [ID] [NVARCHAR](18) NOT NULL DEFAULT (' '),
         [PackKey] [NVARCHAR](10) NULL DEFAULT (' '),
         [UpdateSource] [NVARCHAR](10) NULL DEFAULT ('0'),
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
   END

   --Validation
   IF @n_continue IN(1,2)
   BEGIN
   	  SELECT TOP 1 @c_Storerkey = O.StorerKey,
   	         @c_Facility = O.Facility
   	  FROM dbo.WAVEDETAIL WD (NOLOCK)
   	  JOIN dbo.ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
   	  WHERE WD.WaveKey = @c_WaveKey

    	SELECT @c_CartonGroup = CartonGroup
      FROM dbo.STORER (NOLOCK)
      WHERE Storerkey = @c_Storerkey

   	 IF EXISTS(SELECT 1
   	           FROM dbo.PACKHEADER PH (NOLOCK)
   	           JOIN dbo.PACKDETAIL PD (NOLOCK) ON PH.PickslipNo = PD.Pickslipno
   	           JOIN dbo.WAVEDETAIL WD (NOLOCK) ON PH.Orderkey = WD.Orderkey
   	           WHERE WD.WaveKey = @c_WaveKey)
   	 BEGIN
          SET @n_continue = 3
          SET @n_Err = 82000
          SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': This Wave was cartonized before. (mspRLWAV03)'
          GOTO QUIT_SP
   	 END

   	 IF NOT EXISTS(SELECT 1
   	               FROM dbo.CARTONIZATION CZ (NOLOCK)
   	               WHERE CZ.CartonizationGroup = @c_CartonGroup)
   	 BEGIN
        SET @n_continue = 3
        SET @n_Err = 562201
        SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': CartonizationGroup ' + RTRIM(ISNULL(@c_CartonGroup,'')) + ' is not setup yet. (mspRLWAV03)'
        GOTO QUIT_SP
   	 END

   	 SET @c_CartonType = ''
   	 SELECT TOP 1 @c_CartonType = CartonType
   	 FROM dbo.CARTONIZATION (NOLOCK)
   	 WHERE CartonizationGroup = @c_CartonGroup
   	 AND Cube = 0
   	 AND (CartonWidth = 0 OR CartonLength = 0 OR CartonHeight = 0)
   	 ORDER BY CartonType

     IF ISNULL(@c_CartonType,'') <> ''
     BEGIN
        SET @n_continue = 3
        SET @n_Err = 562202
        SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Cube or LxWxH must setup for carton type ' + RTRIM(@c_CartonType) + '. (mspRLWAV03)'
        GOTO QUIT_SP
     END

   	 SET @c_Sku = ''
   	 SELECT TOP 1 @c_Sku = OD.Sku
   	 FROM dbo.WAVEDETAIL WD (NOLOCK)
   	 JOIN dbo.ORDERDETAIL OD (NOLOCK) ON WD.Orderkey = OD.Orderkey
   	 JOIN dbo.SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
     WHERE WD.WaveKey = @c_WaveKey
     AND STDCUBE = 0
     AND (Width = 0 OR Length = 0 OR Height = 0)
     ORDER BY OD.Sku

     IF ISNULL(@c_Sku,'') <> ''
     BEGIN
        SET @n_continue = 3
        SET @n_Err = 562203
        SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': StdCube or LxWxH must setup for Sku ' + RTRIM(@c_Sku) + '. (mspRLWAV03)'
        GOTO QUIT_SP
     END
   END

  --Initialize Pickdetail work in progress staging table
   IF @n_continue IN(1,2)
   BEGIN
      EXEC dbo.isp_CreatePickdetail_WIP
           @c_Loadkey               = ''
          ,@c_WaveKey               = @c_WaveKey
          ,@c_WIP_RefNo             = @c_SourceType
          ,@c_PickCondition_SQL     = ''
          ,@c_Action                = 'I'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
          ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
          ,@b_Success               = @b_Success OUTPUT
          ,@n_Err                   = @n_Err     OUTPUT
          ,@c_ErrMsg                = @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_continue = 3
      END
   END

   --Prepare common data
   IF @n_continue IN(1,2)
   BEGIN
      CREATE TABLE #OrderGroup
      (
         OrderKey NVARCHAR(10) NOT NULL,
         MPOCFlag CHAR(1) NULL,
         OrderGroup NVARCHAR(10) NULL
      )

      CREATE TABLE #ORDERSKU
      (
          RowID INT IDENTITY(1, 1) PRIMARY KEY,
          Orderkey NVARCHAR(10),
          Storerkey NVARCHAR(15),
          Sku NVARCHAR(20),
          TotalQty INT,
          TotalCube DECIMAL(15, 7),
          TotalQtyPacked INT,
          TotalCubePacked DECIMAL(15, 7),
          StdCube DECIMAL(15, 7),
          Length DECIMAL(15, 7),
          Width DECIMAL(15, 7),
          Height DECIMAL(15, 7),
          OrderGroup NVARCHAR(10),
          MasterShipmentID NVARCHAR(10)
      );
      CREATE INDEX IDX_ORDERSKU_ORD ON #ORDERSKU (Orderkey)

      CREATE TABLE #CARTONIZATION (RowID INT IDENTITY(1,1) PRIMARY KEY,
                                   CartonizationGroup NVARCHAR(10),
                                   CartonType   NVARCHAR(10),
                                   UseSequence  INT,
                                   Cube         DECIMAL(15,7),
                                   MaxWeight    DECIMAL(20,7),
                                   MaxCount     INT,
                                   MaxSku       INT,
                                   CartonLength DECIMAL(15,7),
                                   CartonWidth  DECIMAL(15,7),
                                   CartonHeight DECIMAL(15,7))

      CREATE TABLE #CARTON (RowID        INT IDENTITY(1,1) PRIMARY KEY,
                            OrderGroup   NVARCHAR(10) NOT NULL,
                            Orderkey     NVARCHAR(10) NOT NULL,
                            CartonNo     INT NULL DEFAULT 0,
                            LabelNo      NVARCHAR(20) NULL DEFAULT '',
                            CartonGroup  NVARCHAR(10) NULL DEFAULT '',
                            CartonType   NVARCHAR(10) NULL DEFAULT '',
                            MaxCube      DECIMAL(15,7) NULL DEFAULT 0,
                            MaxWeight    DECIMAL(20,7) NULL DEFAULT 0,
                            MaxCount     INT NULL DEFAULT 0,
                            MaxSku       INT NULL DEFAULT 0,
                            CartonLength DECIMAL(15,7) NULL DEFAULT 0,
                            CartonWidth  DECIMAL(15,7) NULL DEFAULT 0,
                            CartonHeight DECIMAL(15,7) NULL DEFAULT 0,
                            UCCNo        NVARCHAR(20) NULL DEFAULT '')
      CREATE INDEX IDX_CTN ON #CARTON (OrderGroup, Orderkey)

      CREATE TABLE #CARTONDETAIL (RowID       INT IDENTITY(1,1) PRIMARY KEY,
                                  OrderGroup   NVARCHAR(10) NOT NULL,
                                  Orderkey    NVARCHAR(10) NOT NULL,
                                  CartonNo    INT,
                                  Storerkey   NVARCHAR(15),
                                  Sku         NVARCHAR(20),
                                  Qty         INT,
                                  RowRef      INT)
      CREATE INDEX IDX_CTNDET ON #CARTONDETAIL (OrderGroup, Orderkey, CartonNo)

      CREATE TABLE #ROWTRACK (RowID INT)
      CREATE TABLE #CTNTRACK (RowID INT)

      SELECT @c_RLWAV_Opt5 = SC.Option5
      FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'WAVGENPACKFROMPICKED_SP') AS SC

      SELECT @c_CartonItemOptimize = dbo.fnc_GetParamValueFromString('@c_CartonItemOptimize', @c_RLWAV_Opt5, @c_CartonItemOptimize)

      -- MPOC Order Group
      INSERT INTO #OrderGroup
      (
          OrderKey,
          MPOCFlag,
          OrderGroup
      )
      SELECT DISTINCT PD.OrderKey, '0', ''
      FROM #PICKDETAIL_WIP PD

      -- Assign MPOC Flag
      IF @n_continue IN(1,2)
      BEGIN
         DECLARE CUR_MPOCFLAG CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT OrderKey
         FROM #OrderGroup OG

         OPEN CUR_MPOCFLAG

         FETCH NEXT FROM CUR_MPOCFLAG INTO @c_Orderkey

         WHILE @@FETCH_STATUS = 0
         BEGIN
             EXEC dbo.msp_GetMPOCRequired
                @c_OrderKey =@c_Orderkey,
                @n_MPOCFlag =@n_MPOCFlag OUTPUT,
                @b_Success = 1,
                @n_Err = @n_Err OUTPUT,
                @c_ErrMsg = @c_ErrMsg OUTPUT,
                @b_debug = @b_debug

            --IF @b_debug=3
            --   SET @n_MPOCFlag = '1'

             -- None MPOC Order, Pack by OrderKey
             UPDATE #OrderGroup
               SET MPOCFlag = CAST(@n_MPOCFlag AS CHAR(1)),
                   OrderGroup = CASE WHEN @n_MPOCFlag = 0 THEN OrderKey ELSE '' END
             WHERE OrderKey = @c_Orderkey

             FETCH NEXT FROM CUR_MPOCFLAG INTO @c_Orderkey
         END
         CLOSE CUR_MPOCFLAG
         DEALLOCATE CUR_MPOCFLAG


      END -- IF @n_continue IN(1,2)


      --Cartonization info
      INSERT INTO #CARTONIZATION (CartonizationGroup,
                                  CartonType,
                                  UseSequence,
                                  Cube,
                                  MaxWeight,
                                  MaxCount,
                                  MaxSku,
                                  CartonLength,
                                  CartonWidth,
                                  CartonHeight)
      SELECT CZ.CartonizationGroup, CZ.CartonType, CZ.UseSequence,
             CASE WHEN ISNULL(CZ.CartonLength,0) * ISNULL(CZ.CartonWidth,0) * ISNULL(CZ.CartonHeight,0) > 0 THEN
                       CZ.CartonLength * CZ.CartonWidth * CZ.CartonHeight
                  ELSE CZ.Cube
             END * (CASE WHEN ISNULL(CZ.FillTolerance,0) = 0 THEN 1 ELSE CZ.FillTolerance * 0.01 END ) AS  [Cube],
             CZ.MaxWeight,
             CASE WHEN CZ.MaxCount = 0 THEN 9999999 ELSE CZ.MaxCount END AS [MaxCount],
             9999999 AS[MaxSku],
             ISNULL(CZ.CartonLength,0), ISNULL(CZ.CartonWidth,0), ISNULL(CZ.CartonHeight,0)
      FROM dbo.CARTONIZATION CZ (NOLOCK)
      WHERE CZ.CartonizationGroup = @c_CartonGroup

      IF @b_debug = 1
        SELECT * FROM #CARTONIZATION

      --Order sku info
      INSERT INTO #ORDERSKU (Orderkey, Storerkey, Sku, TotalQty, TotalCube, TotalQtyPacked, TotalCubePacked, StdCube, Length, Width, Height, OrderGroup, MasterShipmentID)
      SELECT PD.OrderKey, PD.Storerkey, PD.Sku,
             SUM(PD.Qty) AS TotalQty,
             SUM(PD.Qty * CASE WHEN (SKU.Length * SKU.Width * SKU.Height) > 0 THEN
                              (SKU.Length * SKU.Width * SKU.Height)
                          ELSE SKU.STDCUBE END) AS TotalCube,
             0 TotalQtyPacked,
             0 TotalCubePacked,
             CASE WHEN (SKU.Length * SKU.Width * SKU.Height) > 0 THEN
                  (SKU.Length * SKU.Width * SKU.Height)
             ELSE SKU.STDCUBE END AS StdCube,
             SKU.Length,
             SKU.Width,
             SKU.Height,
             OG.OrderGroup AS OrderGroup,
             '' AS MasterShipmentID
       FROM #PICKDETAIL_WIP PD
       JOIN dbo.LOC (NOLOCK) LOC ON PD.Loc = LOC.Loc
       JOIN dbo.SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
       JOIN dbo.PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
       JOIN #OrderGroup OG ON OG.OrderKey = PD.OrderKey
       GROUP BY PD.OrderKey, PD.Storerkey, PD.Sku, SKU.Length, SKU.Width, SKU.Height,
                CASE WHEN (SKU.Length * SKU.Width * SKU.Height) > 0 THEN
                     (SKU.Length * SKU.Width * SKU.Height)
                ELSE SKU.STDCUBE END, OG.OrderGroup
       ORDER BY PD.OrderKey, TotalCube DESC, PD.Sku


      -- Assign Order Group for MPOC Orders
      -- Group by Orders.Consigneekey, Orders.Billtokey, Orders.Markforkey
      /* declare variables */
      DECLARE @c_ConsigneeKey NVARCHAR(15),
               @c_BillToKey NVARCHAR(15),
               @c_MarkforKey NVARCHAR(15),
               @c_MPOCOrder  NVARCHAR(25);

      DECLARE CUR_MPOC_GROUP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT O.ConsigneeKey, O.BillToKey, O.MarkforKey
      FROM #ORDERSKU OS
      JOIN dbo.ORDERS O WITH (NOLOCK) ON OS.Orderkey = O.OrderKey
      JOIN #OrderGroup OG ON OG.OrderKey = O.OrderKey
      WHERE OG.MPOCFlag <> '0'

      OPEN CUR_MPOC_GROUP

      FETCH NEXT FROM CUR_MPOC_GROUP INTO @c_ConsigneeKey, @c_BillToKey, @c_MarkforKey

      WHILE @@FETCH_STATUS = 0
      BEGIN
         SET @c_MPOCOrder = ''
         SET @b_Success=1
         EXEC dbo.nspg_GetKey @KeyName = N'MPOC',
                              @fieldlength = 9,
                              @keystring = @c_MPOCOrder OUTPUT,
                              @b_Success = @b_Success OUTPUT,
                              @n_err = @n_err OUTPUT,
                              @c_errmsg = @c_errmsg OUTPUT

         IF @c_MPOCOrder<>'' AND @b_Success=1
         BEGIN
            UPDATE OS
            SET OS.OrderGroup='M' + @c_MPOCOrder
            FROM #ORDERSKU OS
            JOIN dbo.ORDERS O WITH (NOLOCK) ON OS.Orderkey = O.OrderKey
            WHERE OS.OrderGroup=''
            AND O.ConsigneeKey = @c_ConsigneeKey
            AND O.BillToKey  = @c_BillToKey
            AND O.MarkforKey = @c_MarkforKey

            UPDATE OG
            SET OG.OrderGroup='M' + @c_MPOCOrder
            FROM #OrderGroup OG
            JOIN dbo.ORDERS O WITH (NOLOCK) ON OG.Orderkey = O.OrderKey
            WHERE OG.OrderGroup=''
            AND O.ConsigneeKey = @c_ConsigneeKey
            AND O.BillToKey  = @c_BillToKey
            AND O.MarkforKey = @c_MarkforKey

         END

         FETCH NEXT FROM CUR_MPOC_GROUP INTO @c_ConsigneeKey, @c_BillToKey, @c_MarkforKey
      END

      CLOSE CUR_MPOC_GROUP
      DEALLOCATE CUR_MPOC_GROUP

      /* declare variables */
      DECLARE @n_OSRowID   INT=0,
              @c_MPOCFlag  CHAR(1) = '',
              @c_MasterShpmntID NVARCHAR(20) = '',
              @c_DepartmentID NCHAR(100) = ''

      DECLARE CUR_ORDER_SKU CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT OS.RowID, OS.Storerkey, OS.Sku, OG.MPOCFlag, ISNULL(OI.Notes, '')
      FROM #ORDERSKU OS
      JOIN #OrderGroup OG ON OG.OrderKey = OS.OrderKey
      JOIN dbo.OrderInfo OI WITH (NOLOCK) ON OI.OrderKey = OG.OrderKey
      WHERE OG.MPOCFlag <> '0'

      OPEN CUR_ORDER_SKU

      FETCH NEXT FROM CUR_ORDER_SKU INTO @n_OSRowID, @c_Storerkey, @c_Sku, @c_MPOCFlag, @c_DepartmentID

      WHILE @@FETCH_STATUS = 0
      BEGIN
         SET @c_MasterShpmntID = ''

         IF ISNULL(@c_DepartmentID,'') <> ''
         BEGIN
            SELECT @c_MasterShpmntID = CLK.Short
            FROM dbo.CODELKUP CLK WITH (NOLOCK)
            WHERE CLK.LISTNAME='MPOCDEP'
            AND CLK.Storerkey = @c_Storerkey
            AND CLK.Code = @c_DepartmentID

            IF @c_MasterShpmntID<>''
            BEGIN
               UPDATE #ORDERSKU
                  SET MasterShipmentID = @c_MasterShpmntID
               WHERE RowID = @n_OSRowID
            END

         END
         FETCH NEXT FROM CUR_ORDER_SKU INTO @n_OSRowID, @c_Storerkey, @c_Sku, @c_MPOCFlag, @c_DepartmentID
      END
      CLOSE CUR_ORDER_SKU
      DEALLOCATE CUR_ORDER_SKU


       IF @b_debug = 1
         SELECT * FROM #ORDERSKU
   END  -- IF @n_continue IN(1,2)

   --------------------------------------------------
   -- Process Cartonization for None MPOC Orders
   --------------------------------------------------
   IF @n_continue IN(1,2)
   BEGIN

      IF @b_debug=2
      BEGIN
          PRINT '*** Process Cartonization for None MPOC Orders ***'
          PRINT '** Carton Group: ' + @c_CartonGroup
      END
   	DECLARE CUR_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   	   SELECT DISTINCT OS.Orderkey
   	   FROM #ORDERSKU OS
         JOIN #OrderGroup OG ON OG.OrderKey = OS.Orderkey
         WHERE OG.MPOCFlag = '0'
   	   ORDER BY OS.Orderkey

   	  OPEN CUR_ORD

   	  FETCH NEXT FROM CUR_ORD INTO @c_Orderkey

   	  WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
   	  BEGIN
     	     SET @c_NewCarton = 'Y'
     	     SET @n_CartonNo = 0

           IF @b_debug=2
           BEGIN
               PRINT '---- OrderKey: ' + @c_Orderkey + '  ------'

           END
           --pack full carton qty
           IF @n_continue IN(1,2)
           BEGIN
         	 DECLARE CUR_UCC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         	   SELECT OS.RowID, OS.Sku, PD.Qty, PD.DropID, OS.StdCube
         	   FROM #ORDERSKU OS (NOLOCK)
         	   JOIN #PickDetail_WIP PD (NOLOCK) ON OS.Orderkey = PD.Orderkey AND OS.Storerkey = PD.Storerkey AND OS.Sku = PD.Sku
         	   WHERE OS.Orderkey = @c_Orderkey
         	   AND PD.UOM = '2'
         	   AND ISNULL(PD.DropID,'') <> ''
         	   ORDER BY OS.RowID

            OPEN CUR_UCC

   	      FETCH NEXT FROM CUR_UCC INTO @n_RowID, @c_Sku, @n_PackQty, @c_UCCNo, @n_StdCube

        	   WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
   	      BEGIN
   	        	SET @n_CartonNo = @n_CartonNo + 1

         	   INSERT INTO #CARTON (Orderkey, CartonNo, LabelNo, CartonGroup, CartonType, MaxCube, MaxWeight, MaxCount, MaxSku, CartonLength, CartonWidth, CartonHeight, UCCNo, OrderGroup)
         	   VALUES (@c_Orderkey, @n_CartonNo, '', @c_CartonGroup, '', 0, 0, 0, 0, 0, 0, 0, @c_UCCNo, '')

         	   INSERT INTO #CARTONDETAIL (OrderGroup, Orderkey, Storerkey, Sku, CartonNo, Qty, RowRef)  --refer to ORDERSKU.RowID
         	   VALUES ('', @c_Orderkey, @c_Storerkey, @c_Sku, @n_CartonNo, @n_PackQty, @n_RowID)

         	   UPDATE #ORDERSKU
         	   SET TotalQtyPacked = TotalQtyPacked + @n_PackQty,
         	       TotalCubePacked = TotalCubePacked + (@n_PackQty * @n_StdCube)
         	   WHERE RowID = @n_RowID

      	      FETCH NEXT FROM CUR_UCC INTO @n_RowID, @c_Sku, @n_PackQty, @c_UCCNo, @n_StdCube
   	      END
   	      CLOSE CUR_UCC
   	      DEALLOCATE CUR_UCC
         END

         --pack loose carton
         SET @c_NewCarton = 'Y'

         DECLARE CUR_ORDCTNGROUP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT SUM(O.TotalCube - O.TotalCubePacked),
                SUM(O.TotalQty - O.TotalQtyPacked),
                O.Sku,
                O.Length,
                O.Width,
                O.Height,
                O.StdCube
         FROM #ORDERSKU O
         WHERE O.Orderkey = @c_Orderkey
           AND O.TotalQty - O.TotalQtyPacked > 0
         GROUP BY O.Sku,
                  O.Length,
                  O.Width,
                  O.Height,
                  O.StdCube
         ORDER BY O.Sku;

         OPEN CUR_ORDCTNGROUP

         FETCH NEXT FROM CUR_ORDCTNGROUP INTO @n_OrderCube, @n_OrderQty, @c_Sku, @n_SKULength, @n_SKUWidth, @n_SKUHeight, @n_StdCube

         SET @n_CartonNo = 0
         WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)  --pack by order
         BEGIN
            SELECT @n_VAS_LineCount = 0, @c_VAS_CartonType=''

            SELECT @n_VAS_LineCount = COUNT(1)
            FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)
            WHERE WOD.ExternWorkOrderKey = @c_Orderkey
            AND WOD.Sku = @c_Sku
            AND WOD.Type = 'S02'

            SELECT TOP 1
                 @c_VAS_CartonType= WOD.Type
            FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)
            WHERE WOD.ExternWorkOrderKey = @c_Orderkey
            AND WOD.Remarks='LPN_SIZE'
            ORDER BY WOD.ExternLineNo

            IF @n_VAS_LineCount = 1
            BEGIN
               SET @c_NewCarton = 'Y'

               SELECT @n_VAS_QtyCanPack = WOD.Qty
               FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)
               WHERE WOD.ExternWorkOrderKey = @c_Orderkey
               AND WOD.Sku = @c_Sku
               AND WOD.Type = 'S02'
            END
            ELSE IF @n_VAS_LineCount > 1
            BEGIN
               SET @c_NewCarton = 'Y'

               SELECT @n_VAS_QtyCanPack = WOD.Qty
               FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)
               WHERE WOD.ExternWorkOrderKey = @c_Orderkey
               AND WOD.Sku = @c_Sku
               AND WOD.Type = 'S02'
            END

         	WHILE 1=1 AND @n_continue IN(1,2) AND @n_OrderQty > 0
         	BEGIN
         	  	-- SELECT @c_SKU = '', @n_StdCube = 0
         	  	SELECT @n_QtyCanPackByCube = 0, @n_QtyCanPackByCount = 0, @n_QtyCanPack = 0
               SELECT @n_OrderCube = @n_OrderQty * @n_StdCube

               IF @b_debug=2
               BEGIN
                   PRINT 'NewCarton: ' + @c_NewCarton + ' Order Qty: ' +CAST(@n_OrderQty AS VARCHAR(20)) + ' Order Cube: ' + CAST(@n_OrderCube AS VARCHAR(20))
                        + ' StdCube: ' + CAST(@n_StdCube AS VARCHAR(20))
               END
         	  	IF @c_NewCarton = 'Y' --new carton
         	  	BEGIN
         	  	  	SELECT @n_CartonMaxCube = 0, @n_CartonMaxCount = 0, @n_CartonMaxWeight = 0, @c_NewCarton = 'N', @n_CartonNo = 0, @c_CartonType = ''
         	  	  	SELECT @n_CartonLength = 0, @n_CartonWidth = 0, @n_CartonHeight = 0



                  SELECT @n_CartonNo = MAX(CartonNo)
                  FROM #CARTON
                  WHERE Orderkey = @c_Orderkey

                  SET @n_CartonNo = ISNULL(@n_CartonNo,0)

         	  	  	SET @n_CartonNo = @n_CartonNo + 1

                  -- Getting Right Carton Type by LWH and Cube
                  IF @c_VAS_CartonType <> ''
                  BEGIN
                     SELECT @c_CartonType=CZ.CartonType, @n_CartonLength=CZ.CartonLength,
                            @n_CartonWidth=CZ.CartonWidth, @n_CartonHeight=CZ.CartonHeight
         	  	  	   FROM #CARTONIZATION CZ
                     WHERE CZ.CartonType = @c_VAS_CartonType

                     IF dbo.fnc_CartonCanFit(@n_SKULength, @n_SKUWidth, @n_SKUHeight, @n_CartonLength, @n_CartonWidth, @n_CartonHeight) = 0
                     BEGIN
                        SET @c_CartonType = N'';
                     END;
                  END
                  IF @c_CartonType = N''
                  BEGIN
					      TRUNCATE TABLE #CTNTRACK

                     WHILE 1=1 AND @n_continue IN(1,2)
                     BEGIN
                        SET @c_CartonType = N''

                        SELECT TOP 1 @n_CTNRowID = RowID,
                           @c_CartonType= CZ.CartonType, @n_CartonLength=CZ.CartonLength, @n_CartonWidth=CZ.CartonWidth, @n_CartonHeight=CZ.CartonHeight
                        FROM #CARTONIZATION CZ
                        WHERE CZ.Cube >= @n_OrderCube
						      AND NOT EXISTS(SELECT 1 FROM #CTNTRACK C WHERE C.ROWID = CZ.RowID)
                        ORDER BY CZ.Cube
                        IF @c_CartonType = N''
                        BEGIN
                           SELECT TOP 1 @n_CTNRowID = RowID,
                              @c_CartonType= CZ.CartonType, @n_CartonLength=CZ.CartonLength, @n_CartonWidth=CZ.CartonWidth, @n_CartonHeight=CZ.CartonHeight
                           FROM #CARTONIZATION CZ
                           WHERE CZ.Cube >= @n_StdCube
						         AND NOT EXISTS(SELECT 1 FROM #CTNTRACK C WHERE C.ROWID = CZ.RowID)
                           ORDER BY CZ.Cube DESC
                        END
                        IF @c_CartonType = N''
                        BEGIN
                           BREAK
                        END
                        IF dbo.fnc_CartonCanFit(@n_SKULength, @n_SKUWidth, @n_SKUHeight, @n_CartonLength, @n_CartonWidth, @n_CartonHeight) = 1
                        BEGIN
                           BREAK
                        END
                        ELSE
                           SET @c_CartonType = N''

						      INSERT INTO #CTNTRACK VALUES (@n_CTNRowID)
                     END -- WHILE 1=1

                     -- SELECT SortSeq = CASE WHEN CZ.Cube < @n_OrderCube AND CZ.Cube >= @n_StdCube THEN 2
                     --                       WHEN CZ.Cube >= @n_OrderCube  THEN 1
                     --                       ELSE 3
                     --                  END,
                     --    CZ.CartonType, CZ.CartonLength, CZ.CartonWidth, CZ.CartonHeight
         	  	  	   -- FROM #CARTONIZATION CZ
         	  	  	   -- WHERE CZ.Cube >= @n_StdCube
         	  	  	   -- ORDER BY SortSeq, CZ.Cube DESC

                     -- OPEN CUR_CartonType

                     -- FETCH NEXT FROM CUR_CartonType
                     -- INTO @n_SortSeq, @c_CartonType, @n_CartonLength, @n_CartonWidth, @n_CartonHeight;

                     -- WHILE @@FETCH_STATUS = 0
                     -- BEGIN
                     --    IF dbo.fnc_CartonCanFit(@n_SKULength, @n_SKUWidth, @n_SKUHeight, @n_CartonLength, @n_CartonWidth, @n_CartonHeight) = 0
                     --    BEGIN
                     --       SET @c_CartonType = N'';
                     --    END
                     --    ELSE
                     --    BEGIN
                     --       BREAK
                     --    END

                     --    FETCH NEXT FROM CUR_CartonType INTO @n_SortSeq, @c_CartonType, @n_CartonLength, @n_CartonWidth, @n_CartonHeight;
                     -- END

                     -- CLOSE CUR_CartonType
                     -- DEALLOCATE CUR_CartonType

                  END -- IF @c_CartonType = N''

         	  	  	IF @c_CartonType = ''
         	  	  	BEGIN
                     SET @n_continue = 3
                     SET @n_Err = 562204
                     SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Unable to find Carton type for Order: ' + RTRIM(@c_Orderkey) + '.(mspRLWAV03)'

                     IF @b_debug=2
                        PRINT @c_Errmsg

                     BREAK
         	  	  	END

         	  	  	--Get carton setup
         	  	  	SELECT @n_CartonMaxCube = CZ.Cube,
         	  	  	      @n_CartonMaxWeight = CZ.MaxWeight,
         	  	  	      @n_CartonMaxCount = CZ.MaxCount,
         	  	  	      @n_CartonMaxSku = CZ.MaxSku
         	  	  	FROM #CARTONIZATION CZ (NOLOCK)
         	  	  	WHERE CZ.CartonType = @c_CartonType

                  INSERT INTO #CARTON (Orderkey, CartonNo, LabelNo, CartonGroup, CartonType, MaxCube, MaxWeight, MaxCount, MaxSku, CartonLength, CartonWidth, CartonHeight, UCCNo, OrderGroup)
         	      VALUES (@c_Orderkey, @n_CartonNo, '', @c_CartonGroup, @c_CartonType, @n_CartonMaxCube, @n_CartonMaxWeight, @n_CartonMaxCount, @n_CartonMaxSku, @n_CartonLength , @n_CartonWidth, @n_CartonHeight, '', '')
         	  	END -- IF @c_NewCarton = 'Y'

               IF @b_debug=2
               BEGIN
                   PRINT 'Carton No: ' + CAST(@n_CartonNo As varchar(10))
               END
         	  	--Get item to pack
         	  	TRUNCATE TABLE #ROWTRACK

         	  	--Try search all items of the order that can fit the remaining space of the carton, priority by Sku
         	  	WHILE @n_QtyCanPack = 0 AND @n_continue IN(1,2)
         	  	BEGIN
           	  	   SET @n_RowID = 0

      	  	      IF EXISTS(SELECT 1 FROM #CARTONDETAIL WHERE CartonNo = @n_CartonNo AND Orderkey = @c_Orderkey)
         	  	   BEGIN
         	  	      --Get the sku can fully best fit in the existing carton
         	  	      SELECT TOP 1 @n_RowID = OS.RowID,
         	  	            @c_Sku = OS.Sku,
         	  	            @n_StdCube = OS.StdCube,
         	  	            @n_PackQty = OS.TotalQty - OS.TotalQtyPacked
         	  	      FROM #ORDERSKU OS (NOLOCK)
         	  	      WHERE OS.Orderkey = @c_Orderkey
         	  	      AND OS.TotalQty - OS.TotalQtyPacked > 0
         	  	      AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)
         	  	      AND @n_CartonMaxCube >= (OS.TotalCube - OS.TotalCubePacked)
         	  	      ORDER BY (OS.TotalCube - OS.TotalCubePacked) DESC, OS.Sku

         	  	      IF @n_RowID = 0
         	  	      BEGIN
         	  	     	  	--Get the smaller cube of the sku mix with existing carton
         	  	         SELECT TOP 1 @n_RowID = OS.RowID,
         	  	               @c_Sku = OS.Sku,
         	  	               @n_StdCube = OS.StdCube,
         	  	               @n_PackQty = OS.TotalQty - OS.TotalQtyPacked
         	  	         FROM #ORDERSKU OS (NOLOCK)
         	  	         WHERE OS.Orderkey = @c_Orderkey
         	  	         AND OS.TotalQty - OS.TotalQtyPacked > 0
         	  	         AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)
         	  	         --AND OS.SkuGroup = @c_SkuGroup
         	  	         ORDER BY (OS.TotalCube - OS.TotalCubePacked), OS.Sku
         	  	      END
         	  	   END
         	  	   ELSE
         	  	   BEGIN
         	  	      --Get the sku by larger cube sequence to the new carton
         	  	      SELECT TOP 1 @n_RowID = OS.RowID,
         	  	            @c_Sku = OS.Sku,
         	  	            @n_StdCube = OS.StdCube,
         	  	            @n_PackQty = OS.TotalQty - OS.TotalQtyPacked
         	  	      FROM #ORDERSKU OS (NOLOCK)
         	  	      WHERE OS.Orderkey = @c_Orderkey
         	  	      AND OS.TotalQty - OS.TotalQtyPacked > 0
         	  	      AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)
         	  	      --AND OS.SkuGroup = @c_SkuGroup
         	  	      ORDER BY OS.RowID
         	  	   END

                  -- No outstanding Item to pack, go to next order
         	  	   IF @n_RowID = 0
         	  	   BEGIN
                     SET @n_QtyCanPack = 0
                     SET @n_OrderQty = 0
         	  	      BREAK
         	  	   END

                  IF @b_debug=2
                  BEGIN
                      PRINT 'SKU: ' + @c_Sku + ' StdCube: ' + CAST(@n_StdCube AS VARCHAR(20))
                  END

         	  	   INSERT INTO #ROWTRACK(RowID) VALUES (@n_RowID)

         	  	   --Validate the carton at lease can fit 1 qty of the sku
         	      IF NOT EXISTS(SELECT 1 FROM #CARTONIZATION WHERE Cube >= @n_StdCube AND CartonType = @c_CartonType)
         	      BEGIN
                     SET @n_continue = 3
                     SET @n_Err = 562205
                     SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': No Carton type can fit a Sku ' + RTRIM(@c_Sku) + '.(mspRLWAV03)'

                     BREAK
         	      END

         	  	   IF @n_StdCube > 0
                     SET @n_QtyCanPackByCube = FLOOR(@n_CartonMaxCube / @n_StdCube)

         	  	   SET @n_QtyCanPack = @n_QtyCanPackByCube

                  IF @n_VAS_QtyCanPack > 0
                     SET @n_QtyCanPack = @n_VAS_QtyCanPack

         	  	   IF @n_StdCube = 0  --if sku cube not setup just pack all qty
         	  	      SET @n_QtyCanPack = @n_PackQty

         	  	   IF @n_PackQty < @n_QtyCanPack
         	  	      SET @n_QtyCanPack = @n_PackQty

                  IF @b_debug=2
                  BEGIN
                      PRINT '>>> QtyCanPackByCube: ' + CAST(@n_QtyCanPackByCube AS VARCHAR(10)) + ' QtyCanPack: ' + CAST(@n_QtyCanPack AS VARCHAR(10))
                  END

         	  	   IF @c_CartonItemOptimize <> 'Y'
         	  	      BREAK --if current item cannot fit current carton open new carton and not search for other/next item.
         	   END -- WHILE @n_QtyCanPack = 0

         	  	IF @n_continue = 3
         	  	   BREAK

         	  	IF @n_QtyCanPack = 0  --carton full
         	  	BEGIN
         	  	   SET @c_NewCarton = 'Y'
         	  	END
         	  	ELSE
               BEGIN
                  --Pack to Carton
                  INSERT INTO #CARTONDETAIL (OrderGroup, Orderkey, Storerkey, Sku, CartonNo, Qty, RowRef)  --refer to ORDERSKU.RowID
                  VALUES ('', @c_Orderkey, @c_Storerkey, @c_Sku, @n_CartonNo, @n_QtyCanPack, @n_RowID)

                  --Update counters
                  SET @n_OrderCube = @n_OrderCube - (@n_QtyCanPack * @n_StdCube)
                  SET @n_OrderQty = @n_OrderQty - @n_QtyCanPack
                  SET @n_CartonMaxCube = @n_CartonMaxCube - (@n_QtyCanPack * @n_StdCube)

                  UPDATE #ORDERSKU
                  SET TotalQtyPacked = TotalQtyPacked + @n_QtyCanPack,
                     TotalCubePacked = TotalCubePacked + (@n_QtyCanPack * @n_StdCube)
                  WHERE RowID = @n_RowID
               END

         	END -- WHILE @n_OrderQty > 0

            NEXT_CTNORSKU:
            FETCH NEXT FROM CUR_ORDCTNGROUP INTO @n_OrderCube, @n_OrderQty, @c_Sku, @n_SKULength, @n_SKUWidth, @n_SKUHeight, @n_StdCube
         END
         CLOSE CUR_ORDCTNGROUP
         DEALLOCATE CUR_ORDCTNGROUP

         FETCH_ORDER:
         FETCH NEXT FROM CUR_ORD INTO @c_Orderkey
      END
      CLOSE CUR_ORD
      DEALLOCATE CUR_ORD
   END -- No MPOC Orders
   -- Process Cartonization for MPOC Orders
   -- XXXXXX

   IF @n_continue IN(1,2)
   BEGIN
      IF @b_debug=3
      BEGIN
          PRINT '*** Process Cartonization for MPOC Orders ***'
      END
   	DECLARE CUR_MPOC_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   	   SELECT DISTINCT OG.OrderGroup
   	   FROM #ORDERSKU OG
         WHERE OG.OrderGroup > ''
   	   ORDER BY OG.OrderGroup

   	  OPEN CUR_MPOC_ORD

   	  FETCH NEXT FROM CUR_MPOC_ORD INTO @c_OrderGroup

   	  WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
   	  BEGIN
     	   SET @c_NewCarton = 'Y'
     	   SET @n_CartonNo = 0

         IF @b_debug=3
         BEGIN
             PRINT '>>> OrderGroup: ' + @c_OrderGroup + ' <<<'
         END

         --pack full carton qty
         IF @n_continue IN(1,2)
         BEGIN
         	DECLARE CUR_UCC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         	   SELECT OS.RowID, OS.Sku, PD.Qty, PD.DropID, OS.StdCube, OS.Orderkey
         	   FROM #ORDERSKU OS (NOLOCK)
         	   JOIN #PickDetail_WIP PD (NOLOCK) ON OS.Orderkey = PD.Orderkey AND OS.Storerkey = PD.Storerkey AND OS.Sku = PD.Sku
         	   WHERE OS.OrderGroup = @c_OrderGroup
         	   AND PD.UOM = '2'
         	   AND ISNULL(PD.DropID,'') <> ''
         	   ORDER BY OS.RowID

            OPEN CUR_UCC

   	      FETCH NEXT FROM CUR_UCC INTO @n_RowID, @c_Sku, @n_PackQty, @c_UCCNo, @n_StdCube, @c_Orderkey

        	   WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
   	      BEGIN
   	        	SET @n_CartonNo = @n_CartonNo + 1

         	   INSERT INTO #CARTON (Orderkey, CartonNo, LabelNo, CartonGroup, CartonType, MaxCube, MaxWeight, MaxCount, MaxSku, CartonLength, CartonWidth, CartonHeight, UCCNo, OrderGroup)
         	   VALUES (@c_Orderkey, @n_CartonNo, '', @c_CartonGroup, '', 0, 0, 0, 0, 0, 0, 0, @c_UCCNo, @c_OrderGroup)

         	   INSERT INTO #CARTONDETAIL (OrderGroup, Orderkey, Storerkey, Sku, CartonNo, Qty, RowRef)  --refer to ORDERSKU.RowID
         	   VALUES (@c_OrderGroup, @c_Orderkey, @c_Storerkey, @c_Sku, @n_CartonNo, @n_PackQty, @n_RowID)

         	   UPDATE #ORDERSKU
         	   SET TotalQtyPacked = TotalQtyPacked + @n_PackQty,
         	       TotalCubePacked = TotalCubePacked + (@n_PackQty * @n_StdCube)
         	   WHERE RowID = @n_RowID

      	      FETCH NEXT FROM CUR_UCC INTO @n_RowID, @c_Sku, @n_PackQty, @c_UCCNo, @n_StdCube, @c_Orderkey
   	      END
   	      CLOSE CUR_UCC
   	      DEALLOCATE CUR_UCC
         END

         SET @c_NewCarton = 'Y'

         --pack loose carton
         DECLARE CUR_MPOC_ORDCTNGROUP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT SUM(O.TotalCube - O.TotalCubePacked),
                SUM(O.TotalQty - O.TotalQtyPacked),
                O.Sku,
                O.Length,
                O.Width,
                O.Height,
                O.MasterShipmentID
         FROM #ORDERSKU O
         WHERE O.OrderGroup = @c_OrderGroup
           AND O.TotalQty - O.TotalQtyPacked > 0
         GROUP BY O.Sku,
                  O.Length,
                  O.Width,
                  O.Height,
                  O.MasterShipmentID
         ORDER BY O.Sku;

         OPEN CUR_MPOC_ORDCTNGROUP

         FETCH NEXT FROM CUR_MPOC_ORDCTNGROUP INTO @n_OrderCube, @n_OrderQty, @c_Sku, @n_SKULength, @n_SKUWidth, @n_SKUHeight, @c_MasterShpmntID

         SET @n_CartonNo = 0
         WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)  --pack by order
         BEGIN
         	WHILE 1=1 AND @n_continue IN(1,2) AND @n_OrderQty > 0
         	BEGIN
         	  	SELECT @c_SKU = '', @n_StdCube = 0
         	  	SELECT @n_QtyCanPackByCube = 0, @n_QtyCanPackByCount = 0, @n_QtyCanPack = 0

               IF @b_debug=3
               BEGIN
                     PRINT 'NewCarton: ' + @c_NewCarton
               END

         	   IF @c_NewCarton = 'Y' --new carton
         	   BEGIN
         	  	  	SELECT @n_CartonMaxCube = 0, @n_CartonMaxCount = 0, @n_CartonMaxWeight = 0, @c_NewCarton = 'N', @n_CartonNo = 0, @c_CartonType = ''
         	  	  	SELECT @n_CartonLength = 0, @n_CartonWidth = 0, @n_CartonHeight = 0

                  SELECT @n_CartonNo = MAX(CartonNo)
                  FROM #CARTON
                  WHERE OrderGroup = @c_OrderGroup

                  SET @n_CartonNo = ISNULL(@n_CartonNo,0)

         	  	  	SET @n_CartonNo = @n_CartonNo + 1

                  -- Getting Right Carton Type by LWH and Cube
                  DECLARE CUR_CartonType CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT CZ.CartonType, CZ.CartonLength, CZ.CartonWidth, CZ.CartonHeight
         	  	  	FROM #CARTONIZATION CZ
         	  	  	WHERE CZ.Cube >= @n_OrderCube
         	  	  	ORDER BY CZ.Cube

                  OPEN CUR_CartonType

                  FETCH NEXT FROM CUR_CartonType
                  INTO @c_CartonType, @n_CartonLength, @n_CartonWidth, @n_CartonHeight;

                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                     IF dbo.fnc_CartonCanFit(@n_SKULength, @n_SKUWidth, @n_SKUHeight, @n_CartonLength, @n_CartonWidth, @n_CartonHeight) = 0
                     BEGIN
                        SET @c_CartonType = N'';
                     END;
                     ELSE
                        BREAK

                     FETCH NEXT FROM CUR_CartonType INTO @c_CartonType, @n_CartonLength, @n_CartonWidth, @n_CartonHeight;
                  END

                  CLOSE CUR_CartonType
                  DEALLOCATE CUR_CartonType

         	  	  	IF @c_CartonType = ''
         	  	  	BEGIN
                     SET @n_continue = 3
                     SET @n_Err = 562206
                     SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Unable to find Carton type for Order: ' + RTRIM(@c_Orderkey) + '.(mspRLWAV03)'
                     BREAK
         	  	  	END

         	  	  	--Get carton setup
         	  	  	SELECT @n_CartonMaxCube = CZ.Cube,
         	  	  	      @n_CartonMaxWeight = CZ.MaxWeight,
         	  	  	      @n_CartonMaxCount = CZ.MaxCount,
         	  	  	      @n_CartonMaxSku = CZ.MaxSku
         	  	  	FROM #CARTONIZATION CZ (NOLOCK)
         	  	  	WHERE CZ.CartonType = @c_CartonType

                  INSERT INTO #CARTON (Orderkey, CartonNo, LabelNo, CartonGroup, CartonType, MaxCube, MaxWeight, MaxCount, MaxSku, CartonLength, CartonWidth, CartonHeight, UCCNo, OrderGroup)
         	      VALUES ('', @n_CartonNo, '', @c_CartonGroup, @c_CartonType, @n_CartonMaxCube, @n_CartonMaxWeight, @n_CartonMaxCount, @n_CartonMaxSku, @n_CartonLength , @n_CartonWidth, @n_CartonHeight, '', @c_OrderGroup)
         	  	END --IF @c_NewCarton = 'Y'

         	  	--Get item to pack
         	  	TRUNCATE TABLE #ROWTRACK

         	  	--Try search all items of the order that can fit the remaining space of the carton, priority by Sku
         	  	WHILE @n_QtyCanPack = 0 AND @n_continue IN(1,2)
         	  	BEGIN
           	  	   SET @n_RowID = 0

      	  	     	IF EXISTS(SELECT 1 FROM #CARTON WHERE CartonNo = @n_CartonNo AND OrderGroup = @c_OrderGroup)
         	  	   BEGIN
         	  	      --Get the sku can fully best fit in the existing carton
         	  	      SELECT TOP 1 @n_RowID = OS.RowID,
         	  	            @c_Sku = OS.Sku,
         	  	            @n_StdCube = OS.StdCube,
         	  	            @n_PackQty = OS.TotalQty - OS.TotalQtyPacked,
                           @c_Orderkey = OS.Orderkey
         	  	      FROM #ORDERSKU OS (NOLOCK)
         	  	      WHERE OS.OrderGroup = @c_OrderGroup
         	  	      AND OS.TotalQty - OS.TotalQtyPacked > 0
         	  	      AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)
         	  	      AND @n_CartonMaxCube >= (OS.TotalCube - OS.TotalCubePacked)
                     AND OS.MasterShipmentID = @c_MasterShpmntID
         	  	      ORDER BY (OS.TotalCube - OS.TotalCubePacked) DESC, OS.Sku

         	  	      IF @n_RowID = 0
         	  	      BEGIN
         	  	     	  	--Get the smaller cube of the sku mix with existing carton
         	  	         SELECT TOP 1 @n_RowID = OS.RowID,
         	  	               @c_Sku = OS.Sku,
         	  	               @n_StdCube = OS.StdCube,
         	  	               @n_PackQty = OS.TotalQty - OS.TotalQtyPacked,
                              @c_Orderkey = OS.Orderkey
         	  	         FROM #ORDERSKU OS (NOLOCK)
         	  	         WHERE OS.OrderGroup = @c_OrderGroup
         	  	         AND OS.TotalQty - OS.TotalQtyPacked > 0
         	  	         AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)
                        AND OS.MasterShipmentID = @c_MasterShpmntID
         	  	         ORDER BY (OS.TotalCube - OS.TotalCubePacked), OS.Sku
         	  	      END
         	  	   END
         	  	   ELSE
         	  	   BEGIN
         	  	      --Get the sku by larger cube sequence to the new carton
         	  	      SELECT TOP 1 @n_RowID = OS.RowID,
         	  	            @c_Sku = OS.Sku,
         	  	            @n_StdCube = OS.StdCube,
         	  	            @n_PackQty = OS.TotalQty - OS.TotalQtyPacked,
                           @c_Orderkey = OS.Orderkey
         	  	      FROM #ORDERSKU OS (NOLOCK)
         	  	      WHERE OS.OrderGroup = @c_OrderGroup
         	  	      AND OS.TotalQty - OS.TotalQtyPacked > 0
                     AND OS.MasterShipmentID = @c_MasterShpmntID
         	  	      AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)
         	  	      ORDER BY OS.RowID
         	  	   END

         	  	   IF @n_RowID = 0
         	  	   BEGIN
                     SET @n_QtyCanPack = 0
         	  	      BREAK
         	  	   END

                  IF @b_debug=3
                  BEGIN
                     PRINT 'SKU: ' + @c_Sku + ' StdCube: ' + CAST(@n_StdCube AS VARCHAR(20)) + '  OrderKey: ' + @c_Orderkey
                  END

         	  	   INSERT INTO #ROWTRACK(RowID) VALUES (@n_RowID)

         	  	   --Validate the carton at lease can fit 1 qty of the sku
         	      IF NOT EXISTS(SELECT 1 FROM #CARTONIZATION WHERE Cube >= @n_StdCube AND CartonType = @c_CartonType)
         	      BEGIN
                     SET @n_continue = 3
                     SET @n_Err = 562207
                     SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': No Carton type can fit a Sku ' + RTRIM(@c_Sku) + '.(mspRLWAV03)'

                     BREAK
         	      END

         	  	   IF @n_StdCube > 0
                     SET @n_QtyCanPackByCube = FLOOR(@n_CartonMaxCube / @n_StdCube)

         	  	   SET @n_QtyCanPack = @n_QtyCanPackByCube

         	  	   IF @n_StdCube = 0  --if sku cube not setup just pack all qty
         	  	      SET @n_QtyCanPack = @n_PackQty


         	  	   IF @n_PackQty < @n_QtyCanPack
         	  	      SET @n_QtyCanPack = @n_PackQty

                  IF @b_debug=3
                  BEGIN
                     PRINT '@n_QtyCanPackByCube: ' + CAST(@n_QtyCanPackByCube AS VARCHAR(10)) + ', @n_QtyCanPack: ' + CAST(@n_QtyCanPack AS VARCHAR(10))
                  END

         	  	   IF @c_CartonItemOptimize <> 'Y'
         	  	      BREAK --if current item cannot fit current carton open new carton and not search for other/next item.
         	   END -- WHILE @n_QtyCanPack

         	  	IF @n_continue = 3
         	  	   BREAK

         	  	IF @n_QtyCanPack = 0  --carton full
         	  	BEGIN
         	  	   SET @c_NewCarton = 'Y'
         	  	   GOTO NEXT_CTNORSKU2
         	  	END

         	  	--Pack to Carton
         	  	INSERT INTO #CARTONDETAIL (OrderGroup, Orderkey, Storerkey, Sku, CartonNo, Qty, RowRef)  --refer to ORDERSKU.RowID
         	  	VALUES (@c_OrderGroup, @c_OrderKey, @c_Storerkey, @c_Sku, @n_CartonNo, @n_QtyCanPack, @n_RowID)

         	  	--Update counters
         	  	SET @n_OrderCube = @n_OrderCube - (@n_QtyCanPack * @n_StdCube)
         	  	SET @n_OrderQty = @n_OrderQty - @n_QtyCanPack
         	  	SET @n_CartonMaxCube = @n_CartonMaxCube - (@n_QtyCanPack * @n_StdCube)


         	  	UPDATE #ORDERSKU
         	  	SET TotalQtyPacked = TotalQtyPacked + @n_QtyCanPack,
         	  	   TotalCubePacked = TotalCubePacked + (@n_QtyCanPack * @n_StdCube)
         	  	WHERE RowID = @n_RowID
         	END -- @n_OrderQty > 0
          	NEXT_CTNORSKU2:

            FETCH NEXT FROM CUR_MPOC_ORDCTNGROUP INTO @n_OrderCube, @n_OrderQty, @c_Sku, @n_SKULength, @n_SKUWidth, @n_SKUHeight, @c_MasterShpmntID
         END
         CLOSE CUR_MPOC_ORDCTNGROUP
         DEALLOCATE CUR_MPOC_ORDCTNGROUP

         FETCH NEXT FROM CUR_MPOC_ORD INTO @c_OrderGroup
      END
      CLOSE CUR_MPOC_ORD
      DEALLOCATE CUR_MPOC_ORD
   END -- No MPOC Orders

   --Create pickslip
   IF @n_continue IN(1,2)
   BEGIN
      EXEC dbo.isp_CreatePickSlip
             @c_WaveKey = @c_WaveKey
            ,@c_PickslipType = ''
            ,@c_ConsolidateByLoad  = 'N'
            ,@c_Refkeylookup       = 'N'
            ,@c_LinkPickSlipToPick = 'Y'
            ,@c_AutoScanIn         = 'N'
            ,@b_Success            = @b_Success OUTPUT
            ,@n_Err                = @n_Err     OUTPUT
            ,@c_ErrMsg             = @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
         SET @n_Continue = 3
   END

   IF @b_debug = 3
   BEGIN
      SELECT * FROM #CARTON
      SELECT * FROM #CARTONDETAIL
   END

   --Create packing records For None MPOC Orders
   IF @n_continue IN(1,2)
   BEGIN
     IF @b_debug <> 0
        PRINT '*** Create packing records  ***'

     SET @c_OrderGroup = ''
     SET @c_PreOrderGroup = ''

      DECLARE CUR_PACKORDER CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
        SELECT DISTINCT CT.OrderGroup, CT.Orderkey, PH.PickHeaderKey
        FROM #CARTONDETAIL CT
        JOIN dbo.PICKHEADER PH (NOLOCK) ON CT.Orderkey = PH.Orderkey
        ORDER BY CT.OrderGroup, CT.Orderkey

      OPEN CUR_PACKORDER

      FETCH NEXT FROM CUR_PACKORDER INTO @c_OrderGroup, @c_Orderkey, @c_Pickslipno

      WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)  --get order
      BEGIN
         IF @b_debug <> 0
            PRINT '@c_OrderGroup: ' + @c_OrderGroup + ' @c_Orderkey:' + @c_Orderkey + ' @c_Pickslipno: ' + @c_Pickslipno

         --Create packheader
         IF NOT EXISTS (SELECT 1 FROM dbo.PackHeader (NOLOCK) WHERE Pickslipno = @c_Pickslipno)
	       BEGIN
            INSERT INTO dbo.PackHeader (Route, OrderKey, OrderRefNo, Loadkey, Consigneekey, StorerKey, PickSlipNo)
            SELECT TOP 1 O.Route, O.Orderkey, '', O.LoadKey, '',O.Storerkey, @c_PickSlipNo
            FROM  dbo.PICKHEADER PH (NOLOCK)
            JOIN  dbo.ORDERS O (NOLOCK) ON (PH.Orderkey = O.Orderkey)
            WHERE PH.PickHeaderKey = @c_PickSlipNo

            SET @n_Err = @@ERROR

            IF @n_Err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 562208
               SELECT @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Error Insert Packheader Table (mspRLWAV03)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
            END
	       END


         DECLARE CUR_PACKCARTON CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT CT.CartonNo, CT.CartonType, CT.UCCNo, CT.CartonLength, CT.CartonWidth, CT.CartonHeight
         FROM #CARTON CT
         JOIN #CARTONDETAIL CTD ON CT.Orderkey = CTD.Orderkey AND CT.CartonNo = CTD.CartonNo
         WHERE CT.Orderkey = @c_Orderkey AND CT.OrderGroup = ''
         UNION ALL
         SELECT DISTINCT CT.CartonNo, CT.CartonType, CT.UCCNo, CT.CartonLength, CT.CartonWidth, CT.CartonHeight
         FROM #CARTON CT
         JOIN #CARTONDETAIL CTD ON CT.OrderGroup = CTD.OrderGroup AND CT.CartonNo = CTD.CartonNo
         WHERE CT.OrderGroup = @c_OrderGroup
         AND CT.OrderGroup > ''
         ORDER BY CT.CartonNo

         OPEN CUR_PACKCARTON

         FETCH NEXT FROM CUR_PACKCARTON INTO @n_CartonNo, @c_CartonType, @c_UCCNo, @n_CartonLength, @n_CartonWidth, @n_CartonHeight

         WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)  --get Carton
         BEGIN
            IF @b_debug <> 0
            PRINT  '@n_CartonNo: ' + CAST(@n_CartonNo AS VARCHAR(5)) + ' @c_CartonType: ' + @c_CartonType + ' @c_PreOrderGroup: ' + @c_PreOrderGroup

         	IF ISNULL(@c_UCCNo,'') <> ''
         	BEGIN
         	  	SET @c_LabelNo = @c_UCCNo
         	END
         	ELSE
         	BEGIN
               IF @c_OrderGroup <> @c_PreOrderGroup OR @c_OrderGroup = ''
               BEGIN
         	      EXEC dbo.isp_GenUCCLabelNo_Std
                  @cPickslipNo = @c_Pickslipno,
                  @nCartonNo   = @n_CartonNo,
                  @cLabelNo    = @c_LabelNo  OUTPUT,
                  @b_success   = @b_Success  OUTPUT,
                  @n_err       = @n_Err      OUTPUT,
                  @c_errmsg    = @c_Errmsg   OUTPUT

                  IF @b_Success <> 1
                     SET @n_continue = 3

                  SET @c_PreOrderGroup = @c_OrderGroup
               END
            END

            --Update labelno to #CARTON
            IF @c_OrderGroup = ''
            BEGIN
               UPDATE #CARTON
                  SET LabelNo = @c_LabelNo
               WHERE Orderkey = @c_Orderkey
               AND CartonNo = @n_CartonNo

               SELECT @n_TotCartonQty = 0, @n_TotCartonCube = 0, @n_TotCartonWeight = 0
               SELECT @n_TotCartonQty  = SUM(CTD.Qty),
                     @n_TotCartonCube = MAX(CT.MaxCube),
                     @n_TotCartonWeight = 0
               FROM #CARTONDETAIL CTD
               JOIN #CARTON CT ON CTD.CartonNo = CT.CartonNo AND CT.Orderkey = CTD.Orderkey
               WHERE CTD.Orderkey = @c_Orderkey
               AND CTD.CartonNo = @n_CartonNo
            END
            ELSE
            BEGIN
               UPDATE #CARTON
                  SET LabelNo = @c_LabelNo
               WHERE OrderGroup = @c_OrderGroup
               AND CartonNo = @n_CartonNo
               AND Orderkey=''

               SELECT @n_TotCartonQty = 0, @n_TotCartonCube = 0, @n_TotCartonWeight = 0
               SELECT @n_TotCartonQty  = SUM(CTD.Qty),
                     @n_TotCartonCube = MAX(CT.MaxCube),
                     @n_TotCartonWeight = 0
               FROM #CARTONDETAIL CTD
               JOIN #CARTON CT ON CTD.CartonNo = CT.CartonNo AND CT.OrderGroup = CTD.OrderGroup
               WHERE CT.OrderGroup = @c_OrderGroup
               AND CTD.CartonNo = @n_CartonNo
               AND CT.Orderkey=''
            END

            --Get packed carton cube,qty,weight
            --Create packinfo
            IF EXISTS (SELECT 1 FROM dbo.PackInfo (NOLOCK) WHERE Pickslipno = @c_PickslipNo
   	                       AND CartonNo = @n_CartonNo)
   	      BEGIN
   	        	DELETE FROM dbo.PackInfo WHERE Pickslipno = @c_PickslipNo AND CartonNo = @n_CartonNo
   	      END

   	      INSERT INTO dbo.PackInfo (Pickslipno, CartonNo, CartonType, Cube, Weight, Qty, Length, Width, Height, UCCNo)
   	      VALUES (@c_PickslipNo, @n_CartonNo, @c_CartonType, @n_TotCartonCube,
                    @n_TotCartonWeight, @n_TotCartonQty, @n_CartonLength, @n_CartonWidth, @n_CartonHeight, @c_LabelNo)

            SET @n_Err = @@ERROR
            IF @n_Err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 562209
               SELECT @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Error Insert Packinfo Table (mspRLWAV03)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
            END

            DECLARE CUR_PACKSKU CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT CTD.Storerkey, CTD.Sku, SUM(CTD.Qty)
               FROM #CARTONDETAIL CTD
               WHERE CTD.Orderkey = @c_Orderkey
               AND CTD.CartonNo = @n_CartonNo
               GROUP BY CTD.Storerkey, CTD.Sku
               ORDER BY MIN(CTD.RowID)

            OPEN CUR_PACKSKU

            FETCH NEXT FROM CUR_PACKSKU INTO @c_Storerkey, @c_Sku, @n_PackQty

            WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)  --get sku
            BEGIN
               -- CartonNo and LabelLineNo will be inserted by trigger
               INSERT INTO dbo.PackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, AddWho, AddDate, EditWho, EditDate, Refno, DropId)
               VALUES (@c_PickSlipNo, 0, @c_LabelNo, '00000', @c_StorerKey, @c_SKU,
                       @n_PackQty, sUser_sName(), GETDATE(), sUser_sName(), GETDATE(), @c_UCCNo, '')

               SET @n_Err = @@ERROR
               IF @n_Err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 562210
                  SELECT @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Error Insert Packdetail Table (mspRLWAV03)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '
               END

               FETCH NEXT FROM CUR_PACKSKU INTO @c_Storerkey, @c_Sku, @n_PackQty
            END
            CLOSE CUR_PACKSKU
            DEALLOCATE CUR_PACKSKU

            FETCH NEXT FROM CUR_PACKCARTON INTO @n_CartonNo, @c_CartonType, @c_UCCNo, @n_CartonLength, @n_CartonWidth, @n_CartonHeight
         END
         CLOSE CUR_PACKCARTON
         DEALLOCATE CUR_PACKCARTON

         FETCH NEXT FROM CUR_PACKORDER INTO @c_OrderGroup, @c_Orderkey, @c_Pickslipno
      END
      CLOSE CUR_PACKORDER
      DEALLOCATE CUR_PACKORDER
   END
   --IF @b_debug=3
   --BEGIN
   --    --SELECT * FROM #CARTON
   --END

   --Update labelno to pickdetail caseid
   IF @n_continue IN(1,2)
   BEGIN
   	UPDATE #PICKDETAIL_WIP SET CaseID = ''

      DECLARE CUR_LABELUPD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT CTD.Orderkey, CT.CartonNo, CTD.Storerkey, CTD.Sku, CTD.Qty, CT.LabelNo, CT.UCCNo
         FROM #CARTON CT
         JOIN #CARTONDETAIL CTD ON CT.Orderkey = CTD.Orderkey AND CT.CartonNo = CTD.CartonNo
         WHERE CT.Orderkey > ''
         UNION ALL
         SELECT CTD.Orderkey, CT.CartonNo, CTD.Storerkey, CTD.Sku, CTD.Qty, CT.LabelNo, CT.UCCNo
         FROM #CARTON CT
         JOIN #CARTONDETAIL CTD ON CT.OrderGroup = CTD.OrderGroup AND CT.CartonNo = CTD.CartonNo
         WHERE CT.Orderkey = ''
         ORDER BY CTD.Orderkey, CT.CartonNo, CTD.Storerkey, CTD.Sku

      OPEN CUR_LABELUPD

      FETCH NEXT FROM CUR_LABELUPD INTO @c_Orderkey, @n_CartonNo, @c_Storerkey, @c_Sku, @n_PackQty, @c_LabelNo, @c_UCCNo

      WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
      BEGIN
         DECLARE CUR_PICKDET_UPDATE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT PD.PickDetailKey, PD.Qty
            FROM #PICKDETAIL_WIP PD (NOLOCK)
            JOIN dbo.LOC LOC (NOLOCK) ON PD.Loc = LOC.Loc
            JOIN dbo.SKU SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
            JOIN dbo.PACK PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
            WHERE PD.OrderKey = @c_Orderkey
            AND PD.Storerkey = @c_Storerkey
            AND PD.Sku = @c_Sku
            AND ISNULL(PD.CaseID,'') = ''
            ORDER BY CASE WHEN PD.DropID = @c_UCCNo THEN 1 ELSE 2 END, LOC.Putawayzone, LogicalLocation, PD.PickDetailKey

         OPEN CUR_PICKDET_UPDATE

         FETCH NEXT FROM CUR_PICKDET_UPDATE INTO @c_PickDetailKey, @n_PickdetQty

         WHILE @@FETCH_STATUS <> -1 AND @n_packqty > 0
         BEGIN
            IF @n_PickdetQty <= @n_packqty
            BEGIN
            	 UPDATE #PICKDETAIL_WIP WITH (ROWLOCK)
            	 SET CaseId = @c_labelno,
            	     UOMQty = CASE WHEN UOM = '6' THEN Qty ELSE UOMQty END
            	 WHERE PickDetailKey = @c_PickDetailKey

		          SELECT @n_packqty = @n_packqty - @n_PickdetQty
            END
            ELSE
            BEGIN  -- pickqty > packqty
            	 SELECT @n_splitqty = @n_PickdetQty - @n_packqty

	             EXECUTE dbo.nspg_GetKey
               'PICKDETAILKEY',
               10,
               @c_NewPickdetailkey OUTPUT,
               @b_Success OUTPUT,
               @n_Err OUTPUT,
               @c_Errmsg OUTPUT

               IF NOT @b_Success = 1
               BEGIN
               	  SELECT @n_continue = 3
               END

            	 INSERT #PICKDETAIL_WIP
                      (PickDetailKey, CaseID, PickHeaderKey, OrderKey, OrderLineNumber, Lot,
                       Storerkey, Sku, AltSku, UOM, UOMQty, Qty, QtyMoved, Status,
                       DropID, Loc, ID, PackKey, UpdateSource, CartonGroup, CartonType,
                       ToLoc, DoReplenish, ReplenishZone, DoCartonize, PickMethod,
                       WaveKey, EffectiveDate, OptimizeCop, ShipFlag, PickSlipNo, Taskdetailkey, TaskManagerReasonkey, Notes, WIP_Refno, Channel_ID)
               SELECT @c_newpickdetailkey, '', PD.PickHeaderKey, PD.OrderKey, PD.OrderLineNumber, PD.Lot,
                      PD.Storerkey, PD.Sku, PD.AltSku, PD.UOM,
                      CASE WHEN PD.UOM = '6' THEN @n_splitqty
                           WHEN PD.UOM = '2' AND CaseCnt > 0 AND @n_splitqty % CAST(IIF(CaseCnt > 0, CaseCnt, 1) AS INT) = 0 THEN FLOOR(@n_splitqty / CaseCnt)
                      ELSE PD.UOMQty END ,
                      @n_splitqty, PD.QtyMoved, PD.Status,
                      PD.DropID, PD.Loc, PD.ID, PD.PackKey, PD.UpdateSource, PD.CartonGroup, PD.CartonType,
                      PD.ToLoc, PD.DoReplenish, PD.ReplenishZone, PD.DoCartonize, PD.PickMethod,
                      PD.WaveKey, PD.EffectiveDate, '9', PD.ShipFlag, PD.PickSlipNo, PD.TaskDetailKey, PD.TaskManagerReasonKey, PD.Notes, PD.WIP_Refno, PD.Channel_ID
               FROM #PickDetail_WIP PD (NOLOCK)
               JOIN dbo.SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
               JOIN dbo.PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
               WHERE PD.PickDetailKey = @c_PickDetailKey

               UPDATE #PICKDETAIL_WIP
            	 SET CaseID = @c_labelno,
            	     Qty = @n_packqty,
            	     UOMQty =
                   CASE WHEN UOM = '6' THEN @n_packqty
                        WHEN UOM = '2' AND CaseCnt > 0 AND @n_packqty % CAST(IIF(CaseCnt > 0, CaseCnt, 1) AS INT) = 0 THEN FLOOR(@n_packqty / CaseCnt)
                   ELSE UOMQty END
		         	     --UOMQTY = CASE UOM WHEN '6' THEN @n_packqty ELSE UOMQty END
		         	 FROM #PICKDETAIL_WIP
               JOIN dbo.SKU (NOLOCK) ON #PICKDETAIL_WIP .Storerkey = SKU.Storerkey AND #PICKDETAIL_WIP .Sku = SKU.Sku
               JOIN dbo.PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
            	 WHERE PickDetailKey = @c_PickDetailKey

               SELECT @n_packqty = 0
            END
            FETCH NEXT FROM CUR_PICKDET_UPDATE INTO @c_PickDetailKey, @n_PickdetQty
         END
         CLOSE CUR_PICKDET_UPDATE
         DEALLOCATE CUR_PICKDET_UPDATE

         FETCH NEXT FROM CUR_LABELUPD INTO @c_Orderkey, @n_CartonNo, @c_Storerkey, @c_Sku, @n_PackQty, @c_LabelNo, @c_UCCNo
      END
      CLOSE CUR_LABELUPD
      DEALLOCATE CUR_LABELUPD
   END

   -----Update pickdetail_WIP work in progress staging table back to pickdetail
   IF @n_continue IN(1,2)
   BEGIN
      EXEC dbo.isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
           ,@c_WaveKey               = @c_WaveKey
           ,@c_WIP_RefNo             = @c_SourceType
           ,@c_PickCondition_SQL     = ''
           ,@c_Action                = 'U'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
           ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
           ,@b_Success               = @b_Success OUTPUT
           ,@n_Err                   = @n_Err     OUTPUT
           ,@c_ErrMsg                = @c_ErrMsg  OUTPUT

      IF @b_Success <> 1
      BEGIN
         SET @n_continue = 3
      END
   END


   -- Gegerate Pick Tasks
   IF @n_continue IN(1,2)
   BEGIN
      /* declare variables */
      DECLARE @c_LOT NVARCHAR(10) = '',
              @c_FromLOC NVARCHAR(10) = '',
              @c_ToLOC NVARCHAR(10) = '',
              @c_TaskdetailKey NVARCHAR(10)='',
              @c_ID NVARCHAR(18) = '',
              @c_AreaKey NVARCHAR(10) = ''

      DECLARE CUR_PICKTASK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT P.PickDetailKey, P.CaseID, P.WaveKey, P.Storerkey, P.Sku, P.LOT, P.LOC, P.Qty, P.ID
      FROM #PickDetail_WIP P
      WHERE P.UOM='6'

      OPEN CUR_PICKTASK

      FETCH NEXT FROM CUR_PICKTASK INTO @c_PickDetailKey, @c_LabelNo, @c_WaveKey, @c_Storerkey, @c_Sku, @c_LOT, @c_FromLOC, @n_PickdetQty, @c_ID

      WHILE @@FETCH_STATUS = 0
      BEGIN
         SELECT @c_Facility = Facility, @c_AreaKey = AD.AreaKey
         FROM dbo.LOC WITH (NOLOCK)
         JOIN dbo.AreaDetail AD WITH (NOLOCK) ON AD.PutawayZone = LOC.PutawayZone
         WHERE Loc = @c_FromLOC

         SELECT TOP 1 @c_ToLOC = LOC
         FROM dbo.LOC WITH (NOLOCK)
         WHERE Facility = @c_Facility
         AND PutawayZone='LVSVAS'
         ORDER BY LogicalLocation

         EXECUTE dbo.nspg_Getkey
            'TaskDetailKey'
           , 10
           , @c_TaskdetailKey OUTPUT
           , @b_success       OUTPUT
           , @n_err           OUTPUT
           , @c_errmsg        OUTPUT

         IF @b_success <> 1
         BEGIN
      	    SET @n_continue = 3
         END

         INSERT dbo.TASKDETAIL
               ( TaskDetailKey, TaskType, Storerkey, Sku, Lot
               , UOM, UOMQty, Qty, FromLoc, FromID, ToLoc
               , ToId, SourceType, SourceKey, Caseid, Priority
               , SourcePriority, OrderKey, OrderLineNumber, PickDetailKey
               , PickMethod, STATUS, WaveKey, Areakey
               , Message01, SystemQty, GroupKey)
         VALUES (
                 @c_TaskDetailKey
               , 'ASTCPK' -- TaskType
               , @c_Storerkey
               , @c_Sku
               , @c_Lot -- Lot,
               , '6' -- UOM
               , @n_PickdetQty  -- UOMQty,
               , @n_PickdetQty
               , @c_fromloc
               , @c_ID
               , @c_ToLoc
               , @c_ID
               , 'mspRLWAV03' --SourceType
               , @c_PickDetailKey  --SourceKey
               , '' -- Caseid
               , '5' -- Priority
               , '9' -- SourcePriority
               , '' -- Orderkey,
               , '' -- OrderLineNumber
               , '' -- PickDetailKey
               , 'B2B-Loose'
               , '0'  --Status
               , @c_WaveKey
               , @c_AreaKey
               , ''
               , @n_PickdetQty
               , '')

              SELECT @n_err = @@ERROR
              IF @n_err <> 0
              BEGIN
                 SELECT @n_continue = 3
                 SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_err), @n_err = 562211
                 SELECT @c_ErrMsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err) + ': Insert Into TaskDetail Failed (mspRLWAV03)' +
                                    ' ( '+' SQLSvr MESSAGE= ' + @c_ErrMsg + ' ) '
                 GOTO QUIT_SP
              END

          FETCH NEXT FROM CUR_PICKTASK INTO @c_PickDetailKey, @c_LabelNo, @c_WaveKey, @c_Storerkey, @c_Sku, @c_LOT, @c_FromLOC, @n_PickdetQty, @c_ID
      END

      CLOSE CUR_PICKTASK
      DEALLOCATE CUR_PICKTASK


   END -- IF @n_continue IN(1,2)

   -- Insert Transmitlog2
   IF @n_continue IN(1,2)
   BEGIN
       EXEC  [dbo].[ispGenTransmitLog2]
               @c_TableName      = 'WSWVRLSLVS'
,              @c_Key1           = @c_WaveKey
,              @c_Key2           = ''
,              @c_Key3           = @c_Storerkey
,              @c_TransmitBatch  = 1
,              @b_Success        = @b_Success    OUTPUT
,              @n_err            = @n_Err        OUTPUT
,              @c_errmsg         = @c_ErrMsg     OUTPUT
   END

   QUIT_SP:

   IF @n_Continue = 3 -- Error Occured - Process AND Return  
   BEGIN
      SELECT @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE dbo.nsp_logerror @n_Err, @c_ErrMsg, 'mspRLWAV03'
      RAISERROR(@c_ErrMsg, 16, 1) WITH SETERROR -- SQL2012  
      --RAISERROR @nErr @cErrmsg  
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[mspRLWAV03] TO NSQL
GO
