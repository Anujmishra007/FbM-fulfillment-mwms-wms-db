         
/***************************************************************************/            
/* Stored Procedure: isp_RPT_WV_WAVPLISTC_004                              */            
/* Creation Date: 16-NOV-2022                                              */            
/* Copyright: LFL                                                          */            
/* Written by: CHONGCS                                                     */            
/*                                                                         */            
/* Purpose: WMS-21137 JP BirkenStock BSJ Load Picking List                 */            
/*                                                                         */            
/* Called By: RPT_WV_WAVPLISTC_004                                         */            
/*                                                                         */            
/* GitLab Version: 1.0                                                     */            
/*                                                                         */            
/* Version: 1.0                                                            */            
/*                                                                         */            
/* Data Modifications:                                                     */            
/*                                                                         */            
/* Updates:                                                                */            
/* Date         Author  Ver   Purposes                                     */        
/* 16-NOV-2022  CHONGCS 1.0   DevOps Combine Script                        */        
/***************************************************************************/           
          
CREATE OR ALTER  PROC [dbo].[isp_RPT_WV_WAVPLISTC_004] (          
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
                   
   DECLARE         
           --@c_Wavekey         NVARCHAR(10)          
           @c_Type            NVARCHAR(2)          
       --  , @c_Loadkey         NVARCHAR(10)          
         , @c_PickSlipNo      NVARCHAR(10)          
         , @c_RPickSlipNo   NVARCHAR(10)          
         , @c_PrintedFlag     NVARCHAR(1)           
        
DECLARE --@c_wavekey         NVARCHAR(20)        
      -- ,@c_Getwavekey      NVARCHAR(20)        
     --  ,@c_storerkey       NVARCHAR(20)        
        @c_Xpickqty        NVARCHAR(10)        
       ,@c_YpickQty        NVARCHAR(10)        
      -- ,@c_pickdetailkey   NVARCHAR(20)        
       ,@c_loadkey         NVARCHAR(20)        
    --   ,@c_loc             NVARCHAR(20)        
    --   ,@c_sku             NVARCHAR(20)        
       ,@c_PIPickslipno    NVARCHAR(20)        
       ,@c_GetPIPickslipno NVARCHAR(20)        
       ,@c_PAPickslipno    NVARCHAR(20)        
       ,@c_GetPAPickslipno NVARCHAR(20)        
       ,@c_UPPAPickslipno  NVARCHAR(20)        
       ,@n_pqty            INT        
       ,@n_ODqty           INT         
   --    ,@n_ttlpqty         INT        
       ,@n_ttlODqty        INT =0        
       ,@n_Xpickqty        INT =0        
       ,@n_YpickQty        INT        
     --  ,@c_orderkey        NVARCHAR(20)        
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
         , @c_ST_Company      NVARCHAR(45)          
         , @c_Orderkey        NVARCHAR(10)          
         , @c_getOrderkey     NVARCHAR(10)        
         , @c_OrderType       NVARCHAR(10)          
         , @c_Stop            NVARCHAR(10)          
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
          
         , @c_PAZone             NVARCHAR(10)         
         , @c_PrevPAZone         NVARCHAR(10)         
         , @c_PADescr            NVARCHAR(60)           
         , @c_LogicalLoc         NVARCHAR(18)          
         , @c_Sku                NVARCHAR(20)          
         , @c_SkuDescr           NVARCHAR(60)          
         , @c_HazardousFlag      NVARCHAR(30)          
         , @c_Loc                NVARCHAR(10)          
         , @c_ID                 NVARCHAR(18)              
         , @c_DropID             NVARCHAR(20)           
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
                
   CREATE TABLE #TempTotalQtyPerPickslip (Pickslipno NVARCHAR(10), Pickzone NVARCHAR(20), Qty INT, Remarks NVARCHAR(250) )        
          
   SET @n_StartTCnt  =  @@TRANCOUNT          
   SET @n_Continue   =  1          
          
   SET @c_PickHeaderkey = ''          
   SET @c_Storerkey     = ''          
   SET @c_ST_Company    = ''          
   SET @c_Orderkey      = ''          
   SET @c_OrderType     = ''          
   SET @c_Stop   = ''          
   SET @c_ExternOrderkey= ''          
          
   SET @c_BuyerPO       = ''          
   SET @c_Consigneekey  = ''          
   SET @c_C_Company     = ''               
   SET @c_RPickSlipNo   = ''                        
          
   SET @n_TotalCBM      = 0.00          
   SET @n_TotalGrossWgt = 0.00          
   SET @n_noOfTotes     = 0          
                                
   SET @c_Sku           = ''          
   SET @c_SkuDescr      = ''          
   SET @c_HazardousFlag = ''          
   SET @c_Loc           = ''          
   SET @c_ID            = ''          
   SET @c_DropID        = ''          
           
   SET @c_PZone         = ''        
          
          
   SET @n_Qty           = 0          
   SET @c_PADescr       = ''          
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
        
CREATE TABLE #TMPWAVPLISTC004H        
(  rowno            INT NOT NULL IDENTITY(1,1) PRIMARY KEY,        
   Pickdetailkey    NVARCHAR(20),        
   PIPickslipno     NVARCHAR(20),        
   PAPickslipno     NVARCHAR(20),        
   Wavekey          NVARCHAR(20),        
   loadkey          NVARCHAR(20),        
   Orderkey         NVARCHAR(500),        
   ExtOrdkey        NVARCHAR(500),        
   sku              NVARCHAR(20),        
   ordlinenumber    NVARCHAR(10),        
   pqty             INT,        
   odqty        INT,        
   Recgrp           INT,        
   psgrp            INT         
)        
        
CREATE TABLE #TMPWAVPLISTC004        
(  rowno            INT NOT NULL IDENTITY(1,1) PRIMARY KEY,        
   PIPickslipno     NVARCHAR(20),        
   PAPickslipno     NVARCHAR(20),        
   Wavekey          NVARCHAR(20),        
   loadkey          NVARCHAR(20),        
   Orderkey         NVARCHAR(500),        
   ExtOrdkey        NVARCHAR(500),        
   ctnsku           NVARCHAR(20),        
   qty              INT,        
   ttlpqty          INT,        
   ttlodqty         INT,        
   Xqty             INT,        
   Yqty             INT,        
   taskno           NVARCHAR(5)        
        
)        
        
            SELECT @c_storerkey = oh.storerkey        
            FROM orders oh WITH (NOLOCK)        
            WHERE oh.userdefine09 = @c_wavekey        
        
        
            SELECT @c_Xpickqty = c.Short        
            FROM dbo.CODELKUP C (NOLOCK)         
            WHERE c.LISTNAME='PickQty'        
            AND UPPER(c.Code)='X'        
            AND c.Storerkey=@c_storerkey        
        
        
            SELECT @c_Ypickqty = c.Short        
            FROM dbo.CODELKUP C (NOLOCK)         
            WHERE c.LISTNAME='PickQty'        
            AND UPPER(c.Code)='Y'        
            AND c.Storerkey=@c_storerkey        
        
        
            SET @n_Xpickqty = CAST (@c_Xpickqty AS INT)        
            SET @n_Ypickqty = CAST (@c_Ypickqty AS INT)        
          
                       
   WHILE @@TRANCOUNT > 0          
   BEGIN          
      COMMIT TRAN          
   END        
             
   SET @c_OrderKey = ''          
   SET @c_Pickzone = ''        
   SET @c_PrevPAzone = ''        
   SET @c_PickDetailKey = ''          
   SET @n_continue = 1        
         
DECLARE CUR_WAVELOAD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR         
    SELECT DISTINCT OH.UserDefine09,OH.LoadKey        
    FROM ORDERS OH WITH (NOLOCK)        
    WHERE OH.UserDefine09=@c_wavekey        
    AND ISNULL(OH.LoadKey,'') <> ''        
    ORDER BY OH.UserDefine09,OH.LoadKey        
        
 OPEN CUR_WAVELOAD        
        
      FETCH NEXT FROM CUR_WAVELOAD INTO @c_Getwavekey,@c_loadkey        
      WHILE @@FETCH_STATUS = 0        
      BEGIN        
                     
                     SET @n_ttlpqty = 0        
                     SET @n_ttlODqty = 0        
                     SET @n_rowctn = 1        
                     SET @c_preorderkey     = ''        
                     SET @c_preExtOrdkey    = ''        
                     SET @n_psgrp   = 1        
         
                     --loop for sku qty > Xpickqty        
                     DECLARE CUR_LOADPICK1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR         
SELECT PD.PICKDETAILKEY,ph.PickHeaderKey,pd.PICKSLIPNO,O.ORDERKEY,pd.SKU,pd.QTY,LOC,od.OriginalQty,od.OrderLineNumber        
                     FROM ORDERS O (NOLOCK)        
                     JOIN orderdetail od WITH (NOLOCK) ON od.OrderKey=o.orderkey        
                     JOIN PICKDETAIL PD WITH (NOLOCK) ON (Od.ORDERKEY=PD.ORDERKEY AND od.OrderLineNumber = pd.OrderLineNumber AND od.Sku=pd.Sku AND od.StorerKey = pd.Storerkey)        
                     LEFT JOIN dbo.PickHeader PH WITH (NOLOCK) ON PH.LoadKey=o.LoadKey     
                     WHERE O.USERDEFINE09 =@c_Getwavekey and o.loadkey =@c_loadkey and pd.qty > @n_Xpickqty AND ISNULL(PD.PICKHEADERKEY,'') = '' --AND ISNULL(PD.PICKSLIPNO,'') = ''        
                     ORDER BY pd.sku        
        
                       OPEN CUR_LOADPICK1        
                      FETCH NEXT FROM CUR_LOADPICK1 INTO @c_pickdetailkey,@c_PAPickslipno,@c_PIPickslipno,@c_orderkey,@c_sku,@n_pqty,@c_loc,@n_ODqty,@c_odlineno        
                      WHILE @@FETCH_STATUS = 0        
                      BEGIN        
        
        
        
                        SELECT @n_psgrp = MAX(psgrp)        
      FROM #TMPWAVPLISTC004H          
                        WHERE  Wavekey = @c_Getwavekey --AND loadkey=@c_loadkey         
        
                        --SELECT 'qty>X',@n_rowctn 'rowctn',ISNULL(@c_PIPickslipno,''), @n_psgrp '@n_psgrp'        
        
                              IF ISNULL(@n_psgrp,0) = 0        
                              BEGIN        
                                 SET @n_psgrp = 1        
                              END        
                              ELSE        
                              BEGIN        
                                 SET @n_psgrp = @n_psgrp + 1        
                              END        
         
         
                      IF NOT EXISTS (SELECT 1 FROM PICKHEADER (NOLOCK)         
                                          WHERE wavekey      = @c_GetWavekey AND ISNULL(loadkey,'')='' ) AND ISNULL(@c_PIPickslipno,'') = ''         
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
        
                           IF ISNULL(@c_PAPickslipno,'') = ''        
                           BEGIN         
                                   SET @c_PAPickslipno = ''        
                           END         
        
                           SET @n_ttlpqty =  @n_ttlpqty + @n_pqty        
                           SET @n_ttlODqty = @n_ttlODqty +  @n_ODqty        
                           SET @c_taskno = RIGHT('00' + RTRIM(CAST(RTRIM(@n_rowctn) AS NCHAR(2))),2)        
        
                     INSERT INTO #TMPWAVPLISTC004H         
                     (        
                         Pickdetailkey,        
                         PIPickslipno,        
                         PAPickslipno,        
                         Wavekey,        
                         loadkey,        
                         Orderkey,        
                         ExtOrdkey,        
                         sku,        
                         ordlinenumber,        
                         pqty,        
                         odqty,        
                         Recgrp,psgrp        
                     )        
                     VALUES        
          (   @c_pickdetailkey,@c_PIPickslipno,@c_PAPickslipno,@c_Getwavekey,@c_loadkey,@c_orderkey,@c_ExtOrdkey,@c_sku,@c_odlineno,@n_pqty,@n_ODqty,@n_rowctn,@n_psgrp)        
        
        
                      INSERT INTO #TMPWAVPLISTC004         
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
   Xqty,        
                          Yqty,        
                          taskno          
                      )        
                      VALUES        
                      (   @c_PIPickslipno,@c_PAPickslipno,@c_Getwavekey,@c_loadkey,@c_orderkey,@c_ExtOrdkey,1,@n_pqty,@n_ttlpqty,@n_ttlODqty,@n_Xpickqty,@n_YpickQty,@c_taskno)        
        
        
                       SET @n_rowctn = @n_rowctn + 1         
        
                      FETCH NEXT FROM CUR_LOADPICK1 INTO @c_pickdetailkey,@c_PAPickslipno,@c_PIPickslipno,@c_orderkey,@c_sku,@n_pqty,@c_loc,@n_ODqty,@c_odlineno        
                      END        
                      CLOSE CUR_LOADPICK1        
                    DEALLOCATE CUR_LOADPICK1        
                        
                     SET @n_ttlpqty = 0        
                     SET @n_ttlODqty = 0        
                     SET @n_rowctn = 1        
                     SET @n_Pickslipnoctn = 1        
                     SET @c_mergeExtOrdkey = ''        
                     SET @c_mergeExtOrdkey = ''        
                     SET @c_taskno = '00'        
                     SET @n_ctnrec = 1        
                     SET @c_newpickslip = 'N'        
                     SET @n_psgrp   = 1        
                     SET @n_prevpsgrp = 1        
                     SET @n_ctnremaning = 0        
        
                     --loop for sku qty <= Xpickqty        
                     DECLARE CUR_LOADPICK2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR         
                     SELECT PD.PICKDETAILKEY,ph.PickHeaderKey,pd.PICKSLIPNO,O.ORDERKEY,pd.SKU,pd.QTY,PD.LOC,od.OriginalQty,od.ExternOrderKey,od.OrderLineNumber        
                     FROM ORDERS O WITH (NOLOCK)        
                     JOIN orderdetail od (NOLOCK) ON od.OrderKey=o.orderkey        
                     JOIN PICKDETAIL PD WITH (NOLOCK)ON (Od.ORDERKEY=PD.ORDERKEY AND od.OrderLineNumber = pd.OrderLineNumber AND od.Sku=pd.Sku AND od.StorerKey = pd.Storerkey)        
                     LEFT JOIN dbo.PickHeader PH WITH (NOLOCK) ON PH.LoadKey=o.LoadKey        
                     WHERE O.USERDEFINE09 =@c_Getwavekey and o.loadkey =@c_loadkey and pd.qty <= @n_Xpickqty        
                       AND ISNULL(PD.PICKHEADERKEY,'') = '' --AND ISNULL(PD.PICKSLIPNO,'') = ''        
                     ORDER BY PD.LOC,pd.sku        
        
                      OPEN CUR_LOADPICK2        
                      FETCH NEXT FROM CUR_LOADPICK2 INTO @c_pickdetailkey,@c_PAPickslipno,@c_PIPickslipno,@c_orderkey,@c_sku,@n_pqty,@c_loc,@n_ODqty,@c_ExtOrdkey,@c_odlineno        
                      WHILE @@FETCH_STATUS = 0        
                      BEGIN        
        
        
                        SELECT @n_psgrp = MAX(psgrp)        
                        FROM #TMPWAVPLISTC004H          
                        WHERE  Wavekey = @c_Getwavekey         
        
                        IF @n_rowctn = 1        
                        BEGIN        
                           IF ISNULL(@n_psgrp,0) = 0        
                           BEGIN        
                              SET @n_psgrp = 1        
                           END        
                           BEGIN        
        
                           SET @n_psgrp = @n_psgrp + 1        
                      END        
                      END        
                     INSERT INTO #TMPWAVPLISTC004H         
                     (        
                         Pickdetailkey,        
                         PIPickslipno,        
                         PAPickslipno,        
                         Wavekey,        
                         loadkey,        
                         Orderkey,        
                         ExtOrdkey,        
                         sku,        
                         ordlinenumber,        
                         pqty,        
                         odqty,        
                         Recgrp,psgrp        
                     )        
                     VALUES        
                     (   @c_pickdetailkey,@c_PIPickslipno,@c_PAPickslipno,@c_Getwavekey,@c_loadkey,@c_orderkey,@c_ExtOrdkey,@c_sku,@c_odlineno,@n_pqty,@n_ODqty,@n_rowctn,@n_psgrp)        
        
                                    SELECT @n_ctnrec = COUNT(1)        
                                    FROM ORDERS O WITH (NOLOCK)        
                                    JOIN orderdetail od (NOLOCK) ON od.OrderKey=o.orderkey        
                                    JOIN PICKDETAIL PD WITH (NOLOCK) ON (Od.ORDERKEY=PD.ORDERKEY AND od.OrderLineNumber = pd.OrderLineNumber AND od.Sku=pd.Sku AND od.StorerKey = pd.Storerkey)        
                                    WHERE O.USERDEFINE09 =@c_Getwavekey and o.loadkey =@c_loadkey and pd.qty <= @n_Xpickqty --AND ISNULL(PIPickslipno,'') = ''        
        
                                    SELECT @n_ctnremaning = COUNT(1)        
                                    FROM #TMPWAVPLISTC004H         
                                    WHERE wavekey=@c_getwavekey AND loadkey = @c_loadkey AND pqty <=@n_Xpickqty        
        
        
        
                                   SET @n_ttlpqty = @n_ttlpqty + @n_pqty        
                                   SET @n_ttlODqty = @n_ttlODqty + @n_ODqty        
           
                           IF @n_rowctn = 1        
                           BEGIN        
                               SET @c_mergeorderkey = @c_orderkey         
                               SET @c_mergeExtOrdkey =@c_ExtOrdkey         
                           END        
                           ELSE --IF @n_rowctn >1 AND @n_rowctn <= @n_YpickQty         
                           BEGIN        
                                 IF @c_preExtOrdkey <> @c_ExtOrdkey        
                                 BEGIN        
                                      SET @c_mergeExtOrdkey =@c_mergeExtOrdkey+ @c_delimiter + @c_ExtOrdkey        
                                 END        
                                 IF @c_preorderkey <> @c_orderkey        
                                 BEGIN        
                                      SET @c_mergeorderkey = @c_mergeorderkey + @c_delimiter + @c_orderkey          
                                 END        
                           END        
        
                           IF @n_rowctn = @n_ctnrec OR  @n_rowctn = @n_YpickQty OR @n_ctnrec = @n_ctnremaning        
                           BEGIN        
                                  SET  @c_newpickslip = 'Y'        
                                  SET @n_prevpsgrp = @n_psgrp        
                                  SET @n_psgrp = @n_psgrp + 1        
                           END        
        
