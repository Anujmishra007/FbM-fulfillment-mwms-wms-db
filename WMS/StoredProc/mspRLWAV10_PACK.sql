SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/    
/* Stored Procedure: mspRLWAV10                                          */    
/* Creation Date: 2026-01-22                                             */    
/* Copyright: Maersk Logistics                                           */    
/* Written by: Wan                                                       */    
/*                                                                       */    
/* Purpose: FCR-10124 - UK Columbia SportWear Release Wave               */    
/*                                                                       */    
/* Called By: Wave                                                       */    
/*                                                                       */    
/* Version: 1.0                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 10-Feb-2026 WLChooi  1.0   Initial Version                            */
/*************************************************************************/      
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV10_PACK]       
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
         , @c_DocType               NVARCHAR(10)   = ''  
         , @c_BillToKey             NVARCHAR(15)   = ''
         , @c_Consigneekey          NVARCHAR(15)   = ''
         , @c_ExternOrderkey        NVARCHAR(30)   = ''
         , @c_Door                  NVARCHAR(10)   = ''
         , @c_Route                 NVARCHAR(10)   = ''
         , @c_PickSlipNo            NVARCHAR(10)   = ''
         , @n_PackGrpNo             INT            = 0
         , @n_HardCTNGrpNo          INT            = 0
         , @n_HardCTNGrpNo_P        INT            = 0
         , @n_SortCTNGrpNo          INT            = 0
         , @c_PackType              NVARCHAR(50)   = ''   
         , @c_HardCTNGroup          NVARCHAR(1000) = ''
         , @c_SortCTNGroup          NVARCHAR(1000) = ''
         , @b_CZN_Check             BIT            = 0
         , @b_GetSmaller            BIT            = 1

         , @n_ID_oitp               INT            = 0
         , @n_RowID_cz              INT            = 0         
         , @n_RowID_pcz             INT            = 0
         , @n_RowID_cd              INT            = 0
         , @n_AccessQty             INT            = 0
         , @n_SkuAccessQty          INT            = 0
         , @n_GetSmaller            INT            = 1 

         , @n_CartonNo_Cnt          INT            = 0
         , @n_TotalAuditCtn         INT            = 0
         , @n_AuditPercent          DECIMAL(5,2)   = 0
         , @c_AuditPercent          NVARCHAR(10)   = ''
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
         , @n_CartonNo_Last         INT            = 0  

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
         , @n_Weight                FLOAT          = 0.00 
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
         , @c_NewPickDetailKey      NVARCHAR(10)   = ''
         , @c_LabelNo               NVARCHAR(20)   = ''

         , @c_SQL                   NVARCHAR(4000) = ''
         , @c_SQLParms              NVARCHAR(4000) = ''
         , @c_SQLCond               NVARCHAR(4000) = ''
  
   DECLARE @cur_PCKGRPH          CURSOR
         , @cur_PCKGRPS          CURSOR
         , @cur_PRECTN           CURSOR   
         , @cur_SPLPD            CURSOR
         , @cur_CLOSECTN         CURSOR

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
      ,  Dim1              [DECIMAL](10,6)NOT NULL DEFAULT(0.00)  
      ,  Dim2              [DECIMAL](10,6)NOT NULL DEFAULT(0.00)  
      ,  Dim3              [DECIMAL](10,6)NOT NULL DEFAULT(0.00)  
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
      )

      IF OBJECT_ID('tempdb..#CartonDetail') IS NOT NULL
      BEGIN
         DROP TABLE #CartonDetail
      END

      CREATE TABLE #CartonDetail
      (  [RowID]           [int]          NOT NULL IDENTITY(1,1) PRIMARY KEY
      ,  [PickDetailKey]   [nvarchar](18) NOT NULL DEFAULT (' ')
      ,  [OrderKey]        [nvarchar](10) NOT NULL DEFAULT (' ')
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
      ORDER BY p.PickDetailKey

      SET @c_PackType     = 'ORDERS.Orderkey'
      SET @c_HardCTNGroup = 'ORDERS.Orderkey, ISNULL(SKU.BUSR7,'''')'

      SET @c_SortCTNGroup = @c_HardCTNGroup + 
                          + ',CASE WHEN PICKDETAIL.UOM = ''2'' THEN 2 ELSE 6 END'
                          + ',CASE WHEN PICKDETAIL.UOM >= ''6'''
                          +      ' AND  PICKSKU.SumSKUQty > @n_AccessQty THEN 0 ELSE 1 END'
                          + ',CASE WHEN WORKORDERDETAIL.WorkOrderkey IS NULL THEN 0 ELSE 1 END'
                          + ',CASE WHEN WORKORDERDETAIL.WorkOrderkey IS NULL'
                          +      ' THEN ISNULL(SKU.ItemClass,'''')'
                          +      ' WHEN WORKORDERDETAIL.Type = ''PA'''
                          +      ' THEN WORKORDERDETAIL.Type'
                          +      ' WHEN WORKORDERDETAIL.Type = ''PU'''
                          +      ' THEN WORKORDERDETAIL.Type'
                          +      ' WHEN WORKORDERDETAIL.Type = ''PD'''
                          +      ' THEN WORKORDERDETAIL.Type'
                          +      ' ELSE '''' END'
                          + ',CASE WHEN WORKORDERDETAIL.WorkOrderkey IS NULL'
                          +      ' THEN ISNULL(SKU.Size,'''')'
                          +      ' WHEN WORKORDERDETAIL.Type = ''PA'''
                          +      ' THEN ISNULL(SKU.SKU,'''')'
                          +      ' WHEN WORKORDERDETAIL.Type = ''PU'''
                          +      ' THEN WORKORDERDETAIL.Type'
                          +      ' WHEN WORKORDERDETAIL.Type = ''PD'''
                          +      ' THEN WORKORDERDETAIL.Type'
                          +      ' ELSE '''' END'
   END
 
   IF @n_Continue = 1
   BEGIN
      SELECT @c_CTNGroup = st.CartonGroup
      FROM STORER st (NOLOCK)
      WHERE st.StorerKey = @c_Storerkey

      --Full Carton/ UCC Carton Type
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
      )
      SELECT 
         c.CartonizationGroup  
      ,  c.CartonType          
      ,  c.[Cube]              
      ,  c.MaxWeight 
      ,  CartonLength = ISNULL(c.CartonLength,0.00)  
      ,  CartonWidth  = ISNULL(c.CartonWidth,0.00)   
      ,  CartonHeight = ISNULL(c.CartonHeight,0.00) 
      ,  FillTolerance= 100.00                                       --Not using FillTolerance
      ,  Dim1 = cds.MinVal
      ,  Dim2 = cds.MidVal
      ,  Dim3 = cds.MaxVal
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
      WHERE CODELKUP.Listname IN ('CSCUK01CFG', 'CSCUK01GCR', 'CSCUK01PT', 'ORDERAUDIT' ) 
      AND   CODELKUP.Storerkey = @c_Storerkey
      ORDER BY CODELKUP.Listname
           ,   CODELKUP.Code 

      SELECT @n_AccessQty = CASE WHEN ISNUMERIC(cl.Short) = 1 THEN cl.Short ELSE 0 END
      FROM @TMP_CL AS cl 
      WHERE cl.Listname = 'CSCUK01CFG'

      -- Picking Loc: PICKDETAIL.ToLoc, get at mspRLWAV10_DATA
      SET @c_SQL = N'SELECT PICKDETAIL.PickDetailKey'  
                 +  ', ORDERS.OrderKey' 
                 +  ', ORDERS.DocType'                  
                 +  ', ORDERS.BillToKey' 
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
                 +  ', SKU.StdCube'  
                 +  ', SKU.StdGrossWgt'  
                 +  ', Dim1 = sds.MinVal'
                 +  ', Dim2 = sds.MidVal'
                 +  ', Dim3 = sds.MaxVal'
                 +  ', PQI.PackQtyIndicator'                     
                 +  ', PICKDETAIL.UOM'              
                 +  ', PICKDETAIL.Qty'              
                 +  ', PICKDETAIL.DropID' 
                 +  ', IsVAS = CASE WHEN WORKORDERDETAIL.WorkOrderKey IS NULL THEN 0 ELSE 1 END'                 
                 +  ', VAS   = ISNULL(WORKORDERDETAIL.Type,'''')'
                 +  ', VASQty= ISNULL(WORKORDERDETAIL.VASQty,0)'
                 +  ', SkuAccessQty = CASE WHEN PICKDETAIL.UOM >= ''6'''
                 +                       ' AND  PICKSKU.SumSKUQty > @n_AccessQty'
                 +                       ' THEN 0 ELSE 1 END'
                 +  ' FROM #PickDetail_WIP PICKDETAIL'
                 +  ' JOIN ORDERS (NOLOCK) ON ORDERS.Orderkey = PICKDETAIL.Orderkey'
                 +  ' JOIN SKU (NOLOCK) ON  SKU.Storerkey = PICKDETAIL.Storerkey'
                 +                    ' AND SKU.Sku = PICKDETAIL.Sku'
                 +  ' JOIN PACK (NOLOCK) ON  PACK.Packkey = SKU.Packkey'
                 +  ' JOIN LOC (NOLOCK) ON LOC.Loc = PICKDETAIL.ToLoc'                 
                 +  ' JOIN ORDERDETAIL (NOLOCK)  ON ORDERDETAIL.Orderkey = ORDERS.Orderkey'
                 +  ' CROSS APPLY (SELECT MIN(val) AS MinVal' 
                 +                    ' , SUM(val) - MIN(val) - MAX(val) AS MidVal'
                 +                    ' , MAX(val) AS MaxVal'                        
                 +               ' FROM (VALUES (SKU.Length), (SKU.Width), (SKU.Height)) AS x(val)'
                 +               ') sds'
                 +  ' CROSS APPLY ( SELECT PackQtyIndicator = CASE WHEN SKU.PackQtyIndicator > 0'
                 +                                               ' THEN SKU.PackQtyIndicator ELSE 1 END' 
                 +              ' ) PQI' 
                 +  ' OUTER APPLY ( SELECT WorkOrderkey = MIN(w.WorkOrderKey)'
                 +                     ' , [Type] = MIN(w.[Type])'
                 +                     ' , VASQty = MAX(CASE WHEN w.[Type] = ''PU'' THEN w.Qty ELSE 0 END)'
                 +                ' FROM WORKORDERDETAIL w (NOLOCK)'
                 +                ' WHERE w.ExternWorkOrderKey = ORDERDETAIL.Orderkey'
                 +                ' AND w.ExternLineNo = ORDERDETAIL.OrderLineNumber'
                 +                ' AND w.[Type] IN (''PA'',''PD'',''PU'')'
                 +              ' ) AS WORKORDERDETAIL'
                 +  ' CROSS APPLY ( SELECT SumSKUQty = FLOOR(SUM(PD.Qty)/PQI.PackQtyIndicator)'
                 +                ' FROM #PICKDETAIL_WIP PD'
                 +                ' WHERE PD.Orderkey = PICKDETAIL.Orderkey'
                 +                ' AND PD.Storerkey = PICKDETAIL.Storerkey'
                 +                ' AND PD.SKU = PICKDETAIL.SKU'
                 +              ' ) AS PICKSKU'
                 +  ' ORDER BY PackGrpNo'
                 +         ' , HardCTNGrpNo'
                 +         ' , SortCTNGrpNo'
                 +         ' , LOC.LogicalLocation'
                 +         ' , PICKDETAIL.PickDetailKey'

      SET @c_SQLParms = N'@n_AccessQty INT'

      INSERT INTO #PRECTN  (  [PickDetailKey], [OrderKey], [DocType], [BillToKey]         
                           ,  [PackGrpNo], [HardCTNGrpNo],[SortCTNGrpNo]     
                           ,  [Storerkey], [Sku], [BUSR7], [ItemClass], [Size]              
                           ,  [Length], [Width], [Height], [StdCube], [StdGrossWgt]
                           ,  [Dim1], [Dim2], [Dim3]
                           ,  [PackQtyIndicator]         
                           ,  [UOM], [Qty], [DropID]  
                           ,  [IsVAS], [VAS], [VASQty], [SkuAccessQty]                                         
                           )
      EXEC sp_ExecuteSQL @c_SQL 
                        ,@c_SQLParms
                        ,@n_AccessQty = @n_AccessQty

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
      SELECT DISTINCT
            pcz.Orderkey
         ,  pcz.DocType
         ,  pcz.BillToKey
         ,  pcz.Storerkey
         ,  pcz.PackGrpNo
      FROM #PRECTN AS pcz
      ORDER BY pcz.PackGrpNo 

      OPEN @cur_PCKGRPH

      FETCH NEXT FROM @cur_PCKGRPH INTO @c_Orderkey, @c_DocType, @c_BillToKey, @c_Storerkey
                                       ,@n_PackGrpNo 
 
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
         FROM #CTNZ AS cz  
         
         WHERE cz.CartonizationGroup = @c_CTNGroup
         ORDER BY cz.RowID

         SELECT TOP 1 
                  @c_CartonType_Max = cz.CartonType
               ,  @n_CartonCube_Max = cz.[Cube]
               ,  @n_CartonWeight_Max = cz.MaxWeight
         FROM #CTNZ AS cz 
         WHERE cz.CartonDefault = 1
         ORDER BY cz.RowID

         -- B2C
         IF @c_DocType = 'E'
         BEGIN
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
            )
            SELECT cz.CartonizationGroup
                  ,cz.CartonType
                  ,cz.[Cube]  
                  ,CartonWeight = CASE WHEN ISNUMERIC(cl1.UDF02) = 0 
                                       THEN cz.MaxWeight
                                       WHEN CONVERT(FLOAT, cl1.UDF02) = 0.0000 
                                       THEN cz.MaxWeight
                                       ELSE cl1.UDF02
                                       END
                  ,cz.CartonLength          
                  ,cz.CartonWidth           
                  ,cz.CartonHeight
                  ,cz.Dim1
                  ,cz.Dim2
                  ,cz.Dim3                  
            FROM @TMP_CL cl1 
            JOIN @t_CTNZ cz  ON  cz.CartonizationGroup = @c_CTNGroup
                             AND cz.CartonType = cl1.Short
            WHERE cl1.ListName = 'CSCUK01GCR'
            AND   cl1.Code     > ''
            AND   cl1.Storerkey= @c_Storerkey
            AND   cl1.Code2    = @c_BillToKey
            AND   cl1.Long     = 'ECO'   --ECO stands for ECOM
            AND   cl1.Short    > ''
            AND   cl1.UDF01    = 'Y'
            ORDER BY cl1.Code

            SET @n_ROwCount = @@ROWCOUNT
            IF @n_ROwCount = 0
            BEGIN
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
               FROM @t_CTNZ cz  
               WHERE cz.CartonizationGroup = @c_CTNGroup
               ORDER BY cz.RowID
            END
         END
         ------------------------
         -- UOM = '2'
         ------------------------
         SET @n_Cnt = 0
         INSERT INTO #CartonDetail 
            (  [PickDetailKey]    
            ,  [OrderKey]         
            ,  [CartonGroup]      
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
            ,  [IsApi]
            )
         SELECT 
               pcz.PickDetailKey     
            ,  pcz.OrderKey          
            ,  CartonGroup = ISNULL(czb.CartonizationGroup,czs.CartonizationGroup)      
            ,  CartonType  = ISNULL(czb.CartonType,czs.CartonType)            
            ,  CartonSeqNo = DENSE_RANK() OVER (ORDER BY pcz.DropID)      
            ,  CartonCube  = ISNULL(czb.[Cube],czs.[Cube])     
            ,  CartonWeight= ISNULL(czb.MaxWeight,czs.MaxWeight)    
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
            ,  pcz.Qty               
            ,  pcz.DropID           
            ,  PickRefkey = ''      
            ,  RefPickMode = ''     
            ,  Notes      = ''                
            ,  [Status]   = '9'
            ,  IsApi = 0
         FROM #PRECTN AS pcz
         CROSS APPLY (  SELECT TotalPackCube = SUM(pcz1.StdCube*pcz1.Qty_PI)
                        FROM #PRECTN AS pcz1
                        WHERE pcz1.DropID = pcz.DropID
                     ) cs
         OUTER APPLY (  SELECT TOP 1
                              cz.CartonizationGroup
                           ,  cz.CartonType
                           ,  cz.[Cube]
                           ,  cz.MaxWeight
                        FROM @TMP_CL cl1
                        JOIN @TMP_CL cl2 ON  cl2.ListName = 'CSCUK01GCR'
                                         AND cl2.Code > ''
                                         AND cl2.Storerkey = pcz.Storerkey
                                         AND cl2.Code2 = @c_BillToKey
                                         AND cl2.Long  = cl1.UDF01
                                         AND cl2.UDF01 = 'Y'
                        JOIN @t_CTNZ AS cz ON cz.CartonType = cl2.Short
                        WHERE cl1.ListName = 'CSCUK01PT'
                        AND   cl1.Code = pcz.BUSR7
                        AND   cl1.Storerkey = pcz.Storerkey
                        AND   cl1.UDF01 > ''
                        AND   cz.[Cube] >= cs.TotalPackCube
                        ORDER BY cz.RowID
                     ) czb
         OUTER APPLY (  SELECT TOP 1  
                              cz.CartonizationGroup
                           ,  cz.CartonType
                           ,  cz.[Cube]
                           ,  cz.MaxWeight
                        FROM @t_CTNZ AS cz
                        WHERE cz.[Cube] >= cs.TotalPackCube 
                        ORDER BY cz.RowID
                      ) czs
         WHERE pcz.PackGrpNo = @n_PackGrpNo
         AND   pcz.UOM = '2'
         ORDER BY pcz.RowID 

         --------------------------
         -- UOM = '6' & '7' Normal
         --------------------------
         SET @n_SkuAccessQty   = 0
         PRECZN:
         SET @n_HardCTNGrpNo_P = ''
         SET @c_ItemClass_P    = ''
         SET @c_Size_P         = ''

         SET @n_CartonSeqNo = 0
         SELECT TOP 1 @n_CartonSeqNo = cd.CartonSeqNo
         FROM #CartonDetail AS cd 
         WHERE cd.OrderKey = @c_Orderkey
         ORDER BY cd.CartonSeqNo DESC

         SET @cur_PCKGRPS = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT top 1  RowID_pcz = MIN(pcz.RowID) 
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
               ,  VASQty   = SUM(pcz.VASQty)
               ,  VASQty_PI= SUM(pcz.VASQty_PI)
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
               
               -- B2B
               IF @c_DocType <> 'E'
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
                  FROM #CTNZ AS cz  
                  WHERE cz.CartonizationGroup = @c_CTNGroup
                  ORDER BY cz.RowID

                  SELECT TOP 1 
                           @c_CartonType_Max = cz.CartonType
                        ,  @n_CartonCube_Max = cz.[Cube]
                        ,  @n_CartonWeight_Max = cz.MaxWeight
                  FROM #CTNZ AS cz 
                  WHERE cz.CartonDefault = 1
                  ORDER BY cz.RowID

                  SET @n_RowCount     = 0
                  SET @c_CTNGroup_BTK = ''

                  SELECT @n_RowCount     = 1
                        ,@c_CTNGroup_BTK = cl1.UDF01
                        ,@b_API          = IIF(ISNUMERIC(cl1.UDF02) = 1, cl1.UDF02, 0)
                  FROM @TMP_CL cl1 
                  WHERE cl1.ListName = 'CSCUK01PT'
                  AND   cl1.Code     = @c_BUSR7
                  AND   cl1.Storerkey= @c_Storerkey

                  IF @n_RowCount = 1 AND @c_CTNGroup_BTK > ''
                  BEGIN
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
                     )
                     SELECT cz.CartonizationGroup
                           ,cz.CartonType
                           ,cz.[Cube]  
                           ,CartonWeight = CASE WHEN ISNUMERIC(cl1.UDF02) = 0 
                                                THEN cz.MaxWeight
                                                WHEN CONVERT(FLOAT, cl1.UDF02) = 0.0000 
                                                THEN cz.MaxWeight
                                                ELSE cl1.UDF02
                                                END
                           ,cz.CartonLength          
                           ,cz.CartonWidth           
                           ,cz.CartonHeight
                           ,cz.Dim1
                           ,cz.Dim2
                           ,cz.Dim3                           
                     FROM @TMP_CL cl1 
                     JOIN @t_CTNZ cz  ON  cz.CartonizationGroup = @c_CTNGroup
                                      AND cz.CartonType = cl1.Short
                     WHERE cl1.ListName = 'CSCUK01GCR'
                     AND   cl1.Code     > ''
                     AND   cl1.Storerkey= @c_Storerkey
                     AND   cl1.Code2    = @c_BillToKey
                     AND   cl1.Long     = @c_CTNGroup_BTK         --BillToKey CartonGroup          
                     AND   cl1.Short    > ''
                     AND   cl1.UDF01    = 'Y'
                     ORDER BY cl1.Code
                     SET @n_RowCount = @@ROWCOUNT
                  END

                  IF @n_RowCount = 0 OR (@n_RowCount = 1 AND @c_CTNGroup_BTK = '')
                  BEGIN
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
                     FROM @t_CTNZ cz  
                     WHERE cz.CartonizationGroup = @c_CTNGroup
                     ORDER BY cz.RowID
                  END
               END
            END

            -- VAS - Open new carton even same SKUs
            IF @b_NewCarton = 0 AND @b_IsVAS = 1 AND @c_Sku_P  = @c_Sku
            BEGIN
               SET @b_NewCarton = 1
            END   

            SET @n_RowID_pcz = 0
            --SET @n_Qty_pd    = 0  
            --SET @c_RefPickMode = ''
            WHILE @n_Qty > 0 AND @n_Continue = 1
            BEGIN
               SET @n_GetSmaller = 1
               SET @b_CZN_Check  = 0
               --DELETE FROM @t_ItemToPack

               --SET @b_API = 1

               IF @b_NewCarton = 0 AND @n_SkuAccessQty = 0
               BEGIN
                  IF @c_VAS = 'PA'  AND @n_QtyLeftToFulFill_PI = 0
                  BEGIN
                     SET @b_NewCarton = 1
                  END

                  -- Non-VAS
                  -- If current open box already contains sku and next sku 
                  -- to pack has different Sku.Itemclass
                  IF @c_VAS <> 'PA' AND  
                     @c_ItemClass <> @c_ItemClass_P
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
                        INSERT INTO #OptimizeItemToPack (Storerkey, Sku, Dim1, Dim2, Dim3, Quantity)
                        SELECT Storerkey, Sku, pcz.[Length], pcz.Width, pcz.Height, Qty_PI
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
                     END
                  END

                  -- Non-VAS
                  -- If current open box already contains sku and next sku to pack 
                  -- has same Sku.Itemclass (but different size):
                  --IF @c_VAS <> 'PA' AND  
                  --   @c_ItemClass = @c_ItemClass_P AND
                  --   @c_Size <> @c_Size_P 
                  --BEGIN 
                  --   SET @n_ItemQty_Sum  = 0
                  --   SELECT @n_ItemQty_Sum  = SUM(pcz.Qty_PI)
                  --   FROM #PRECTN AS pcz
                  --   WHERE pcz.PackGrpNo    = @n_PackGrpNo
                  --   AND   pcz.HardCTNGrpNo = @n_HardCTNGrpNo
                  --   AND   pcz.SortCTNGrpNo = @n_SortCTNGrpNo
                  --   AND   pcz.ItemClass    = @c_ItemClass
                  --   AND   pcz.Size         = @c_Size
                  --   AND   pcz.RowID        > @n_RowID_pcz

                  --   IF @n_ItemQty_Sum <= @n_AccessQty
                  --   BEGIN
                  --      PRINT 'Last Carton#'
                  --      PRINT 'INSERT INTO #CARTONDetail'

                  --      SET @n_Qty = 0 -- Make it break the Loop for next item
                  --   END
                  --   ELSE IF @n_ItemQty_Sum > @n_AccessQty
                  --   BEGIN
                  --      SET @b_NewCarton = 1
                  --   END 
                  --END
               END

               IF @n_Qty > 0
               BEGIN               
                  IF @b_NewCarton = 1
                  BEGIN
                     DELETE FROM @t_ItemToPack;

                     IF EXISTS ( SELECT 1
                                 FROM #CartonDetail AS cd
                                 WHERE cd.Orderkey = @c_Orderkey
                                 AND   cd.CartonSeqNo = @n_CartonSeqNo
                                 AND   cd.[Status] = '0'
                                 )
                     BEGIN
                        --Get smaller carton if any and close carton
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
                     SET @n_CBMLeftToFulFill = @n_CartonCube  
                     SET @n_WgtLeftToFulFill = @n_CartonWeight

                     IF @c_VAS = 'PA' AND @n_SkuAccessQty = 0
                     BEGIN 
                        SET @n_QtyLeftToFulFill_PI = @n_VASQty_PI
                     END
                  END

                  IF @c_VAS = 'PA' AND @n_SkuAccessQty = 0
                  BEGIN
                     SET @b_API = 0
                     SET @n_QtyToPack_PI = @n_Qty_PI
                     IF @n_Qty_PI > @n_VASQty_PI
                     BEGIN
                        SET @n_QtyToPack_PI = @n_VASQty_PI
                     END
                  END
                  ELSE 
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

                        IF @n_CBMLeftToFulFill > @n_ItemCBM
                        BEGIN
                           SET @n_QtyCBM_PI = FLOOR(@n_ItemCBM/@n_StdCube) 
                        END
                        ELSE
                        BEGIN
                           SET @n_QtyCBM_PI = FLOOR(@n_CBMLeftToFulFill/@n_StdCube) 
                        END

                        IF @n_WgtLeftToFulFill > @n_ItemWgt
                        BEGIN
                           SET @n_QtyWgt_PI = FLOOR(@n_ItemWgt/@n_StdGrossWgt) 
                        END
                        ELSE
                        BEGIN
                           SET @n_QtyWgt_PI = FLOOR(@n_WgtLeftToFulFill/@n_StdGrossWgt)
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
                  
                  IF @n_QtyToPack_PI = 0
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
                     SET @b_GetSmaller   = 0
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
                        INSERT INTO @t_ItemToPack (Storerkey, Sku, [Length], Width, Height, Qty)
                        VALUES (@c_Storerkey, @c_Sku, @n_Length, @n_Width, @n_Height, @n_QtyToPack)
                        
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
                              , @c_Algorithm   = ''
                              , @b_Success     = @b_Success       OUTPUT    
                              , @n_Err         = @n_Err           OUTPUT    
                              , @c_ErrMsg      = @c_ErrMsg        OUTPUT   
                              , @b_debug       = 0  

                           IF @b_Success = 0
                           BEGIN
                              SET @n_Continue = 3
                           END
                           
                           IF @n_Continue = 1
                           BEGIN
                              SET @c_IsCompletePack = ''    
                              SELECT @c_IsCompletePack = orn.IsCompletePack  
                              FROM @t_OptimizeResult AS orn

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
                        ELSE IF @b_CZN_Check = 2
                        BEGIN
                           GOTO CZN_Close
                        END
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
                                     @n_RowID_pcz = pcz.RowID
                                    ,@c_RefPickKey= pcz.PickDetailKey
                                    ,@n_Qty_pd    = pcz.Qty
                              FROM #PRECTN AS pcz
                              WHERE pcz.Orderkey = @c_Orderkey
                              AND   pcz.HardCTNGrpNo = @n_HardCTNGrpNo
                              AND   pcz.SortCTNGrpNo = @n_SortCTNGrpNo
                              AND   pcz.Storerkey= @c_Storerkey
                              AND   pcz.Sku      = @c_Sku
                              AND   pcz.[Status] = '0'
                              AND   pcz.RowID   >= @n_RowID_pcz
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
                              --WHERE pcz.RowID = @n_RowID_pcz
                              WHERE pcz.Pickdetailkey = @c_RefPickKey
                           END

                           INSERT INTO #CartonDetail 
                              (  [PickDetailKey]    
                              ,  [OrderKey]         
                              ,  [CartonGroup]      
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
                              )
                           SELECT 
                                 pcz.PickDetailKey  
                              ,  pcz.OrderKey          
                              ,  CartonGroup = @c_CTNGroup 
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
                           FROM #PRECTN AS pcz
                           WHERE pcz.Pickdetailkey = @c_RefPickKey
                        END

                        SET @n_TotalQty_PI         = @n_TotalQty_PI + @n_QtyToPack_PI 
                        SET @n_TotalCBM            = @n_TotalCBM + (@n_StdCube*@n_QtyToPack_PI)
                        SET @n_TotalWgt            = @n_TotalWgt + (@n_StdGrossWgt*@n_QtyToPack_PI)
                        SET @n_QtyLeftToFulFill_PI = @n_QtyLeftToFulFill_PI - @n_QtyToPack_PI
                        SET @n_CBMLeftToFulFill    = @n_CBMLeftToFulFill - (@n_StdCube*@n_QtyToPack_PI)
                        SET @n_WgtLeftToFulFill    = @n_WgtLeftToFulFill - (@n_StdCube*@n_QtyToPack_PI)
                        SET @n_Qty_PI              = @n_Qty_PI - @n_QtyToPack_PI 
                        SET @n_Qty                 = @n_Qty    - @n_QtyToPack
                     END
                     
                     ------------------------------
                     -- Get Smaller Carton & Close
                     ------------------------------
                     CLOSE_CTN:
                     IF @n_Continue = 1 AND @b_NewCarton = 1
                     BEGIN
                        IF @n_GetSmaller = 1
                        BEGIN
                           IF @b_API = 0
                           BEGIN
                              SELECT TOP 1
                                   @c_CartonType   = cz.CartonType
                                 , @n_CartonCube   = cz.[Cube]
                                 , @n_CartonWeight = cz.MaxWeight
                                 , @n_FillTolerance= 100.00
                              FROM #CTNZ cz
                              WHERE cz.CartonizationGroup = @c_CTNGroup 
                              AND   cz.[Cube]    >= @n_TotalCBM  
                              AND   cz.MaxWeight >= @n_TotalWgt
                              AND   cz.CartonDefault = 0
                              ORDER BY cz.RowID DESC
                           END
                           ELSE
                           BEGIN
                              SET @c_IsCompletePack = ''
                              WHILE @c_IsCompletePack <> 'TRUE' 
                              BEGIN
                                 SELECT TOP 1
                                      @c_CartonType   = cz.CartonType
                                    , @n_CartonCube   = cz.[Cube]
                                    , @n_CartonWeight = cz.MaxWeight
                                    , @n_FillTolerance= 100.00
                                    , @n_RowID_cz     = cz.RowID
                                 FROM #CTNZ cz
                                 WHERE cz.CartonizationGroup = @c_CTNGroup 
                                 AND   cz.[Cube]    >= @n_TotalCBM  
                                 AND   cz.MaxWeight >= @n_TotalWgt
                                 AND   cz.CartonDefault = 0
                                 AND   cz.RowID > @n_RowID_cz
                                 ORDER BY cz.RowID 

                                 IF @@ROWCOUNT = 0
                                 BEGIN
                                    BREAK
                                 END

                                 SET @b_CZN_Check = 2

                                 GOTO CTZ_API
                                 CZN_Close:
                              END
                           END
                        END

                        UPDATE cd
                        SET CartonType   = @c_CartonType      
                           ,CartonCube   = @n_CartonCube     
                           ,CartonWeight = @n_CartonWeight
                           ,[Status]     = '9'
                        FROM #CartonDetail AS cd
                        WHERE cd.OrderKey = @c_Orderkey
                        AND   cd.CartonSeqNo = @n_CartonSeqNo
                     END
                  END
               END    
            END  
            
            SET @n_HardCTNGrpNo_P = @n_HardCTNGrpNo
            SET @c_ItemClass_P = @c_ItemClass
            SET @c_Size_P = @c_Size
            SET @c_Sku_P  = @c_Sku 
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

         -- Close Last Carton
         IF @n_Continue = 1 
         BEGIN
            SET @cur_CLOSECTN = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT cd.OrderKey, cd.CartonSeqNo, cd.IsApi
                 , SUM((cd.Qty / cd.PackQtyIndicator) * cd.StdCube)
                 , SUM((cd.Qty / cd.PackQtyIndicator) * cd.StdGrossWgt)
                 , cz.RowID
            FROM #CartonDetail AS cd
            JOIN #CTNZ AS cz ON cd.CartonGroup = cz.CartonizationGroup AND cd.CartonType = cz.CartonType
            WHERE cd.[Status] = '0'
            AND cd.UOM >= '6'
            GROUP BY cd.OrderKey, cd.CartonSeqNo, cd.IsApi, cz.RowID
            ORDER BY cd.OrderKey, cd.CartonSeqNo

            OPEN @cur_CLOSECTN

            FETCH NEXT FROM @cur_CLOSECTN INTO @c_Orderkey, @n_CartonSeqNo, @b_API, @n_TotalCBM, @n_TotalWgt, @n_RowID_cz

            WHILE @@FETCH_STATUS <> -1
            BEGIN
               IF @b_API = 0
               BEGIN
                  SELECT TOP 1
                       @c_CartonType   = cz.CartonType
                     , @n_CartonCube   = cz.[Cube]
                     , @n_CartonWeight = cz.MaxWeight
                     , @n_FillTolerance= 100.00
                  FROM #CTNZ cz
                  WHERE cz.CartonizationGroup = @c_CTNGroup 
                  AND   cz.[Cube]    >= @n_TotalCBM  
                  AND   cz.MaxWeight >= @n_TotalWgt
                  AND   cz.CartonDefault = 0
                  ORDER BY cz.RowID DESC
               END
               ELSE
               BEGIN
                  SET @c_IsCompletePack = ''
                  WHILE @c_IsCompletePack <> 'TRUE' 
                  BEGIN
                     SELECT TOP 1
                          @c_CartonType   = cz.CartonType
                        , @n_CartonCube   = cz.[Cube]
                        , @n_CartonWeight = cz.MaxWeight
                        , @n_FillTolerance= 100.00
                        , @n_RowID_cz     = cz.RowID
                     FROM #CTNZ cz
                     WHERE cz.CartonizationGroup = @c_CTNGroup 
                     AND   cz.[Cube]    >= @n_TotalCBM  
                     AND   cz.MaxWeight >= @n_TotalWgt
                     AND   cz.CartonDefault = 0
                     AND   cz.RowID > @n_RowID_cz
                     ORDER BY cz.RowID 
                     
                     IF @@ROWCOUNT = 0
                     BEGIN
                        GOTO NEXT_CLOSE_CTN
                     END

                     SET @c_IsCompletePack = ''
                     WHILE @c_IsCompletePack <> 'TRUE'
                     BEGIN
                        DELETE FROM @t_OptimizeResult; 

                        INSERT INTO @t_OptimizeResult (ContainerID, AlgorithmID, IsCompletePack, ID, SKU, Qty)    
                        EXEC isp_SubmitToCartonizeAPI    
                             @c_CartonGroup = @c_CTNGroup     
                           , @c_CartonType  = @c_CartonType
                           , @c_Algorithm   = ''
                           , @b_Success     = @b_Success       OUTPUT    
                           , @n_Err         = @n_Err           OUTPUT    
                           , @c_ErrMsg      = @c_ErrMsg        OUTPUT   
                           , @b_debug       = 0  

                        IF @b_Success = 0
                        BEGIN
                           SET @n_Continue = 3
                        END
                        
                        IF @n_Continue = 1
                        BEGIN
                           SET @c_IsCompletePack = ''    
                           SELECT @c_IsCompletePack = orn.IsCompletePack  
                           FROM @t_OptimizeResult AS orn
                           
                           BREAK
                        END
                     END   -- @b_API = 1 Loop
                  END
               END

               UPDATE cd
               SET CartonType   = @c_CartonType      
                  ,CartonCube   = @n_CartonCube     
                  ,CartonWeight = @n_CartonWeight
                  ,[Status]     = '9'
               FROM #CartonDetail AS cd
               WHERE cd.OrderKey = @c_Orderkey
               AND   cd.CartonSeqNo = @n_CartonSeqNo

               NEXT_CLOSE_CTN:
               FETCH NEXT FROM @cur_CLOSECTN INTO @c_Orderkey, @n_CartonSeqNo, @b_API, @n_TotalCBM, @n_TotalWgt, @n_RowID_cz
            END
            CLOSE @cur_CLOSECTN
            DEALLOCATE @cur_CLOSECTN
         END

         SET @n_SkuAccessQty = @n_SkuAccessQty + 1
         IF EXISTS ( SELECT 1 
                     FROM #PRECTN AS pcz
                     WHERE SkuAccessQty = @n_SkuAccessQty
                   )
         BEGIN
            GOTO PRECZN
         END

         IF @n_Debug = 9
         BEGIN
            SELECT Src = '#CartonDetail',* FROM #CartonDetail
            SELECT Src = '#PRECTN',* FROM #PRECTN
         END
         -----------------------------------
         --UPDATE Carton(s) for Audit
         -----------------------------------
         SELECT TOP 1 
                  @c_AuditPercent = CL.Short
         FROM @TMP_CL cl
         WHERE CL.LISTNAME = 'ORDERAUDIT'
         AND CL.Storerkey = @c_Storerkey
         AND CL.Code IN (@c_BillToKey,@c_Storerkey)
         ORDER BY CASE WHEN CL.Code = @c_BillToKey 
                       THEN 1
                       WHEN CL.Code = @c_Storerkey
                       THEN 2
                       ELSE 9
                       END

         IF @c_AuditPercent > ''
         BEGIN
            SET @c_AuditPercent = REPLACE(@c_AuditPercent,'%','')
         END

         SET @n_AuditPercent = CASE WHEN ISNUMERIC(@c_AuditPercent) = 1 
                                    THEN CONVERT(Decimal(5,2), @n_AuditPercent)
                                    ELSE 0
                                    END
                  
         IF @n_AuditPercent > 0  
         BEGIN
            SELECT @n_CartonNo_Cnt = COUNT(DISTINCT cd.CartonSeqNo)
            FROM #CartonDetail cd
            WHERE cd.OrderKey = @c_Orderkey
            AND cd.UOM >= '6'
            AND cd.[Status] = '9'
            AND cd.IsVas = 0

            IF @n_CartonNo_Cnt > 0 
            BEGIN
               SET @n_TotalAuditCtn = @n_CartonNo_Cnt * (@n_AuditPercent / 100.00)
            END

            IF @n_TotalAuditCtn > 0
            BEGIN
               UPDATE cd
                  SET [Audit] = 1
               FROM #CartonDetail AS cd
               CROSS APPLY (
                              SELECT TOP (@n_TotalAuditCtn)
                                       cd.OrderKey
                                      ,cd.CartonSeqNo 
                              FROM #CartonDetail AS cd
                              WHERE cd.OrderKey = @c_Orderkey
                              AND cd.UOM >= '6'
                              AND cd.[Status] = '9'
                              AND cd.IsVas    = 0
                              GROUP BY cd.UOM, cd.CartonSeqNo
                              ORDER BY CASE WHEN cd.UOM >= '6' THEN 1 ELSE 9 END
                                    ,  cd.CartonSeqNo DESC
                           ) aud
               WHERE cd.Orderkey = @c_Orderkey
               AND cd.CartonSeqNo = aud.CartonSeqNo
            END
         END

         BUILD_PACK: 
         IF @n_Continue = 1 
         BEGIN
            ------------------------------------------
            --- Create PACK  - START
            ------------------------------------------
            IF EXISTS ( SELECT 1
                        FROM #CartonDetail AS cd
                        WHERE cd.OrderKey = @c_Orderkey
                        AND cd.CartonSeqNo > 0
                        AND cd.RefPickKey > ''
                        AND cd.[Status] = '9'
                      )
            BEGIN
               EXEC [dbo].[isp_CreatePickSlip]     
                   @c_Orderkey              = @c_Orderkey            
                  ,@c_Wavekey               = @c_Wavekey                            --2026-01-20   
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
                  GOTO PACK_END
               END

               SET @c_PickSlipNo = ''
               SELECT @c_PickSlipNo = p.PickHeaderKey
               FROM dbo.PICKHEADER AS p  WITH (NOLOCK)
               WHERE p.Orderkey = @c_Orderkey
               AND   p.[Zone] = '3'
         
               IF NOT EXISTS (SELECT 1 FROM PACKHEADER PH WITH (NOLOCK) 
                              WHERE PH.PickSlipNo = @c_PickSlipNo)
               BEGIN
                  INSERT INTO PACKHEADER (PickSlipNo, Storerkey, Orderkey, Loadkey
                                          , Consigneekey, [Route], OrderRefNo ) 
                  SELECT @c_Pickslipno , o.Storerkey, o.Orderkey, ISNULL(o.LoadKey,'')
                        , o.Consigneekey, o.[Route], o.ExternOrderkey                  
                  FROM ORDERS o (NOLOCK) 
                  WHERE o.Orderkey = @c_Orderkey

                  SET @n_err = @@ERROR  
                  IF @n_err <> 0  
                  BEGIN
                     SET @n_Continue = 3  
                     SET @n_Err = 64010 
                     SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                                  +': Insert PACKHEADER Failed. (mspRLWAV10_PACK)' 
                     GOTO PACK_END
                  END         
               END
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
                  WHERE cd.OrderKey  = @c_Orderkey
                  AND cd.CartonType  > ''
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
                         +',@c_Orderkey: ' + @c_Orderkey
                  END 

                  EXEC isp_GenUCCLabelNo_Std    
                        @cPickslipNo   = @c_PickSlipNo  
                     ,  @nCartonNo     = 0  
                     ,  @cLabelNo      = @c_LabelNo   OUTPUT  
                     ,  @b_success     = @b_success   OUTPUT  
                     ,  @n_err         = @n_err       OUTPUT  
                     ,  @c_errmsg      = @c_errmsg    OUTPUT  
  
                  IF @b_Success = 0  
                  BEGIN  
                     SET @n_Continue = 3  
                     SET @n_err = 64020   
                     SET @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)
                                  +': Error Executing isp_GenUCCLabelNo_Std. (mspRLWAV10_PACK)'   
                                  + ' ( ' + @c_errmsg + ' ) ' 
                     GOTO PACK_END             
                  END  

                  SET @cur_SPLPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                  SELECT cd.RowID 
                        ,cd.Qty
                        ,cd.RefPickkey
                        ,cd.RefPickMode
                  FROM #CartonDetail AS cd
                  WHERE cd.Orderkey   = @c_Orderkey
                  AND   cd.CartonType > ''
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
                              , pd.DropID
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
                        WHERE cd.RowID = @n_RowID_cd

                        SET @n_err = @@ERROR  
                        IF @n_err <> 0  
                        BEGIN
                           SET @n_Continue = 3  
                           SET @n_Err   = 64030
                           SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                                        +': Insert PICKDETAIL Failed. (mspRLWAV10_PACK)' 
                           GOTO PACK_END
                        END 

                        UPDATE cd
                           SET cd.PickDetailKey = @c_PickDetailKey
                             , cd.LabelNo       = @c_LabelNo
                        FROM #CartonDetail AS cd
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
                                        +': Update PICKDETAIL Failed. (mspRLWAV10_PACK)' 
                           GOTO PACK_END
                        END 
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
                  WHERE cd.Orderkey  = @c_Orderkey
                  AND cd.CartonSeqNo = @n_CartonSeqNo
                  AND cd.LabelNo = ''
                  AND cd.[Status]='9'
               END
               -----------------------------------------------------
               -- Gen Label#,Stamp CaseID and Split PickDetail - END
               -----------------------------------------------------
               IF @n_debug >= 1
               BEGIN
                  SELECT @c_PickSlipNo
                        ,CartonNo   = cd.CartonSeqNo 
                        ,[Weight]   = ISNULL(SUM(cd.Weight * cd.Qty),0.00)
                        ,[Cube]     = cz.[Cube]                                   
                        ,Qty        = ISNULL(SUM(cd.Qty),0)
                        ,CartonType = cd.CartonType
                        ,[Length]   = cz.CartonLength
                        ,[Width]    = cz.CartonWidth
                        ,[Height]   = cz.CartonHeight
                        ,UCCNo      = CASE WHEN cd.UOM = '2' THEN cd.LabelNo ELSE '' END
                  FROM #CartonDetail AS cd
                  JOIN @t_CTNZ AS cz ON  cz.CartonizationGroup = cd.CartonGroup
                                     AND cz.CartonType = cd.CartonType
                  WHERE cd.Orderkey = @c_Orderkey
                  AND cd.CartonType > ''
                  AND cd.[Status]   ='9'
                  GROUP BY cd.CartonSeqNo
                        ,  cd.CartonType
                        ,  cz.[Cube]  
                        ,  cz.CartonLength
                        ,  cz.CartonWidth
                        ,  cz.CartonHeight 
                        ,  CASE WHEN cd.UOM = '2' THEN cd.LabelNo ELSE '' END                                   
            
                  SELECT @c_PickSlipNo
                        ,CartonNo = cd.CartonSeqNo 
                        ,cd.LabelNo
                        ,LabelLine = RIGHT('00000' + CONVERT(NVARCHAR(5), ROW_NUMBER() 
                                       OVER (PARTITION BY cd.LabelNo 
                                       ORDER BY cd.CartonSeqNo, cd.Storerkey, cd.Sku)),5)
                        ,cd.Storerkey
                        ,cd.Sku
                        ,Qty = ISNULL(SUM(cd.Qty),0)
                  FROM #CartonDetail AS cd
                  WHERE cd.Orderkey = @c_Orderkey
                  AND cd.CartonType > ''
                  GROUP BY cd.CartonSeqNo
                        ,  cd.LabelNo
                        ,  cd.Storerkey
                        ,  cd.Sku
               
                  SELECT @c_PickSlipNo
                        ,CartonNo = cd.CartonSeqNo  
                        ,cd.LabelNo
                        ,cd.Storerkey
                        ,cd.Sku
                        ,cd.Qty
                        ,Cartontype,cartonseqno
                        ,[status]
                  FROM #CartonDetail AS cd
                  WHERE cd.Orderkey = @c_Orderkey  
                  AND cd.CartonType > ''
                  ORDER BY cd.CartonSeqNo    
               END
            
               SET @n_CartonNo_Last = 0                                             
               SELECT TOP 1 @n_CartonNo_Last = pd.CartonNo 
               FROM dbo.PackDetail pd
               WHERE pd.PickSlipNo = @c_PickSlipNo
               ORDER BY pd.CartonNo DESC

               INSERT INTO dbo.PackDetail
                  (  PickSlipNo
                  ,  CartonNo
                  ,  LabelNo
                  ,  LabelLine
                  ,  Storerkey
                  ,  Sku
                  ,  Qty
                  ,  ExpQty
                  )
               SELECT PickSlipNo = @c_PickSlipNo
                     ,CartonNo = cd.CartonSeqNo + @n_CartonNo_Last                  
                     ,cd.LabelNo
                     ,LabelLine = RIGHT('00000' + CONVERT(NVARCHAR(5), 
                                          ROW_NUMBER() OVER (  PARTITION BY cd.LabelNo 
                                                               ORDER BY cd.CartonSeqNo
                                                                      , cd.Storerkey
                                                                      , cd.Sku))
                                      ,5)
                     ,cd.Storerkey
                     ,cd.Sku
                     ,Qty    = CASE WHEN cd.IsVas = 1 AND cd.UOM >= '6' 
                                    THEN 0
                                    WHEN cd.[Audit] = 0 
                                    THEN 0 
                                    ELSE SUM(cd.Qty) END
                     ,ExpQty = CASE WHEN cd.IsVas = 1 AND cd.UOM >= '6' 
                                    THEN SUM(cd.Qty) 
                                    WHEN cd.[Audit] = 1 
                                    THEN SUM(cd.Qty) 
                                    ELSE 0 END
               FROM #CartonDetail AS cd
               WHERE cd.Orderkey = @c_Orderkey
               AND cd.CartonType > ''
               AND cd.[Status] = '9'
               GROUP BY cd.CartonSeqNo
                     ,  cd.LabelNo
                     ,  cd.Storerkey
                     ,  cd.Sku
                     ,  cd.IsVAS
                     ,  cd.UOM
                     ,  cd.[Audit]
               ORDER BY cd.CartonSeqNo
                     ,  cd.Storerkey
                     ,  cd.Sku

               SET @n_err = @@ERROR  
               IF @n_err <> 0  
               BEGIN
                  SET @n_Continue = 3  
                  SET @n_Err      = 64050 
                  SET @c_errmsg   ='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                                  +': Insert PACKDETAIL Failed. (mspRLWAV10_PACK)' 
                  GOTO PACK_END
               END 
         
               INSERT INTO dbo.PackInfo
                  (  PickSlipNo
                  ,  CartonNo
                  ,  [Weight]
                  ,  [Cube]
                  ,  Qty
                  ,  CartonType
                  ,  [Length] 
                  ,  [Width]  
                  ,  [Height] 
                  ,  UCCNo
                  ,  CartonStatus
                  )
               SELECT @c_PickSlipNo
                     ,CartonNo   = cd.CartonSeqNo  + @n_CartonNo_Last              
                     ,[Weight]   = ISNULL(SUM(cd.Weight * cd.Qty),0.00)
                     ,[Cube]     = cz.[Cube]                                   
                     ,Qty        = CASE WHEN cd.[Audit] = 1 
                                        THEN 0 
                                        ELSE ISNULL(SUM(cd.Qty),0) END
                     ,CartonType = cd.CartonType
                     ,[Length]   = cz.CartonLength
                     ,[Width]    = cz.CartonWidth
                     ,[Height]   = cz.CartonHeight
                     ,UCCNo      = CASE WHEN cd.UOM = '2' THEN cd.LabelNo ELSE '' END
                     ,CartonStatus = CASE WHEN cd.[Audit] = 1 THEN 'PENDAUDIT' ELSE '' END
               FROM #CartonDetail AS cd
               CROSS APPLY (
                            SELECT TOP 1
                                    cz1.CartonLength
                                 ,  cz1.CartonWidth
                                 ,  cz1.CartonHeight
                                 ,  cz1.[Cube] 
                            FROM #CTNZ AS cz1 
                            WHERE cz1.CartonizationGroup = cd.CartonGroup
                            AND cz1.CartonType = cd.CartonType
                            ) cz
               WHERE cd.Orderkey = @c_Orderkey
               AND cd.CartonType > ''
               AND cd.[Status]   = '9'
               GROUP BY cd.CartonSeqNo
                     ,  cd.CartonType
                     ,  cz.[Cube]  
                     ,  cz.CartonLength
                     ,  cz.CartonWidth
                     ,  cz.CartonHeight 
                     ,  CASE WHEN cd.UOM = '2' THEN cd.LabelNo ELSE '' END
                     ,  cd.[Audit]
 
               SET @n_err = @@ERROR  
               IF @n_err <> 0  
               BEGIN
                  SET @n_Continue = 3  
                  SET @n_Err   = 64060 
                  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                               +': Insert PACKINFO Failed. (mspRLWAV10_PACK)' 
                  GOTO PACK_END
               END 

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
               WHERE cd.Orderkey   = @c_Orderkey
               AND   cd.CartonType > ''
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
               WHERE cd.Orderkey   = @c_Orderkey
               AND   cd.CartonType > ''
               AND   cd.[LabelNo]  > ''
               AND   cd.[Status]   = '9'
               AND   cd.RefPickMode = 'N'
               
               ------------------------------------------
               --- Create PACK  - END
               ------------------------------------------
               PACK_END:
            END
         END
  
         FETCH NEXT FROM @cur_PCKGRPH INTO @c_Orderkey, @c_DocType, @c_BillToKey, @c_Storerkey
                                          ,@n_PackGrpNo 
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV10_PACK'
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
GRANT EXECUTE ON [dbo].[mspRLWAV10_PACK] TO [NSQL]
GO