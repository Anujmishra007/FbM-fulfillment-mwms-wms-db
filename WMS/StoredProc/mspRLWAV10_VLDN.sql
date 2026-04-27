SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/    
/* Stored Procedure: mspRLWAV10_VLDN                                     */    
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
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV10_VLDN]       
   @c_Wavekey     NVARCHAR(10)
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

         , @c_SourceType         NVARCHAR(30)   = 'mspRLWAV10'
         , @c_Facility           NVARCHAR(5)    = ''
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_Userdefine01       NVARCHAR(20)   = ''
         , @c_MBOLKey            NVARCHAR(10)   = ''  
         , @c_DocType            NVARCHAR(10)   = '' 
         , @c_Orderkey           NVARCHAR(10)   = '' 
         , @c_OrderLineNumber    NVARCHAR(5)    = '' 
         , @c_Sku                NVARCHAR(20)   = ''
         , @c_Loc                NVARCHAR(10)   = ''

         , @c_SQL                NVARCHAR(4000) = ''
         , @c_SQLParms           NVARCHAR(4000) = ''
         , @c_Option5            NVARCHAR(MAX) = ''
         , @c_PackECOM           NVARCHAR(10)   = 'N'
         , @c_CartonGroup_B2C    NVARCHAR(10)   = ''
         , @n_MaxCube_B2C        FLOAT          = 0.00
         , @c_ECOMPackingByTote  NVARCHAR(10)   = 'Y'

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
      ,  [PackGroupH]      [int]          NOT NULL DEFAULT (0)
      ,  [PackGroupS]      [int]          NOT NULL DEFAULT (0)
      )
      CREATE INDEX IDX_CNZ ON #PickDetail_WIP (PackGroupH, PackGroupS)
      CREATE INDEX IDX_Case ON #PickDetail_WIP (Orderkey, CaseID, Lot, Loc, ID)

      EXEC [dbo].[mspRLWAV10_DATA]        
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
                         + 'Nothing to release. (mspRLWAV10_VLDN)'
      END
   END

   IF @n_Continue = 1
   BEGIN
      SELECT @c_Userdefine01 = w.UserDefine01
      FROM WAVE w (NOLOCK) 
      WHERE w.Wavekey = @c_Wavekey
 
      SELECT TOP 1 
               @c_Facility  = o.Facility
            ,  @c_Storerkey = o.StorerKey
      FROM #PickDetail_WIP AS pw
      JOIN ORDERS o (NOLOCK) On o.OrderKey = pw.OrderKey
      ORDER BY pickdetailkey

      SELECT @c_Option5 = ISNULL(fgr.Option5,'')
      FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'ReleaseWave_SP') AS fgr

      IF ISNULL(@c_Option5, '') <> ''
      BEGIN
         SELECT @c_PackECOM = dbo.fnc_GetParamValueFromString('@c_PackECOM', @c_Option5, @c_PackECOM)
         SELECT @c_CartonGroup_B2C = dbo.fnc_GetParamValueFromString('@c_CartonGroup_B2C', @c_Option5, @c_CartonGroup_B2C)
         SELECT @c_ECOMPackingByTote = dbo.fnc_GetParamValueFromString('@c_ECOMPackingByTote', @c_Option5, @c_ECOMPackingByTote)
      END
   END

   IF @n_Continue = 1
   BEGIN
      SET @c_Sku = ''
      SELECT TOP 1 
               @c_Sku = pw.Sku
            ,  @c_Loc = pw.loc 
            ,  @c_Orderkey = pw.OrderKey  
            ,  @c_OrderLineNumber = pw.OrderLineNumber  
      FROM #PICKDETAIL_WIP AS pw  
      JOIN dbo.SKU AS s WITH (NOLOCK) ON s.StorerKey = pw.Storerkey AND s.Sku = pw.Sku  
      WHERE s.PackQtyIndicator > 1  
      GROUP BY pw.Orderkey, pw.OrderLineNumber, pw.Storerkey, pw.Sku, pw.Loc, s.PackQtyIndicator  
      HAVING (SUM(pw.Qty) % s.PackQtyIndicator) > 0  
  
      IF @c_Sku > ''  
      BEGIN    
         SET @n_Continue = 3    
         SET @n_Err = 63030    
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                      +': Loose Bundle Found. Sku: ' + @c_Sku 
                      + ', Loc: ' + @c_Loc 
                      + ', Orderkey: ' + @c_Orderkey 
                      + ', OrderLine#: ' + @c_OrderLineNumber                     
                      +'. (mspRLWAV10_VLDN)'                                                                                                    
         GOTO QUIT_SP    
      END
      
      IF @n_Continue = 1 AND @c_PackECOM = 'Y' AND @c_ECOMPackingByTote = 'Y'
      BEGIN
         IF @n_Continue = 1
         AND EXISTS ( SELECT 1
                      FROM #PickDetail_WIP AS pw
                      JOIN ORDERS o WITH (NOLOCK) ON o.OrderKey = pw.OrderKey
                      WHERE pw.WaveKey = @c_Wavekey
                      AND o.Doctype = 'E' ) 
         BEGIN
            IF @n_Continue = 1 AND ISNULL(@c_CartonGroup_B2C, '') = ''
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 63040
               SET @c_ErrMsg  = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                              + 'Cartonization Group for B2C not set up in Storerconfig. ' 
                              + 'Wave#: ' + @c_Wavekey + ' . (mspRLWAV10_VLDN)'
            END

            IF @n_Continue = 1
            AND NOT EXISTS ( SELECT 1
                             FROM dbo.CARTONIZATION (NOLOCK)
                             WHERE CartonizationGroup = @c_CartonGroup_B2C )
            BEGIN
               SET @n_Continue = 3
               SET @n_Err = 63045
               SET @c_ErrMsg  = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                              + 'Cartonization Group for B2C: ' + TRIM(@c_CartonGroup_B2C) + ' is not valid. ' 
                              + 'Wave#: ' + @c_Wavekey + ' . (mspRLWAV10_VLDN)'
            END

            IF @n_Continue = 1
            BEGIN
               SELECT TOP 1 @n_MaxCube_B2C = cz.[Cube]
               FROM dbo.CARTONIZATION cz WITH (NOLOCK)
               WHERE cz.CartonizationGroup = @c_CartonGroup_B2C
               ORDER BY cz.[Cube] DESC

               IF @n_MaxCube_B2C <= 0.00
               BEGIN
                  SET @n_Continue = 3  
                  SET @n_err = 63046  
                  SET @c_errmsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                                + 'Max Cube for B2C Carton Group: ' + TRIM(@c_CartonGroup_B2C) + ' is 0. ' 
                                + 'Wave#: ' + @c_Wavekey + ' . (mspRLWAV10_VLDN)' 
               END
            END

            --IF @n_Continue = 1
            --BEGIN
            --   SET @c_Sku = ''
            --   SELECT TOP 1 @c_Sku = pw.Sku
            --   FROM #PICKDETAIL_WIP AS pw  
            --   JOIN dbo.SKU AS s WITH (NOLOCK) ON s.StorerKey = pw.Storerkey AND s.Sku = pw.Sku  
            --   JOIN dbo.PACK AS p WITH (NOLOCK) ON p.Packkey = s.Packkey
            --   WHERE @n_MaxCube_B2C < CASE WHEN ISNULL(p.CubeUOM3, 0.00) = 0.00 THEN s.StdCube ELSE p.CubeUOM3 END
            --   AND pw.UOM >= '6'
            
            --   IF @c_Sku > ''
            --   BEGIN
            --      SET @n_Continue = 3  
            --      SET @n_err = 63047  
            --      SET @c_errmsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
            --                    + 'Sku: ' + TRIM(@c_Sku) + '''s cube > Tote''s cube. ' 
            --                    + 'Wave#: ' + @c_Wavekey + ' . (mspRLWAV10_VLDN)' 
            --   END
            --END
         END
      END
   END

   IF @n_Continue = 1
   BEGIN
      IF @c_Userdefine01 <> 'WaveReplenRelease'
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 63050
         SET @c_ErrMsg  = 'NSQL' + CONVERT(NCHAR(5),@n_Err) + ': '
                        + 'Replenishment task has not been released for Wave#: ' 
                        + @c_Wavekey + ' . (mspRLWAV10_VLDN)'
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV10_VLDN'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
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
GRANT EXECUTE ON [dbo].[mspRLWAV10_VLDN] TO [NSQL]
GO