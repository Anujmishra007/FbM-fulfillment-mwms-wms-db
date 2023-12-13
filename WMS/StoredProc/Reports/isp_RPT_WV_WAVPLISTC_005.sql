           
/***************************************************************************/              
/* Stored Procedure: isp_RPT_WV_WAVPLISTC_005                              */              
/* Creation Date: 23-NOV-2022                                              */              
/* Copyright: LFL                                                          */              
/* Written by: CHONGCS                                                     */              
/*                                                                         */              
/* Purpose: WMS-21138 JP BirkenStock BSJ Wave Picking List                 */              
/*                                                                         */              
/* Called By: RPT_WV_WAVPLISTC_005                                         */              
/*                                                                         */              
/* GitLab Version: 1.0                                                     */              
/*                                                                         */              
/* Version: 1.0                                                            */              
/*                                                                         */              
/* Data Modifications:                                                     */              
/*                                                                         */              
/* Updates:                                                                */              
/* Date         Author  Ver   Purposes                                     */          
/* 23-NOV-2022  CHONGCS 1.0   DevOps Combine Script                        */          
/***************************************************************************/             
            
CREATE OR ALTER   PROC [dbo].[isp_RPT_WV_WAVPLISTC_005] (            
   @c_Wavekey           NVARCHAR(13) ,          
   @c_PreGenRptData     NVARCHAR(10) = ''          
)            
AS            
            
BEGIN            
   SET NOCOUNT ON               
   SET QUOTED_IDENTIFIER OFF               
   SET ANSI_NULLS OFF               
   SET CONCAT_NULL_YIELDS_NULL OFF              
             
   DECLARE @n_StartTCnt       INT            
         , @n_Continue        INT                       
         , @b_Success         INT            
         , @n_Err             INT            
         , @c_Errmsg          NVARCHAR(255)            
                     
          
