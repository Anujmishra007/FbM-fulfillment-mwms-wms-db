SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/
/* Stored Procedure: mspRLWAV10_TOTE                                     */
/* Creation Date: 2026-04-14                                             */
/* Copyright: Maersk Logistics                                           */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: FCR-10124 - UK Columbia SportWear Release Wave               */
/*          For ECOM Tote Packing                                        */
/*                                                                       */
/* Called By: Wave                                                       */
/*                                                                       */
/* Version: 4.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author   Ver   Purposes                                   */
/* 14-Apr-2026 WLChooi  1.0   Initial Version                            */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV10_TOTE]
   @c_Wavekey     NVARCHAR(10)
,  @b_Success     INT            = 1   OUTPUT
,  @n_Err         INT            = 0   OUTPUT
,  @c_ErrMsg      NVARCHAR(255)  = ''  OUTPUT
,  @n_debug       INT            = 0
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    

   DECLARE
           @n_StartTCnt             INT   = @@TRANCOUNT
         , @n_Continue              INT   = 1
         , @n_RowCount              INT   = 0
         , @n_Cnt                   INT   = 0

         , @c_SourceType            NVARCHAR(30)   = 'mspRLWAV10'
         , @c_Facility              NVARCHAR(5)    = ''
         , @c_Storerkey             NVARCHAR(15)   = ''
         , @c_Orderkey              NVARCHAR(10)   = ''  
         , @c_PickSlipNo            NVARCHAR(10)   = ''
         , @n_PackGrpNo             INT            = 0
         , @n_HardCTNGrpNo          INT            = 0
         , @n_HardCTNGrpNo_P        INT            = 0
         , @n_SortCTNGrpNo          INT            = 0
         , @c_PackType              NVARCHAR(50)   = ''   
         , @c_HardCTNGroup          NVARCHAR(1000) = ''
         , @c_SortCTNGroup          NVARCHAR(1000) = ''
         , @b_CZN_Check             INT            = 0

         , @n_ID_oitp               INT            = 0
         , @n_RowID_cz              INT            = 0         
         , @n_RowID_pcz             INT            = 0
         , @n_RowID_cd              INT            = 0
         , @n_SkuAccessQty          INT            = 0
         , @n_GetSmaller            INT            = 1 

         , @n_CartonNo_Cnt          INT            = 0
         , @c_IsCompletePack        NVARCHAR(5)    = ''

         , @c_CTNGroup              NVARCHAR(10)   = ''
         , @c_CTNGroup_BTK          NVARCHAR(50)   = ''
         , @c_CartonType_Max        NVARCHAR(10)   = ''
         , @n_CartonCube_Max        FLOAT          = 0.00
         , @n_CartonWeight_Max      FLOAT          = 0.00
         , @c_CartonType            NVARCHAR(10)   = ''
         , @n_CartonLength          FLOAT          = 0.00
         , @n_CartonWidth           FLOAT          = 0.00
         , @n_CartonHeight          FLOAT          = 0.00
         , @n_CartonCube            FLOAT          = 0.00
         , @n_CartonWeight          FLOAT          = 0.00
         , @n_Dim1_Ctn              Decimal(10,6)  = 0.00
         , @n_Dim2_Ctn              Decimal(10,6)  = 0.00
         , @n_Dim3_Ctn              Decimal(10,6)  = 0.00
         , @n_FillTolerance         FLOAT          = 0.00

         , @b_NewCarton             BIT            = 0
         , @b_IsVas                 BIT            = 0
         , @b_API                   BIT            = 0
         , @n_CartonSeqNo           INT            = 0

         , @c_Sku                   NVARCHAR(20)   = ''
         , @c_Sku_P                 NVARCHAR(20)   = ''
         , @c_BUSR7                 NVARCHAR(30)   = ''
         , @c_ItemClass             NVARCHAR(10)   = ''
         , @c_ItemClass_P           NVARCHAR(10)   = ''
         , @c_Size                  NVARCHAR(20)   = ''
         , @c_Size_P                NVARCHAR(20)   = ''
         , @c_UOM                   NVARCHAR(20)   = ''
         , @c_VAS                   NVARCHAR(18)   = ''
         , @n_Length                FLOAT          = 0.00
         , @n_Width                 FLOAT          = 0.00
         , @n_Height                FLOAT          = 0.00
         , @n_StdCube               FLOAT          = 0.00
         , @n_StdGrossWgt           FLOAT          = 0.00
         , @n_Dim1_Sku              Decimal(10,6)  = 0.00
         , @n_Dim2_Sku              Decimal(10,6)  = 0.00
         , @n_Dim3_Sku              Decimal(10,6)  = 0.00
         , @n_PackQtyIndicator      INT            = 0
         , @n_Qty                   INT            = 0
         , @n_Qty_PI                INT            = 0
         , @n_VASQty                INT            = 0
         , @n_VASQty_PI             INT            = 0
         , @n_QtyCBM_PI             INT            = 0
         , @n_QtyWgt_PI             INT            = 0
         , @n_QtyToPack             INT            = 0
         , @n_QtyToPack_PI          INT            = 0
         , @n_ItemQty_SUM           INT            = 0
         , @n_ItemCBM_SUM           FLOAT          = 0.00
         , @n_ItemWgt_SUM           FLOAT          = 0.00
         , @n_ItemCBM               FLOAT          = 0.00
         , @n_ItemWgt               FLOAT          = 0.00
         , @n_TotalQty_PI           INT            = 0
         , @n_TotalCBM              FLOAT          = 0.00
         , @n_TotalWgt              FLOAT          = 0.00
         , @n_QtyLeftToFulFill_PI   INT            = 0
         , @n_CBMLeftToFulFill      FLOAT          = 0.00
         , @n_WgtLeftToFulFill      FLOAT          = 0.00

         , @n_QtyToPack_cd          INT            = 0
         , @n_Qty_pd                INT            = 0
         , @n_QtyToPack_ins         INT            = 0
         , @c_RefPickKey            NVARCHAR(10)   = ''
         , @c_RefPickMode           NVARCHAR(1)    = ''  --blank:no change, S:Split, N:New
         , @c_Notes                 NVARCHAR(50)   = ''
         , @c_PickDetailKey         NVARCHAR(10)   = ''
         , @c_LabelNo               NVARCHAR(20)   = ''

         , @c_SQL                   NVARCHAR(4000) = ''
         , @c_SQLParms              NVARCHAR(4000) = ''
         , @c_SQLCond               NVARCHAR(4000) = ''
         , @c_Option5               NVARCHAR(4000) = '' 
         , @c_OtherParms            NVARCHAR(MAX)  = '' 
         , @b_IsVAS_P               BIT            = 0  
         , @c_Algorithm             NVARCHAR(10)   = '' 
         , @n_RowID_pre             INT            = 0  
         , @c_VAS_P                 NVARCHAR(10)   = '' 

   DECLARE @cur_PCKGRPH          CURSOR
         , @cur_PCKGRPS          CURSOR
         , @cur_PRECTN           CURSOR
         , @cur_SPLPD            CURSOR

   DECLARE @t_CTNZ            TABLE
      (  RowID                INT            IDENTITY(1,1) PRIMARY KEY
      ,  CartonizationGroup   NVARCHAR(10)   NOT NULL DEFAULT ('')
      ,  CartonType           NVARCHAR(10)   NOT NULL DEFAULT ('')
      ,  [Cube]               FLOAT          NOT NULL DEFAULT (0.00)
      ,  MaxWeight            FLOAT          NOT NULL DEFAULT (0.00)
      ,  CartonLength         FLOAT          NOT NULL DEFAULT (0.00)
      ,  CartonWidth          FLOAT          NOT NULL DEFAULT (0.00)
      ,  CartonHeight         FLOAT          NOT NULL DEFAULT (0.00)
      ,  Dim1                 DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
      ,  Dim2                 DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
      ,  Dim3                 DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
      ,  FillTolerance        INT            NOT NULL DEFAULT (0)
      ,  CartonWeight         FLOAT          NOT NULL DEFAULT (0.00)
      )

    DECLARE @TMP_CL              TABLE
      ( [RowID]                  INT               IDENTITY(1,1) PRIMARY KEY
      , [LISTNAME]               [nvarchar](10)    NULL
      , [Code]                   [nvarchar](30)    NULL
      , [Description]            [nvarchar](250)   NULL
      , [Short]                  [nvarchar](10)    NULL
      , [Long]                   [nvarchar](250)   NULL
      , [Notes]                  [nvarchar](4000)  NULL
      , [Notes2]                 [nvarchar](4000)  NULL
      , [Storerkey]              [nvarchar](50)    NOT NULL
      , [UDF01]                  [nvarchar](60)    NOT NULL
      , [UDF02]                  [nvarchar](60)    NOT NULL
      , [UDF03]                  [nvarchar](60)    NOT NULL
      , [UDF04]                  [nvarchar](60)    NOT NULL
      , [UDF05]                  [nvarchar](60)    NOT NULL
      , [code2]                  [nvarchar](30)    NOT NULL
      )
   SET @b_Success = 1
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''

   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NULL
   BEGIN
      CREATE TABLE #PickDetail_WIP(
         [PickDetailKey]   [nvarchar](18) NOT NULL PRIMARY KEY
      ,  [CaseID]          [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [PickHeaderKey]   [nvarchar](18) NOT NULL
      ,  [OrderKey]        [nvarchar](10) NOT NULL
      ,  [OrderLineNumber] [nvarchar](5)  NOT NULL
      ,  [Lot]             [nvarchar](10) NOT NULL
      ,  [Storerkey]       [nvarchar](15) NOT NULL
      ,  [Sku]             [nvarchar](20) NOT NULL
      ,  [AltSku]          [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [UOM]             [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [UOMQty]          [int]          NOT NULL DEFAULT (0)
      ,  [Qty]             [int]          NOT NULL DEFAULT (0)
      ,  [QtyMoved]        [int]          NOT NULL DEFAULT (0)
      ,  [Status]          [nvarchar](10) NOT NULL DEFAULT ('0')
      ,  [DropID]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [Loc]             [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN')
      ,  [ID]              [nvarchar](18) NOT NULL DEFAULT (' ')
      ,  [PackKey]         [nvarchar](10) NULL     DEFAULT (' ')
      ,  [UpdateSource]    [nvarchar](10) NULL     DEFAULT ('0')
      ,  [CartonGroup]     [nvarchar](10) NULL
      ,  [CartonType]      [nvarchar](10) NULL
      ,  [ToLoc]           [nvarchar](10) NULL     DEFAULT (' ')
      ,  [DoReplenish]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [ReplenishZone]   [nvarchar](10) NULL     DEFAULT (' ')
      ,  [DoCartonize]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [PickMethod]      [nvarchar](1)  NOT NULL DEFAULT (' ')
      ,  [WaveKey]         [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [LoadKey]         [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [EffectiveDate]   [datetime]     NOT NULL DEFAULT (getdate())
      ,  [AddDate]         [datetime]     NOT NULL DEFAULT (getdate())
      ,  [AddWho]          [nvarchar](128)NOT NULL DEFAULT (suser_sname())
      ,  [EditDate]        [datetime]     NOT NULL DEFAULT (getdate())
      ,  [EditWho]         [nvarchar](128)NOT NULL DEFAULT (suser_sname())
      ,  [TrafficCop]      [nvarchar](1)  NULL
      ,  [ArchiveCop]      [nvarchar](1)  NULL
      ,  [OptimizeCop]     [nvarchar](1)  NULL
      ,  [ShipFlag]        [nvarchar](1)  NULL     DEFAULT ('0')
      ,  [PickSlipNo]      [nvarchar](10) NULL
      ,  [TaskDetailKey]   [nvarchar](10) NULL
      ,  [TaskManagerReasonKey] [nvarchar](10) NULL
      ,  [Notes]           [nvarchar](4000)NULL
      ,  [MoveRefKey]      [nvarchar](10) NULL     DEFAULT ('')
      ,  [WIP_Refno]       [nvarchar](30) NULL     DEFAULT ('')
      ,  [Channel_ID]      [bigint]       NULL     DEFAULT (0)
      )
      CREATE INDEX IDX_Case ON #PickDetail_WIP (Orderkey, CaseID, Lot, Loc, ID)

      EXEC [dbo].[mspRLWAV10_DATA]
         @c_Wavekey     = @c_Wavekey
      ,  @b_Success     = @b_Success   OUTPUT
      ,  @n_Err         = @n_Err       OUTPUT
      ,  @c_ErrMsg      = @c_ErrMsg    OUTPUT
      ,  @n_debug       = @n_debug
   END

   SET @n_Continue = CASE WHEN @b_Success = 0 THEN 3
                          WHEN @b_Success = 1 THEN 1
                          WHEN @b_Success = 2 THEN 4
                          END

   IF @n_Continue = 1
   BEGIN
      IF NOT EXISTS ( SELECT 1
                      FROM #PickDetail_WIP pw
                      WHERE pw.WaveKey = @c_Wavekey
                      AND (pw.CaseID = '' OR pw.CaseID IS NULL) 
                    )
      BEGIN
         SET @n_Continue = 4
      END
   END

   IF @n_Continue = 1
   BEGIN
      IF OBJECT_ID('tempdb..#CTNZ ','U') IS NOT NULL
      BEGIN
         DROP TABLE #CTNZ
      END

      CREATE TABLE #CTNZ
      (  RowID                INT            IDENTITY(1,1) PRIMARY KEY
      ,  CartonizationGroup   NVARCHAR(10)   NOT NULL DEFAULT ('')
      ,  CartonType           NVARCHAR(10)   NOT NULL DEFAULT ('')
      ,  [Cube]               FLOAT          NOT NULL DEFAULT (0.00)
      ,  MaxWeight            FLOAT          NOT NULL DEFAULT (0.00)
      ,  CartonLength         FLOAT          NOT NULL DEFAULT (0.00)
      ,  CartonWidth          FLOAT          NOT NULL DEFAULT (0.00)
      ,  CartonHeight         FLOAT          NOT NULL DEFAULT (0.00)
      ,  Dim1                 DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
      ,  Dim2                 DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
      ,  Dim3                 DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
      ,  CartonDefault        BIT            NOT NULL DEFAULT (0)
      )

      IF OBJECT_ID('tempdb..#OptimizeItemToPack','U') IS NOT NULL
      BEGIN
         DROP TABLE #OptimizeItemToPack
      END

      CREATE TABLE #OptimizeItemToPack
         (
            ID          INT                     IDENTITY(1,1)  PRIMARY KEY
         ,  Storerkey   NVARCHAR(15)   NOT NULL DEFAULT('')
         ,  SKU         NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  Dim1        DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
         ,  Dim2        DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
         ,  Dim3        DECIMAL(10,6)  NOT NULL DEFAULT(0.00)
         ,  Quantity    INT            NOT NULL DEFAULT(0)
         ,  CZNCheck    INT            NOT NULL DEFAULT(0)
         )

      IF OBJECT_ID('tempdb..#PRECTN') IS NOT NULL
      BEGIN
         DROP TABLE #PRECTN
      END

      CREATE TABLE #PRECTN
      (  [RowID]           [int]          NOT NULL IDENTITY(1,1) PRIMARY KEY
      ,  [PickDetailKey]   [nvarchar](18) NOT NULL DEFAULT (' ')
      ,  [OrderKey]        [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [DocType]         [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [BillToKey]       [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [OrderGroup]      [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [PackGrpNo]       [int]          NOT NULL DEFAULT (0)
      ,  [HardCTNGrpNo]    [int]          NOT NULL DEFAULT (0)
      ,  [SortCTNGrpNo]    [int]          NOT NULL DEFAULT (0)
      ,  [Storerkey]       [nvarchar](15) NOT NULL DEFAULT (' ')
      ,  [Sku]             [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [BUSR7]           [nvarchar](30) NOT NULL DEFAULT (' ')
    --,  [SkuGroup]        [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [ItemClass]       [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [Size]            [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [Length]          [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [Width]           [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [Height]          [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [StdCube]         [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [StdGrossWgt]     [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [Weight]          [REAL]         NOT NULL DEFAULT (0.00)
      ,  [Dim1]            [DECIMAL](10,6)NOT NULL DEFAULT(0.00)
      ,  [Dim2]            [DECIMAL](10,6)NOT NULL DEFAULT(0.00)
      ,  [Dim3]            [DECIMAL](10,6)NOT NULL DEFAULT(0.00)
      ,  [PackQtyIndicator][int]          NOT NULL DEFAULT (0)
      ,  [UOM]             [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [Qty]             [int]          NOT NULL DEFAULT (0)
      ,  [Qty_PI]          [int]          NOT NULL DEFAULT (0)
      ,  [DropID]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [ToLoc]           [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [IsVAS]           [bit]          NOT NULL DEFAULT (0)
      ,  [VAS]             [nvarchar](18) NOT NULL DEFAULT (' ')
      ,  [VASQty]          [int]          NOT NULL DEFAULT (0)
      ,  [VASQty_PI]       [int]          NOT NULL DEFAULT (0)
      ,  [SkuAccessQty]    [int]          NOT NULL DEFAULT (0)
      ,  [Status]          [nvarchar](1)  NOT NULL DEFAULT ('0')
      ,  [UserDefine01]    [nvarchar](50) NOT NULL DEFAULT ('')
      ,  [Shipperkey]      [nvarchar](15) NOT NULL DEFAULT ('')
      ,  [HasAnyVAS]       [bit]          NOT NULL DEFAULT (0)
      )

      IF OBJECT_ID('tempdb..#CartonDetail') IS NOT NULL
      BEGIN
         DROP TABLE #CartonDetail
      END

      CREATE TABLE #CartonDetail
      (  [RowID]           [int]          NOT NULL IDENTITY(1,1) PRIMARY KEY
      ,  [PickDetailKey]   [nvarchar](18) NOT NULL DEFAULT (' ')
      ,  [OrderKey]        [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [OrderGroup]      [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [DocType]         [nvarchar] (5) NOT NULL DEFAULT ('')
      ,  [CartonGroup]     [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [CartonType]      [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [CartonSeqNo]     [int]          NOT NULL DEFAULT (0)
      ,  [CartonCube]      [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [CartonWeight]    [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [LabelNo]         [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [Storerkey]       [nvarchar](15) NOT NULL DEFAULT (' ')
      ,  [Sku]             [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [Busr7]           [nvarchar](30) NOT NULL DEFAULT (' ')
      ,  [ItemClass]       [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [Size]            [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [Length]          [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [Width]           [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [Height]          [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [StdCube]         [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [StdGrossWgt]     [FLOAT]        NOT NULL DEFAULT (0.00)
      ,  [Weight]          [REAL]         NOT NULL DEFAULT (0.00)
      ,  [PackQtyIndicator][int]          NOT NULL DEFAULT (0)
      ,  [UOM]             [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [Qty]             [int]          NOT NULL DEFAULT (0)
      ,  [DropID]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [RefPickKey]      [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [RefPickMode]     [nvarchar](1)  NOT NULL DEFAULT ('')
      ,  [Notes]           [nvarchar](500)NOT NULL DEFAULT ('')
      ,  [Audit]           [bit]          NOT NULL DEFAULT (0)
      ,  [Status]          [nvarchar](1)  NOT NULL DEFAULT ('0')
      ,  [RowRef_pcz]      [int]          NOT NULL DEFAULT (0)
      ,  [IsVAS]           [bit]          NOT NULL DEFAULT (0)
      ,  [IsApi]           [BIT]          NOT NULL DEFAULT (0)
      ,  [Dim1]            [DECIMAL](10,6)NOT NULL DEFAULT(0.00)
      ,  [Dim2]            [DECIMAL](10,6)NOT NULL DEFAULT(0.00)
      ,  [Dim3]            [DECIMAL](10,6)NOT NULL DEFAULT(0.00)
      )
      CREATE INDEX IDX_CartonSeqNo ON #CartonDetail (Orderkey, CartonSeqNo, RefPickKey)

      DECLARE @t_OptimizeResult     TABLE
         (  ContainerID          NVARCHAR(10)   NULL  DEFAULT('')
         ,  AlgorithmID          NVARCHAR(10)   NULL  DEFAULT('')
         ,  IsCompletePack       NVARCHAR(10)   NULL  DEFAULT('')
         ,  ID                   INT            NULL  DEFAULT('')
         ,  SKU                  NVARCHAR(20)   NULL  DEFAULT('')
         ,  Qty                  INT            NULL  DEFAULT(0)
         )

      DECLARE @t_ItemToPack      TABLE
         (  RowID                INT                     IDENTITY(1,1)  PRIMARY KEY
         ,  Storerkey            NVARCHAR(15)   NOT NULL DEFAULT('')
         ,  SKU                  NVARCHAR(20)   NOT NULL DEFAULT('')
         ,  [Length]             FLOAT          NOT NULL DEFAULT (0.00)
         ,  [Width]              FLOAT          NOT NULL DEFAULT (0.00)
         ,  [Height]             FLOAT          NOT NULL DEFAULT (0.00)
         ,  Qty                  INT            NOT NULL DEFAULT(0)
         )

      SELECT TOP 1
            @c_Facility  = o.Facility
         ,  @c_Storerkey = p.Storerkey
      FROM #PickDetail_WIP p
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = p.OrderKey

      SET @c_PackType     = 'PICKDETAIL.Wavekey'
      SET @c_HardCTNGroup = 'PICKDETAIL.Wavekey, ISNULL(SKU.BUSR7,'''')'
      SET @c_Algorithm    = 'HEIGHT'

      SET @c_SortCTNGroup = @c_HardCTNGroup

      -- Get optional configuration if available
      SELECT @c_Option5 = ISNULL(fgr.Option5,'')
      FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'ReleaseWave_SP') AS fgr

      IF ISNULL(@c_Option5, '') <> ''
      BEGIN
         SELECT @c_CTNGroup = dbo.fnc_GetParamValueFromString('@c_CartonGroup_B2C', @c_Option5, @c_CTNGroup)
      END
   END

   IF @n_Continue = 1
   BEGIN
      EXEC [dbo].[isp_CreatePickSlip]
          @c_Wavekey               = @c_Wavekey
         ,@c_PickslipType          = '3'
         ,@c_ConsolidateByLoad     = 'N'
         ,@c_Refkeylookup          = 'N'
         ,@c_LinkPickSlipToPick    = 'Y'
         ,@c_AutoScanIn            = 'N'
         ,@b_Success               = @b_Success  OUTPUT
         ,@n_Err                   = @n_Err      OUTPUT
         ,@c_ErrMsg                = @c_ErrMsg   OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
      END
   END

   IF @n_Continue = 1
   BEGIN
      INSERT INTO @t_CTNZ
      (  CartonizationGroup
      ,  CartonType
      ,  [Cube]
      ,  MaxWeight
      ,  CartonLength
      ,  CartonWidth
      ,  CartonHeight
      ,  Dim1
      ,  Dim2
      ,  Dim3
      ,  FillTolerance
      ,  CartonWeight
      )
      SELECT
         c.CartonizationGroup
      ,  c.CartonType
      ,  c.[Cube]
      ,  ISNULL(c.MaxWeight, 0.00) - ISNULL(c.CartonWeight, 0.00)
      ,  CartonLength = ISNULL(c.CartonLength,0.00)
      ,  CartonWidth  = ISNULL(c.CartonWidth,0.00)
      ,  CartonHeight = ISNULL(c.CartonHeight,0.00)
      ,  Dim1 = cds.MinVal
      ,  Dim2 = cds.MidVal
      ,  Dim3 = cds.MaxVal
      ,  FillTolerance= 100.00
      ,  ISNULL(c.CartonWeight, 0.00)
      FROM dbo.CARTONIZATION AS c (NOLOCK)
      CROSS APPLY (SELECT MIN(val) AS MinVal
                        , SUM(val) - MIN(val) - MAX(val) AS MidVal
                        , MAX(val) AS MaxVal
                   FROM (VALUES (ISNULL(c.CartonLength,0.00))
                              , (ISNULL(c.CartonWidth,0.00))
                              , (ISNULL(c.CartonHeight,0.00))) AS x(val)
                  ) cds
      WHERE c.CartonizationGroup = @c_CTNGroup
      ORDER BY c.[Cube] DESC

      INSERT INTO @TMP_CL (Listname, Code, Description, Short, Long
                        ,  Notes, Notes2, Storerkey
                        ,  UDF01, UDF02, UDF03, UDF04, UDF05, Code2)
      SELECT CODELKUP.Listname
           , CODELKUP.Code
           , [Description] = ISNULL(CODELKUP.[Description],'')
           , Short = ISNULL(CODELKUP.Short,'')
           , Long  = ISNULL(CODELKUP.Long ,'')
           , Notes = ISNULL(CODELKUP.Notes,'')
           , Notes2= ISNULL(CODELKUP.Notes2,'')
           , CODELKUP.Storerkey
           , CODELKUP.UDF01
           , CODELKUP.UDF02
           , CODELKUP.UDF03
           , CODELKUP.UDF04
           , CODELKUP.UDF05
           , CODELKUP.Code2
      FROM CODELKUP (NOLOCK)
      WHERE CODELKUP.Listname IN (  'CSCUK01CFG', 'CSCUK01GCR',
                                    'CSCUK01PT', 'ORDERAUDIT'
                                 ,  'CSCORDTYPE', 'CSCAUDUOM'
                                 ,  'SHIPERCODE'
                                 )
      AND   CODELKUP.Storerkey = @c_Storerkey
      ORDER BY CODELKUP.Listname
           ,   CODELKUP.Code

      -- Set optional configuration
      SET @c_SQLCond = ' WHERE (PICKDETAIL.CaseID = '''' OR PICKDETAIL.CaseID IS NULL) AND ORDERS.DocType = ''E'' '

      -- Picking Loc: PICKDETAIL.ToLoc, get at mspRLWAV10_DATA
      SET @c_SQL = N'SELECT PICKDETAIL.PickDetailKey'
                 +  ', ORDERS.OrderKey'
                 +  ', ORDERS.DocType'
                 +  ', ORDERS.BillToKey'
                 +  ', ORDERS.OrderGroup'
                 +  ', PackGrpNo     = DENSE_RANK() OVER (ORDER BY ' + @c_PackType + ')'
                 +  ', HardCTNGrpNo  = '+ CASE WHEN @c_HardCTNGroup > ''
                                               THEN 'DENSE_RANK() OVER (ORDER BY ' + @c_HardCTNGroup  + ')'
                                               ELSE '0'
                                               END
                 +  ', SortCTNGrpNo  = ' + CASE WHEN @c_SortCTNGroup > ''
                                                THEN 'DENSE_RANK() OVER (ORDER BY ' + @c_SortCTNGroup  + ')'
                                                ELSE '0'
                                                END
                 +  ', PICKDETAIL.Storerkey'
                 +  ', PICKDETAIL.Sku'
                 +  ', BUSR7 = ISNULL(SKU.BUSR7,'''')'
                 +  ', ItemClass = ISNULL(SKU.ItemClass,'''')'
                 +  ', Size = ISNULL(SKU.Size,'''')'
                 +  ', PACK.LengthUOM3'
                 +  ', PACK.WidthUOM3'
                 +  ', PACK.HeightUOM3'
                 +  ', StdCube = CASE WHEN ISNULL(PACK.CubeUOM3, 0.00) = 0.00 THEN SKU.StdCube ELSE PACK.CubeUOM3 END'
                 +  ', StdGrossWgt = CASE WHEN ISNULL(SKU.StdGrossWgt, 0.00) = 0.00 THEN SKU.GrossWgt ELSE SKU.StdGrossWgt END'
                 +  ', Weight = CASE WHEN ISNULL(SKU.StdGrossWgt, 0.00) = 0.00 THEN SKU.GrossWgt ELSE SKU.StdGrossWgt END'
                 +  ', Dim1 = sds.MinVal'
                 +  ', Dim2 = sds.MidVal'
                 +  ', Dim3 = sds.MaxVal'
                 +  ', PQI.PackQtyIndicator'
                 +  ', PICKDETAIL.UOM'
                 +  ', PICKDETAIL.Qty'
                 +  ', PICKDETAIL.DropID'
                 +  ', IsVAS = 0'
                 +  ', VAS   = '''''
                 +  ', VASQty= 0'
                 +  ', SkuAccessQty = 0'
                 +  ', UserDefine01 = ISNULL(ORDERS.UserDefine01, '''')'
                 +  ', Shipperkey = ISNULL(ORDERS.Shipperkey, '''')'
                 +  ', HasAnyVas = 0'
                 +  ' FROM #PickDetail_WIP PICKDETAIL'
                 +  ' JOIN ORDERS (NOLOCK) ON ORDERS.Orderkey = PICKDETAIL.Orderkey'
                 +  ' JOIN SKU (NOLOCK) ON  SKU.Storerkey = PICKDETAIL.Storerkey'
                 +                    ' AND SKU.Sku = PICKDETAIL.Sku'
                 +  ' JOIN PACK (NOLOCK) ON  PACK.Packkey = SKU.Packkey'
                 +  ' JOIN LOC (NOLOCK) ON LOC.Loc = PICKDETAIL.ToLoc'
                 +  ' CROSS APPLY (SELECT MIN(val) AS MinVal'
                 +                    ' , SUM(val) - MIN(val) - MAX(val) AS MidVal'
                 +                    ' , MAX(val) AS MaxVal'
                 +               ' FROM (VALUES (PACK.LengthUOM3), (PACK.WidthUOM3), (PACK.HeightUOM3)) AS x(val)'
                 +               ') sds'
                 +  ' CROSS APPLY ( SELECT PackQtyIndicator = CASE WHEN SKU.PackQtyIndicator > 0'
                 +                                               ' THEN SKU.PackQtyIndicator ELSE 1 END'
                 +              ' ) PQI'
                 +  @c_SQLCond
                 +  ' ORDER BY PackGrpNo'
                 +         ' , HardCTNGrpNo'
                 +         ' , SortCTNGrpNo'
                 +         ' , LOC.LogicalLocation'
                 +         ' , PICKDETAIL.PickDetailKey'

      SET @c_SQLParms = N''

      INSERT INTO #PRECTN  (  [PickDetailKey], [OrderKey], [DocType], [BillToKey], [OrderGroup]
                           ,  [PackGrpNo], [HardCTNGrpNo],[SortCTNGrpNo]
                           ,  [Storerkey], [Sku], [BUSR7], [ItemClass], [Size]
                           ,  [Length], [Width], [Height], [StdCube], [StdGrossWgt], [Weight]
                           ,  [Dim1], [Dim2], [Dim3]
                           ,  [PackQtyIndicator]
                           ,  [UOM], [Qty], [DropID]
                           ,  [IsVAS], [VAS], [VASQty], [SkuAccessQty]
                           ,  [UserDefine01], [Shipperkey]
                           ,  [HasAnyVAS]
                           )
      EXEC sp_ExecuteSQL @c_SQL
                        ,@c_SQLParms

      SET @n_RowCount = @@ROWCOUNT

      IF @n_RowCount = 0
      BEGIN
         SET @n_Continue = 4
      END

      IF @n_Continue = 1
      BEGIN
         UPDATE pcz
            SET pcz.Qty_PI    = pcz.Qty/pcz.PackQtyIndicator
               ,pcz.VASQty_PI = pcz.VASQty/pcz.PackQtyIndicator
         FROM #PRECTN pcz
      END
   END

   IF @n_Continue = 1
   BEGIN
      SET @cur_PCKGRPH = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT pcz.PackGrpNo
      FROM #PRECTN AS pcz
      GROUP BY pcz.PackGrpNo
      ORDER BY pcz.PackGrpNo

      OPEN @cur_PCKGRPH

      FETCH NEXT FROM @cur_PCKGRPH INTO @n_PackGrpNo

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         TRUNCATE TABLE #CTNZ;
         INSERT INTO #CTNZ
            (
                  CartonizationGroup
               ,  CartonType
               ,  [Cube]
               ,  MaxWeight
               ,  CartonLength
               ,  CartonWidth
               ,  CartonHeight
               ,  Dim1
               ,  Dim2
               ,  Dim3
               ,  CartonDefault
            )
         SELECT TOP 1 cz.CartonizationGroup
               ,cz.CartonType
               ,cz.[Cube]
               ,cz.MaxWeight
               ,cz.CartonLength
               ,cz.CartonWidth
               ,cz.CartonHeight
               ,cz.Dim1
               ,cz.Dim2
               ,cz.Dim3
               ,CartonDefault = 1
         FROM @t_CTNZ AS cz
         WHERE cz.CartonizationGroup = @c_CTNGroup
         ORDER BY cz.RowID

         SELECT TOP 1
                  @c_CartonType_Max = cz.CartonType
               ,  @n_CartonCube_Max = cz.[Cube]
               ,  @n_CartonWeight_Max = cz.MaxWeight
         FROM #CTNZ AS cz
         WHERE cz.CartonDefault = 1
         ORDER BY cz.RowID

         INSERT INTO #CTNZ
            (
                  CartonizationGroup
               ,  CartonType
               ,  [Cube]
               ,  MaxWeight
               ,  CartonLength
               ,  CartonWidth
               ,  CartonHeight
               ,  Dim1
               ,  Dim2
               ,  Dim3
               ,  CartonDefault
            )
         SELECT cz.CartonizationGroup
               ,cz.CartonType
               ,cz.[Cube]
               ,cz.MaxWeight
               ,cz.CartonLength
               ,cz.CartonWidth
               ,cz.CartonHeight
               ,cz.Dim1
               ,cz.Dim2
               ,cz.Dim3
               ,CartonDefault = 0
         FROM @t_CTNZ AS cz
         WHERE cz.CartonizationGroup = @c_CTNGroup
         ORDER BY cz.RowID

         --------------------------
         -- UOM = '6' & '7' Normal
         --------------------------
         SET @n_SkuAccessQty   = 0
         PRECZN:
         SET @n_HardCTNGrpNo_P = 0
         SET @c_ItemClass_P    = ''
         SET @c_Size_P         = ''

         SET @n_CartonSeqNo = 0
         SELECT TOP 1 @n_CartonSeqNo = cd.CartonSeqNo
         FROM #CartonDetail AS cd
         ORDER BY cd.CartonSeqNo DESC

         SET @cur_PCKGRPS = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT   RowID_pcz = MIN(pcz.RowID)
               ,  pcz.HardCTNGrpNo
               ,  pcz.SortCTNGrpNo
               ,  pcz.BUSR7
               ,  pcz.ItemClass
               ,  pcz.Size
               ,  pcz.Sku
               ,  Qty    = SUM(pcz.Qty)
               ,  Qty_PI = SUM(pcz.Qty_PI)
               ,  pcz.StdCube
               ,  pcz.StdGrossWgt
               ,  pcz.Length
               ,  pcz.Width
               ,  pcz.Height
               ,  pcz.Dim1
               ,  pcz.Dim2
               ,  pcz.Dim3
               ,  pcz.PackQtyIndicator
               ,  pcz.IsVAS
               ,  pcz.VAS
               ,  VASQty   = MAX(pcz.VASQty)
               ,  VASQty_PI= MAX(pcz.VASQty_PI)
         FROM #PRECTN AS pcz
         WHERE pcz.PackGrpNo = @n_PackGrpNo
         AND   pcz.UOM >= '6'
         AND   pcz.SkuAccessQty = @n_SkuAccessQty
         GROUP BY pcz.HardCTNGrpNo
               ,  pcz.SortCTNGrpNo
               ,  pcz.BUSR7
               ,  pcz.ItemClass
               ,  pcz.Size
               ,  pcz.Sku
               ,  pcz.StdCube
               ,  pcz.StdGrossWgt
               ,  pcz.Length
               ,  pcz.Width
               ,  pcz.Height
               ,  pcz.Dim1
               ,  pcz.Dim2
               ,  pcz.Dim3
               ,  pcz.PackQtyIndicator
               ,  pcz.IsVAS
               ,  pcz.VAS
         ORDER BY MIN(pcz.RowID)

         OPEN @cur_PCKGRPS

         FETCH NEXT FROM @cur_PCKGRPS INTO   @n_RowID_pcz
                                          ,  @n_HardCTNGrpNo
                                          ,  @n_SortCTNGrpNo
                                          ,  @c_BUSR7
                                          ,  @c_ItemClass
                                          ,  @c_Size
                                          ,  @c_Sku
                                          ,  @n_Qty
                                          ,  @n_Qty_PI
                                          ,  @n_StdCube
                                          ,  @n_StdGrossWgt
                                          ,  @n_Length
                                          ,  @n_Width
                                          ,  @n_Height
                                          ,  @n_Dim1_Sku
                                          ,  @n_Dim2_Sku
                                          ,  @n_Dim3_Sku
                                          ,  @n_PackQtyIndicator
                                          ,  @b_IsVAS
                                          ,  @c_VAS
                                          ,  @n_VASQty
                                          ,  @n_VASQty_PI

         WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
         BEGIN
            IF @n_HardCTNGrpNo_P <> @n_HardCTNGrpNo
            BEGIN
               SET @b_NewCarton = 1
            END

            SELECT @b_API = IIF(ISNUMERIC(cl1.UDF02) = 1, cl1.UDF02, 0)
            FROM @TMP_CL cl1
            WHERE cl1.ListName = 'CSCUK01PT'
            AND   cl1.Code     = @c_BUSR7
            AND   cl1.Storerkey= @c_Storerkey

            IF @n_debug = 3
            BEGIN
               PRINT ' | Wavekey=' + ISNULL(@c_Wavekey, '')
                   + ' | SKU=' + ISNULL(@c_Sku, '')
                   + ' | StdCube=' + ISNULL(CAST(@n_StdCube AS NVARCHAR(30)), '')
                   + ' | StdGrossWgt=' + ISNULL(CAST(@n_StdGrossWgt AS NVARCHAR(30)), '')
                   + ' | CTNGroup_BTK=' + ISNULL(@c_CTNGroup_BTK, '')
                   + ' | API=' + ISNULL(CAST(@b_API AS NVARCHAR(1)), '')
                   + ' | Qty=' + ISNULL(CAST(@n_Qty AS NVARCHAR(20)), '')
                   + ' | QtyPI=' + ISNULL(CAST(@n_Qty_PI AS NVARCHAR(20)), '')
               PRINT ' | MaxCartonType=' + ISNULL(CAST(@c_CartonType_Max AS NVARCHAR(10)), '')
            
               SET @c_OtherParms = (STUFF((SELECT ', ' + TRIM(CartonType) 
                                           FROM #CTNZ 
                                           WHERE CartonDefault = 0 ORDER BY RowID FOR XML PATH('')),1,2,'' ))
               PRINT ' | CartonType=' + ISNULL(CAST(@c_OtherParms AS NVARCHAR(MAX)), '') + CHAR(13)
            END

            SET @n_RowID_pre = 0
            WHILE @n_Qty > 0 AND @n_Continue = 1
            BEGIN
               SET @n_GetSmaller = 0
               SET @b_CZN_Check  = 0

               IF @b_NewCarton = 0 AND @n_SkuAccessQty = 0
               BEGIN
                  -- Non-VAS
                  -- If current open box already contains sku and next sku
                  -- to pack has different Sku.Itemclass
                  IF @b_IsVAS = 0 AND
                     @c_ItemClass <> @c_ItemClass_P AND @c_ItemClass_P > ''
                  BEGIN
                     SET @n_ItemCBM_Sum = 0.00
                     SET @n_ItemWgt_Sum = 0.00
                     SET @n_ItemQty_Sum = 0
                     SELECT @n_ItemCBM_Sum = SUM(pcz.StdCube*pcz.Qty_PI)
                           ,@n_ItemWgt_Sum = SUM(pcz.StdGrossWgt*pcz.Qty_PI)
                           ,@n_ItemQty_Sum = SUM(pcz.Qty_PI)
                     FROM #PRECTN AS pcz
                     WHERE pcz.PackGrpNo    = @n_PackGrpNo
                     AND   pcz.HardCTNGrpNo = @n_HardCTNGrpNo
                     AND   pcz.ItemClass    = @c_ItemClass
                     AND   pcz.UOM         >= '6'
                     AND   pcz.SkuAccessQty = @n_SkuAccessQty
                     AND   pcz.Status       = '0'
                     AND   pcz.RowID       >= @n_RowID_pcz

                     IF @n_ItemCBM_Sum > @n_CBMLeftToFulFill AND
                        @n_ItemWgt_Sum > @n_WgtLeftToFulFill
                     BEGIN
                        SET @b_NewCarton = 1
                     END

                     IF @b_NewCarton = 0 AND @b_API = 1
                     BEGIN
                        SET @b_CZN_Check = 1
                        INSERT INTO #OptimizeItemToPack (Storerkey, Sku, Dim1, Dim2, Dim3, Quantity, CZNCheck)
                        SELECT Storerkey, Sku, pcz.[Height], pcz.[Width], pcz.[Length], Qty_PI, 1
                        FROM #PRECTN AS pcz
                        WHERE pcz.PackGrpNo    = @n_PackGrpNo
                        AND   pcz.HardCTNGrpNo = @n_HardCTNGrpNo
                        AND   pcz.ItemClass    = @c_ItemClass
                        AND   pcz.UOM         >= '6'
                        AND   pcz.SkuAccessQty = @n_SkuAccessQty
                        AND   pcz.Status       = '0'
                        AND   pcz.RowID       >= @n_RowID_pcz

                        GOTO CTZ_API
                        CZN_CHECKED:
                        IF @c_IsCompletePack = 'false'
                        BEGIN
                           SET @b_NewCarton = 1
                        END
                        ELSE
                        BEGIN
                           DELETE FROM #OptimizeItemToPack
                           WHERE CZNCheck = 1
                        END
                     END
                  END
               END

               IF @n_Qty > 0
               BEGIN
                  IF @b_NewCarton = 1
                  BEGIN
                     DELETE FROM @t_ItemToPack;

                     IF EXISTS ( SELECT 1
                                 FROM #CartonDetail AS cd
                                 WHERE cd.CartonSeqNo = @n_CartonSeqNo
                                 AND   cd.[Status] = '0'
                                 )
                     BEGIN
                        GOTO CLOSE_CTN
                     END

                     SET @c_CartonType   = ''
                     SET @n_CartonCube   = 0.00
                     SET @n_CartonWeight = 0.00
                     SET @n_FillTolerance= 0.00

                     SELECT TOP 1
                          @n_RowID_cz     = cz.RowID
                        , @c_CartonType   = cz.CartonType
                        , @n_CartonCube   = cz.[Cube]
                        , @n_CartonWeight = cz.MaxWeight
                        , @n_Dim1_Ctn     = cz.Dim1
                        , @n_Dim2_Ctn     = cz.Dim2
                        , @n_Dim3_Ctn     = cz.Dim3
                        , @n_FillTolerance= 100.00
                     FROM #CTNZ cz
                     WHERE cz.CartonizationGroup = @c_CTNGroup
                     AND   cz.CartonDefault = 0
                     ORDER BY cz.RowID

                     SET @n_CartonSeqNo = @n_CartonSeqNo + 1
                     SET @n_TotalCBM   = 0.00   --Reset CBM
                     SET @n_TotalWgt   = 0.00   --Reset Wgt
                     SET @n_CBMLeftToFulFill = @n_CartonCube
                     SET @n_WgtLeftToFulFill = @n_CartonWeight
                  END

                  IF @n_Continue = 1
                  BEGIN
                     SET @n_QtyToPack_PI = 0
                     IF @b_API = 0 OR
                        (
                        @b_API = 1 AND
                        @n_Dim1_Sku <= @n_Dim1_Ctn AND
                        @n_Dim2_Sku <= @n_Dim2_Ctn AND
                        @n_Dim3_Sku <= @n_Dim3_Ctn
                        )
                     BEGIN
                        SET @n_ItemCBM = 0.00
                        SET @n_ItemWgt = 0.00
                        SET @n_ItemCBM = @n_StdCube*@n_Qty_PI
                        SET @n_ItemWgt = @n_StdGrossWgt*@n_Qty_PI
                        SET @n_QtyCBM_PI = 0
                        SET @n_QtyWgt_PI = 0

                        IF @n_StdCube > 0
                        BEGIN
                           IF @n_CBMLeftToFulFill > @n_ItemCBM
                           BEGIN
                              SET @n_QtyCBM_PI = FLOOR(ROUND(@n_ItemCBM / @n_StdCube, 6))
                           END
                           ELSE
                           BEGIN
                              SET @n_QtyCBM_PI = FLOOR(ROUND(@n_CBMLeftToFulFill / @n_StdCube, 6))
                           END
                        END

                        IF @n_StdGrossWgt > 0
                        BEGIN
                           IF @n_WgtLeftToFulFill > @n_ItemWgt
                           BEGIN
                              SET @n_QtyWgt_PI = FLOOR(ROUND(@n_ItemWgt / @n_StdGrossWgt, 6))
                           END
                           ELSE
                           BEGIN
                              SET @n_QtyWgt_PI = FLOOR(ROUND(@n_WgtLeftToFulFill / @n_StdGrossWgt, 6))
                           END
                        END
                        
                        IF @n_QtyWgt_PI < @n_QtyCBM_PI
                        BEGIN
                           SET @n_QtyToPack_PI = @n_QtyWgt_PI
                        END
                        ELSE
                        BEGIN
                           SET @n_QtyToPack_PI = @n_QtyCBM_PI
                        END
                     END
                  END

                  SET @n_QtyToPack_PI = IIF(@n_QtyToPack_PI < 0, 0, @n_QtyToPack_PI)
                  
                  IF @n_QtyToPack_PI = 0 AND @b_NewCarton = 0
                  BEGIN
                     SET @b_NewCarton = 1
                     GOTO CLOSE_CTN
                  END
                  ELSE
                  BEGIN
                     SET @n_QtyToPack = @n_QtyToPack_PI * @n_PackQtyIndicator
                  END

                  -- Item Cannot pack into Large Carton
                  IF @n_QtyToPack = 0 AND @b_NewCarton = 1
                  BEGIN
                     SET @b_API          = 0
                     SET @n_GetSmaller   = 0
                     SET @n_QtyToPack_PI = 1
                     SET @n_QtyToPack    = @n_QtyToPack_PI * @n_PackQtyIndicator
                     SET @c_CartonType   = @c_CartonType_Max
                     SET @n_CartonCube   = @n_CartonCube_Max
                     SET @n_CartonWeight = @n_CartonWeight_Max
                  END

                  IF @n_QtyToPack > 0
                  BEGIN
                     SET @b_NewCarton = 0

                     IF @b_API = 1
                     BEGIN
                        SET @b_CZN_Check = 0
                        INSERT INTO @t_ItemToPack (Storerkey, Sku, [Length], Width, Height, Qty)
                        VALUES (@c_Storerkey, @c_Sku, @n_Height, @n_Width, @n_Length, @n_QtyToPack)

                        TRUNCATE TABLE #OptimizeItemToPack;
                        INSERT INTO #OptimizeItemToPack (Storerkey, Sku, Dim1, Dim2, Dim3, Quantity)
                        SELECT Storerkey, Sku, [Length], Width, Height, Qty
                        FROM @t_ItemToPack AS otp
                        ORDER BY otp.RowID

                        CTZ_API:
                        SET @c_IsCompletePack = ''
                        WHILE @c_IsCompletePack <> 'TRUE'
                        BEGIN
                           DELETE FROM @t_OptimizeResult;

                           INSERT INTO @t_OptimizeResult (ContainerID, AlgorithmID, IsCompletePack, ID, SKU, Qty)
                           EXEC isp_SubmitToCartonizeAPI
                                @c_CartonGroup = @c_CTNGroup
                              , @c_CartonType  = @c_CartonType
                              , @c_Algorithm   = @c_Algorithm
                              , @b_Success     = @b_Success       OUTPUT
                              , @n_Err         = @n_Err           OUTPUT
                              , @c_ErrMsg      = @c_ErrMsg        OUTPUT
                              , @b_debug       = 0

                           IF @b_Success = 0
                           BEGIN
                              SET @n_Continue = 3
                              BREAK
                           END
                           
                           IF @n_Continue = 1
                           BEGIN
                              SET @c_IsCompletePack = ''
                              SELECT @c_IsCompletePack = orn.IsCompletePack
                              FROM @t_OptimizeResult AS orn

                              -- Cannot fit even 1 qty, it returns nothing
                              IF NOT EXISTS ( SELECT 1 FROM @t_OptimizeResult )
                                 SET @c_IsCompletePack = 'false'

                              IF @b_CZN_Check IN (1,2)
                              BEGIN
                                 BREAK
                              END

                              IF @c_IsCompletePack = 'false'
                              BEGIN
                                 SET @b_NewCarton = 1
                                 SET @n_id_oitp = 0

                                 SELECT TOP 1 @n_id_oitp = oitp.ID
                                 FROM #OptimizeItemToPack AS oitp
                                 WHERE oitp.Quantity > 0
                                 ORDER BY oitp.ID DESC

                                 IF @n_id_oitp > 0
                                 BEGIN
                                    UPDATE oitp
                                       SET oitp.Quantity = Quantity - 1
                                    FROM #OptimizeItemToPack AS oitp
                                    WHERE oitp.ID = @n_id_oitp
                                    AND oitp.Quantity > 0

                                    IF EXISTS ( SELECT 1
                                                FROM #OptimizeItemToPack AS oitp
                                                WHERE oitp.Quantity > 0
                                              )
                                    BEGIN
                                       SET @n_QtyToPack_PI = @n_QtyToPack_PI - 1
                                       SET @n_QtyToPack = @n_QtyToPack_PI * @n_PackQtyIndicator
                                    END
                                    ELSE
                                    BEGIN
                                       SET @n_GetSmaller = 0
                                       SET @c_CartonType   = @c_CartonType_Max
                                       SET @n_CartonCube   = @n_CartonCube_Max
                                       SET @n_CartonWeight = @n_CartonWeight_Max
                                       SET @c_IsCompletePack = 'TRUE'
                                    END
                                 END
                              END
                           END
                        END   -- @b_API = 1 Loop
                        IF @b_CZN_Check = 1
                        BEGIN
                           GOTO CZN_CHECKED
                        END
                        --ELSE IF @b_CZN_Check = 2
                        --BEGIN
                        --   GOTO CZN_Close
                        --END
                     END

                     IF @n_Continue = 1 AND @n_QtyToPack > 0
                     BEGIN
                        SET @n_QtyToPack_cd = @n_QtyToPack
                        WHILE @n_QtyToPack_cd > 0
                        BEGIN
                           -- Do not get next record if pickdetail still have remainqty
                           IF @n_Qty_pd = 0
                           BEGIN
                              SET @c_RefPickMode = ''
                              SET @c_RefPickKey  = ''
                              SELECT TOP 1
                                     @n_RowID_pre = pcz.RowID
                                    ,@c_RefPickKey= pcz.PickDetailKey
                                    ,@n_Qty_pd    = pcz.Qty
                              FROM #PRECTN AS pcz
                              WHERE pcz.PackGrpNo = @n_PackGrpNo
                              AND   pcz.HardCTNGrpNo = @n_HardCTNGrpNo
                              AND   pcz.SortCTNGrpNo = @n_SortCTNGrpNo
                              AND   pcz.Storerkey= @c_Storerkey
                              AND   pcz.Sku      = @c_Sku
                              AND   pcz.[Status] = '0'
                              AND   pcz.RowID   > @n_RowID_pre
                              ORDER BY pcz.RowID

                              SET @n_RowCount = @@ROWCOUNT

                              IF @n_RowCount = 0
                              BEGIN
                                 BREAK
                              END
                              SET @c_Notes = 'RefPickKey: ' +  @c_RefPickKey
                                           + ' '
                                           + 'Qty: ' + CONVERT(NVARCHAR(10),@n_Qty_pd)
                           END
                           -- if the pickdetail qty full pack into current carton
                           -- its pickmode = ''
                           -- if the pickdetail qty partially into current carton
                           -- its pickmode = S:Split and remainqty to next carton(s)
                           -- its pickmode = N:New
                           -- #CartonDetail pickmode used to update or create new pickdetail
                           SET @n_QtyToPack_ins = @n_QtyToPack_cd

                           IF @n_Qty_pd <= @n_QtyToPack_cd
                           BEGIN
                              SET @n_QtyToPack_ins = @n_Qty_pd
                           END

                           IF @c_RefPickMode = ''
                           BEGIN
                              SET @c_RefPickMode = 'S'
                           END
                           ELSE IF @c_RefPickMode = 'S'
                           BEGIN
                              SET @c_RefPickMode = 'N'
                           END

                           SET @n_Qty_pd = @n_Qty_pd - @n_QtyToPack_ins
                           SET @n_QtyToPack_cd = @n_QtyToPack_cd - @n_QtyToPack_ins

                           IF @c_RefPickMode IN ('', 'N')
                           BEGIN
                              UPDATE pcz
                              SET pcz.Status = '9'
                              FROM #PRECTN pcz
                              WHERE pcz.Pickdetailkey = @c_RefPickKey
                           END

                           INSERT INTO #CartonDetail
                              (  [PickDetailKey]
                              ,  [OrderKey]
                              ,  [CartonGroup]
                              ,  [OrderGroup]
                              ,  [DocType]
                              ,  [CartonType]
                              ,  [CartonSeqNo]
                              ,  [CartonCube]
                              ,  [CartonWeight]
                              ,  [LabelNo]
                              ,  [Storerkey]
                              ,  [Sku]
                              ,  [Busr7]
                              ,  [ItemClass]
                              ,  [Size]
                              ,  [Length]
                              ,  [Width]
                              ,  [Height]
                              ,  [StdCube]
                              ,  [StdGrossWgt]
                              ,  [Weight]
                              ,  [PackQtyIndicator]
                              ,  [UOM]
                              ,  [Qty]
                              ,  [DropID]
                              ,  [RefPickkey]
                              ,  [RefPickMode]
                              ,  [Notes]
                              ,  [Status]
                              ,  [RowRef_pcz]
                              ,  [IsApi]
                              ,  [IsVAS]
                              ,  [Dim1]
                              ,  [Dim2]
                              ,  [Dim3]
                              )
                           SELECT
                                 pcz.PickDetailKey
                              ,  pcz.OrderKey
                              ,  CartonGroup = @c_CTNGroup
                              ,  pcz.OrderGroup
                              ,  pcz.DocType
                              ,  CartonType  = @c_CartonType
                              ,  CartonSeqNo = @n_CartonSeqNo
                              ,  CartonCube  = @n_CartonCube
                              ,  CartonWeight= @n_CartonWeight
                              ,  LabelNo = ''
                              ,  pcz.Storerkey
                              ,  pcz.Sku
                              ,  pcz.Busr7
                              ,  pcz.ItemClass
                              ,  pcz.Size
                              ,  pcz.[Length]
                              ,  pcz.Width
                              ,  pcz.Height
                              ,  pcz.StdCube
                              ,  pcz.StdGrossWgt
                              ,  pcz.[Weight]
                              ,  pcz.PackQtyIndicator
                              ,  pcz.UOM
                              ,  Qty = @n_QtyToPack_ins
                              ,  pcz.DropID
                              ,  RefPickkey = @c_RefPickKey
                              ,  RefPickMode= @c_RefPickMode
                              ,  Notes      = @c_Notes
                              ,  [Status]   = '0'
                              ,  RowRef_pcz = pcz.RowID
                              ,  IsApi = @b_API
                              ,  IsVAS = pcz.IsVAS
                              ,  pcz.Dim1
                              ,  pcz.Dim2
                              ,  pcz.Dim3
                           FROM #PRECTN AS pcz
                           WHERE pcz.Pickdetailkey = @c_RefPickKey
                        END

                        SET @n_TotalQty_PI         = @n_TotalQty_PI + @n_QtyToPack_PI
                        SET @n_TotalCBM            = @n_TotalCBM + (@n_StdCube*@n_QtyToPack_PI)
                        SET @n_TotalWgt            = @n_TotalWgt + (@n_StdGrossWgt*@n_QtyToPack_PI)
                        SET @n_QtyLeftToFulFill_PI = @n_QtyLeftToFulFill_PI - @n_QtyToPack_PI
                        SET @n_CBMLeftToFulFill    = @n_CBMLeftToFulFill - (@n_StdCube*@n_QtyToPack_PI)
                        SET @n_WgtLeftToFulFill    = @n_WgtLeftToFulFill - (@n_StdGrossWgt*@n_QtyToPack_PI)
                        SET @n_Qty_PI              = @n_Qty_PI - @n_QtyToPack_PI
                        SET @n_Qty                 = @n_Qty    - @n_QtyToPack
                     END

                     ------------------------------
                     -- Get Smaller Carton & Close
                     ------------------------------
                     CLOSE_CTN:
                     IF @n_Continue = 1 AND @b_NewCarton = 1
                     BEGIN
                        UPDATE cd
                        SET CartonType   = @c_CartonType
                           ,CartonCube   = @n_CartonCube
                           ,CartonWeight = @n_CartonWeight
                           ,[Status]     = '9'
                        FROM #CartonDetail AS cd
                        WHERE cd.CartonSeqNo = @n_CartonSeqNo

                        IF EXISTS ( SELECT 1 FROM #OptimizeItemToPack )
                           TRUNCATE TABLE #OptimizeItemToPack
                     END
                  END
               END
            END

            SET @n_HardCTNGrpNo_P = @n_HardCTNGrpNo
            SET @c_ItemClass_P = @c_ItemClass
            SET @c_Size_P = @c_Size
            SET @c_Sku_P  = @c_Sku
            SET @b_IsVAS_P  = @b_IsVAS
            SET @c_VAS_P = @c_VAS
            FETCH NEXT FROM @cur_PCKGRPS INTO   @n_RowID_pcz
                                             ,  @n_HardCTNGrpNo
                                             ,  @n_SortCTNGrpNo
                                             ,  @c_BUSR7
                                             ,  @c_ItemClass
                                             ,  @c_Size
                                             ,  @c_Sku
                                             ,  @n_Qty
                                             ,  @n_Qty_PI
                                             ,  @n_StdCube
                                             ,  @n_StdGrossWgt
                                             ,  @n_Length
                                             ,  @n_Width
                                             ,  @n_Height
                                             ,  @n_Dim1_Sku
                                             ,  @n_Dim2_Sku
                                             ,  @n_Dim3_Sku
                                             ,  @n_PackQtyIndicator
                                             ,  @b_IsVAS
                                             ,  @c_VAS
                                             ,  @n_VASQty
                                             ,  @n_VASQty_PI
         END
         CLOSE @cur_PCKGRPS
         DEALLOCATE @cur_PCKGRPS

         IF @n_Debug = 9
         BEGIN
            SELECT Src = '#CartonDetail',* FROM #CartonDetail
            SELECT Src = '#PRECTN',* FROM #PRECTN
         END

         -- Close Last Carton
         UPDATE cd
         SET [Status] = '9'
         FROM #CartonDetail AS cd
         WHERE cd.CartonSeqNo = @n_CartonSeqNo
         
         BUILD_PACK:
         IF @n_Continue = 1
         BEGIN
            ------------------------------------------
            --- Create PACK  - START
            ------------------------------------------
            IF EXISTS ( SELECT 1
                        FROM #CartonDetail AS cd
                        WHERE cd.CartonSeqNo > 0
                        AND cd.RefPickKey > ''
                        AND cd.[Status] = '9'
                      )
            BEGIN
               -------------------------------------------------------
               -- Gen Label#,Stamp CaseID, PickSlipNo
               -- and Split PickDetail - START
               -------------------------------------------------------
               SET @n_CartonSeqNo = 0
               WHILE 1 = 1
               BEGIN
                  SET @c_LabelNo = ''
                  SELECT TOP 1
                              @n_CartonSeqNo = cd.CartonSeqNo
                           ,  @c_LabelNo = cd.LabelNo
                  FROM #CartonDetail AS cd
                  WHERE cd.CartonType  > ''
                  AND cd.CartonSeqNo > @n_CartonSeqNo
                  AND cd.LabelNo = ''
                  AND cd.[Status] = '9'
                  ORDER BY cd.CartonSeqNo

                  SET @n_RowCount = @@ROWCOUNT
                  IF @n_RowCount = 0
                  BEGIN
                     BREAK
                  END

                  IF @n_debug = 1
                  BEGIN
                     PRINT '@c_LabelNo: ' + @c_LabelNo
                  END

                  IF ISNULL(@c_LabelNo, '') = ''
                  BEGIN
                     EXECUTE nspg_getkey  
                       @KeyName     = 'CSCUKEcomToteLabel'  
                     , @fieldlength = 10  
                     , @keystring  = @c_LabelNo             OUTPUT  
                     , @b_success  = @b_success             OUTPUT  
                     , @n_err      = @n_err                 OUTPUT  
                     , @c_errmsg   = @c_errmsg              OUTPUT

                     IF @b_Success = 0
                     BEGIN
                        SET @n_Continue = 3
                        SET @n_err = 64020
                        SET @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)
                                     +': Error Executing nspg_getkey. (mspRLWAV10_TOTE)'
                                     + ' ( ' + @c_errmsg + ' ) '
                        GOTO PACK_END
                     END
                  END

                  SET @cur_SPLPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT cd.RowID
                        ,cd.Qty
                        ,cd.RefPickkey
                        ,cd.RefPickMode
                  FROM #CartonDetail AS cd
                  WHERE cd.CartonType > ''
                  AND   cd.CartonSeqNo = @n_CartonSeqNo
                  AND   cd.LabelNo  = ''
                  AND   cd.[Status] = '9'
                  ORDER BY cd.CartonSeqNo
                        ,  cd.RefPickkey
                        ,  cd.RowID

                  OPEN @cur_SPLPD

                  FETCH NEXT FROM @cur_SPLPD INTO  @n_RowID_cd
                                                ,  @n_Qty
                                                ,  @c_RefPickkey
                                                ,  @c_RefPickMode

                  WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
                  BEGIN
                     IF @c_RefPickMode = 'N'
                     BEGIN
                        SET @b_success = 1
                        EXECUTE nspg_getkey
                           @KeyName     = 'Pickdetailkey'
                        ,  @fieldlength = 10
                        ,  @keystring   = @c_PickDetailKey  OUTPUT
                        ,  @b_success   = @b_success        OUTPUT
                        ,  @n_err       = @n_err            OUTPUT
                        ,  @c_errmsg    = @c_errmsg         OUTPUT

                        IF @b_success = 0
                        BEGIN
                           SET @n_Continue = 3
                           GOTO PACK_END
                        END

                        INSERT INTO PickDetail
                              (  PickDetailKey
                              ,  CaseID
                              ,  PickHeaderKey
                              ,  OrderKey
                              ,  OrderLineNumber
                              ,  Lot
                              ,  Storerkey
                              ,  Sku
                              ,  AltSku
                              ,  UOM
                              ,  UOMQty
                              ,  Qty
                              ,  QtyMoved
                              ,  [Status]
                              ,  DropID
                              ,  Loc
                              ,  ID
                              ,  PackKey
                              ,  UpdateSource
                              ,  CartonGroup
                              ,  CartonType
                              ,  ToLoc
                              ,  DoReplenish
                              ,  ReplenishZone
                              ,  DoCartonize
                              ,  PickMethod
                              ,  WaveKey
                              ,  EffectiveDate
                              ,  OptimizeCop
                              ,  ShipFlag
                              ,  PickSlipNo
                              ,  Taskdetailkey
                              ,  TaskManagerReasonkey
                              ,  Notes
                              ,  Channel_ID
                              )
                        SELECT PickDetailKey = @c_PickDetailKey
                              , CaseID = @c_LabelNo
                              , pd.PickHeaderKey
                              , pd.OrderKey
                              , pd.OrderLineNumber
                              , pd.Lot
                              , pd.Storerkey
                              , pd.Sku
                              , pd.AltSku
                              , pd.UOM
                              , cd.Qty
                              , cd.Qty
                              , pd.QtyMoved
                              , pd.[Status]
                              , IIF((ISNULL(U.UCCNo, '') = '' OR ISNULL(pd.DropID, '') = '') AND pd.UOM >= '6', @c_LabelNo, pd.DropID)
                              , pd.Loc
                              , pd.ID
                              , pd.PackKey
                              , pd.UpdateSource
                              , cd.CartonGroup
                              , cd.CartonType
                              , pd.ToLoc
                              , pd.DoReplenish
                              , pd.ReplenishZone
                              , pd.DoCartonize
                              , pd.PickMethod
                              , pd.WaveKey
                              , pd.EffectiveDate
                              , OptimizeCop = '9'
                              , pd.ShipFlag
                              , PickSlipNo = @c_PickSlipNo
                              , pd.Taskdetailkey
                              , pd.TaskManagerReasonkey
                              , cd.Notes
                              , pd.Channel_ID
                        FROM #CartonDetail AS cd
                        JOIN PickDetail AS pd (NOLOCK) ON pd.PickDetailKey = cd.RefPickKey
                        LEFT JOIN UCC U (NOLOCK) ON U.UCCNo = pd.DropID
                                                AND U.Storerkey = pd.Storerkey
                                                AND U.SKU = pd.SKU
                        WHERE cd.RowID = @n_RowID_cd

                        SET @n_err = @@ERROR
                        IF @n_err <> 0
                        BEGIN
                           SET @n_Continue = 3
                           SET @n_Err   = 64030
                           SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                                        +': Insert PICKDETAIL Failed. (mspRLWAV10_TOTE)'
                           GOTO PACK_END
                        END

                        UPDATE cd
                           SET cd.PickDetailKey = @c_PickDetailKey
                             , cd.LabelNo       = @c_LabelNo
                             , cd.DropID        = ISNULL(pd.DropID, '')
                        FROM #CartonDetail AS cd
                        JOIN PickDetail AS pd (NOLOCK) ON pd.PickDetailKey = @c_PickDetailKey
                        WHERE cd.RowID = @n_RowID_cd
                        AND   cd.[Status] = '9'
                     END
                     ELSE
                     BEGIN
                        UPDATE pd WITH (ROWLOCK)
                           SET pd.CaseID     = @c_LabelNo
                              ,pd.Qty        = CASE WHEN @c_RefPickMode = 'S' THEN @n_Qty ELSE pd.Qty END
                              ,pd.CartonType = cd.CartonType
                              ,pd.CartonGroup= cd.CartonGroup
                              ,pd.Trafficcop = NULL
                              ,pd.EditWho    = SUSER_SNAME()
                              ,pd.EditDate   = GETDATE()
                              ,pd.DropID     = IIF(ISNULL(pd.DropID, '') = '' AND pd.UOM >= '6', @c_LabelNo, pd.DropID)
                        FROM #CartonDetail AS cd
                        JOIN PickDetail AS pd ON pd.PickDetailKey = cd.RefPickkey
                        WHERE cd.RowID = @n_RowID_cd
                        AND   cd.[Status] = '9'

                        SET @n_err = @@ERROR
                        IF @n_err <> 0
                        BEGIN
                           SET @n_Continue = 3
                           SET @n_Err = 64040
                           SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                                        +': Update PICKDETAIL Failed. (mspRLWAV10_TOTE)'
                           GOTO PACK_END
                        END

                        UPDATE cd
                           SET cd.DropID = ISNULL(pd.DropID, '')
                        FROM #CartonDetail AS cd
                        JOIN PickDetail AS pd (NOLOCK) ON pd.PickDetailKey = cd.RefPickkey
                        WHERE cd.RowID = @n_RowID_cd
                        AND   cd.[Status] = '9'
                     END

                     FETCH NEXT FROM @cur_SPLPD INTO  @n_RowID_cd
                                                   ,  @n_Qty
                                                   ,  @c_RefPickkey
                                                   ,  @c_RefPickMode
                  END
                  CLOSE @cur_SPLPD
                  DEALLOCATE @cur_SPLPD

                  UPDATE cd
                  SET cd.LabelNo = @c_labelNo
                  FROM #CartonDetail AS cd
                  WHERE cd.CartonSeqNo = @n_CartonSeqNo
                  AND cd.LabelNo = ''
                  AND cd.[Status] = '9'
               END
               -----------------------------------------------------
               -- Gen Label#,Stamp CaseID and Split PickDetail - END
               -----------------------------------------------------
               UPDATE pw
                  SET pw.Qty         = CASE WHEN cd.RefPickMode = 'S'
                                            THEN cd.Qty
                                            ELSE pw.Qty END
                     ,pw.PickSlipNo  = @c_PickSlipNo
                     ,pw.CaseID      = cd.LabelNo
                     ,pw.CartonType  = cd.CartonType
                     ,pw.CartonGroup = cd.CartonGroup
               FROM #CartonDetail AS cd
               JOIN #PickDetail_WIP AS pw ON pw.PickdetailKey = cd.RefPickKey
               WHERE cd.CartonType > ''
               AND   cd.[LabelNo]  > ''
               AND   cd.[Status]   = '9'

               INSERT INTO #PickDetail_WIP
               (  [PickDetailKey]
               ,  [CaseID]
               ,  [PickHeaderKey]
               ,  [OrderKey]
               ,  [OrderLineNumber]
               ,  [Lot]
               ,  [Storerkey]
               ,  [Sku]
               ,  [AltSku]
               ,  [UOM]
               ,  [UOMQty]
               ,  [Qty]
               ,  [QtyMoved]
               ,  [Status]
               ,  [DropID]
               ,  [Loc]
               ,  [ID]
               ,  [PackKey]
               ,  [UpdateSource]
               ,  [CartonGroup]
               ,  [CartonType]
               ,  [ToLoc]
               ,  [DoReplenish]
               ,  [ReplenishZone]
               ,  [DoCartonize]
               ,  [PickMethod]
               ,  [WaveKey]
               ,  [LoadKey]
               ,  [EffectiveDate]
               ,  [AddDate]
               ,  [AddWho]
               ,  [EditDate]
               ,  [EditWho]
               ,  [TrafficCop]
               ,  [ArchiveCop]
               ,  [OptimizeCop]
               ,  [ShipFlag]
               ,  [PickSlipNo]
               ,  [TaskDetailKey]
               ,  [TaskManagerReasonKey]
               ,  [Notes]
               ,  [MoveRefKey]
               ,  [WIP_Refno]
               ,  [Channel_ID]
               )
               SELECT
                  cd.[PickDetailKey]
               ,  cd.[LabelNo]
               ,  pw.[PickHeaderKey]
               ,  pw.[OrderKey]
               ,  pw.[OrderLineNumber]
               ,  pw.[Lot]
               ,  pw.[Storerkey]
               ,  pw.[Sku]
               ,  pw.[AltSku]
               ,  pw.[UOM]
               ,  UOMQty = cd.Qty
               ,  Qty    = cd.Qty
               ,  pw.[QtyMoved]
               ,  pw.[Status]
               ,  pw.[DropID]
               ,  pw.[Loc]
               ,  pw.[ID]
               ,  pw.[PackKey]
               ,  pw.[UpdateSource]
               ,  cd.[CartonGroup]
               ,  cd.[CartonType]
               ,  pw.[ToLoc]
               ,  pw.[DoReplenish]
               ,  pw.[ReplenishZone]
               ,  pw.[DoCartonize]
               ,  pw.[PickMethod]
               ,  pw.[Wavekey]
               ,  pw.[LoadKey]
               ,  pw.[EffectiveDate]
               ,  pw.[AddDate]
               ,  pw.[AddWho]
               ,  pw.[EditDate]
               ,  pw.[EditWho]
               ,  pw.[TrafficCop]
               ,  pw.[ArchiveCop]
               ,  pw.[OptimizeCop]
               ,  pw.[ShipFlag]
               ,  pw.[PickSlipNo]
               ,  pw.[TaskDetailKey]
               ,  pw.TaskManagerReasonKey
               ,  cd.[Notes]
               ,  pw.[MoveRefKey]
               ,  WIP_Refno = pw.WIP_Refno
               ,  pw.[Channel_ID]
               FROM #CartonDetail AS cd
               JOIN #PickDetail_WIP AS pw ON pw.PickDetailKey = cd.RefPickKey
               WHERE cd.CartonType > ''
               AND   cd.[LabelNo]  > ''
               AND   cd.[Status]   = '9'
               AND   cd.RefPickMode = 'N'

               ------------------------------------------
               --- Create PACK  - END
               ------------------------------------------
               PACK_END:
            END
         END

         POST_PACK:
         FETCH NEXT FROM @cur_PCKGRPH INTO @n_PackGrpNo
      END
      CLOSE @cur_PCKGRPH
      DEALLOCATE @cur_PCKGRPH
   END

   IF @n_Debug = 9
   BEGIN
      SELECT Src = '#PickDetail_WIP', * FROM #PickDetail_WIP
   END

QUIT_SP:
   IF OBJECT_ID('tempdb..#CartonDetail') IS NOT NULL
   BEGIN
      DROP TABLE #CartonDetail
   END

   IF OBJECT_ID('tempdb..#CTNZ') IS NOT NULL
   BEGIN
      DROP TABLE #CTNZ
   END

   IF OBJECT_ID('tempdb..#OptimizeItemToPack') IS NOT NULL
   BEGIN
      DROP TABLE #OptimizeItemToPack
   END

   IF OBJECT_ID('tempdb..#PickDetail_WIP') IS NOT NULL
   BEGIN
      DROP TABLE #PickDetail_WIP
   END

   IF OBJECT_ID('tempdb..#PRECTN') IS NOT NULL
   BEGIN
      DROP TABLE #PRECTN
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV10_TOTE'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END
GO
GRANT EXECUTE ON [dbo].[mspRLWAV10_TOTE] TO [NSQL]
GO