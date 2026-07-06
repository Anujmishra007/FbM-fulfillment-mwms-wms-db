SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/**************************************************************************/    
/* Stored Procedure: mspRLWAV13_ePack                                     */    
/* Creation Date: 2026-06-22                                              */    
/* Copyright: Maersk                                                      */    
/* Written by: Wan                                                        */    
/*                                                                        */    
/* Purpose: FCR-12980 - AEOMX Release Wave                                */  
/*                                                                        */  
/* Called By: Wave Release                                                */    
/*          :                                                             */    
/* PVCS Version: 1.0                                                      */    
/*                                                                        */    
/* Data Modifications:                                                    */    
/*                                                                        */    
/* Updates:                                                               */    
/* Date        Author   Ver   Purposes                                    */ 
/**************************************************************************/   
 
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV13_ePack]        
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
         , @n_RowCount           INT   = 0

         , @c_SourceType         NVARCHAR(30)= 'mspRLWAV13'
         , @c_UserName           NVARCHAR(128) = ''    

         , @c_Loadkey            NVARCHAR(10)= ''
         , @c_Orderkey           NVARCHAR(10)= ''

         , @c_PickSlipNo         NVARCHAR(10)= ''
         , @c_CartonGroup        NVARCHAR(10)= 'AEO_ECOMM'
         , @c_CartonType         NVARCHAR(10)= ''
         , @c_LabelNo            NVARCHAR(10)= ''
         , @n_CartonNo           INT

         , @n_CBMTotal           FLOAT       = 0.00
         , @n_StdGrossWgt        FLOAT       = 0.00
         , @n_CartonCube         FLOAT       = 0.00
         , @n_CartonLength       FLOAT       = 0.00
         , @n_CartonWidth        FLOAT       = 0.00
         , @n_CartonHeight       FLOAT       = 0.00

         , @c_SQL                NVARCHAR(MAX) = ''
         , @c_SQLParms           NVARCHAR(2000)= ''                                   
  
         , @cur_eCom              CURSOR

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
      SET @cur_eCom = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT pw.Orderkey
         ,   TotalCBM = SUM(p.CubeUOM3)
      FROM #PICKDETAIL_WIP AS pw
      JOIN SKU s (NOLOCK) ON s.Storerkey = pw.Storerkey
                          AND s.Sku = pw.Sku
      JOIN Pack p (NOLOCK) ON p.Packkey = s.Packkey
      GROUP BY pw.Orderkey

      OPEN @cur_eCom

      FETCH NEXT FROM @cur_eCom INTO @c_Orderkey
                                    ,@n_CBMTotal

      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1
      BEGIN
         SET @c_CartonType = ''
         SELECT TOP 1 
                   @c_CartonType  = cz.CartonType
                  ,@n_CartonCube  = cz.[Cube]                   
                  ,@n_CartonLength= cz.CartonLength
                  ,@n_CartonWidth = cz.CartonWidth
                  ,@n_CartonHeight= cz.CartonHeight
         FROM Cartonization AS cz
         WHERE cz.cartonizationGroup = @c_CartonGroup
         AND   cz.[Cube] >= @n_CBMTotal
         ORDER BY cz.[Cube] 
 
         IF @c_CartonType = ''
         BEGIN
            SET @n_Continue = 3  
            SET @n_Err = 65010 
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                           +': Carton Type Not found. (mspRLWAV13_ePack)' 
         END

         IF @n_Continue = 1
         BEGIN
            EXEC [dbo].[isp_CreatePickSlip]     
               @c_Orderkey              = @c_Orderkey        
            ,  @c_Loadkey               = ''   --Create discrete or conso load determine by @c_ConsolidateByLoad setting  
            ,  @c_Wavekey               = @c_Wavekey  --Create discrete or conso load of the wave determine by @c_ConsolidateByLoad setting     
            ,  @c_PickslipType          = '3'   --Discrete('8', '3', 'D')  Conso('5','6','7','9','C')  Xdock ('XD','LB','LP')  
            ,  @c_ConsolidateByLoad     = 'N'   --Y=Create load consolidate pickslip  N=create discrete pickslip  
            ,  @c_Refkeylookup          = 'N'   --Y=Create refkeylookup records  N=Not create  
            ,  @c_LinkPickSlipToPick    = 'Y'   --Y=Update pickslipno to pickdetail.pickslipno  N=Not update to pickdetail  
            ,  @c_AutoScanIn            = 'N'   --Y=Auto scan in the pickslip N=Not auto scan in                                              
            ,  @b_Success               = @b_Success  OUTPUT  
            ,  @n_Err                   = @n_Err      OUTPUT   
            ,  @c_ErrMsg                = @c_ErrMsg   OUTPUT
            ,  @c_PickSlipWithWavekey   = 'Y'   --Y=Create Wavekey to PickHeader if not blank    

            IF @b_Success = 0
            BEGIN
               SET @n_Continue = 3
            END
         END
         
         IF @n_Continue = 1
         BEGIN
            SELECT @c_PickSlipNo = ph.PickHeaderKey
            FROM PICKHEADER ph (NOLOCK)
            WHERE ph.Orderkey = @c_Orderkey
            
            IF NOT EXISTS (SELECT 1 FROM PACKHEADER ph (NOLOCK)
                           WHERE ph.PickSlipNo = @c_PickSlipNo
                           )
            BEGIN 
               INSERT INTO PACKHEADER (PickSlipNo, Storerkey, Orderkey, Loadkey
                                      ,Consigneekey, [Route], OrderRefNo 
                                      )  
               SELECT PickSlipNo = @c_Pickslipno 
                     ,o.Storerkey
                     ,o.Orderkey
                     ,o.Loadkey
                     ,o.Consigneekey
                     ,o.[Route]
                     ,o.ExternOrderkey
               FROM ORDERS o (NOLOCK)
               WHERE o.Orderkey = @c_Orderkey

               SET @n_err = @@ERROR  
               IF @n_err <> 0  
               BEGIN
                  SET @n_Continue = 3  
                  SET @n_Err = 65020 
                  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                                 +': Insert PACKHEADER Failed. (mspRLWAV13_ePack)' 
               END    
            END
         END

         IF @n_Continue = 1
         BEGIN
            EXEC isp_GenUCCLabelNo_Std    
               @cPickslipNo   = @c_PickSlipNo  
            ,  @nCartonNo     = 0  
            ,  @cLabelNo      = @c_LabelNo   OUTPUT  
            ,  @b_success     = @b_success   OUTPUT  
            ,  @n_err         = @n_err       OUTPUT  
            ,  @c_errmsg      = @c_errmsg    OUTPUT  
  
            IF @b_Success <> 1  
            BEGIN  
               SET @n_Continue = 3  
               SET @n_err = 65030   
               SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Executing isp_GenUCCLabelNo_Std. (mspRLWAV13_ePack)'   
            END
         END

         SET @n_RowCount = 0
         IF @n_Continue = 1 AND @c_LabelNo > ''
         BEGIN
            SET @n_CartonNo = 0
            SELECT TOP 1 @n_CartonNo = pd.CartonNo 
            FROM dbo.PackDetail pd (NOLOCK)
            WHERE pd.PickSlipNo = @c_PickSlipNo
            ORDER BY pd.CartonNo DESC

            SET @n_CartonNo = @n_CartonNo + 1

            INSERT INTO dbo.PackDetail
                        (  PickSlipNo
                        ,  CartonNo
                        ,  LabelNo
                        ,  LabelLine
                        ,  Storerkey
                        ,  Sku
                        ,  Qty
                        )
            SELECT @c_PickSlipNo
                  ,CartonNo = @n_CartonNo
                  ,LabelNo  = @c_LabelNo
                  ,LabelLine = RIGHT('00000' + CONVERT(NVARCHAR(5), ROW_NUMBER() 
                                 OVER (ORDER BY pw.Storerkey, pw.Sku)),5)
                  ,pw.Storerkey
                  ,pw.Sku
                  ,Qty = ISNULL(SUM(pw.Qty),0)
            FROM #PICKDETAIL_WIP AS pw
            WHERE pw.Orderkey = @c_Orderkey
            GROUP BY pw.Storerkey
                  ,  pw.Sku

            SET @n_RowCount = @@ROWCOUNT
            SET @n_err = @@ERROR  
            IF @n_err <> 0  
            BEGIN
               SET @n_continue = 3  
               SET @n_Err = 65040 
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                              +': Insert PACKDETAIL Failed. (mspRLWAV13_ePack)' 
            END 
         END

         IF @n_Continue = 1 AND @n_RowCount > 0
         BEGIN      
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
               )
            SELECT PickSlipNo = @c_PickSlipNo
                  ,CartonNo   = @n_CartonNo
                  ,[Weight]   = ISNULL(SUM(s.StdGrossWgt * pw.Qty),0.00)
                  ,[Cube]     = @n_CartonCube                                    
                  ,Qty        = ISNULL(SUM(pw.Qty),0)
                  ,CartonType = @c_CartonType
                  ,[Length]   = @n_CartonLength
                  ,[Width]    = @n_CartonWidth
                  ,[Height]   = @n_CartonHeight
            FROM #PICKDETAIL_WIP AS pw
            JOIN SKU s (NOLOCK) ON  s.Storerkey = pw.Storerkey
                                AND s.Sku = pw.Sku
            WHERE pw.Orderkey = @c_Orderkey
 
            SET @n_err = @@ERROR  
            IF @n_err <> 0  
            BEGIN
               SET @n_continue = 3  
               SET @n_Err = 65050 
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)
                              +': Insert PACKINFO Failed. (mspRLWAV13_ePack)' 
            END 
         END

         IF @n_Continue = 1
         BEGIN
            UPDATE pw
               SET pw.DoCartonize= 'Y'
                  ,pw.CartonType = @c_CartonType
                  ,pw.CaseID     = @c_LabelNo
                  ,pw.EditWho    = @c_UserName 
                  ,pw.EditDate   = GetDate()
            FROM #PICKDETAIL_WIP AS pw
            WHERE pw.Orderkey = @c_Orderkey
         END
 
         FETCH NEXT FROM @cur_eCom INTO @c_Orderkey
                                       ,@n_CBMTotal
      END
      CLOSE @cur_eCom
      DEALLOCATE @cur_eCom
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV13_ePack'
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
GRANT EXECUTE ON mspRLWAV13_ePack TO NSQL
GO