DECLARE @c_loadkey         NVARCHAR(20)          
       ,@c_prevloadkey     NVARCHAR(20)          
       ,@c_PIPickslipno    NVARCHAR(20)          
       ,@c_prevPIPickslipno NVARCHAR(20)          
       ,@c_GetPIPickslipno NVARCHAR(20)          
       ,@c_PickSlipNo      NVARCHAR(10)            
       ,@c_PAPickslipno    NVARCHAR(20)          
       ,@c_GetPAPickslipno NVARCHAR(20)          
       ,@c_UPPAPickslipno  NVARCHAR(20)          
       ,@n_pqty            INT          
       ,@n_ODqty           INT           
       ,@n_ttlODqty        INT =0          
       ,@n_Xpickqty        INT =0          
       ,@n_YpickQty        INT          
       ,@c_ExtOrdkey       NVARCHAR(50)          
       ,@c_preorderkey     NVARCHAR(20) = ''          
       ,@c_preExtOrdkey    NVARCHAR(50) = ''          
       ,@c_mergeorderkey   NVARCHAR(500)          
       ,@c_mergeExtOrdkey  NVARCHAR(500)          
       ,@c_delimiter       NVARCHAR(1)          
       ,@n_rowctn          INT = 1          
       ,@n_Pickslipnoctn   INT = 1          
       ,@c_taskno          NVARCHAR(2)          
       ,@n_ctnrec          INT = 0          
       ,@c_newpickslip     NVARCHAR(1) = 'N'          
       ,@c_odlineno        NVARCHAR(10)          
       ,@n_psgrp           INT = 1          
       ,@n_prevpsgrp       INT = 1          
       ,@n_ctnremaning     INT = 1          
       ,@c_lastrec         NVARCHAR(1) ='N'          
          
             
   DECLARE @c_PickHeaderkey   NVARCHAR(10)             
         , @c_Storerkey       NVARCHAR(15)             
         , @c_Orderkey        NVARCHAR(10)            
         , @c_getOrderkey     NVARCHAR(10)           
         , @c_ExternOrderkey  NVARCHAR(50)               
            
         , @c_BuyerPO         NVARCHAR(20)            
         , @c_OrderGroup      NVARCHAR(20)            
         , @c_Sectionkey      NVARCHAR(10)            
         , @c_DeliveryDate    NVARCHAR(10)            
         , @c_Consigneekey    NVARCHAR(15)            
         , @c_C_Company       NVARCHAR(45)            
                                       
            
         , @n_TotalCBM        FLOAT               
         , @n_TotalGrossWgt   FLOAT            
         , @n_noOfTotes       INT            
            
         , @n_Qty                INT            
         , @c_UserDefine02       NVARCHAR(18)           
         , @n_NoOfLine           INT          
         , @c_GetStorerkey       NVARCHAR(15)            
         , @c_pickZone           NVARCHAR(10)          
         , @c_PZone              NVARCHAR(10)          
         , @n_MaxRow             INT          
         , @n_RowNo              INT          
         , @n_CntRowNo           INT          
         , @c_OrdKey             NVARCHAR(20)          
         , @c_OrdLineNo          NVARCHAR(5)          
         , @c_GetWavekey         NVARCHAR(10)          
         , @c_PrevGetWavekey     NVARCHAR(10)          
         , @c_GetPickSlipNo      NVARCHAR(10)              
         , @c_GetPickZone        NVARCHAR(10)          
         , @c_GetOrdKey          NVARCHAR(20)          
         , @c_GetLoadkey         NVARCHAR(10)          
         , @c_PickDetailKey      NVARCHAR(18)           
         , @c_GetPickDetailKey   NVARCHAR(18)           
         , @c_ExecStatement      NVARCHAR(4000)          
         , @c_GetPHOrdKey        NVARCHAR(20)          
         , @c_GetWDOrdKey        NVARCHAR(20)          
         , @n_TTLPQty            INT           
         , @c_gettaskno          NVARCHAR(5)          
         , @n_ctnsku             INT          
         , @n_TTLLPQTY           INT          
         , @n_TTLLODQTY          INT            
            
   SET @n_StartTCnt  =  @@TRANCOUNT            
   SET @n_Continue   =  1            
            
   SET @c_PickHeaderkey = ''            
   SET @c_Storerkey     = ''             
   SET @c_Orderkey      = ''            
   SET @c_ExternOrderkey= ''            
            
   SET @c_BuyerPO       = ''            
   SET @c_Consigneekey  = ''            
   SET @c_C_Company     = ''                 
                                 
             
   SET @c_PZone         = ''          
            
            
   SET @n_Qty           = 0            
   SET @c_UserDefine02  = ''            
   SET @n_NoOfLine      =  1          
   SET @c_GetStorerkey  = ''          
   SET @n_CntRowNo      = 1          
          
          
   SET  @c_delimiter = ','          
   --SET @n_MaxRow =  1          
            
   WHILE @@TranCount > 0              
   BEGIN              
      COMMIT TRAN              
   END              
          
CREATE TABLE #TMPWAVPLISTC005H          
(  rowno            INT NOT NULL IDENTITY(1,1) PRIMARY KEY,          
   Pickdetailkey    NVARCHAR(20),          
   PIPickslipno     NVARCHAR(20),          
   PAPickslipno     NVARCHAR(20),          
   Pickslipno       NVARCHAR(20),          
   Wavekey          NVARCHAR(20),          
   loadkey          NVARCHAR(20),          
   sku              NVARCHAR(20),          
   pqty             INT,          
   odqty            INT,          
   Recgrp           INT,          
   psgrp            INT           
)          
          
CREATE TABLE #TMPWAVPLISTC005          
(  rowno            INT NOT NULL IDENTITY(1,1) PRIMARY KEY,          
   PIPickslipno     NVARCHAR(20),          
   PAPickslipno     NVARCHAR(20),          
   Wavekey          NVARCHAR(20),          
   loadkey          NVARCHAR(20),          
   Orderkey         NVARCHAR(500),          
   ExtOrdkey      NVARCHAR(500),          
   ctnsku           NVARCHAR(20),          
   qty            INT,          
   ttlpqty          INT,          
   ttlodqty         INT,          
   taskno           NVARCHAR(5)          
          
)          
          
            SELECT @c_storerkey = oh.storerkey          
            FROM orders oh WITH (NOLOCK)          
            WHERE oh.userdefine09 = @c_wavekey          
            
                         
   WHILE @@TRANCOUNT > 0            
   BEGIN            
      COMMIT TRAN            
   END          
               
   SET @c_OrderKey = ''            
   SET @c_Pickzone = ''          
   SET @c_PickDetailKey = ''            
   SET @n_continue = 1           
   SET @c_prevloadkey =''          
   SET @n_ctnsku = 0          
   SET @c_prevPIPickslipno = ''          
   SET @c_PrevGetWavekey = ''          
          
          
