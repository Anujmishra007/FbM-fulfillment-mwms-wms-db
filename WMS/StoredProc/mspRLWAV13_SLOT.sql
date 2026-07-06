SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/**************************************************************************/    
/* Stored Procedure: mspRLWAV13_Slot                                      */    
/* Creation Date: 2026-06-24                                              */    
/* Copyright: Maersk                                                      */    
/* Written by: Wan                                                        */    
/*                                                                        */    
/* Purpose: FCR-12980 - AEOMX Release Wave                                */  
/*                                                                        */  
/* Called By: Wave Release                                                */    
/*          :                                                             */    
/* Version: 1.0                                                           */    
/*                                                                        */    
/* Data Modifications:                                                    */    
/*                                                                        */    
/* Updates:                                                               */    
/* Date        Author   Ver   Purposes                                    */ 
/**************************************************************************/   
 
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV13_Slot]        
   @c_Wavekey     NVARCHAR(10)
,  @c_Storerkey   NVARCHAR(15)   = '' 
,  @c_Facility    NVARCHAR(5)    = '' 
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
           @n_StartTCnt          INT   = @@TRANCOUNT
         , @n_Continue           INT   = 1
         , @n_Cnt                INT   = 0

         , @c_SourceType         NVARCHAR(30)= 'mspRLWAV13'
         , @c_UserName           NVARCHAR(128) = ''              

         , @c_Channel_b          NVARCHAR(20)= ''
         , @c_Client             NVARCHAR(20)= ''
         , @c_CartonGroup        NVARCHAR(10)= ''
         , @c_CartonType         NVARCHAR(10)= ''
         , @c_AttribSortGrp1     NVARCHAR(50)= ''
         , @c_AttribSortGrp2     NVARCHAR(50)= ''
         , @c_AttribSortGrp3     NVARCHAR(50)= ''
         , @c_AttribSortGrp4     NVARCHAR(50)= ''
         , @c_AttribSortGrp5     NVARCHAR(50)= ''
         , @c_AttribSortGrp1_P   NVARCHAR(50)= ''
         , @c_AttribSortGrp2_P   NVARCHAR(50)= ''
         , @c_AttribSortGrp3_P   NVARCHAR(50)= ''
         , @c_AttribSortGrp4_P   NVARCHAR(50)= ''
         , @c_AttribSortGrp5_P   NVARCHAR(50)= ''
         , @c_SlotUOM            NVARCHAR(1) = ''
         , @c_ListName_Rule      NVARCHAR(10)= ''
         , @c_Code_Rule          NVARCHAR(30)= ''
         , @c_Code_Rule_P        NVARCHAR(30)= ''
         , @c_Code_RuleMapTo     NVARCHAR(50)= ''

         , @c_PickDetailKey      NVARCHAR(10)= ''
         , @c_PickDetailKey_New  NVARCHAR(10)= ''
         , @c_Sku                NVARCHAR(20)= ''
         , @c_VirtualCaseID      NVARCHAR(20)= ''

         , @n_SlotSequence       INT         = 0 
         , @n_Qty                INT         = 0 
         , @n_QtyLeftToFill      INT         = 0 
         , @n_QtyFill            INT         = 0 
         , @n_QtyToTake          INT         = 0 
         , @n_QtyDeptLimit       INT         = 0             
         , @n_QtyLimit           INT         = 0 
         , @n_QtyLimitLeftToFill INT         = 0 
         , @n_QtyTotal           INT         = 0 
         , @n_CBMAlloc           FLOAT       = 0.00
         , @n_CBMTotal           FLOAT       = 0.00
         , @n_CBMLeftToFill      FLOAT       = 0.00
         , @n_CubeUOM3           FLOAT       = 0.00
         , @n_StdGrossWgt        FLOAT       = 0.00
         , @n_CartonCube         FLOAT       = 0.00

         , @b_Split              BIT         = 0
         , @b_SlotNew            BIT         = 0

         , @c_SQL                NVARCHAR(MAX) = ''
         , @c_SQLParms           NVARCHAR(2000)= ''                                   
  
         , @cur_Slot             CURSOR

   DECLARE @t_CL                 TABLE
         (  [RowID]              INT               IDENTITY(1,1) PRIMARY KEY                   
         ,  [LISTNAME]           [nvarchar](10)    NULL     
         ,  [Code]               [nvarchar](30)    NULL  
         ,  [Description]        [nvarchar](250)   NULL  
         ,  [Short]              [nvarchar](10)    NULL  
         ,  [Long]               [nvarchar](250)   NULL  
         ,  [Notes]              [nvarchar](4000)  NULL  
         ,  [Notes2]             [nvarchar](4000)  NULL  
         ,  [Storerkey]          [nvarchar](50)    NOT NULL  
         ,  [UDF01]              [nvarchar](60)    NOT NULL  
         ,  [UDF02]              [nvarchar](60)    NOT NULL  
         ,  [UDF03]              [nvarchar](60)    NOT NULL  
         ,  [UDF04]              [nvarchar](60)    NOT NULL  
         ,  [UDF05]              [nvarchar](60)    NOT NULL  
         ,  [code2]              [nvarchar](30)    NOT NULL 
         )  

   DECLARE @t_CZ                 TABLE
         (  [CartonizationKey]   [nvarchar](10)                    PRIMARY KEY                   
         ,  [CartonizationGroup] [nvarchar](10)    NOT NULL     
         ,  [CartonType]         [nvarchar](30)    NOT NULL  
         ,  [UseSequence]        [int]             NOT NULL  
         ,  [Cube]               [float]           NOT NULL  
         ,  [MaxWeight]          [float]           NOT NULL  
         ,  [MaxCount]           [float]           NOT NULL  
         ,  [CartonWeight]       [float]           NULL  
         ,  [CartonLength]       [float]           NULL  
         ,  [CartonWidth]        [float]           NULL  
         ,  [CartonHeight]       [float]           NULL  
         ,  [FillTolerance]      [int]             NULL  
         )  

   SET @b_Success = 1    
   SET @n_Err     = 0    
   SET @c_ErrMsg  = ''    
   SET @c_UserName= dbo.fnc_GetUserName()

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
      CREATE INDEX IDX_Case ON #PickDetail_WIP (CaseID, Lot, Loc, ID)
      CREATE INDEX IDX_RPF ON #PickDetail_WIP (ReplenishZone)

      EXEC [dbo].[mspRLWAV13_DATA]        
         @c_Wavekey     = @c_Wavekey 
      ,  @b_Success     = @b_Success   OUTPUT
      ,  @n_Err         = @n_Err       OUTPUT
      ,  @c_ErrMsg      = @c_ErrMsg    OUTPUT 
      ,  @n_debug       = @n_debug  
 
      SET @n_Continue = CASE WHEN @b_Success = 0 THEN 3
                             ELSE 1
                             END
   END

   IF @n_Continue = 1
   BEGIN
      IF OBJECT_ID('tempdb..#PICKDETAIL_SLOT') IS NOT NULL
      BEGIN
         DROP TABLE #PICKDETAIL_SLOT;
      END

      CREATE TABLE #PICKDETAIL_SLOT
      (
         [PickDetailKey]   [nvarchar](18) NOT NULL PRIMARY KEY
      ,  [AttribSortGrp1]  [nvarchar](50) NOT NULL DEFAULT (' ')
      ,  [AttribSortGrp2]  [nvarchar](50) NOT NULL DEFAULT (' ')
      ,  [AttribSortGrp3]  [nvarchar](50) NOT NULL DEFAULT (' ')
      ,  [AttribSortGrp4]  [nvarchar](50) NOT NULL DEFAULT (' ')
      ,  [AttribSortGrp5]  [nvarchar](50) NOT NULL DEFAULT (' ')
      ,  [Rule_ListName]   [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [Rule_Code]       [nvarchar](10) NOT NULL DEFAULT (' ')
      )         
   END

   IF @n_Continue = 1
   BEGIN
      
      IF @c_Storerkey = ''
      BEGIN 
         SELECT TOP 1 @c_Storerkey = pw.Storerkey
         FROM #PickDetail_WIP AS pw
      END
      
      SELECT  
            @c_Channel_b = w.UserDefine03
         ,  @c_Client    = w.UserDefine05
      FROM WAVE w (NOLOCK) 
      WHERE w.Wavekey = @c_Wavekey

      SET @c_CartonGroup = 'AEO_PACKAG'
      SET @c_AttribSortGrp1 = 'ORDERS.Consigneekey'
      SET @c_AttribSortGrp2 = ''
      SET @c_ListName_Rule = ''
      SET @c_SlotUOM = ''

      IF @c_Client = 'COPP'
      BEGIN
         SET @c_CartonGroup    = 'AEO_COPPEL'
         SET @c_AttribSortGrp2 = 'SKU.BUSR1'
         SET @c_ListName_Rule  = 'COPPELPPAC'
         SET @c_Code_RuleMapTo = 'SKU.BUSR1'
      END
      ELSE IF @c_Client IN ('LIV','SUB')
      BEGIN
         SET @c_AttribSortGrp2 = 'SKU.SkuGroup'
      END
      ELSE IF @c_Client = 'ML'
      BEGIN
         SET @c_SlotUOM = '6' 
      END
      ELSE IF @c_Channel_b = 'RTL'
      BEGIN
         SET @c_AttribSortGrp2 = 'SKU.SkuGroup'
      END

      SET @c_SQL = N'SELECT PickDetail_WIP.PickDetailKey'
                 + ',' + IIF(@c_AttribSortGrp1 > '', @c_AttribSortGrp1, '''''')
                 + ',' + IIF(@c_AttribSortGrp2 > '', @c_AttribSortGrp2, '''''')
                 + ',' + IIF(@c_AttribSortGrp3 > '', @c_AttribSortGrp3, '''''')
                 + ',' + IIF(@c_AttribSortGrp4 > '', @c_AttribSortGrp4, '''''')
                 + ',' + IIF(@c_AttribSortGrp5 > '', @c_AttribSortGrp5, '''''')
                 + ',' + IIF(@c_ListName_Rule > '',  '''' + @c_ListName_Rule + '''', '''''')
                 + ',' + IIF(@c_Code_RuleMapTo > '', @c_Code_RuleMapTo, '''''') 
                 + ' FROM #PickDetail_WIP AS PickDetail_WIP'
                 + ' JOIN ORDERS (NOLOCK) ON ORDERS.Orderkey = PickDetail_WIP.Orderkey'
                 + ' JOIN SKU (NOLOCK) ON SKU.StorerKey = PickDetail_WIP.Storerkey'
                 + '                   AND SKU.Sku = PickDetail_WIP.Sku'
                 + ' WHERE PickDetail_WIP.CaseID = '''''
                 + CASE WHEN @c_SlotUOM > '' 
                        THEN ' AND PickDetail_WIP.UOM = @c_SlotUOM'
                        END

      SET @c_SQLParms= N'@c_AttribSortGrp1   NVARCHAR(50)'
                     + ',@c_AttribSortGrp2   NVARCHAR(50)'
                     + ',@c_AttribSortGrp3   NVARCHAR(50)'
                     + ',@c_AttribSortGrp4   NVARCHAR(50)'
                     + ',@c_AttribSortGrp5   NVARCHAR(50)'
                     + ',@c_ListName_Rule    NVARCHAR(10)'
                     + ',@c_Code_RuleMapTo   NVARCHAR(50)'
                     + ',@c_SlotUOM          NVARCHAR(1)'

      INSERT INTO  #PICKDETAIL_SLOT
      (  [PickDetailKey]  
      ,  [AttribSortGrp1], [AttribSortGrp2], [AttribSortGrp3], [AttribSortGrp4], [AttribSortGrp5] 
      ,  [Rule_ListName],  [Rule_Code]  
      )

      EXEC sp_ExecuteSQL @c_SQL
                        ,@c_SQLParms
                        ,@c_AttribSortGrp1 
                        ,@c_AttribSortGrp2 
                        ,@c_AttribSortGrp3 
                        ,@c_AttribSortGrp4 
                        ,@c_AttribSortGrp5 
                        ,@c_ListName_Rule     
                        ,@c_Code_RuleMapTo
                        ,@c_SlotUOM

      IF @c_ListName_Rule > ''
      BEGIN
         INSERT INTO @t_CL ( Listname, Code, Description, Short, Long                
                           , Notes, Notes2, Storerkey
                           , UDF01, UDF02, UDF03, UDF04, UDF05, Code2
                           )  
         SELECT cl.Listname   
            ,   cl.Code   
            ,   [Description] = ISNULL(cl.[Description],'')   
            ,   Short = ISNULL(cl.Short,'')      
            ,   Long  = ISNULL(cl.Long ,'')     
            ,   Notes = ISNULL(cl.Notes,'')      
            ,   Notes2= ISNULL(cl.Notes2,'')           
            ,   cl.Storerkey  
            ,   cl.UDF01  
            ,   cl.UDF02    
            ,   cl.UDF03   
            ,   cl.UDF04   
            ,   cl.UDF05     
            ,   cl.Code2  
         FROM CODELKUP CL (NOLOCK)  
         WHERE cl.Listname = @c_ListName_Rule
         AND   cl.Storerkey= @c_Storerkey
      END

      INSERT INTO @t_CZ
            (  [CartonizationKey]                 
            ,  [CartonizationGroup] 
            ,  [CartonType]         
            ,  [UseSequence]        
            ,  [Cube]               
            ,  [MaxWeight]          
            ,  [MaxCount]           
            ,  [CartonWeight]       
            ,  [CartonLength]       
            ,  [CartonWidth]        
            ,  [CartonHeight]       
            ,  [FillTolerance]      
            )
      SELECT   cz.CartonizationKey                 
            ,  cz.CartonizationGroup     
            ,  cz.CartonType 
            ,  cz.UseSequence 
            ,  cz.[Cube]               
            ,  cz.MaxWeight           
            ,  cz.MaxCount             
            ,  CartonWeight  = ISNULL(cz.CartonWeight,0.00) 
            ,  CartonLength  = ISNULL(cz.CartonLength,0.00)  
            ,  CartonWidth   = ISNULL(cz.CartonWidth,0.00) 
            ,  CartonHeight  = ISNULL(cz.CartonHeight,0.00)  
            ,  FillTolerance = ISNULL(cz.FillTolerance,0.00) 
      FROM CARTONIZATION cz (NOLOCK)
      WHERE cz.CartonizationGroup = @c_CartonGroup
      ORDER BY cz.[Cube] 
   END

   IF @n_Continue = 1
   BEGIN
      SET @n_SlotSequence = 0

      SELECT TOP 1 @n_SlotSequence = RIGHT(pd.Caseid,6)
      FROM PICKDETAIL pd (NOLOCK)
      WHERE pd.CaseID Like @c_Wavekey + '_[0-9][0-9][0-9][0-9][0-9][0-9]%'
      AND LEN(pd.CaseID) = LEN(@c_Wavekey) + 7
      ORDER BY pd.CaseID DESC

      SET @b_SlotNew = 0
      SET @cur_Slot = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT   ps.PickDetailKey
            ,  ps.AttribSortGrp1
            ,  ps.AttribSortGrp2
            ,  ps.AttribSortGrp3
            ,  ps.AttribSortGrp4
            ,  ps.AttribSortGrp5
            ,  ps.Rule_ListName
            ,  ps.Rule_Code
            ,  pw.Storerkey
            ,  pw.Sku
            ,  pw.Qty
            ,  p.CubeUOM3 
            ,  s.StdGrossWgt
      FROM #PICKDETAIL_SLOT AS ps
      JOIN #PICKDETAIL_WIP AS pw ON pw.PickDetailKey = ps.PickDetailKey
      JOIN SKU s (NOLOCK) ON  s.Storerkey = pw.Storerkey
                          AND s.Sku = pw.Sku
      JOIN Pack p (NOLOCK) ON p.Packkey = s.Packkey
      ORDER BY ps.AttribSortGrp1
            ,  ps.AttribSortGrp2
            ,  ps.AttribSortGrp3
            ,  ps.AttribSortGrp4
            ,  ps.AttribSortGrp5

      OPEN @cur_Slot

      FETCH NEXT FROM @cur_Slot INTO @c_PickDetailKey
                                    ,@c_AttribSortGrp1
                                    ,@c_AttribSortGrp2
                                    ,@c_AttribSortGrp3
                                    ,@c_AttribSortGrp4
                                    ,@c_AttribSortGrp5
                                    ,@c_ListName_Rule
                                    ,@c_Code_Rule
                                    ,@c_Storerkey
                                    ,@c_Sku
                                    ,@n_Qty
                                    ,@n_CubeUOM3
                                    ,@n_StdGrossWgt

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         SET @n_QtyLeftToFill = @n_Qty
         SET @b_Split = 0
         
         WHILE @n_QtyLeftToFill > 0 AND @n_Continue = 1
         BEGIN
            SET @n_QtyLimitLeftToFill = @n_QtyLeftToFill            
            IF @c_AttribSortGrp1_P <> @c_AttribSortGrp1 OR
               @c_AttribSortGrp2_P <> @c_AttribSortGrp2 OR
               @c_AttribSortGrp3_P <> @c_AttribSortGrp3 OR
               @c_AttribSortGrp4_P <> @c_AttribSortGrp4 OR
               @c_AttribSortGrp5_P <> @c_AttribSortGrp5 OR
               @n_CartonCube <= @n_CBMTotal + @n_CubeUOM3 OR
               @n_QtyToTake = 0
            BEGIN 
               SET @b_SlotNew = 1
            END

            IF @c_Code_Rule > ''
            BEGIN
               IF @n_QtyLimit = 0 
               BEGIN
                  SET @b_SlotNew = 1
               END

               IF @c_Code_Rule_P <> @c_Code_Rule 
               BEGIN
                  SET @n_QtyDeptLimit = 0
                  SELECT @n_QtyDeptLimit = cl.UDF01
                  FROM @t_CL cl
                  WHERE cl.LISTNAME = @c_ListName_Rule
                  AND   cl.Code = @c_Code_Rule
                  AND   cl.Storerkey = @c_Storerkey

                  SET @b_SlotNew = 1  
               END
            END

            IF @b_SlotNew = 1
            BEGIN
               IF @n_CBMTotal > 0
               BEGIN
                  GOTO SMALLER_CTN
                  NEW_SLOT:
               END

               SET @n_CartonCube = 0.00
               SET @c_Cartontype = ''
               SELECT TOP 1 
                        @n_CartonCube = cz.[Cube]
                     ,  @c_Cartontype = cz.CartonType
               FROM @t_CZ AS cz
               WHERE cz.cartonizationGroup = @c_CartonGroup
               ORDER BY cz.[Cube] DESC

               IF @n_CartonCube = 0.00
               BEGIN
                  SET @n_Continue = 3  
                  SET @n_Err = 66010 
                  SET @c_ErrMsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)
                                + ': CartonGroup/CartonType not setup. (mspRLWAV13_Slot'
                  BREAK
               END

               SET @b_SlotNew  = 0
               SET @n_QtyTotal = 0.00
               SET @n_CBMTotal = 0.00
               SET @n_CBMLeftToFill = @n_CartonCube
               
               IF @c_Code_Rule > ''
               BEGIN
                  SET @n_QtyLimit = 0
                  SET @n_QtyLimit = @n_QtyDeptLimit 
               END

               SET @n_SlotSequence = @n_SlotSequence + 1

               SET @c_VirtualCaseID = @c_Wavekey + 
                                    + '_'
                                    + RIGHT('000000' + CONVERT(NVARCHAR(6), @n_SlotSequence),6)
            END
            
            IF @c_Code_Rule > ''
            BEGIN
               IF @n_QtyLimit < @n_QtyLimitLeftToFill
               BEGIN
                  SET @n_QtyLimitLeftToFill = @n_QtyLimit
               END
            END

            SET @n_QtyToTake = 0
            SET @n_QtyFill = FLOOR(@n_CBMLeftToFill/@n_CubeUOM3) 
            IF @n_QtyFill >= @n_QtyLimitLeftToFill
            BEGIN
               SET @n_QtyToTake = @n_QtyLimitLeftToFill
            END
            ELSE
            BEGIN
               SET @n_QtyToTake = @n_QtyFill
            END
            SET @n_CBMAlloc = @n_CubeUOM3 * @n_QtyToTake

            IF @n_QtyToTake > 0
            BEGIN
               SET @n_QtyTotal = @n_QtyTotal + @n_QtyToTake
               SET @n_CBMTotal = @n_CBMTotal + @n_CBMAlloc
               SET @n_CBMLeftToFill = @n_CBMLeftToFill - @n_CBMAlloc
               SET @n_QtyLimitLeftToFill = @n_QtyLimitLeftToFill - @n_QtyToTake
               SET @n_QtyLeftToFill = @n_QtyLeftToFill - @n_QtyToTake
               IF @c_Code_Rule > ''
               BEGIN
                  SET @n_QtyLimit = @n_QtyLimit - @n_QtyToTake
               END
               
               IF @b_Split = 0
               BEGIN
                  UPDATE pw
                     SET pw.CaseID = @c_VirtualCaseID
                        ,pw.Qty = @n_QtyToTake
                        ,pw.CartonType = @c_CartonType
                        ,pw.EditWho    = @c_UserName
                        ,pw.EditDate   = GetDate()
                  FROM #PICKDETAIL_WIP AS pw
                  WHERE pw.PickdetailKey = @c_PickdetailKey
               END
               ELSE IF @b_Split = 1 
               BEGIN
                  SET @b_Success = 1    
                  EXECUTE nspg_getkey   
                        @KeyName    = 'PickDetailKey'             
                     ,  @fieldlength= 10    
                     ,  @keystring  = @c_PickDetailKey_New  OUTPUT  
                     ,  @b_Success  = @b_Success            OUTPUT  
                     ,  @n_err      = @n_err                OUTPUT  
                     ,  @c_errmsg   = @c_errmsg             OUTPUT  

                  IF @b_Success <> 1    
                  BEGIN    
                     SET @n_Continue = 3    
                  END 
                  
                  IF @n_Continue = 1
                  BEGIN
                     INSERT INTO #PickDetail_WIP 
                        (
                           [PickDetailKey]   
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
                           PickdetailKey = @c_PickDetailKey_New   
                        ,  CaseID = @c_VirtualCaseID           
                        ,  pw.PickHeaderKey   
                        ,  pw.OrderKey        
                        ,  pw.OrderLineNumber 
                        ,  pw.Lot            
                        ,  pw.Storerkey      
                        ,  pw.Sku             
                        ,  pw.AltSku          
                        ,  pw.UOM            
                        ,  pw.UOMQty         
                        ,  Qty = @n_QtyToTake            
                        ,  pw.QtyMoved        
                        ,  pw.[Status]          
                        ,  pw.DropID           
                        ,  pw.Loc              
                        ,  pw.ID              
                        ,  pw.PackKey         
                        ,  pw.UpdateSource     
                        ,  pw.CartonGroup      
                        ,  CartonType = @c_CartonType       
                        ,  pw.ToLoc          
                        ,  pw.DoReplenish      
                        ,  pw.ReplenishZone    
                        ,  pw.DoCartonize      
                        ,  pw.PickMethod       
                        ,  WaveKey = @c_WaveKey         
                        ,  pw.LoadKey         
                        ,  pw.EffectiveDate    
                        ,  OptimizeCop = '9'          
                        ,  pw.ShipFlag         
                        ,  pw.PickSlipNo       
                        ,  pw.TaskDetailKey    
                        ,  pw.TaskManagerReasonKey  
                        ,  Notes = 'Ref Pickdetailkey: ' + @c_PickdetailKey
                                 + ', Qty: ' + CONVERT(NVARCHAR(10), @n_Qty)        
                        ,  pw.MoveRefKey    
                        ,  pw.WIP_Refno        
                        ,  pw.Channel_ID       
                     FROM #PICKDETAIL_WIP AS pw
                     WHERE pw.PickdetailKey = @c_PickdetailKey
                  END
               END  -- Split
               
               IF @n_QtyLeftToFill > 0 
               BEGIN
                  SET @b_Split = 1
               END
            END
         END

         SET @c_AttribSortGrp1_P = @c_AttribSortGrp1
         SET @c_AttribSortGrp2_P = @c_AttribSortGrp2
         SET @c_AttribSortGrp3_P = @c_AttribSortGrp3
         SET @c_AttribSortGrp4_P = @c_AttribSortGrp4
         SET @c_AttribSortGrp5_P = @c_AttribSortGrp5
         SET @c_Code_Rule_P = @c_Code_Rule

         FETCH NEXT FROM @cur_Slot INTO @c_PickDetailKey
                                       ,@c_AttribSortGrp1
                                       ,@c_AttribSortGrp2
                                       ,@c_AttribSortGrp3
                                       ,@c_AttribSortGrp4
                                       ,@c_AttribSortGrp5
                                       ,@c_ListName_Rule
                                       ,@c_Code_Rule
                                       ,@c_Storerkey
                                       ,@c_Sku
                                       ,@n_Qty
                                       ,@n_CubeUOM3
                                       ,@n_StdGrossWgt
      END
      CLOSE @cur_Slot
      DEALLOCATE @cur_Slot
   END
   SET @b_SlotNew = 0

   SMALLER_CTN:
   IF @n_Continue = 1 AND @c_Cartontype > ''
   BEGIN
      SET @n_Cnt = 0
      SELECT TOP 1 
               @n_Cnt = 1
            ,  @c_Cartontype = cz.CartonType
      FROM @t_CZ AS cz
      WHERE cz.cartonizationGroup = @c_CartonGroup
      AND cz.[Cube] >= @n_CBMTotal
      AND cz.CartonType <> @c_Cartontype
      ORDER BY cz.[Cube]

      IF @n_Cnt = 1
      BEGIN
         UPDATE #PickDetail_WIP
         SET CartonType = @c_Cartontype
         WHERE CaseID = @c_VirtualCaseID
      END
      
      IF @b_SlotNew = 1
      BEGIN
         GOTO NEW_SLOT
      END
   END
QUIT_SP:
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV13_Slot'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      IF @n_Continue = 4 SET @b_Success = 4

      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END 
GO
GRANT EXECUTE ON mspRLWAV13_Slot TO NSQL
GO
