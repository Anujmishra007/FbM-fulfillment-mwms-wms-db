IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetPickSlipWave26_1]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetPickSlipWave26_1]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_GetPickSlipWave26_1                                 */
/* Creation Date: 07-SEP-2020                                           */
/* Copyright: LF Logistics                                              */
/* Written by: CSCHONG                                                  */
/*                                                                      */
/* Purpose: WMS-14891 - KR_ADIDAS_Picking Slip Report Data Window_NEW   */
/*        :                                                             */
/* Called By: R_dw_print_wave_pickslip_26_1                             */
/*          :                                                           */
/* PVCS Version: 1.6                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */   
/************************************************************************/
CREATE PROC isp_GetPickSlipWave26_1
            @c_Wavekey        NVARCHAR(10)
         ,  @c_PickSlipNo     NVARCHAR(10)
         ,  @c_Zone           NVARCHAR(10)
         ,  @c_PrintedFlag    NCHAR(1)
         ,  @n_NoOfSku        INT
         ,  @n_NoOfPickLines  INT
         ,  @c_ordselectkey NVARCHAR(20)
         ,  @c_colorcode    NVARCHAR(20)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT

         , @n_WaveSeqOfDay    INT
         , @dt_Adddate        DATETIME
         , @d_Adddate         DATETIME

         , @c_Storerkey       NVARCHAR(15)                                     
         , @c_ordermode       NVARCHAR(30)                                     
         , @n_TTLSeq          INT                                               

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1

  
   SELECT TOP 1 @dt_Adddate = CASE WHEN ISNULL(TD.AddDate,'')  <>'1900-01-01 00:00:00.000' 
                               THEN MIN(TD.AddDate) ELSE WH.EditDate END  
         ,@c_Storerkey= OH.Storerkey                                           
   FROM WAVE WH  WITH (NOLOCK)
   JOIN WAVEDETAIL WD WITH (NOLOCK) ON (WH.Wavekey = WD.Wavekey)               
   JOIN ORDERS     OH WITH (NOLOCK) ON (WD.Orderkey= OH.Orderkey)              
   LEFT JOIN Taskdetail TD WITH (NOLOCK) ON TD.wavekey=WH.wavekey              
   WHERE WH.Wavekey = @c_Wavekey
   GROUP BY OH.Storerkey,TD.AddDate ,WH.EditDate
   

   SET @d_Adddate = CONVERT (DATETIME, CONVERT(NVARCHAR(10), @dt_Adddate, 112))
 
   IF OBJECT_ID('tempdb..#TMP_WAVORD','u') IS NOT NULL  
   BEGIN  
      DROP TABLE #TMP_WAVORD;  
   END       
  
   CREATE TABLE #TMP_WAVORD    
      (  Wavekey  NVARCHAR(10) NOT NULL   DEFAULT ('')    
      ,  Orderkey NVARCHAR(10) NOT NULL   DEFAULT ('')      
      ,  OpenQty  INT          NOT NULL   DEFAULT (0)    
      ,  EditDate DATETIME     NULL           
      )      
    
   INSERT INTO #TMP_WAVORD    
      (  Wavekey    
      ,  Orderkey    
      ,  OpenQty    
      ,  EditDate    
      )    
   SELECT WH.Wavekey    
         ,OD.Orderkey     
         ,OpenQty= ISNULL(SUM(OD.OpenQty),0)      
         ,WH.EditDate      
   FROM WAVE        WH WITH (NOLOCK)      
   JOIN WAVEDETAIL  WD WITH (NOLOCK) ON WD.WaveKey  = WH.WaveKey     
   JOIN ORDERDETAIL OD WITH (NOLOCK) ON WD.Orderkey = OD.Orderkey    
   WHERE WH.AddDate BETWEEN @d_Adddate AND DATEADD(d, 1, @d_Adddate)      
   AND OD.Storerkey = @c_Storerkey    
   GROUP BY WH.Wavekey, WH.EditDate, OD.Orderkey    
   ORDER BY WH.Wavekey, OD.Orderkey    
    
   SELECT MaxOrderQty= CASE WHEN MAX(WH.OpenQty) = 1 THEN 'Single' ELSE 'Multi' END      
         ,WH.Wavekey      
         ,ReleaseDate =CASE WHEN ISNULL(TD.AddDate,'')  <>'1900-01-01 00:00:00.000'       
                            THEN MIN(TD.AddDate) ELSE WH.EditDate END      
   INTO #TMP_Wave      
   FROM #TMP_WAVORD WH    
   LEFT JOIN Taskdetail TD WITH (NOLOCK) ON TD.wavekey=WH.wavekey                    
   GROUP BY WH.Wavekey,TD.AddDate ,WH.EditDate      
      
     SELECT WaveSeqOfDay  = ROW_NUMBER() OVER (PARTITION BY  WH.MaxOrderQty ORDER BY WH.Wavekey)
          ,ordermode = WH.MaxOrderQty                                     
          ,Wavekey = WH.wavekey
          ,DateRelease = WH.ReleaseDate
   INTO   #TMP_WaveSeq     
   FROM #TMP_Wave WH   
 
  --select * from #TMP_WaveSeq                                               
   
   SET @n_WaveSeqOfDay = 0
   SET @c_ordermode = ''
   
   SELECT @n_WaveSeqOfDay  = WH.WaveSeqOfDay
          ,@c_ordermode = WH.ordermode                                     
   FROM #TMP_WaveSeq WH   
   WHERE Wavekey = @c_Wavekey
     
   SET @n_TTLSeq = 1

      SELECT @n_TTLSeq = COUNT(1)
      FROM #TMP_WaveSeq
      WHERE DateRelease <= @dt_Adddate

                             
   SELECT PH.Wavekey
         ,AddDate = @dt_Adddate
         ,@c_ordermode AS ordermode                                             
         ,WaveSeqOfDay = CONVERT( NVARCHAR(10), @n_WaveSeqOfDay )
         ,PH.PickHeaderkey
         ,LOC.PutawayZone                                       
         ,@c_Printedflag  
         ,PD.Storerkey
         ,PD.Loc
         ,PD.ID
         ,Style   = SKU.Style 
         ,Color   = SKU.color
         ,Size    = SKU.Size
         ,SkuDescr= ISNULL(MIN(SKU.Descr),0)
         ,AltSku  = ISNULL(RTRIM(SKU.manufacturersku), '')
        -- ,SKU.SkuGroup
         , ISNULL(C.long,'')
         ,Qty    = ISNULL(SUM(PD.Qty),0)
         ,NoOfSku= @n_NoOfSku 
         ,NoOfPickLines= @n_NoOfPickLines 
         ,TTLSeq  = @n_TTLSeq                                           
         ,logicalloc = loc.logicallocation                             
         ,OrdSelectkey = @c_ordselectkey       
         ,Colorcode = @c_colorcode          
   FROM PICKDETAIL PD   WITH (NOLOCK) 
   JOIN LOC        LOC  WITH (NOLOCK) ON (PD.Loc = LOC.Loc)    
   JOIN SKU        SKU  WITH (NOLOCK) ON (PD.Storerkey = SKU.Storerkey)
                                      AND(PD.Sku = SKU.Sku)
   JOIN REFKEYLOOKUP RL WITH (NOLOCK) ON (PD.PickDetailKey = RL.PickDetailkey)
   JOIN (SELECT OD.Orderkey, Openqty = SUM(OD.OpenQty) FROM ORDERS OH WITH (NOLOCK)
         JOIN ORDERDETAIL OD WITH (NOLOCK) ON (OH.Orderkey = OD.Orderkey) 
         WHERE OH.UserDefine09 = @c_Wavekey
         GROUP BY OD.Orderkey) ODSUM ON (ODSUM.Orderkey = PD.Orderkey)
   JOIN PICKHEADER PH WITH (NOLOCK) ON (RL.PickSlipNo = PH.PickHeaderkey)
   LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.LISTNAME = 'ADSKUDIV' AND C.Storerkey=sku.StorerKey AND C.code=SKU.SKUGROUP
   WHERE PH.PickHeaderKey = @c_PickSlipNo
   AND   LOC.PutawayZone = @c_Zone                              
   AND   PD.Status < '5'
   GROUP BY PH.Wavekey
         ,  PH.PickHeaderkey
         ,  LOC.PutawayZone                                     
         ,  PD.Storerkey
         ,  PD.Loc
         ,  PD.ID
         ,  SKU.Style 
         ,  SKU.color
         ,  SKU.Size
         ,  ISNULL(RTRIM(SKU.manufacturersku), '')
         --,  SKU.SkuGroup
         , ISNULL(C.long,'')
         ,loc.logicallocation                                  --(CS02)
   ORDER BY ISNULL(RTRIM(PH.PickHeaderkey), '') 
         ,  LOC.PutawayZone                                       
         ,  loc.logicallocation                                --(CS02)
         ,  PD.Loc
         ,  Style
         ,  Color
         ,  Size

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetPickSlipWave26_1] TO nSQL 
GO