INSERT INTO #TMPWAVPLISTC005H          
(          
    Pickdetailkey,          
    PIPickslipno,          
    PAPickslipno,          
    Pickslipno,          
    Wavekey,          
    loadkey,          
    sku,          
    pqty,          
    odqty,          
    Recgrp,          
    psgrp          
)          
 SELECT PD.PICKDETAILKEY,ISNULL(PW.PickHeaderKey,'') AS PIPICKSLIPNO,ISNULL(PL.PickHeaderKey,'') AS PAPICKSLIPNO,pd.PICKSLIPNO AS PICKSLIPNO,o.UserDefine09 AS wavekey,o.LoadKey,--O.ORDERKEY,          
                   pd.sku,pd.QTY,od.OriginalQty,1,1          
                     FROM ORDERS O (NOLOCK)          
                     JOIN orderdetail od WITH (NOLOCK) ON od.OrderKey=o.orderkey          
                     JOIN PICKDETAIL PD WITH (NOLOCK) ON (Od.ORDERKEY=PD.ORDERKEY AND od.OrderLineNumber = pd.OrderLineNumber AND od.Sku=pd.Sku AND od.StorerKey = pd.Storerkey)          
                     LEFT JOIN dbo.PickHeader PL WITH (NOLOCK) ON PL.LoadKey=o.LoadKey          
                     LEFT JOIN dbo.PICKHEADER PW WITH (NOLOCK) ON PW.WaveKey=O.UserDefine09 --AND PW.StorerKey=O.StorerKey          
                     WHERE O.USERDEFINE09 =@c_wavekey AND ISNULL(O.LoadKey,'') <> ''          
                     ORDER BY PD.PICKDETAILKEY          
          
 --SELECT DISTINCT Wavekey,loadkey,PIPickslipno,PAPickslipno,Pickslipno          
 --   FROM #TMPWAVPLISTC005H          
           
