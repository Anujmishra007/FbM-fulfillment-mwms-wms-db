SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: mspWAVPK01                                         */
/* Creation Date: 05-Dec-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: FCR-9548 Brazil - Cajamar - ONBR - SP Pack from Pick        */
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
/* 31-Dec-2025  WLChooi  1.0  Initial Version                           */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[mspWAVPK01]  
        @c_Wavekey NVARCHAR(10)
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
                                        
   DECLARE @c_SourceType               NVARCHAR(30)              
         , @n_StartTCnt                INT          = 0  
         , @n_Continue                 INT          = 1  
         , @c_Storerkey                NVARCHAR(15)   
         , @c_Facility                 NVARCHAR(5)      
         , @c_CartonGroup              NVARCHAR(10) = ''            
         , @c_RLWAV_Opt5               NVARCHAR(4000)  
         , @c_CartonItemOptimize       NVARCHAR(30) = 'Y'  
         , @c_NewCarton                NVARCHAR(1)  
         , @n_CartonNo                 INT
         , @n_ActualCartonNo           INT
         , @c_CartonType               NVARCHAR(10)  
         , @c_NewCartonType            NVARCHAR(10)  
         , @n_CartonMaxCube            DECIMAL(15,7)  
         , @n_NewCartonMaxCube         DECIMAL(15,7) 
         , @n_CartonRemainCube         DECIMAL(15,7)  
         , @n_CartonMaxWeight          DECIMAL(20,7)     

         , @n_CartonMaxCount           INT  
         , @n_CartonMaxSku             INT  
         , @n_ForceCartonMaxSku        INT = 0
         , @c_Orderkey                 NVARCHAR(10)  
         , @n_OrderCube                DECIMAL(15,7)  
         --, @n_OrderWeight              DECIMAL(15,7)                           
         , @n_RowID                    INT  
         , @n_OrderQty                 INT  
         , @c_Sku                      NVARCHAR(20)  
         , @n_StdCube                  DECIMAL(15,7)  
         , @n_CartonLength             DECIMAL(15,7)        
         , @n_CartonWidth              DECIMAL(15,7)        
         , @n_CartonHeight             DECIMAL(15,7)  
         , @n_SKULength                DECIMAL(15,7)   
         , @n_SKUWidth                 DECIMAL(15,7)  
         , @n_SKUHeight                DECIMAL(15,7)  
         , @n_QtyCanPackByCube         INT  
         , @n_QtyCanPackByCount        INT  
         , @n_QtyCanPack               INT  
         , @c_PickslipNo               NVARCHAR(10)  
         , @c_LabelNo                  NVARCHAR(20)  
         , @n_TotCartonCube            DECIMAL(15,7)  
         , @n_TotCartonWeight          DECIMAL(15,7)  
         , @n_CartonWeight             DECIMAL(15,7)
         , @n_TotCartonQty             INT  
         , @n_PackQty                  INT        
         , @n_PickdetQty               INT  
         , @c_PickDetailKey            NVARCHAR(10)  
         , @c_NewPickDetailKey         NVARCHAR(10)  
         , @n_SplitQty                 INT  
         --, @c_KeyName                  NVARCHAR(18)  
         , @c_UCCNo                    NVARCHAR(20)  
         , @c_SkuGroup                 NVARCHAR(10)  
         , @c_ItemClass                NVARCHAR(10)  
         --, @n_MPOCFlag                 INT = 0   
         , @c_OrderGroup               NVARCHAR(10) = ''   
         , @c_PreOrderGroup            NVARCHAR(10) = ''  
         --, @n_SortSeq                  INT      
         , @n_CTNRowID                 INT = 0   
         , @n_SKUGroupCube             DECIMAL(15,7) = 0  
         , @c_Replenishmentkey         NVARCHAR(10)  
         --, @b_OneSKUPerCarton          BIT = 0   
         , @b_MDS_Flag                 BIT = 0
         , @c_LabelLine                NVARCHAR(10)
         , @c_DefaultPackInfoFlag      NVARCHAR(1) = '0'
         --, @b_InsertTask               BIT = 1
         , @CUR_WaveOrd                CURSOR  
  
   DECLARE @n_VAS_LineCount            INT = 0
         , @n_VAS_QtyCanPack           INT = 0
         , @c_VAS_CartonType           NVARCHAR(12) = ''
  
   DECLARE @c_OrderType                NVARCHAR(10) = ''
         , @c_DocType                  NVARCHAR(1)
         , @c_VASFlag                  NVARCHAR(10) = 'N'
         , @c_Consigneekey             NVARCHAR(15) = ''
         , @c_CaseID                   NVARCHAR(20) = ''
  
   SELECT @n_StartTCnt = @@TRANCOUNT, @n_Continue = 1, @b_Success = 1, @n_err = 0, @c_errmsg = '', @c_SourceType = 'mspWAVPK01'  
      
   IF @@TRANCOUNT = 0  
      BEGIN TRAN  
  
   --Create pickdetail Work in progress temporary table      
   IF @n_continue IN(1,2)  
   BEGIN  
      CREATE TABLE #PickDetail_WIP (  
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
      SELECT TOP 1 @c_Storerkey = O.StorerKey
                 , @c_Facility = O.Facility
                 , @c_DocType = O.DocType 
      FROM dbo.WAVEDETAIL WD (NOLOCK)  
      JOIN dbo.ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey  
      WHERE WD.WaveKey = @c_Wavekey  
            
      SELECT @c_CartonGroup = CartonGroup  
      FROM dbo.STORER (NOLOCK)  
      WHERE Storerkey = @c_Storerkey

      IF EXISTS ( SELECT 1  
                  FROM WAVEDETAIL WD WITH (NOLOCK)  
                  JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey  
                  WHERE WD.WaveKey = @c_Wavekey  
                  AND NOT EXISTS ( SELECT 1  
                                   FROM LoadPlan LP WITH (NOLOCK)  
                                   WHERE LP.Loadkey = OH.LoadKey ) )  
      BEGIN  
         SET @n_continue = 3  
         SET @n_Err = 82021  
         SET @c_Errmsg = 'NSQL' + CONVERT(NVARCHAR(10),@n_Err) + ': Missing LoadKey: Generate Load. (mspWAVPK01)'  
         GOTO QUIT_SP  
      END 
        
      IF NOT EXISTS (SELECT 1  
                     FROM dbo.CARTONIZATION CZ (NOLOCK)  
                     WHERE CZ.CartonizationGroup = @c_CartonGroup)  
      BEGIN  
         SET @n_continue = 3  
         SET @n_Err = 562201  
         SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': CartonizationGroup ' + RTRIM(ISNULL(@c_CartonGroup,'')) + ' is not setup yet. (mspWAVPK01)'      
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
         SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Cube or LxWxH must setup for carton type ' + RTRIM(@c_CartonType) + '. (mspWAVPK01)'       
         GOTO QUIT_SP    
      END                   
       
      SET @c_Sku = ''  
      SELECT TOP 1 @c_Sku = OD.Sku  
      FROM dbo.WAVEDETAIL WD (NOLOCK)  
      JOIN dbo.ORDERDETAIL OD (NOLOCK) ON WD.Orderkey = OD.Orderkey  
      JOIN dbo.SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku  
      WHERE WD.WaveKey = @c_Wavekey                        
      AND STDCUBE = 0   
      AND (Width = 0 OR Length = 0 OR Height = 0)
  
      IF ISNULL(@c_Sku,'') <> ''  
      BEGIN  
         SET @n_continue = 3  
         SET @n_Err = 562203  
         SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': StdCube or LxWxH must setup for Sku ' + RTRIM(@c_Sku) + '. (mspWAVPK01)'       
         GOTO QUIT_SP    
      END       
     
      IF @n_continue IN(1,2)
      BEGIN  
         SET @c_Replenishmentkey = ''
         SELECT TOP 1 @c_Replenishmentkey = RP.Replenishmentkey   
         FROM REPLENISHMENT RP (NOLOCK)   
         INNER JOIN WAVE W (NOLOCK) ON RP.Wavekey = W.Wavekey  
         WHERE W.Wavekey = @c_Wavekey  
         AND RP.Confirmed <> 'Y'  
  
         IF ISNULL(@c_Replenishmentkey,'') <> ''  
         BEGIN  
            SET @n_continue = 3  
            SET @n_Err = 561016  
            SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Replenishment incomplete ' + RTRIM(@c_Replenishmentkey) + '. (mspWAVPK01)'       
            GOTO QUIT_SP    
         END   
      END  
   END -- @n_continue IN(1,2)

   --Initialize Pickdetail work in progress staging table      
   IF @n_continue IN(1,2)  
   BEGIN        
      EXEC dbo.isp_CreatePickdetail_WIP  
           @c_Loadkey               = ''  
          ,@c_Wavekey               = @c_Wavekey  
          ,@c_WIP_RefNo             = @c_SourceType  
          ,@c_PickCondition_SQL     = 'AND PICKDETAIL.Status = ''0'' '  
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
      CREATE TABLE #ORDERSKU
      (
         RowID           INT IDENTITY(1, 1) PRIMARY KEY
       , Orderkey        NVARCHAR(10)
       , Storerkey       NVARCHAR(15)
       , Sku             NVARCHAR(20)
       , TotalQty        INT
       , TotalCube       DECIMAL(15, 7)
       , TotalQtyPacked  INT
       , TotalCubePacked DECIMAL(15, 7)
       , StdCube         DECIMAL(15, 7)
       , Length          DECIMAL(15, 7)
       , Width           DECIMAL(15, 7)
       , Height          DECIMAL(15, 7)
       , OrderType       NVARCHAR(10)
       , Consigneekey    NVARCHAR(15)
       , IsFullyPacked   NVARCHAR(1) DEFAULT('N')
      );
      CREATE INDEX IDX_ORDERSKU_ORD ON #ORDERSKU (Orderkey)
      CREATE INDEX IDX_ORDERSKU_ORD_SKU ON #ORDERSKU (Orderkey, Sku) INCLUDE (TotalQty, TotalQtyPacked, StdCube, Storerkey)
                                
      CREATE TABLE #CARTONIZATION
      (
         RowID              INT           IDENTITY(1, 1) PRIMARY KEY
       , CartonizationGroup NVARCHAR(10)
       , CartonType         NVARCHAR(10)
       , UseSequence        INT
       , Cube               DECIMAL(15, 7)
       , MaxWeight          DECIMAL(20, 7)
       , MaxCount           INT
       , MaxSku             INT
       , CartonLength       DECIMAL(15, 7)
       , CartonWidth        DECIMAL(15, 7)
       , CartonHeight       DECIMAL(15, 7)
       , IsGeneric          INT           DEFAULT 1
       , CartonWeight       DECIMAL(20, 7)
      )
      CREATE INDEX IDX_CTNZ_CartonType ON #CARTONIZATION (CartonType) 
      INCLUDE (Cube, CartonLength, CartonWidth, CartonHeight, MaxWeight, CartonWeight, IsGeneric, RowID);
  
      CREATE TABLE #CARTON
      (
         RowID         INT            IDENTITY(1, 1) PRIMARY KEY
       , OrderGroup    NVARCHAR(10)   NOT NULL
       , Orderkey      NVARCHAR(10)   NOT NULL
       , CartonNo      INT            NULL DEFAULT 0
       , LabelNo       NVARCHAR(20)   NULL DEFAULT ''
       , CartonGroup   NVARCHAR(10)   NULL DEFAULT ''
       , CartonType    NVARCHAR(10)   NULL DEFAULT ''
       , MaxCube       DECIMAL(15, 7) NULL DEFAULT 0
       , MaxWeight     DECIMAL(20, 7) NULL DEFAULT 0
       , MaxCount      INT            NULL DEFAULT 0
       , MaxSku        INT            NULL DEFAULT 0
       , CartonLength  DECIMAL(15, 7) NULL DEFAULT 0
       , CartonWidth   DECIMAL(15, 7) NULL DEFAULT 0
       , CartonHeight  DECIMAL(15, 7) NULL DEFAULT 0
       , UCCNo         NVARCHAR(20)   NULL DEFAULT ''
       , VASCartonType NVARCHAR(10)   NULL DEFAULT ''
       , CartonWeight  DECIMAL(20, 7)
      ) 
      CREATE INDEX IDX_CTN ON #CARTON (OrderGroup, Orderkey)
      CREATE INDEX IDX_CTN_ORD_CTN ON #CARTON (Orderkey, CartonNo)                              
  
      CREATE TABLE #CARTONDETAIL
      (
         RowID      INT          IDENTITY(1, 1) PRIMARY KEY
       , OrderGroup NVARCHAR(10) NOT NULL
       , Orderkey   NVARCHAR(10) NOT NULL
       , CartonNo   INT
       , Storerkey  NVARCHAR(15)
       , Sku        NVARCHAR(20)
       , Qty        INT
       , RowRef     INT
      )
      CREATE INDEX IDX_CTNDET ON #CARTONDETAIL (OrderGroup, Orderkey, CartonNo)
      CREATE INDEX IDX_CTNDET_ORD_CTN_SKU ON #CARTONDETAIL (Orderkey, CartonNo, Sku)                                                               
        
      CREATE TABLE #ROWTRACK (RowID INT PRIMARY KEY)
      CREATE TABLE #CTNTRACK (RowID INT PRIMARY KEY)
  
      CREATE TABLE #SKUGROUP
      (
         RowID     INT           IDENTITY(1, 1) PRIMARY KEY
       , SkuGroup  NVARCHAR(10)
       , ItemClass NVARCHAR(10)
       , TotalCube DECIMAL(15, 7)
      )

      CREATE TABLE #TMP_PACK (
         Orderkey    NVARCHAR(10)
       , Storerkey   NVARCHAR(15)
       , SKU         NVARCHAR(20)
       , LabelNo     NVARCHAR(20)
       , UCCNo       NVARCHAR(20)
      )
                                                                                                            
      SELECT @c_RLWAV_Opt5 = SC.Option5  
      FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'WAVGENPACKFROMPICKED_SP') AS SC   
              
      SELECT @c_CartonItemOptimize = dbo.fnc_GetParamValueFromString('@c_CartonItemOptimize', @c_RLWAV_Opt5, @c_CartonItemOptimize)
      SELECT @c_VASFlag = dbo.fnc_GetParamValueFromString('@c_VASFlag', @c_RLWAV_Opt5, @c_VASFlag)

      SET @c_DefaultPackInfoFlag = '0'  
      SELECT @c_DefaultPackInfoFlag = dbo.fnc_GetRight('', @c_Storerkey, '', 'DEFAULT_PACKINFO')       

      --Order sku info  
      INSERT INTO #ORDERSKU (Orderkey, Storerkey, Sku, TotalQty, TotalCube, TotalQtyPacked, TotalCubePacked, StdCube
                           , Length, Width, Height, OrderType, Consigneekey)
      SELECT PD.OrderKey
           , PD.Storerkey
           , PD.Sku
           , SUM(PD.Qty) AS TotalQty
           , SUM(PD.Qty * CASE WHEN ISNULL(SKU.STDCUBE, 0) > 0 THEN SKU.STDCUBE
                               ELSE (SKU.Length * SKU.Width * SKU.Height) END) AS TotalCube
           , 0 TotalQtyPacked
           , 0 TotalCubePacked
           , CASE WHEN ISNULL(SKU.STDCUBE, 0) > 0 THEN SKU.STDCUBE
                  ELSE (SKU.Length * SKU.Width * SKU.Height) END AS StdCube
           , SKU.Length
           , SKU.Width
           , SKU.Height
           , OH.[Type]
           , OH.ConsigneeKey
      FROM #PickDetail_WIP PD
      JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = PD.OrderKey
      JOIN dbo.LOC (NOLOCK) ON PD.Loc = LOC.Loc
      JOIN dbo.SKU (NOLOCK) ON PD.Storerkey = SKU.StorerKey AND PD.Sku = SKU.Sku
      JOIN dbo.PACK (NOLOCK) ON SKU.PACKKey = PACK.PackKey
      WHERE PD.WaveKey = @c_Wavekey
      AND PD.[Status] = '0'
      AND PD.WIP_Refno = @c_SourceType
      GROUP BY PD.OrderKey
             , PD.Storerkey
             , PD.Sku
             , SKU.Length
             , SKU.Width
             , SKU.Height
             , CASE WHEN ISNULL(SKU.STDCUBE, 0) > 0 THEN SKU.STDCUBE
                    ELSE (SKU.Length * SKU.Width * SKU.Height) END
             , OH.[Type]
             , OH.ConsigneeKey
      ORDER BY PD.OrderKey
             , TotalCube DESC
             , PD.Sku

      ;WITH ORD_AGG AS (
         SELECT O.Orderkey, O.Storerkey, O.SKU, TotalQtyPacked = SUM(PD.ExpQty), TotalCubePacked = SUM(PD.ExpQty * O.StdCube)
         FROM #ORDERSKU O
         JOIN PACKHEADER PH (NOLOCK) ON PH.OrderKey = O.Orderkey
         JOIN PACKDETAIL PD (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo
                                    AND PD.Storerkey = O.Storerkey
                                    AND PD.SKU = O.SKU
         GROUP BY O.Orderkey, O.Storerkey, O.SKU )
      UPDATE OS
      SET OS.TotalQtyPacked = ISNULL(OA.TotalQtyPacked, 0)
        , OS.TotalCubePacked = ISNULL(OA.TotalCubePacked, 0)
        , IsFullyPacked = IIF(OS.TotalQty - ISNULL(OA.TotalQtyPacked, 0) = 0, 'Y', OS.IsFullyPacked)
      FROM #ORDERSKU OS
      JOIN ORD_AGG OA ON OA.Orderkey = OS.Orderkey
                     AND OA.Storerkey = OS.Storerkey
                     AND OA.Sku = OS.Sku

      IF @b_debug = 1
         SELECT * FROM #ORDERSKU

      --Cartonization info  
      INSERT INTO #CARTONIZATION (CartonizationGroup, CartonType, UseSequence, Cube, MaxWeight, MaxCount, MaxSku
                                , CartonLength, CartonWidth, CartonHeight, IsGeneric, CartonWeight)
      SELECT CZ.CartonizationGroup
           , CZ.CartonType
           , CZ.UseSequence
           , CASE WHEN ISNULL(CZ.Cube, 0) = 0 THEN
                     ISNULL(CZ.CartonLength, 0) * ISNULL(CZ.CartonWidth, 0) * ISNULL(CZ.CartonHeight, 0)
                  ELSE CZ.Cube END * (CASE WHEN ISNULL(CZ.FillTolerance, 0) = 0 THEN 1
                                           ELSE CZ.FillTolerance * 0.01 END) AS [Cube]
           , CZ.MaxWeight
           , CASE WHEN CZ.MaxCount = 0 THEN 9999999
                  ELSE CZ.MaxCount END AS [MaxCount]
           , 9999999 AS [MaxSku]
           , ISNULL(CZ.CartonLength, 0)
           , ISNULL(CZ.CartonWidth, 0)
           , ISNULL(CZ.CartonHeight, 0)
           , 1
           , ISNULL(CZ.CartonWeight, 0)
      FROM dbo.CARTONIZATION CZ (NOLOCK)
      WHERE CZ.CartonizationGroup = @c_CartonGroup           
        
      IF @b_debug = 1  
        SELECT * FROM #CARTONIZATION
        
      INSERT INTO #TMP_PACK (Orderkey, Storerkey, SKU, LabelNo, UCCNo)
      SELECT DISTINCT PH.OrderKey, PD.StorerKey, PD.SKU, PD.LabelNo, PD.RefNo
      FROM #PickDetail_WIP PW
      JOIN PACKHEADER PH (NOLOCK) ON PH.OrderKey = PW.Orderkey
      JOIN PACKDETAIL PD (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo
      WHERE PW.WaveKey = @c_Wavekey
      AND PW.[Status] = '0'
      AND PW.WIP_Refno = @c_SourceType
      
      IF @c_VASFlag = 'Y'
      BEGIN
         --For VAS CartonType  
         INSERT INTO #CARTONIZATION (CartonizationGroup, CartonType, UseSequence, Cube, MaxWeight, MaxCount, MaxSku
                                   , CartonLength, CartonWidth, CartonHeight, IsGeneric, CartonWeight)
         SELECT CZ.CartonizationGroup
              , CZ.CartonType
              , CZ.UseSequence
              , CASE WHEN ISNULL(CZ.Cube, 0) = 0 THEN
                        ISNULL(CZ.CartonLength, 0) * ISNULL(CZ.CartonWidth, 0) * ISNULL(CZ.CartonHeight, 0)
                     ELSE CZ.Cube END * (CASE WHEN ISNULL(CZ.FillTolerance, 0) = 0 THEN 1
                                              ELSE CZ.FillTolerance * 0.01 END) AS [Cube]
              , CZ.MaxWeight
              , CASE WHEN CZ.MaxCount = 0 THEN 9999999
                     ELSE CZ.MaxCount END AS [MaxCount]
              , 9999999 AS [MaxSku]
              , ISNULL(CZ.CartonLength, 0)
              , ISNULL(CZ.CartonWidth, 0)
              , ISNULL(CZ.CartonHeight, 0)
              , 0
              , ISNULL(CZ.CartonWeight, 0)
         FROM dbo.CARTONIZATION CZ (NOLOCK)
         WHERE CZ.CartonizationGroup = TRIM(@c_CartonGroup) + 'CUST'
      END
   END  -- IF @n_continue IN(1,2)  
  
   --------------------------------------------------  
   -- Process Cartonization for None MPOC Orders  
   --------------------------------------------------  
   IF @n_continue IN(1,2)   
   BEGIN  
      IF @b_debug=2  
      BEGIN  
          PRINT '*** Process Cartonization for Orders ***'  
          PRINT '** Carton Group: ' + @c_CartonGroup   
      END
      
      DECLARE CUR_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT DISTINCT OS.Orderkey  
         FROM #ORDERSKU OS
         WHERE OS.IsFullyPacked = 'N'
         ORDER BY OS.Orderkey  
        
      OPEN CUR_ORD  
        
      FETCH NEXT FROM CUR_ORD INTO @c_Orderkey  
        
      WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)   
      BEGIN              
         TRUNCATE TABLE #SKUGROUP

         SET @c_NewCarton = 'Y'  
         SET @n_CartonNo = 0
         SET @n_ActualCartonNo = 0

         SELECT @n_CartonNo = MAX(CartonNo)  
         FROM #CARTON  
         WHERE Orderkey = @c_Orderkey  
             
         SET @n_CartonNo = ISNULL(@n_CartonNo,0)
         
         SELECT @n_ActualCartonNo = ISNULL(MAX(PD.CartonNo), 0)
         FROM PACKHEADER PH (NOLOCK)
         JOIN PACKDETAIL PD (NOLOCK) ON PH.Pickslipno = PD.PickSlipNo
         WHERE PH.Orderkey = @c_Orderkey
         
         SET @n_ActualCartonNo = ISNULL(@n_ActualCartonNo,0)
         
         IF @n_ActualCartonNo > @n_CartonNo
            SET @n_CartonNo = @n_ActualCartonNo
           
         IF @b_debug=2  
         BEGIN  
            PRINT '---- OrderKey: ' + @c_Orderkey + '  ------'  
         END  
  
         IF @c_VASFlag = 'Y'
         BEGIN
            SET @n_ForceCartonMaxSku = 0  
            SELECT TOP 1 @n_ForceCartonMaxSku = IIF(WOD.[Type] = 'J05', 5, 0)
            FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)
            WHERE WOD.ExternWorkOrderKey = @c_Orderkey
            AND WOD.ExternLineNo = '0H'
         
            SET @c_VAS_CartonType = N''  
            SELECT TOP 1 @c_VAS_CartonType= REPLACE(WOD.Type, 'U', 'RS')
            FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)
            WHERE WOD.ExternWorkOrderKey = @c_Orderkey
            AND WOD.Remarks = 'LPNSIZE'
            ORDER BY WOD.ExternLineNo

            IF @c_VAS_CartonType <> ''   
            BEGIN  
               SELECT @n_CartonLength = CZ.CartonLength
                    , @n_CartonWidth = CZ.CartonWidth
                    , @n_CartonHeight = CZ.CartonHeight
                    , @n_CartonMaxCube = CZ.Cube
                    , @n_CartonMaxWeight = CZ.MaxWeight
                    , @n_CartonWeight = CZ.CartonWeight
               FROM #CARTONIZATION CZ   
               WHERE CZ.CartonType = @c_VAS_CartonType  
   
               IF EXISTS ( SELECT 1 FROM #ORDERSKU OS WHERE OS.Orderkey = @c_Orderkey AND OS.StdCube > @n_CartonMaxCube )  
               BEGIN  
                  SELECT TOP 1 @c_SKU = OS.SKU  
                  FROM #ORDERSKU OS WHERE OS.Orderkey = @c_Orderkey AND OS.StdCube > @n_CartonMaxCube  
   
                  SET @n_continue = 3  
                  SET @n_Err = 82012  
                  SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': SKU(s) '+ @c_SKU + ' Standard Cube cannot fit into carton type ' + RTRIM(@c_VAS_CartonType) + '. (mspWAVPK01)'       
                  GOTO QUIT_SP    
               END  
            END -- IF @c_VAS_CartonType <> ''
         END
         
         --Pack full carton qty, UCC full carton for B2B only 
         IF @c_DocType = 'N' 
         BEGIN
            SET @n_CartonMaxCube   = 0
            SET @n_CartonMaxCount  = 0
            SET @n_CartonLength    = 0
            SET @n_CartonWidth     = 0
            SET @n_CartonHeight    = 0
            SET @n_CartonMaxWeight = 0

            DECLARE CUR_UCC CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT OS.RowID, OS.Sku, Qty = SUM(PD.Qty), PD.DropID, OS.StdCube, PA.CubeUOM1, PA.CaseCnt
                 , PA.LengthUOM1, PA.WidthUOM1, PA.HeightUOM1, MaxWeight = (Sku.STDGROSSWGT * PA.CaseCnt)
            FROM #ORDERSKU OS (NOLOCK)
            JOIN #PickDetail_WIP PD (NOLOCK) ON OS.Orderkey = PD.Orderkey AND OS.Storerkey = PD.Storerkey AND OS.Sku = PD.Sku     
            JOIN dbo.SKU SKU (NOLOCK) ON OS.Sku = SKU.SKU and OS.Storerkey = SKU.Storerkey  
            JOIN dbo.PACK PA (NOLOCK) ON SKU.PackKey = PA.PackKey  
            WHERE OS.Orderkey = @c_Orderkey  
            AND PD.UOM = '2'  
            AND ISNULL(PD.DropID,'') <> ''
            GROUP BY OS.RowID, OS.Sku, PD.DropID, OS.StdCube, PA.CubeUOM1, PA.CaseCnt
                   , PA.LengthUOM1, PA.WidthUOM1, PA.HeightUOM1, Sku.STDGROSSWGT
            ORDER BY OS.RowID
       
            OPEN CUR_UCC  
            
            FETCH NEXT FROM CUR_UCC INTO @n_RowID, @c_Sku, @n_PackQty, @c_UCCNo, @n_StdCube, @n_CartonMaxCube
                                       , @n_CartonMaxCount, @n_CartonLength, @n_CartonWidth, @n_CartonHeight, @n_CartonMaxWeight
            
            WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)   
            BEGIN                   
               SET @c_Consigneekey = N''  
               SET @c_OrderType = N''  
               SET @c_LabelNo = N''  

               --If already packed, do not pack again but update TotalQtyPacked & TotalCubePacked
               IF NOT EXISTS ( SELECT 1
                               FROM #TMP_PACK P
                               WHERE P.OrderKey = @c_Orderkey
                               AND P.StorerKey = @c_Storerkey
                               AND P.SKU = @c_Sku
                               AND P.UCCNo = @c_UCCNo )
               BEGIN
                  SELECT @c_Consigneekey = O.Consigneekey  
                       , @c_OrderType = O.OrderType
                  FROM #ORDERSKU O
                  WHERE O.Orderkey = @c_Orderkey
                  
                  IF EXISTS ( SELECT 1  
                               FROM CODELKUP CL WITH (NOLOCK)  
                               WHERE CL.ListName = 'GS1xLabel'  
                               AND CL.Code = @c_Consigneekey  
                             )  
                  BEGIN  
                     IF EXISTS ( SELECT 1  
                                 FROM CODELKUP CL WITH (NOLOCK)  
                                 WHERE CL.ListName = 'LVSSTO'  
                                 AND CL.Storerkey = @c_Storerkey  
                                 AND CL.Code = @c_Consigneekey  
                                 AND CL.Short = @c_OrderType  
                               )  
                     BEGIN  
                        SET @c_LabelNo = @c_UCCNo  
                     END  
                  END

                  SET @n_CartonNo = @n_CartonNo + 1

                  INSERT INTO #CARTON (Orderkey, CartonNo, LabelNo, CartonGroup, CartonType, MaxCube, MaxWeight, MaxCount, MaxSku,   
                                       CartonLength, CartonWidth, CartonHeight, UCCNo, OrderGroup, VASCartonType, CartonWeight)  
                  VALUES (@c_Orderkey, @n_CartonNo, @c_LabelNo, @c_CartonGroup, 'UCC', @n_CartonMaxCube, @n_CartonMaxWeight, @n_CartonMaxCount, 1
                        , @n_CartonLength, @n_CartonWidth, @n_CartonHeight, @c_UCCNo, '', '', @n_CartonMaxWeight)                                
              
                  INSERT INTO #CARTONDETAIL (OrderGroup, Orderkey, Storerkey, Sku, CartonNo, Qty, RowRef)  --refer to ORDERSKU.RowID  
                  VALUES ('', @c_Orderkey, @c_Storerkey, @c_Sku, @n_CartonNo, @n_PackQty, @n_RowID)   
               END
               
               UPDATE #ORDERSKU   
               SET TotalQtyPacked = TotalQtyPacked + @n_PackQty
                 , TotalCubePacked = TotalCubePacked + (@n_PackQty * @n_StdCube)
               WHERE RowID = @n_RowID
                             
               FETCH NEXT FROM CUR_UCC INTO @n_RowID, @c_Sku, @n_PackQty, @c_UCCNo, @n_StdCube, @n_CartonMaxCube
                                          , @n_CartonMaxCount, @n_CartonLength, @n_CartonWidth, @n_CartonHeight, @n_CartonMaxWeight
            END  
            CLOSE CUR_UCC  
            DEALLOCATE CUR_UCC                                                                                        
         END -- IF @c_DocType = 'N'

         IF @b_debug=2  
         BEGIN           
            IF EXISTS(SELECT 1 FROM #CARTONDETAIL)  
            BEGIN  
               PRINT '*** Full Carton '  
               SELECT *   
               FROM  #CARTONDETAIL  
               WHERE Orderkey = @c_Orderkey   
            END   
         END   
  
         /**************************************************/  
         --      Pack loose carton  
         /**************************************************/  
         SET @c_NewCarton = 'Y'  
  
         INSERT INTO #SKUGROUP (SkuGroup, ItemClass, TotalCube)
         SELECT SKU.SKUGROUP
              , SKU.itemclass
              , SUM(O.StdCube * (O.TotalQty - O.TotalQtyPacked))
         FROM #ORDERSKU O
         JOIN dbo.SKU SKU WITH (NOLOCK) ON O.Storerkey = SKU.StorerKey AND O.Sku = SKU.Sku
         WHERE O.Orderkey = @c_Orderkey AND O.TotalQty - O.TotalQtyPacked > 0
         GROUP BY SKU.SKUGROUP
                , SKU.itemclass
  
         SELECT @n_OrderCube = SUM(O.TotalCube - O.TotalCubePacked)  
         FROM #ORDERSKU O  
         WHERE O.Orderkey = @c_Orderkey  
         AND O.TotalQty - O.TotalQtyPacked > 0  
            
         DECLARE CUR_ORDCTNGROUP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT O.Sku
              , SUM(O.TotalQty - O.TotalQtyPacked)
              , O.Length
              , O.Width
              , O.Height
              , O.StdCube
              , SKU.SKUGROUP
              , SKU.itemclass
         FROM #ORDERSKU O
         JOIN dbo.SKU SKU WITH (NOLOCK) ON O.Storerkey = SKU.StorerKey AND O.Sku = SKU.Sku
         WHERE O.Orderkey = @c_Orderkey 
         AND O.TotalQty - O.TotalQtyPacked > 0
         GROUP BY O.Sku
                , O.Length
                , O.Width
                , O.Height
                , O.StdCube
                , SKU.SKUGROUP
                , SKU.itemclass
         ORDER BY SKU.SKUGROUP
                , SKU.itemclass
                , O.Sku
           
         OPEN CUR_ORDCTNGROUP  
           
         FETCH NEXT FROM CUR_ORDCTNGROUP INTO @c_Sku, @n_OrderQty, @n_SKULength, @n_SKUWidth, @n_SKUHeight, @n_StdCube, @c_SkuGroup, @c_ItemClass   
           
         SET @n_CartonNo = 0
         SET @n_ActualCartonNo = 0
         WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)  --pack by order  
         BEGIN          
            SELECT @n_VAS_LineCount = 0  
            SELECT @n_VAS_QtyCanPack = 0

            IF @c_VASFlag = 'Y'
            BEGIN
               SELECT @n_VAS_LineCount = COUNT(1)   
               FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)   
               JOIN ORDERDETAIL OD WITH (NOLOCK) ON WOD.ExternWorkOrderKey = OD.OrderKey and WOD.ExternLineNo = OD.OrderLineNumber  
               WHERE WOD.ExternWorkOrderKey = @c_Orderkey  
               AND OD.Sku = @c_Sku  
               AND WOD.Type IN ('S02','S06')
               
               -- @b_MDS_Flag  
               IF EXISTS (SELECT 1  
                          FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)   
                          JOIN ORDERDETAIL OD WITH (NOLOCK) ON WOD.ExternWorkOrderKey = OD.OrderKey and WOD.ExternLineNo = OD.OrderLineNumber  
                          WHERE WOD.ExternWorkOrderKey = @c_Orderkey  
                          AND OD.Sku = @c_Sku  
                          AND WOD.Type = 'MDS')
                  SET @b_MDS_Flag = 1  
               ELSE  
                  SET @b_MDS_Flag = 0  
   
               IF @n_VAS_LineCount = 1  
               BEGIN  
                  SET @c_NewCarton = 'Y'  
   
                  SELECT @n_VAS_QtyCanPack = WOD.Qty   
                  FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)   
                  JOIN ORDERDETAIL OD WITH (NOLOCK) ON WOD.ExternWorkOrderKey = OD.OrderKey and WOD.ExternLineNo = OD.OrderLineNumber  
                  WHERE WOD.ExternWorkOrderKey = @c_Orderkey  
                  AND OD.Sku = @c_Sku  
                  AND WOD.Type IN ('S02','S06')
               END  
               ELSE IF @n_VAS_LineCount > 1  
               BEGIN  
                  SET @c_NewCarton = 'Y'  
   
                  SELECT @n_VAS_QtyCanPack = WOD.Qty   
                  FROM dbo.WorkOrderDetail WOD WITH (NOLOCK)   
                  JOIN ORDERDETAIL OD WITH (NOLOCK) ON WOD.ExternWorkOrderKey = OD.OrderKey and WOD.ExternLineNo = OD.OrderLineNumber  
                  WHERE WOD.ExternWorkOrderKey = @c_Orderkey  
                  AND OD.Sku = @c_Sku  
                  AND WOD.Type = 'S02'                   
               END
            END
            
            IF @c_NewCarton = 'N'  
            BEGIN  
               -- If Current Carton SKU Group and Item Class not match to current SKU. Pack to new carton  
               IF NOT EXISTS (SELECT 1 FROM #CARTONDETAIL CTD   
                              JOIN dbo.SKU SKU WITH (NOLOCK) ON SKU.StorerKey = CTD.Storerkey AND SKU.Sku = CTD.Sku   
                              WHERE SKU.SKUGROUP = @c_SkuGroup AND SKU.ItemClass = @c_ItemClass  
                              AND CTD.CartonNo = @n_CartonNo AND CTD.Orderkey = @c_Orderkey )  
               BEGIN  
                   SET @c_NewCarton = 'Y'  
               END  
            END

            IF @n_ForceCartonMaxSku > 0  
            BEGIN  
               IF (SELECT COUNT(DISTINCT SKU) FROM #CARTONDETAIL WHERE Orderkey = @c_Orderkey AND CartonNo = @n_CartonNo) >= @n_ForceCartonMaxSku  
               BEGIN  
                  SET @c_NewCarton = 'Y'  
  
                  IF @b_debug=2  
                     PRINT 'ForceCartonMaxSku: ' + CAST(@n_ForceCartonMaxSku AS VARCHAR(20))   
               END  
            END  
  
            WHILE 1=1 AND @n_continue IN(1,2) AND @n_OrderQty > 0  
            BEGIN      
               SELECT @n_QtyCanPackByCube = 0, @n_QtyCanPackByCount = 0, @n_QtyCanPack = 0  
  
               --SELECT @n_OrderCube = @n_OrderQty * @n_StdCube  
  
               IF @b_debug=2  
               BEGIN  
                  PRINT 'NewCarton: ' + @c_NewCarton + ' Order Qty: ' +CAST(@n_OrderQty AS VARCHAR(20)) + ' Order Cube: ' + CAST(@n_OrderCube AS VARCHAR(20))   
                        + ' StdCube: ' + CAST(@n_StdCube AS VARCHAR(20))   
               END  
                 
               IF @c_NewCarton = 'Y' --new carton  
               BEGIN               
                  SELECT @n_CartonMaxCube = 0, @n_CartonMaxCount = 0, @n_CartonMaxWeight = 0, @c_NewCarton = 'N', @n_CartonNo = 0, @c_CartonType = ''  
                  SELECT @n_CartonLength = 0, @n_CartonWidth = 0, @n_CartonHeight = 0, @n_CartonRemainCube=0     
                    
                  IF @n_VAS_QtyCanPack > 0 AND @c_VASFlag = 'Y'  
                  BEGIN  
                     SET @c_NewCarton = 'Y'
  
                     IF @b_debug = 2 
                        PRINT 'VAS_QtyCanPack > 0, New Carton'  
                  END

                  SELECT @n_CartonNo = MAX(CartonNo)  
                  FROM #CARTON  
                  WHERE Orderkey = @c_Orderkey  
                      
                  SET @n_CartonNo = ISNULL(@n_CartonNo,0)
                  
                  SET @n_ActualCartonNo = 0
                  SELECT @n_ActualCartonNo = ISNULL(MAX(PD.CartonNo), 0)
                  FROM PACKHEADER PH (NOLOCK)
                  JOIN PACKDETAIL PD (NOLOCK) ON PH.Pickslipno = PD.PickSlipNo
                  WHERE PH.Orderkey = @c_Orderkey

                  SET @n_ActualCartonNo = ISNULL(@n_ActualCartonNo,0)

                  IF @n_ActualCartonNo > @n_CartonNo
                     SET @n_CartonNo = @n_ActualCartonNo
                                                  
                  SET @n_CartonNo = @n_CartonNo + 1  

                  IF @c_VAS_CartonType <> '' AND @c_VASFlag = 'Y'
                  BEGIN  
                     SET @c_CartonType = @c_VAS_CartonType  
  
                     -- Check if SKU LxWxH can fit into the carton type  
                     SELECT @c_CartonType = CZ.CartonType
                          , @n_CartonLength = CZ.CartonLength
                          , @n_CartonWidth = CZ.CartonWidth
                          , @n_CartonHeight = CZ.CartonHeight
                          , @n_CartonWeight = CZ.CartonWeight
                     FROM #CARTONIZATION CZ
                     WHERE CZ.CartonType = @c_VAS_CartonType
                    
                     IF dbo.fnc_CartonCanFit(@n_SKULength, @n_SKUWidth, @n_SKUHeight, @n_CartonLength, @n_CartonWidth, @n_CartonHeight) = 0  
                     BEGIN  
                        SET @n_continue = 3  
                        SET @n_Err = 82013  
                        SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': SKU(s) ' + @c_Sku + ' LxWxH cannot fit into carton type ' + RTRIM(@c_VAS_CartonType) + '. (mspWAVPK01)'       
                         GOTO QUIT_SP  
                     END;  
                  END

                  IF @c_CartonType = N''  
                  BEGIN  
                     TRUNCATE TABLE #CTNTRACK  
  
                     WHILE 1=1 AND @n_continue IN(1,2)   
                     BEGIN  
                        SET @c_CartonType = N''  
                        
                        --WITH MDS - 30 Qty per Line, S02/S06 = 10, 10 Qty/ctn, total 3 CTNs, no remainder  
                        --NOT MDS  - 30 Qty per Line, S02/S06 = 8, 3 Cartons - 8 Qty, 1 Carton - 6 Qty total 4 CTNs, with remainder  
                        IF @n_VAS_QtyCanPack > 0 AND @c_VASFlag = 'Y' 
                        BEGIN  
                           SELECT TOP 1 @n_CTNRowID = RowID
                                      , @c_CartonType = CZ.CartonType
                                      , @n_CartonLength = CZ.CartonLength
                                      , @n_CartonWidth = CZ.CartonWidth
                                      , @n_CartonHeight = CZ.CartonHeight
                                      , @n_CartonWeight = CZ.CartonWeight
                           FROM #CARTONIZATION CZ
                           WHERE CZ.Cube >= (@n_StdCube * IIF(@n_OrderQty >= @n_VAS_QtyCanPack, @n_VAS_QtyCanPack, @n_OrderQty))
                           AND   NOT EXISTS (  SELECT 1
                                               FROM #CTNTRACK C
                                               WHERE C.RowID = CZ.RowID)
                           AND   CZ.IsGeneric = 1
                           ORDER BY CZ.Cube;
  
                           IF @b_Debug = 10  
                              SELECT 'VAS Qty', (@n_StdCube * IIF(@n_OrderQty >= @n_VAS_QtyCanPack, @n_VAS_QtyCanPack, @n_OrderQty) ), @c_SKU, @n_OrderQty  
                        END  
  
                        IF @c_CartonType = N'' --Pick Carton that can fit the order cube  
                           SELECT TOP 1 @n_CTNRowID = RowID
                                      , @c_CartonType = CZ.CartonType
                                      , @n_CartonLength = CZ.CartonLength
                                      , @n_CartonWidth = CZ.CartonWidth
                                      , @n_CartonHeight = CZ.CartonHeight
                                      , @n_CartonWeight = CZ.CartonWeight
                           FROM #CARTONIZATION CZ
                           WHERE CZ.Cube >= @n_OrderCube 
                           AND NOT EXISTS ( SELECT 1
                                            FROM #CTNTRACK C
                                            WHERE C.RowID = CZ.RowID)
                           AND CZ.IsGeneric = 1
                           ORDER BY CZ.Cube

                        -- Pick carton type that can fit the entire SKU Group total Cude  
                        IF @c_CartonType = N''  
                        BEGIN  
                           SET @n_SKUGroupCube = 0  
  
                           SELECT @n_SKUGroupCube = TotalCube   
                           FROM #SKUGROUP   
                           WHERE SkuGroup = @c_SkuGroup   
                           and ItemClass = @c_ItemClass
  
                           IF @b_debug=2  
                           BEGIN  
                              PRINT ' SKUGroup Cube: ' + CAST(@n_SKUGroupCube AS VARCHAR(20))   
                                      + ' Sku Group: ' + @c_SkuGroup + ' Item Class: ' + @c_ItemClass   
                              SELECT * FROM #SKUGROUP  
                           END  
  
                           IF @n_SKUGroupCube > 0   
                           BEGIN  
                              SELECT TOP 1 @n_CTNRowID = RowID
                                         , @c_CartonType = CZ.CartonType
                                         , @n_CartonLength = CZ.CartonLength
                                         , @n_CartonWidth = CZ.CartonWidth
                                         , @n_CartonHeight = CZ.CartonHeight
                                         , @n_CartonWeight = CZ.CartonWeight  
                              FROM #CARTONIZATION CZ
                              WHERE CZ.Cube >= @n_SKUGroupCube 
                              AND NOT EXISTS ( SELECT 1
                                               FROM #CTNTRACK C
                                               WHERE C.RowID = CZ.RowID) 
                              AND CZ.IsGeneric = 1
                              ORDER BY CZ.Cube DESC  
                           END   
                        END  
                        -- If can't find carton can fit SKU Group Cube,   
                        -- Pick other carton that can fit the SKU Standard Cude  
                        IF @c_CartonType = N''  
                        BEGIN  
                           SELECT TOP 1 @n_CTNRowID = RowID
                                      , @c_CartonType = CZ.CartonType
                                      , @n_CartonLength = CZ.CartonLength
                                      , @n_CartonWidth = CZ.CartonWidth
                                      , @n_CartonHeight = CZ.CartonHeight
                                      , @n_CartonWeight = CZ.CartonWeight  
                           FROM #CARTONIZATION CZ
                           WHERE CZ.Cube >= @n_StdCube 
                           AND NOT EXISTS ( SELECT 1
                                            FROM #CTNTRACK C
                                            WHERE C.RowID = CZ.RowID) 
                           AND CZ.IsGeneric = 1
                           ORDER BY CZ.Cube DESC 
                        END
                        
                        IF @c_CartonType = N''   
                        BEGIN  
                            SET @n_OrderQty=0;  
                            IF @b_debug=2  
                            BEGIN  
                               PRINT 'Cannot find any carton type can fit. Order No: ' + @c_Orderkey    
                            END   
                            BREAK;  
                        END  
                        ELSE  
                           BREAK;

                        INSERT INTO #CTNTRACK VALUES (@n_CTNRowID)  
                     END -- WHILE 1=1  
                  END -- IF @c_CartonType = N''  
                                         
                  IF @c_CartonType = ''  
                  BEGIN  
                     SET @n_OrderQty=0  
  
                     SET @n_continue = 3  
                     SET @n_Err = 562204  
                     SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Unable to find Carton type for Order: ' + RTRIM(@c_Orderkey) + '.(mspWAVPK01)'  
  
                     IF @b_debug=2  
                        PRINT @c_Errmsg  
  
                     BREAK                   
                  END                                             
                     
                  --Get carton setup  
                  SELECT @n_CartonMaxCube = CZ.Cube
                       , @n_CartonRemainCube = CZ.Cube
                       , @n_CartonMaxWeight = CZ.MaxWeight
                       , @n_CartonMaxCount = CZ.MaxCount
                       , @n_CartonMaxSku = CZ.MaxSku
                       , @n_CartonWeight = CZ.CartonWeight
                  FROM #CARTONIZATION CZ (NOLOCK)
                  WHERE CZ.CartonType = @c_CartonType
                  
                  INSERT INTO #CARTON (Orderkey, CartonNo, LabelNo, CartonGroup, CartonType, MaxCube, MaxWeight, MaxCount,   
                                       MaxSku, CartonLength, CartonWidth, CartonHeight, UCCNo, OrderGroup, VASCartonType, CartonWeight)  
                  VALUES (@c_Orderkey, @n_CartonNo, '', @c_CartonGroup, @c_CartonType, @n_CartonMaxCube, @n_CartonMaxWeight,   
                         @n_CartonMaxCount, @n_CartonMaxSku, @n_CartonLength , @n_CartonWidth, @n_CartonHeight, '', '', @c_VAS_CartonType, @n_CartonWeight)    
               END -- IF @c_NewCarton = 'Y'  
                 
               IF @b_debug=2  
               BEGIN  
                     PRINT 'Carton No: ' + CAST(@n_CartonNo As varchar(10)) + ' Carton Type: ' + @c_CartonType + ' Max Cube: ' + CAST(@n_CartonMaxCube AS VARCHAR(20))  
               END  
  
               --Get item to pack  
               TRUNCATE TABLE #ROWTRACK  
  
               --Try search all items of the order that can fit the remaining space of the carton, priority by Sku   
               WHILE @n_QtyCanPack = 0 AND @n_continue IN(1,2)    
               BEGIN                     
                  SET @n_RowID = 0                      
  
                  IF EXISTS(SELECT 1 FROM #CARTONDETAIL WHERE CartonNo = @n_CartonNo AND Orderkey = @c_Orderkey)  
                  BEGIN  
                     IF @b_debug=2  
                     BEGIN  
                        PRINT '-- Exists in Carton Detail'  
                        PRINT '-- CartonRemainCube: ' + CAST(@n_CartonRemainCube as VARCHAR(20)) + ', @n_StdCube: ' + CAST(@n_StdCube as VARCHAR(20))  
                     END  
  
                     IF @c_VAS_CartonType <> '' AND @c_VASFlag = 'Y'
                     BEGIN  
                        --Get the SKU remaining Qty regardless of Volume  
                        SELECT TOP 1 @n_RowID = OS.RowID                             
                                   , @n_StdCube = OS.StdCube 
                                   , @n_PackQty = OS.TotalQty - OS.TotalQtyPacked  
                        FROM #ORDERSKU OS (NOLOCK)  
                        WHERE OS.Orderkey = @c_Orderkey  
                        AND OS.TotalQty - OS.TotalQtyPacked > 0  
                        AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)  
                        AND OS.Sku = @c_Sku  
                        ORDER BY (OS.TotalCube - OS.TotalCubePacked) DESC, OS.Sku  
                     END  
  
                     IF @n_RowID = 0  
                     BEGIN  
                        --Get the sku can fully best fit in the existing carton  
                        SELECT TOP 1 @n_RowID = OS.RowID
                                   , @n_StdCube = OS.StdCube
                                   , @n_PackQty = OS.TotalQty - OS.TotalQtyPacked
                        FROM #ORDERSKU OS (NOLOCK)  
                        WHERE OS.Orderkey = @c_Orderkey  
                        AND OS.TotalQty - OS.TotalQtyPacked > 0  
                        AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)  
                        AND @n_CartonRemainCube >= (OS.TotalCube - OS.TotalCubePacked)  
                        AND OS.Sku = @c_Sku  
                        ORDER BY (OS.TotalCube - OS.TotalCubePacked) DESC, OS.Sku  
                     END    
                     IF @n_RowID = 0  
                     BEGIN  
                       --Get the smaller cube of the sku mix with existing carton   
                       SELECT TOP 1 @n_RowID = OS.RowID
                                  , @n_StdCube = OS.StdCube
                                  , @n_PackQty = OS.TotalQty - OS.TotalQtyPacked
                       FROM #ORDERSKU OS (NOLOCK)  
                       WHERE OS.Orderkey = @c_Orderkey  
                       AND OS.TotalQty - OS.TotalQtyPacked > 0  
                       AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)  
                       AND OS.StdCube <= @n_CartonRemainCube  
                       AND OS.Sku = @c_Sku  
                       ORDER BY (OS.TotalCube - OS.TotalCubePacked), OS.Sku                           
                     END
                 END  
                 ELSE  
                 BEGIN  
                     --Get the sku by larger cube sequence to the new carton  
                     SELECT TOP 1 @n_RowID = OS.RowID
                                , @c_Sku = OS.Sku
                                , @n_StdCube = OS.StdCube
                                , @n_PackQty = OS.TotalQty - OS.TotalQtyPacked
                     FROM #ORDERSKU OS (NOLOCK)  
                     WHERE OS.Orderkey = @c_Orderkey  
                     AND OS.TotalQty - OS.TotalQtyPacked > 0  
                     AND OS.Sku = @c_Sku  
                     AND OS.RowID NOT IN(SELECT RowID FROM #ROWTRACK)  
                     ORDER BY OS.RowID  
                  END                                                                     
  
                  IF @b_debug=2  
                  BEGIN  
                        PRINT 'SKU: ' + @c_Sku + ' StdCube: ' + CAST(@n_StdCube AS VARCHAR(20))   
                            + ' Pack Qty: ' + CAST(@n_PackQty AS VARCHAR(20)) + ' Row ID: ' + CAST(@n_RowID AS VARCHAR(20))  
                  END  
            
                  -- No outstanding Item to pack, go to next order  
                  IF @n_RowID = 0  
                  BEGIN  
                     -- PRINT '-- @n_RowID = 0'  
                      SET @n_QtyCanPack = 0;  
  
                      IF @c_NewCarton = 'Y'  
                          SET @n_OrderQty = 0;  
  
                      BREAK;  
                  END;  
  
                  INSERT INTO #ROWTRACK(RowID) VALUES (@n_RowID)  
                                         
                  --Validate the carton at lease can fit 1 qty of the sku  
                  IF NOT EXISTS(SELECT 1 FROM #CARTONIZATION WHERE Cube >= @n_StdCube AND CartonType = @c_CartonType)   
                  BEGIN  
                     SET @n_continue = 3  
                     SET @n_Err = 562205  
                     SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': No Carton type can fit a Sku ' + RTRIM(@c_Sku) + '.(mspWAVPK01)'  
  
                     IF @b_debug=2  
                     BEGIN  
                        PRINT 'Error: ' + @c_Errmsg  
                     END  
  
                     BREAK  
                  END                  
                  
                  IF @n_StdCube > 0  
                  BEGIN   
                     SET @n_QtyCanPackByCube = FLOOR(@n_CartonRemainCube / @n_StdCube)    
                     SET @n_QtyCanPack = @n_QtyCanPackByCube   
                  END   
                  ELSE   
                     SET @n_QtyCanPack = @n_PackQty
                  
                  IF @n_VAS_QtyCanPack > 0 AND @c_VASFlag = 'Y'  
                  BEGIN  
                     IF @n_QtyCanPack > @n_VAS_QtyCanPack  
                        SET @n_QtyCanPack = @n_VAS_QtyCanPack  
                  END  
  
                  IF @n_StdCube = 0  --if sku cube not setup just pack all qty  
                    SET @n_QtyCanPack = @n_PackQty                                               
                                        
                  IF @n_PackQty < @n_QtyCanPack  
                    SET @n_QtyCanPack = @n_PackQty  
                   
                  IF @b_debug=2  
                  BEGIN  
                      PRINT '>>> QtyCanPackByCube: ' + CAST(@n_QtyCanPackByCube AS VARCHAR(10)) + ' QtyCanPack: '   
                       + CAST(@n_QtyCanPack AS VARCHAR(10)) + ' Remain Cube: ' + CAST(@n_CartonRemainCube AS VARCHAR(20))  
                  END  
                  
                  IF @n_QtyCanPack <> @n_VAS_QtyCanPack AND @b_MDS_Flag = 1 AND @n_VAS_QtyCanPack > 0 AND @c_VASFlag = 'Y'  
                  BEGIN   
                     SET @n_continue = 3  
                     SET @n_Err = 562206  
                     SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Pack Qty not match with VAS Qty for MDS VAS Code. (mspWAVPK01)'  
  
                     IF @b_debug=2  
                     BEGIN  
                        PRINT 'Error: ' + @c_Errmsg  
                     END  
  
                     BREAK  
                  END  
  
                  IF @c_CartonItemOptimize <> 'Y'  
                    BREAK --if current item cannot fit current carton open new carton and not search for other/next item.   
               END -- WHILE @n_QtyCanPack = 0   
                                  
               IF @n_continue = 3  
                  BREAK  
                     
               IF @n_QtyCanPack = 0  --carton full   
               BEGIN  
                  IF @b_debug=2  
                     PRINT '>>> QtyCanPack = 0,New Carton = Y, OrderQty=' + CAST(@n_OrderQty as varchar(10))  
  
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
                  SET @n_CartonRemainCube = @n_CartonRemainCube - (@n_QtyCanPack * @n_StdCube)         
                           
                  UPDATE #ORDERSKU  
                  SET TotalQtyPacked = TotalQtyPacked + @n_QtyCanPack,   
                     TotalCubePacked = TotalCubePacked + (@n_QtyCanPack * @n_StdCube)  
                  WHERE RowID = @n_RowID   
               END   
            END -- WHILE @n_OrderQty > 0  
  
            NEXT_CTNORSKU:       
  
            FETCH NEXT FROM CUR_ORDCTNGROUP INTO @c_Sku, @n_OrderQty, @n_SKULength, @n_SKUWidth, @n_SKUHeight, @n_StdCube, @c_SkuGroup, @c_ItemClass
         END  
         CLOSE CUR_ORDCTNGROUP  
         DEALLOCATE CUR_ORDCTNGROUP  
  
         FETCH_ORDER:  
         FETCH NEXT FROM CUR_ORD INTO @c_Orderkey         
      END  
      CLOSE CUR_ORD  
      DEALLOCATE CUR_ORD  
   END

   --Create pickslip  
   IF @n_continue IN(1,2)  
   BEGIN  
      EXEC dbo.isp_CreatePickSlip  
             @c_Wavekey = @c_Wavekey  
            ,@c_LinkPickSlipToPick = 'Y'
            ,@c_ConsolidateByLoad  = 'N'
            ,@c_AutoScanIn         = 'Y'
            ,@c_Refkeylookup       = 'N'
            ,@c_PickslipType       = '' 
            ,@b_Success            = @b_Success OUTPUT
            ,@n_Err                = @n_Err     OUTPUT
            ,@c_ErrMsg             = @c_ErrMsg  OUTPUT
        
      IF @b_Success <> 1  
         SET @n_Continue = 3       
     
      SET @CUR_WaveOrd = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Orderkey
      FROM WAVEDETAIL (NOLOCK)
      WHERE Wavekey = @c_Wavekey
      ORDER BY Wavedetailkey
             
      OPEN @CUR_WaveOrd
           
      FETCH NEXT FROM @CUR_WaveOrd INTO @c_Orderkey
             
      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
      BEGIN
         UPDATE PICKHEADER WITH (ROWLOCK)
         SET PICKHEADER.Wavekey = @c_Wavekey
           , PICKHEADER.Trafficcop = NULL
         FROM PICKHEADER
         JOIN ORDERS (NOLOCK) ON PICKHEADER.Orderkey = ORDERS.Orderkey
         WHERE PICKHEADER.Orderkey = @c_Orderkey
               
         FETCH NEXT FROM @CUR_WaveOrd INTO @c_Orderkey
      END           
      CLOSE @CUR_WaveOrd
      DEALLOCATE @CUR_WaveOrd
   END  
  
   IF @b_debug > 0  
   BEGIN  
      SELECT * FROM #CARTON  
      SELECT * FROM #CARTONDETAIL  
   END  
        
   --Create packing records Orders  
   IF @n_continue IN(1,2)   
   BEGIN      
      IF @b_debug <> 0   
      BEGIN  
         PRINT '*** Create packing records  ***'  
      END

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
            INSERT INTO dbo.PackHeader (Route, OrderKey, OrderRefNo, Loadkey, Consigneekey, StorerKey, PickSlipNo, ConsoOrderkey)
            SELECT TOP 1 O.Route, O.Orderkey, '', O.LoadKey, '',O.Storerkey, @c_PickSlipNo, @c_OrderGroup
            FROM dbo.PICKHEADER PH (NOLOCK)  
            JOIN dbo.ORDERS O (NOLOCK) ON (PH.Orderkey = O.Orderkey)  
            WHERE PH.PickHeaderKey = @c_PickSlipNo  
           
            SET @n_Err = @@ERROR  
              
            IF @n_Err <> 0  
            BEGIN  
               SELECT @n_continue = 3  
               SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 562208  
               SELECT @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Error Insert Packheader Table (mspWAVPK01)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '  
            END  
         END

         DECLARE CUR_PACKCARTON CURSOR LOCAL FAST_FORWARD READ_ONLY FOR          
         SELECT DISTINCT CT.CartonNo, CT.CartonType, CT.UCCNo, CT.CartonLength, CT.CartonWidth, CT.CartonHeight, CT.VASCartonType  
                       , CT.LabelNo
                       , CT.CartonWeight
         FROM #CARTON CT  
         JOIN #CARTONDETAIL CTD ON CT.Orderkey = CTD.Orderkey AND CT.CartonNo = CTD.CartonNo  
         WHERE CT.Orderkey = @c_Orderkey 
         AND CT.OrderGroup = ''
           
         OPEN CUR_PACKCARTON
         
         FETCH NEXT FROM CUR_PACKCARTON INTO @n_CartonNo, @c_CartonType, @c_UCCNo, @n_CartonLength, @n_CartonWidth, @n_CartonHeight, @c_VAS_CartonType  
                                          ,  @c_LabelNo
                                          ,  @n_CartonWeight 
                      
         WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)  --get Carton  
         BEGIN     
            IF @b_debug <> 0   
              PRINT  '@n_CartonNo: ' + CAST(@n_CartonNo AS VARCHAR(5)) + ' @c_CartonType: ' + @c_CartonType + ' @c_PreOrderGroup: ' + @c_PreOrderGroup

            IF @c_LabelNo = ''
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
       
               --Update labelno to #CARTON  
               IF @c_OrderGroup = ''  
               BEGIN  
                  UPDATE #CARTON   
                     SET LabelNo = @c_LabelNo  
                  WHERE Orderkey = @c_Orderkey  
                  AND CartonNo = @n_CartonNo    
               END  
               ELSE  
               BEGIN  
                  UPDATE #CARTON   
                  SET LabelNo = @c_LabelNo  
                  WHERE OrderGroup = @c_OrderGroup  
                  AND CartonNo = @n_CartonNo                   
                  AND Orderkey=''  
               END  
            END  
            
            SELECT @n_TotCartonQty = 0, @n_TotCartonCube = 0, @n_TotCartonWeight = 0, @n_CartonMaxCube = 0

            SELECT @n_CartonMaxCube = CT.MaxCube  
            FROM #Carton CT   
            WHERE CT.OrderKey = @c_Orderkey
            AND CartonNo = @n_CartonNo  
  
            SELECT @n_TotCartonQty  = SUM(CTD.Qty),   
                   @n_TotCartonCube = SUM(CTD.Qty * CASE WHEN ISNULL(SKU.STDCUBE, 0) > 0 THEN  SKU.STDCUBE                           
                       ELSE (SKU.Length * SKU.Width * SKU.Height)   
                       END),  
                  @n_TotCartonWeight = SUM(CTD.Qty * ISNULL(SKU.STDNETWGT,0))
            FROM #CARTONDETAIL CTD
            JOIN SKU WITH (NOLOCK) ON CTD.Storerkey = SKU.StorerKey AND CTD.SKU = SKU.Sku   
            JOIN #CARTON CT ON CTD.CartonNo = CT.CartonNo AND CT.Orderkey = CTD.Orderkey  
            WHERE CTD.Orderkey = @c_Orderkey  
            AND CTD.CartonNo = @n_CartonNo

            -- Check the System Calculate Carton Size and Total SKU Cube, if can find small carton, then use the small carton  
            -- CartonType = '' means not VAS Carton Type  
            -- CartonType = 'UCC' means UCC Carton Type  
            IF @n_TotCartonCube > 0 AND @c_VAS_CartonType = '' AND @c_CartonType <> 'UCC' AND @n_CartonMaxCube > 0  
            BEGIN  
               -- if assign carton size with empty percentage more than 10%, then use the small carton  
               IF @n_CartonMaxCube / @n_TotCartonCube > 1.1  
               BEGIN  
                  SELECT @c_NewCartonType = '', @n_NewCartonMaxCube = 0
                  
                   SELECT TOP 1 @c_NewCartonType = CZ.CartonType
                              , @n_NewCartonMaxCube = CZ.Cube
                              , @n_CartonLength = CZ.CartonLength
                              , @n_CartonWidth = CZ.CartonWidth
                              , @n_CartonHeight = CZ.CartonHeight
                              , @n_CartonWeight = CZ.CartonWeight
                  FROM #CARTONIZATION CZ
                  WHERE CZ.Cube >= @n_TotCartonCube  
                  AND CZ.IsGeneric = 1  
                  ORDER BY CZ.Cube
                  
                  IF @c_NewCartonType <> '' and @c_NewCartonType <> @c_CartonType  
                  BEGIN  
                     UPDATE #CARTON
                     SET CartonType = @c_NewCartonType
                       , MaxCube = @n_NewCartonMaxCube
                       , CartonLength = @n_CartonLength
                       , CartonWidth = @n_CartonWidth
                       , CartonHeight = @n_CartonHeight
                     WHERE OrderGroup = @c_OrderGroup
                     AND CartonNo = @n_CartonNo  
  
                     SET @n_TotCartonCube = @n_NewCartonMaxCube  
                     SET @c_CartonType = @c_NewCartonType  
                     SET @n_CartonMaxCube = @n_NewCartonMaxCube  
  
                     IF @b_debug=2  
                     BEGIN  
                        PRINT '   >>> Reassign New Carton Type: ' + @c_CartonType   
                     END   
                  END
               END  
            END

            --Get packed carton cube,qty,weight              
            --Create packinfo              
            IF EXISTS (SELECT 1 FROM dbo.PackInfo (NOLOCK) 
                       WHERE Pickslipno = @c_PickslipNo  
                       AND CartonNo = @n_CartonNo)  
            BEGIN  
               DELETE FROM dbo.PackInfo 
               WHERE Pickslipno = @c_PickslipNo 
               AND CartonNo = @n_CartonNo  
            END

            INSERT INTO dbo.PackInfo (PickSlipNo, CartonNo, CartonType, Cube, Weight, Qty, Length, Width, Height, RefNo)
            VALUES (@c_PickslipNo, @n_CartonNo, @c_CartonType, @n_CartonMaxCube
                  , CASE WHEN @c_DefaultPackInfoFlag = '1' THEN @n_CartonWeight
                         ELSE @n_CartonWeight + @n_TotCartonWeight END, 0, @n_CartonLength, @n_CartonWidth, @n_CartonHeight
                  , @c_LabelNo)

            SET @n_Err = @@ERROR  
            IF @n_Err <> 0  
            BEGIN  
               SELECT @n_continue = 3  
               SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 562209  
               SELECT @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Error Insert Packinfo Table (mspWAVPK01)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '  
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
               SET @c_LabelLine = ''  
  
               SELECT @c_LabelLine = RIGHT('00000' + CAST(CAST(ISNULL(MAX(PD.LabelLine), 0) AS INT) + 1 AS NVARCHAR(5)), 5)  
               FROM PACKDETAIL PD (NOLOCK)  
               WHERE PD.Pickslipno = @c_Pickslipno  
               AND PD.CartonNo = @n_CartonNo 
                                        
               -- CartonNo and LabelLineNo will be inserted by trigger  
               INSERT INTO dbo.PackDetail (PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, ExpQty, AddWho, AddDate, EditWho, EditDate, Refno, DropId)  
               VALUES (@c_PickSlipNo, @n_CartonNo, @c_LabelNo, @c_LabelLine, @c_StorerKey, @c_SKU,
                       @n_PackQty, sUser_sName(), GETDATE(), sUser_sName(), GETDATE(), @c_UCCNo, '')  
                 
               SET @n_Err = @@ERROR  
               IF @n_Err <> 0  
               BEGIN  
                  SELECT @n_continue = 3  
                  SELECT @c_Errmsg = CONVERT(NVARCHAR(250),@n_Err), @n_Err = 562210  
                  SELECT @c_Errmsg='NSQL'+CONVERT(NVARCHAR(10),@n_Err)+': Error Insert Packdetail Table (mspWAVPK01)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_Errmsg) + ' ) '  
               END  
                
               FETCH NEXT FROM CUR_PACKSKU INTO @c_Storerkey, @c_Sku, @n_PackQty              
            END  
            CLOSE CUR_PACKSKU  
            DEALLOCATE CUR_PACKSKU  
                                                        
            FETCH NEXT FROM CUR_PACKCARTON INTO @n_CartonNo, @c_CartonType, @c_UCCNo, @n_CartonLength, @n_CartonWidth, @n_CartonHeight, @c_VAS_CartonType   
                                              , @c_LabelNo 
                                              , @n_CartonWeight
         END  
         CLOSE CUR_PACKCARTON  
         DEALLOCATE CUR_PACKCARTON        
           
         FETCH NEXT FROM CUR_PACKORDER INTO @c_OrderGroup, @c_Orderkey, @c_Pickslipno           
      END                   
      CLOSE CUR_PACKORDER   
      DEALLOCATE CUR_PACKORDER  
   END

   --Update labelno to pickdetail caseid  
   IF @n_continue IN(1,2)   
   BEGIN              
      --UPDATE #PICKDETAIL_WIP SET CaseID = ''  
      TRUNCATE TABLE #TMP_PACK

      INSERT INTO #TMP_PACK (Orderkey, Storerkey, SKU, LabelNo, UCCNo)
      SELECT DISTINCT PH.OrderKey, PD.StorerKey, PD.SKU, PD.LabelNo, PD.RefNo
      FROM #PickDetail_WIP PW
      JOIN PACKHEADER PH (NOLOCK) ON PH.OrderKey = PW.Orderkey
      JOIN PACKDETAIL PD (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo
      WHERE PW.WaveKey = @c_Wavekey
      AND PW.[Status] = '0'
      AND PW.WIP_Refno = @c_SourceType

      DECLARE CUR_LABELUPD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT CTD.Orderkey, CT.CartonNo, CTD.Storerkey, CTD.Sku, CTD.Qty, CT.LabelNo, CT.UCCNo  
         FROM #CARTON CT  
         JOIN #CARTONDETAIL CTD ON CT.Orderkey = CTD.Orderkey AND CT.CartonNo = CTD.CartonNo  
         WHERE CT.Orderkey > ''

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
            AND NOT EXISTS ( SELECT 1
                             FROM #TMP_PACK P
                             WHERE P.OrderKey = PD.OrderKey
                             AND P.StorerKey = PD.Storerkey
                             AND P.SKU = PD.Sku
                             AND P.LabelNo = PD.CaseID )
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
           ,@c_Wavekey               = @c_Wavekey  
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
   
   QUIT_SP:  
   -----Delete pickdetail_WIP work in progress staging table
   IF @n_continue IN (1,2)
   BEGIN
      EXEC isp_CreatePickdetail_WIP    
            @c_Loadkey               = ''
         ,  @c_Wavekey               = @c_Wavekey
         ,  @c_WIP_RefNo             = @c_SourceType
         ,  @c_PickCondition_SQL     = ''
         ,  @c_Action                = 'D'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records    
         ,  @c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization    
         ,  @b_Success               = @b_Success OUTPUT
         ,  @n_Err                   = @n_Err     OUTPUT
         ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT
               
      IF @b_Success <> 1
      BEGIN
         SET @n_continue = 3
      END
   END
        
   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
      DROP TABLE #PICKDETAIL_WIP
  
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
      EXECUTE dbo.nsp_logerror @n_Err, @c_ErrMsg, 'mspWAVPK01'
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