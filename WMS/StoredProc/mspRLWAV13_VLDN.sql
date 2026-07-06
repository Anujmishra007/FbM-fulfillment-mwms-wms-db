SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/**************************************************************************/    
/* Stored Procedure: mspRLWAV13_VLDN                                      */    
/* Creation Date: 2026-06-16                                              */    
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
/* 2026-07-01  Wan      1.0   Remove raise Error                          */
/**************************************************************************/ 

CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV13_VLDN]       
   @c_Wavekey     NVARCHAR(10)
,  @c_Storerkey   NVARCHAR(15)   = '' 
,  @c_Facility    NVARCHAR(5)    = '' 
,  @b_Success     INT            = 1   OUTPUT
,  @n_Err         INT            = 0   OUTPUT
,  @c_ErrMsg      NVARCHAR(255)  = ''  OUTPUT 
,  @b_ReCartonize INT            = 0
,  @n_debug       INT            = 0
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
     
   DECLARE
           @n_StartTCnt          INT            = @@TRANCOUNT
         , @n_Continue           INT            = 1

         , @c_SourceType         NVARCHAR(30)   = 'mspRLWAV13'
 
         , @c_Client             NVARCHAR(20)   = ''
         , @c_AreaKey            NVARCHAR(10)   = ''  
         , @c_Sku                NVARCHAR(20)   = ''
         , @c_Loc                NVARCHAR(10)   = ''
         , @n_CUBEUOM3           FLOAT          = 0.00         

         , @c_SQL                NVARCHAR(4000) = ''
         , @c_SQLParms           NVARCHAR(4000) = ''

   DECLARE @t_CL             TABLE
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
      IF NOT EXISTS ( SELECT 1 FROM #PickDetail_WIP AS pw )
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 63010
         SET @c_ErrMsg   = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                         + 'Nothing to release. (mspRLWAV13_VLDN)'
      END
   END

   IF @n_Continue = 1
   BEGIN
      IF @c_Facility = '' OR @c_Storerkey = ''
      BEGIN
         SELECT TOP 1 
                  @c_Facility  = o.Facility
               ,  @c_Storerkey = o.StorerKey
         FROM #PickDetail_WIP AS pw
         JOIN ORDERS o (NOLOCK) On o.OrderKey = pw.OrderKey
      END

      SET @c_Loc =''
      SELECT TOP 1 @c_Loc = l.loc
      FROM #PICKDETAIL_WIP AS pw
      JOIN LOC l (NOLOCK) ON l.loc = pw.Loc                         
      LEFT JOIN AreaDetail ad (NOLOCK) ON ad.PutawayZone = l.PutawayZone
      WHERE pw.TaskDetailKey = ''
      AND ad.AreaKey IS NULL

      IF @c_Loc > ''
      BEGIN
         SET @n_Continue = 3
         SET @n_Err      = 63020
         SET @c_ErrMsg   = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                         + 'Missing areakey for picking loc. Loc: '             
                         + @c_Loc                                           
                         + '. (mspRLWAV13_VLDN)'
      END
   END

   IF @n_Continue = 1
   BEGIN
      SELECT @c_Client = ISNULL(w.UserDefine05,'')
      FROM WAVE w (NOLOCK)
      WHERE w.Wavekey = @c_Wavekey

      IF @c_Client = 'COPP'
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
            ,   UDF01 = CASE WHEN IsNumeric(cl.UDF01) = 1 THEN cl.UDF01 ELSE '0' END
            ,   cl.UDF02 
            ,   cl.UDF03   
            ,   cl.UDF04   
            ,   cl.UDF05
            ,   cl.Code2  
         FROM CODELKUP CL (NOLOCK)  
         WHERE cl.Listname = 'COPPELPPAC'
         AND   cl.Storerkey= @c_Storerkey

         SET @c_Sku = ''
         SELECT TOP 1 
                  @c_Sku = pw.Sku
         FROM #PICKDETAIL_WIP AS pw  
         JOIN SKU s (NOLOCK) ON s.Storerkey = pw.Storerkey        
                              AND s.Sku = pw.Sku
         WHERE NOT EXISTS (SELECT 1 
                           FROM @t_CL cl  
                           WHERE cl.ListName = 'COPPELPPAC'
                           AND   cl.Code = S.BUSR1
                           AND   cl.Storerkey= pw.Storerkey
                           AND   CONVERT(INT,cl.UDF01) > 0
                           )
         IF @c_Sku > ''  
         BEGIN    
            SET @n_Continue = 3    
            SET @n_Err = 63030    
            SET @c_ErrMsg  = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                           + 'COPPEL predefined corrugate not setup. Sku: ' 
                           + @c_Sku + ' . (mspRLWAV13_VLDN)'                                                                                                
         END   
      END
   END

   IF @n_Continue = 1
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
         ,   UDF01 = CASE WHEN IsNumeric(cl.UDF01) = 1 THEN cl.UDF01 ELSE '0' END  
         ,   UDF02 = CASE WHEN IsNumeric(cl.UDF02) = 1 THEN cl.UDF02 ELSE '0.00' END  
         ,   cl.UDF03   
         ,   cl.UDF04   
         ,   cl.UDF05   
         ,   cl.Code2  
      FROM CODELKUP CL (NOLOCK)  
      WHERE cl.Listname = 'MAX_CAPACI'
      AND   cl.Storerkey= @c_Storerkey

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
      FROM CODELKUP cl (NOLOCK)  
      WHERE cl.Listname = 'AREA_MEZZA'
      AND   cl.Storerkey= @c_Storerkey
   END

   IF @n_Continue = 1
   BEGIN
      SET @c_Sku = ''
      SELECT TOP 1 
               @c_Sku = pw.Sku
      FROM #PICKDETAIL_WIP AS pw  
      WHERE pw.UOM = '2'
      AND   NOT EXISTS (SELECT 1 
                        FROM @t_CL cl  
                        WHERE cl.ListName = 'MAX_CAPACI'
                        AND   cl.Code = 'FULL_UCC'
                        AND   cl.Storerkey= pw.Storerkey
                        AND   CONVERT(INT,cl.UDF01) > 0
                        )
      IF @c_Sku > ''  
      BEGIN    
         SET @n_Continue = 3    
         SET @n_Err = 63040    
         SET @c_ErrMsg  = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                        + 'Max UCC setup not found: ' 
                        + @c_Sku + ' . (mspRLWAV13_VLDN)'                                                                                                
      END  
   END

   IF @n_Continue = 1
   BEGIN
      SET @c_Sku = ''
      SET @n_CUBEUOM3 = 0.00
      SELECT TOP 1 
             @c_Sku = pw.Sku
            ,@n_CUBEUOM3 = p.CUBEUOM3
      FROM #PICKDETAIL_WIP AS pw  
      JOIN dbo.SKU  AS s WITH (NOLOCK) ON s.StorerKey = pw.Storerkey AND s.Sku = pw.Sku  
      JOIN dbo.Pack AS p WITH (NOLOCK) ON p.Packkey = s.Packkey  
      WHERE pw.UOM > '2'
      AND   EXISTS ( SELECT 1 
                     FROM @t_CL cl  
                     WHERE cl.ListName = 'MAX_CAPACI'
                     AND   cl.Code = 'FULL_UCC'
                     AND   cl.Storerkey= pw.Storerkey
                     AND   ((p.CUBEUOM3 > CONVERT(FLOAT,cl.UDF02)) OR p.CUBEUOM3 = 0.00)
                     )
      ORDER BY p.CUBEUOM3

      IF @c_Sku > ''    
      BEGIN   
         IF @n_CUBEUOM3 = 0.00
         BEGIN
            SET @n_Continue = 3    
            SET @n_Err = 63050    
            SET @c_ErrMsg  = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                           + 'Sku''s CubeUOM3 = 0.00. Sku: ' 
                           + @c_Sku + ' . (mspRLWAV13_VLDN)'                                                                                                
         END
         ELSE
         BEGIN
            SET @n_Continue = 3    
            SET @n_Err = 63060    
            SET @c_ErrMsg  = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                           + 'Sku''s CubeUOM3 > Max Tote CBM. Sku: ' 
                           + @c_Sku + ' . (mspRLWAV13_VLDN)' 
         END                  
      END  
   END

   IF @n_Continue = 1
   BEGIN
      SET @c_Loc = ''
      SET @c_AreaKey = ''
      SELECT TOP 1 
               @c_Loc = pw.Loc
            ,  @c_AreaKey = ad.Areakey
      FROM #PICKDETAIL_WIP AS pw  
      JOIN LOC l (NOLOCK) ON l.loc = pw.loc
      JOIN Areadetail ad (NOLOCK) ON ad.putawayzone = l.PutawayZone
      WHERE pw.UOM > '2'
      AND l.LocationType IN ('PICK','DYNPPICK')
      AND   NOT EXISTS (SELECT 1  
                        FROM @t_CL cl  
                        WHERE cl.ListName = 'AREA_MEZZA'
                        AND   cl.Code = ad.Areakey
                        AND   cl.Storerkey= pw.Storerkey
                        AND   cl.UDF02 > '' 
                       )

      IF @c_Loc > ''  
      BEGIN    
         SET @n_Continue = 3    
         SET @n_Err = 63070    
         SET @c_ErrMsg  = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                        + 'Area''s priotiry not setup. Check Areakey setup and Area_Mezza codelkup setup'
                        + '. From Loc: ' + @c_Loc 
                        + ', Areakey: ' + @c_AreaKey 
                        + ' . (mspRLWAV13_VLDN)'                                                                                                
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV13_VLDN'
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
GRANT EXECUTE ON mspRLWAV13_VLDN TO NSQL
GO