DECLARE CUR_WAVELOAD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
    SELECT DISTINCT Wavekey,loadkey,PIPickslipno,PAPickslipno,Pickslipno          
    FROM #TMPWAVPLISTC005H          
    WHERE Wavekey=@c_wavekey          
    ORDER BY Wavekey,loadkey          
          
 OPEN CUR_WAVELOAD          
          
      FETCH NEXT FROM CUR_WAVELOAD INTO @c_Getwavekey,@c_loadkey,@c_PIPickslipno,@c_PAPickslipno,@c_PickSlipNo          
      WHILE @@FETCH_STATUS = 0          
      BEGIN          
                       
                     SET @n_ttlpqty = 0          
                     SET @n_ttlODqty = 0          
                     SET @n_ttllpqty = 0          
                     SET @n_ttllODqty = 0          
                     SET @n_rowctn = 1          
                     SET @c_preorderkey     = ''          
                     SET @c_preExtOrdkey    = ''          
                     SET @n_psgrp   = 1          

                      IF ISNULL(@c_PIPickslipno,'') = ''  OR ISNULL(@c_PAPickslipno,'') =''
                      BEGIN
                           IF ISNULL(@c_PreGenRptData,'')  = ''
                           BEGIN
                                 SET @c_PreGenRptData = 'Y'
                           END
                      END
                          
                --     SELECT @c_GetWavekey '@c_GetWavekey', @c_loadkey '@c_loadkey', @c_PIPickslipno '@c_PIPickslipno'          
          
                     IF @c_PrevGetWavekey <> @c_GetWavekey          
                     BEGIN           
                     IF NOT EXISTS (SELECT 1 FROM PICKHEADER (NOLOCK)           
                                     WHERE wavekey      = @c_GetWavekey) AND (ISNULL(@c_PIPickslipno,'') = '')--  AND ISNULL(@c_PickSlipNo,'') ='')          
                                     AND @c_PreGenRptData = 'Y'           
                     BEGIN           
                                             
                                  EXECUTE nspg_GetKey                 
                                       'PICKSLIP'         
                                    ,  9              
                                    ,   @c_PIPickslipno OUTPUT              
                                    ,  @b_Success    OUTPUT              
                                    ,  @n_err        OUTPUT              
                                    ,  @c_errmsg     OUTPUT                    
                                       
                              SET  @c_PIPickslipno = 'P' +  @c_PIPickslipno                
          
                        END     
                   END          
                   ELSE          
                   BEGIN          
                       IF ISNULL(@c_PIPickslipno,'') = ''           
                       BEGIN          
                             SELECT TOP 1 @c_PIPickslipno= PIPickslipno          
                             FROM #TMPWAVPLISTC005H          
                             WHERE Wavekey=@c_GetWavekey          
                       END            
          
                    
                   END            
                       IF @c_prevloadkey <> @c_loadkey          
              BEGIN              
                           IF NOT EXISTS (SELECT 1 FROM PICKHEADER (NOLOCK)           
                                     WHERE loadkey      = @c_loadkey) AND ISNULL(@c_PAPickslipno,'') = ''           
                                     AND @c_PreGenRptData = 'Y'           
                            BEGIN           
                                             
                                  EXECUTE nspg_GetKey                 
                                       'PICKSLIP'              
                                    ,  9              
                                    ,  @c_PAPickslipno OUTPUT              
                                    ,  @b_Success    OUTPUT              
                                    ,  @n_err        OUTPUT              
                                    ,  @c_errmsg     OUTPUT                    
                                       
                              SET  @c_PAPickslipno = 'D' +  @c_PAPickslipno                
          
                            END            
                       END          
                           SELECT @n_ttlpqty =  SUM(pqty)          
                           FROM #TMPWAVPLISTC005H          
                           WHERE wavekey = @c_GetWavekey           
          
                           SELECT @n_ttlODqty =  SUM(odqty)          
                           FROM #TMPWAVPLISTC005H          
                           WHERE wavekey = @c_GetWavekey            
          
                           SELECT @n_ctnsku = COUNT(Distinct sku)     --G01      
                                 ,@n_ttllpqty =  SUM(pqty)          
                           FROM #TMPWAVPLISTC005H          
                           WHERE wavekey = @c_GetWavekey AND loadkey = @c_loadkey             
          
     SET @c_mergeExtOrdkey = (SELECT distinct RTRIM(OH.Externorderkey)+', '          
                              FROM ORDERS OH (NOLOCK)                           
                              join #TMPWAVPLISTC005H T04 on OH.LoadKey=T04.LoadKey AND OH.LoadKey=@c_loadkey FOR XML PATH(''))              
          
     SET @c_mergeorderkey = (SELECT distinct RTRIM(OH.orderkey)+', '          
                             FROM ORDERS OH (NOLOCK)                           
                             JOIN #TMPWAVPLISTC005H T04 on OH.LoadKey=T04.LoadKey AND OH.LoadKey=@c_loadkey FOR XML PATH(''))             
          
                      INSERT INTO #TMPWAVPLISTC005          
                      (          
                          PIPickslipno,          
                          PAPickslipno,          
                          Wavekey,          
                          loadkey,          
                          Orderkey,          
                          ExtOrdkey,          
                          ctnsku,          
                          qty,          
                          ttlpqty,          
                          ttlodqty,          
                          taskno          
                      )          
                      VALUES (@c_PIPickslipno,@c_PAPickslipno,@c_GetWavekey,@c_loadkey,@c_mergeorderkey,@c_mergeExtOrdkey,@n_ctnsku,@n_ttllpqty,@n_TTLPQTY,@n_TTLODQTY,'00')  --Fixed @n_ttllpqty        
      
       UPDATE #TMPWAVPLISTC005H          
       SET PIPickslipno=@c_PIPickslipno          
       WHERE Wavekey = @c_GetWavekey          
             
             
       UPDATE #TMPWAVPLISTC005H          
       SET PAPickslipno=@c_PAPickslipno           
       WHERE Wavekey = @c_GetWavekey AND loadkey = @c_loadkey          
             
                              
       SET @c_prevloadkey=@c_loadkey          
       SET @c_PrevGetWavekey = @c_GetWavekey          
          
           
      FETCH NEXT FROM CUR_WAVELOAD INTO @c_Getwavekey,@c_loadkey,@c_PIPickslipno,@c_PAPickslipno,@c_PickSlipNo          
      END          
      CLOSE CUR_WAVELOAD          
    DEALLOCATE CUR_WAVELOAD           
          
          
   IF @c_PreGenRptData = 'Y'          
   BEGIN          
             
       DECLARE CUR_INSERTPICKPACKTBL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
       SELECT DISTINCT PIPickslipno,PAPickslipno,loadkey,Wavekey--,RIGHT('00' + RTRIM(CAST(RTRIM(Row_Number() OVER (PARTITION BY loadkey ORDER BY loadkey Asc)) AS NCHAR(2))),2) AS gettaskno          
       FROM #TMPWAVPLISTC005          
       WHERE Wavekey=@c_Wavekey          
       ORDER BY PIPickslipno,PAPickslipno          
          
      OPEN CUR_INSERTPICKPACKTBL          
      FETCH NEXT FROM CUR_INSERTPICKPACKTBL INTO @c_GetPIPickslipno,@c_UPPAPickslipno,@c_loadkey,@c_GetWavekey--,@c_gettaskno          
      WHILE @@FETCH_STATUS = 0          
      BEGIN          
               
          SET @c_getOrderkey = ''          
          SELECT @c_getOrderkey = MAX(OH.orderkey)          
          FROM dbo.ORDERS OH (NOLOCK)          
          WHERE oh.LoadKey=@c_loadkey AND oh.UserDefine09 = @c_GetWavekey          
                
          IF NOT EXISTS (SELECT 1 FROM dbo.PICKHEADER PH WITH (NOLOCK) WHERE PH.PickHeaderKey = @c_GetPIPickslipno AND wavekey = @c_GetWavekey)          
          BEGIN                
                INSERT INTO PICKHEADER (PickHeaderKey, WaveKey, Orderkey,ConsoOrderKey, StorerKey, PickType, Zone, TrafficCop )                                                      
                VALUES (@c_GetPIPickslipno ,@c_GetWavekey, '', '', @c_Storerkey, '0', '', '')   --G01                                               
               
             SELECT @n_err = @@ERROR                
             IF @n_err <> 0                
             BEGIN                
                SELECT @n_continue = 3                
                SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 81110   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PICKHEADER Failed (isp_RPT_WV_WAVPLISTC_005)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '            
          
                 GOTO QUIT              
             END           
            END          
          
            IF NOT EXISTS (SELECT 1 FROM dbo.PICKHEADER WITH (NOLOCK) WHERE PickHeaderKey = @c_UPPAPickslipno AND LoadKey = @c_Loadkey)          
            BEGIN          
                   INSERT INTO PICKHEADER (PickHeaderKey, WaveKey, Orderkey,ExternOrderKey,StorerKey, PickType, Zone, TrafficCop,LoadKey,ConsoOrderKey)                                                          
                   VALUES (@c_UPPAPickslipno , '', '',@c_loadkey, @c_Storerkey, '0', '', '',@c_loadkey,@c_loadkey)   --G01                                                  
                         
                   SELECT @n_err = @@ERROR                
                   IF @n_err <> 0                
                   BEGIN       
                      SELECT @n_continue = 3                
                      SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 81120   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                
                      SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PACKHEADER Failed (isp_RPT_WV_WAVPLISTC_005)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '            
                  
                       GOTO QUIT              
                   END 
                   
                    INSERT INTO dbo.PackHeader (PickSlipNo, StorerKey, OrderKey, LoadKey)        
                    VALUES (@c_UPPAPickslipno, @c_Storerkey, '', @c_loadkey)        
                    
                    SELECT @n_err = @@ERROR                
                    IF @n_err <> 0                
                    BEGIN       
                       SELECT @n_continue = 3                
                       SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 81120   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                
                       SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PACKHEADER Failed (isp_RPT_WV_WAVPLISTC_005)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '            
                    
                        GOTO QUIT              
                    END
                  
            END          
          
      --UPDATE #TMPWAVPLISTC005          
      --SET taskno = @c_gettaskno          
      --WHERE Wavekey = @c_GetWavekey AND loadkey = @c_loadkey AND PIPickslipno =@c_GetPIPickslipno AND PAPickslipno = @c_UPPAPickslipno          
          
      FETCH NEXT FROM CUR_INSERTPICKPACKTBL INTO @c_GetPIPickslipno,@c_UPPAPickslipno,@c_loadkey,@c_GetWavekey--,@c_gettaskno          
      END          
      CLOSE CUR_INSERTPICKPACKTBL          
    DEALLOCATE CUR_INSERTPICKPACKTBL           
          
END          


          
   IF @c_PreGenRptData = 'Y'          
   BEGIN          
      UPDATE PICKDETAIL WITH (ROWLOCK)                
      SET  PickSlipNo = TP.PIPickslipno               
          ,EditWho = SUSER_NAME()              
          ,EditDate = GETDATE()               
          ,TrafficCop = NULL               
      FROM #TMPWAVPLISTC005H   TP WITH (NOLOCK)              
      JOIN PICKDETAIL PD ON (TP.Pickdetailkey = PD.Pickdetailkey)           
      WHERE ISNULL(PD.PickSlipNo,'') = ''             
   END          
             
   GOTO QUIT              
               
QUIT:            
              
            
   IF @n_Continue=3  -- Error Occured - Process And Return              
   BEGIN             
      IF @@TRANCOUNT > @n_StartTCnt              
      BEGIN              
         ROLLBACK TRAN              
      END             
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_RPT_WV_WAVPLISTC_005'              
   END            
              
          
--   SELECT *, Row_Number() OVER (PARTITION BY loadkey ORDER BY loadkey Asc) AS recno          
--,RIGHT('00' + RTRIM(CAST(RTRIM(Row_Number() OVER (PARTITION BY loadkey ORDER BY loadkey Asc)) AS NCHAR(2))),2) AS getrowno          
          
--   FROM #TMPWAVPLISTC004          
          
   --SELECT * FROM #TMPWAVPLISTC004H        

               IF ISNULL(@c_PreGenRptData,'')  = 'Y' 
               BEGIN
                     SET @c_PreGenRptData = ''
               END  
          
          
   IF ISNULL(@c_PreGenRptData,'') = ''          
   BEGIN          
          SELECT PIPickslipno AS PICKSLIPNO,PAPickslipno AS PACKSLIPNO,Wavekey AS wavekey,loadkey AS loadkey,Orderkey AS orderkey,ExtOrdkey AS extordkey,qty AS qty,          
                 ttlpqty AS ttlpty,ttlodqty AS ttlordqty          
          ,ctnsku AS ctnsku          
          FROM #TMPWAVPLISTC005          
   END          
               
          
          
   IF OBJECT_ID('tempdb..#TMPWAVPLISTC004H') IS NOT NULL          
      DROP TABLE #TMPWAVPLISTC004H          
          
   IF OBJECT_ID('tempdb..#TMPWAVPLISTC004') IS NOT NULL          
      DROP TABLE #TMPWAVPLISTC004          
          
          
   IF CURSOR_STATUS('LOCAL' , 'CUR_WAVELOAD') in (0 , 1)          
   BEGIN          
      CLOSE CUR_WAVELOAD          
      DEALLOCATE CUR_WAVELOAD             
   END          
          
          
   IF CURSOR_STATUS('LOCAL' , 'CUR_LOADPICK1') in (0 , 1)          
   BEGIN          
      CLOSE CUR_LOADPICK1          
      DEALLOCATE CUR_LOADPICK1             
   END          
          
          
   IF CURSOR_STATUS('LOCAL' , 'CUR_LOADPICK2') in (0 , 1)          
   BEGIN          
      CLOSE CUR_LOADPICK2          
      DEALLOCATE CUR_LOADPICK2             
   END          
          
   IF CURSOR_STATUS('LOCAL' , 'CUR_INSERTPICKPACKTBL') in (0 , 1)          
   BEGIN          
      CLOSE CUR_INSERTPICKPACKTBL          
      DEALLOCATE CUR_INSERTPICKPACKTBL             
   END          
          
          
          
          
   WHILE @@TRANCOUNT < @n_StartTCnt            
   BEGIN            
 BEGIN TRAN             
   END            
               
   RETURN            
QUIT_SP:          
END 
GO
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVPLISTC_005] TO NSQL
GO   
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVPLISTC_005] TO LogiReportRoleWM 
GO