--SELECT @c_newpickslip '@c_newpickslip'     
    
                           IF @c_newpickslip = 'Y'        
                           BEGIN        
                                  IF NOT EXISTS (SELECT 1 FROM PICKHEADER (NOLOCK)         
                                          WHERE wavekey      = @c_GetWavekey AND ISNULL(loadkey,'')='') AND ISNULL(@c_PIPickslipno,'') = ''        
                                          AND @c_PreGenRptData = 'Y'         
                                  BEGIN         
        
                                     EXECUTE nspg_GetKey        
                                       'PICKSLIP'            
                                    ,  9            
                                    ,  @c_PIPickslipno OUTPUT            
                                    ,  @b_Success    OUTPUT            
                                    ,  @n_err        OUTPUT            
                                    ,  @c_errmsg     OUTPUT                  
                                     
                              SET  @c_PIPickslipno = 'P' +  @c_PIPickslipno              
                           END        
        
                           IF ISNULL(@c_PAPickslipno,'') = ''        
                           BEGIN         
                                   SET @c_PAPickslipno = ''        
                           END         
        
                           SET @c_taskno = RIGHT('00' + RTRIM(CAST(RTRIM(@n_Pickslipnoctn) AS NCHAR(2))),2)        
        
           
    
                           UPDATE #TMPWAVPLISTC004H                                  SET PIPickslipno = @c_PIPickslipno        
                           WHERE Wavekey = @c_Getwavekey AND loadkey=@c_loadkey AND psgrp =@n_prevpsgrp        
                                   
                              INSERT INTO #TMPWAVPLISTC004         
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
                                    Xqty,        
                                    Yqty,        
                                    taskno        
                              )        
                             VALUES        
                              (   @c_PIPickslipno, @c_PAPickslipno,@c_Getwavekey,@c_loadkey,@c_mergeorderkey,@c_mergeExtOrdkey,@n_rowctn,@n_ttlpqty,@n_ttlpqty,@n_ttlODqty,@n_Xpickqty,@n_YpickQty,@c_taskno)        
           
                                 SET @n_rowctn = 0        
                                 SET @n_Pickslipnoctn = @n_Pickslipnoctn + 1           
                                 SET @c_taskno = ''        
                                 SET @c_newpickslip = 'N'        
                           END         
        
                           SET @n_rowctn = @n_rowctn + 1        
                           SET @c_preorderkey = @c_orderkey        
                           SET @c_preExtOrdkey = @c_ExtOrdkey        
                                   
        
                      FETCH NEXT FROM CUR_LOADPICK2 INTO @c_pickdetailkey,@c_PAPickslipno,@c_PIPickslipno,@c_orderkey,@c_sku,@n_pqty,@c_loc,@n_ODqty,@c_ExtOrdkey,@c_odlineno        
                      END        
                      CLOSE CUR_LOADPICK2        
                    DEALLOCATE CUR_LOADPICK2        
         
                SET @c_GetPAPickslipno = ''        
                SET @n_TTLPQty = 0        
                SET @n_ttlODqty = 0        
        
                SELECT @c_GetPAPickslipno = ISNULL(PAPickslipno,'')        
                FROM #TMPWAVPLISTC004H         
                WHERE Wavekey = @c_Getwavekey AND loadkey =@c_loadkey        
        
        
                SELECT @n_TTLPQty = SUM(pqty), @n_ttlODqty = SUM(odqty)        
                FROM #TMPWAVPLISTC004H         
                WHERE Wavekey = @c_Getwavekey AND loadkey =@c_loadkey        
        
                --IF NOT EXISTS (SELECT 1 FROM PACKHEADER (NOLOCK)         
                --               WHERE loadkey      = @c_loadkey) AND  ISNULL(@c_GetPAPickslipno,'') =''        
                --               AND @c_PreGenRptData = 'Y'        
                IF NOT EXISTS (SELECT 1 FROM PICKHEADER (NOLOCK)         
                                          WHERE ISNULL(loadkey,'')= @c_loadkey AND PickHeaderKey LIKE 'D%') AND ISNULL(@c_GetPAPickslipno,'') = ''         
                                          AND @c_PreGenRptData = 'Y'         
                BEGIN        
        
                     EXECUTE nspg_GetKey               
                                       'PICKSLIP'            
                                    ,  9            
                                    ,   @c_GetPAPickslipno OUTPUT            
                                    ,  @b_Success    OUTPUT            
                                    ,  @n_err        OUTPUT            
                                    ,  @c_errmsg     OUTPUT                  
                                     
                              SET  @c_GetPAPickslipno = 'D' +  @c_GetPAPickslipno              
        
        
                          UPDATE #TMPWAVPLISTC004H         
                          SET PAPickslipno = @c_GetPAPickslipno        
                          WHERE Wavekey = @c_Getwavekey AND loadkey =@c_loadkey        
        
        
                          UPDATE #TMPWAVPLISTC004         
                          SET PAPickslipno = @c_GetPAPickslipno        
                          WHERE Wavekey = @c_Getwavekey AND loadkey =@c_loadkey        
               END        
        
                         
     SET @c_mergeExtOrdkey = (SELECT distinct RTRIM(OH.Externorderkey)+', 'FROM ORDERS OH (NOLOCK)                         
            join #TMPWAVPLISTC004H T04 on OH.LoadKey=T04.LoadKey AND OH.LoadKey=@c_loadkey FOR XML PATH(''))            
        
     SET @c_mergeorderkey = (SELECT distinct RTRIM(OH.orderkey)+', 'FROM ORDERS OH (NOLOCK)                         
            join #TMPWAVPLISTC004H T04 on OH.LoadKey=T04.LoadKey AND OH.LoadKey=@c_loadkey FOR XML PATH(''))            
        
        
--SELECT @c_mergeorderkey '@c_mergeorderkey',@c_mergeExtOrdkey '@c_mergeExtOrdkey'        
        
                          UPDATE #TMPWAVPLISTC004         
                          SET  ttlpqty = @n_TTLPQty        
                              ,ttlodqty = @n_ttlODqty        
                              ,Orderkey = @c_mergeorderkey        
           ,ExtOrdkey = @c_mergeExtOrdkey        
                          WHERE Wavekey = @c_Getwavekey AND loadkey =@c_loadkey        
        
      FETCH NEXT FROM CUR_WAVELOAD INTO @c_Getwavekey,@c_loadkey        
      END        
      CLOSE CUR_WAVELOAD        
    DEALLOCATE CUR_WAVELOAD         
        
-- SELECT '04',* FROM #TMPWAVPLISTC004        
--select '04h',* FROM #TMPWAVPLISTC004H        
 --SELECT DISTINCT PIPickslipno,PAPickslipno,loadkey,Wavekey,RIGHT('00' + RTRIM(CAST(RTRIM(Row_Number() OVER (PARTITION BY loadkey ORDER BY loadkey Asc)) AS NCHAR(2))),2) AS gettaskno        
 --      FROM #TMPWAVPLISTC004        
 --      WHERE Wavekey=@c_Wavekey        
 --      ORDER BY PIPickslipno        
        
--GOTO QUIT_SP        
        
   IF @c_PreGenRptData = 'Y'        
   BEGIN        
       DECLARE CUR_INSERTPICKPACKTBL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR         
       SELECT DISTINCT PIPickslipno,PAPickslipno,loadkey,Wavekey,RIGHT('00' + RTRIM(CAST(RTRIM(Row_Number() OVER (PARTITION BY loadkey ORDER BY loadkey Asc)) AS NCHAR(2))),2) AS gettaskno        
       FROM #TMPWAVPLISTC004        
       WHERE Wavekey=@c_Wavekey        
       ORDER BY PIPickslipno        
        
      OPEN CUR_INSERTPICKPACKTBL        
      FETCH NEXT FROM CUR_INSERTPICKPACKTBL INTO @c_GetPIPickslipno,@c_UPPAPickslipno,@c_loadkey,@c_GetWavekey,@c_gettaskno        
      WHILE @@FETCH_STATUS = 0        
      BEGIN        
        
         SET @c_getOrderkey = ''        
        
          SELECT @c_getOrderkey = MAX(OH.orderkey)        
          FROM dbo.ORDERS OH (NOLOCK)        
          WHERE oh.LoadKey=@c_loadkey AND oh.UserDefine09 = @c_GetWavekey        
        
     
      IF NOT EXISTS (SELECT 1 FROM dbo.PICKHEADER WITH (NOLOCK) WHERE PickHeaderKey = @c_GetPIPickslipno AND wavekey =@c_GetWavekey and ConsoOrderKey=@c_loadkey+' '+@c_gettaskno )    --G01    
      BEGIN        
               --  SELECT @c_GetPIPickslipno '@c_GetPIPickslipno',@c_GetWavekey'c_GetWavekey', @c_getOrderkey '@c_getOrderkey', @c_gettaskno '@c_gettaskno'        
        
                --INSERT INTO PICKHEADER (PickHeaderKey, WaveKey, Orderkey,ExternOrderKey, PickType, Zone, TrafficCop)              
                --VALUES (@c_GetPIPickslipno , @c_GetWavekey, @c_getOrderkey,@c_gettaskno, '0', '', '')           
        
 INSERT INTO PICKHEADER (PickHeaderKey, WaveKey, Orderkey,ConsoOrderKey, PickType, Zone, TrafficCop )              
    VALUES (@c_GetPIPickslipno , @c_GetWavekey, '',@c_loadkey+' '+@c_gettaskno, '0', '', '')     --G01      
        
             SELECT @n_err = @@ERROR              
             IF @n_err <> 0              
             BEGIN              
                SELECT @n_continue = 3              
                SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 81110   -- Should Be Set To The SQL Errmessage but I don't know how to do so.              
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PICKHEADER Failed (isp_RPT_WV_WAVPLISTC_004)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '          
        
                 GOTO QUIT            
             END               
             
      END        
        
      IF NOT EXISTS (SELECT 1 FROM dbo.PICKHEADER WITH (NOLOCK) WHERE PickHeaderKey = @c_UPPAPickslipno AND LoadKey = @c_Loadkey)        
      BEGIN        
                --INSERT INTO PICKHEADER (PickHeaderKey, WaveKey, Orderkey,ExternOrderKey, PickType, Zone, TrafficCop,LoadKey,ConsoOrderKey)              
                --VALUES (@c_UPPAPickslipno , '', @c_getOrderkey,'', '0', '', '',@c_loadkey,@c_gettaskno)        
          
    INSERT INTO PICKHEADER (PickHeaderKey, WaveKey, Orderkey,ExternOrderKey, PickType, Zone, TrafficCop,LoadKey,ConsoOrderKey)                  
    VALUES (@c_UPPAPickslipno , '', '',@c_loadkey, '0', '', '',@c_loadkey,@c_loadkey+' '+@c_gettaskno)   --G01          
          
    INSERT INTO PACKHEADER (PickSlipno,Storerkey,Orderkey,LoadKey)                  
    VALUES (@c_UPPAPickslipno ,@c_Storerkey, '',@c_loadkey)   --G01          
        
             SELECT @n_err = @@ERROR              
             IF @n_err <> 0              
             BEGIN              
                SELECT @n_continue = 3              
                SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 81120   -- Should Be Set To The SQL Errmessage but I don't know how to do so.              
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PACKHEADER Failed (isp_RPT_WV_WAVPLISTC_004)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '          
        
                 GOTO QUIT            
             END               
        
      END        
        
      UPDATE #TMPWAVPLISTC004        
      SET taskno = @c_gettaskno        
      WHERE Wavekey = @c_GetWavekey AND loadkey = @c_loadkey AND PIPickslipno =@c_GetPIPickslipno AND PAPickslipno = @c_UPPAPickslipno        
        
        
        
      FETCH NEXT FROM CUR_INSERTPICKPACKTBL INTO @c_GetPIPickslipno,@c_UPPAPickslipno,@c_loadkey,@c_GetWavekey,@c_gettaskno        
      END        
      CLOSE CUR_INSERTPICKPACKTBL        
    DEALLOCATE CUR_INSERTPICKPACKTBL         
--GOTO QUIT_SP        
END        
        
   IF @c_PreGenRptData = 'Y'        
   BEGIN        
      UPDATE PICKDETAIL WITH (ROWLOCK)              
      SET  PickSlipNo = TP.PIPickslipno             
          ,EditWho = SUSER_NAME()            
          ,EditDate = GETDATE()             
          ,TrafficCop = NULL             
      FROM #TMPWAVPLISTC004H   TP WITH (NOLOCK)            
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_RPT_WV_WAVPLISTC_004'            
   END          
            
        
--   SELECT *, Row_Number() OVER (PARTITION BY loadkey ORDER BY loadkey Asc) AS recno        
--,RIGHT('00' + RTRIM(CAST(RTRIM(Row_Number() OVER (PARTITION BY loadkey ORDER BY loadkey Asc)) AS NCHAR(2))),2) AS getrowno        
        
--   FROM #TMPWAVPLISTC004        
        
   --SELECT * FROM #TMPWAVPLISTC004H        
        
        
   IF ISNULL(@c_PreGenRptData,'') = ''        
   BEGIN        
          SELECT PIPickslipno AS PICKSLIPNO,PAPickslipno AS PACKSLIPNO,Wavekey AS wavekey,loadkey AS loadkey,Orderkey AS orderkey,ExtOrdkey AS extordkey,qty AS qty,        
                 ttlpqty AS ttlpty,ttlodqty AS ttlordqty,Xqty AS xqty,Yqty AS yqty--,taskno AS taskno        
          --        Row_Number() OVER (PARTITION BY loadkey ORDER BY loadkey Asc) AS recno        
          ,RIGHT('00' + RTRIM(CAST(RTRIM(Row_Number() OVER (PARTITION BY loadkey ORDER BY loadkey Asc)) AS NCHAR(2))),2) AS gettaskno        
          ,ctnsku AS ctnsku        
          FROM #TMPWAVPLISTC004        
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [isp_RPT_WV_WAVPLISTC_004]  TO NSQL
GO  
GRANT EXECUTE ON [isp_RPT_WV_WAVPLISTC_004] TO JReportRole 
GO