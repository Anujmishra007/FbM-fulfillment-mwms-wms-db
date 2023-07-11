GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO       
/************************************************************************/        
/* Store Procedure: ISP_RPT_WV_WAVPICKSUM_002                           */        
/* Creation Date: 27-OCT-2022                                           */        
/* Copyright:                                                           */        
/* Written by: CSCHONG                                                  */        
/*                                                                      */        
/* Purpose: WMS-21054 [TW] SHDEC WM Report WAVPICKSUM_CR                */        
/*                                                                      */        
/* Called By: RPT_WV_WAVPICKSUM_002                                     */        
/*                                                                      */        
/* PVCS Version: 1.1                                                    */        
/*                                                                      */        
/* Version: 5.4                                                         */        
/*                                                                      */        
/* Data Modifications:                                                  */        
/*                                                                      */        
/* Updates:                                                             */        
/*  Date         Author    Ver.  Purposes                               */    
/*  27-OCT-2022  CHONGCS   1.0   Devops Scripts Combine                 */    
/************************************************************************/        
      
CREATE OR ALTER  PROC dbo.ISP_RPT_WV_WAVPICKSUM_002 (  
                            @c_wavekey NVARCHAR(10)  
                          , @c_PreGenRptData NVARCHAR(10) = ''  )         
 AS        
 BEGIN        
 SET NOCOUNT ON         
 SET ANSI_NULLS OFF    
 SET QUOTED_IDENTIFIER OFF         
 SET CONCAT_NULL_YIELDS_NULL OFF       
     
      
  DECLARE @c_pickheaderkey        NVARCHAR(10),        
    @n_continue             int,        
    @c_errmsg               NVARCHAR(255),        
    @b_success              int,        
    @n_err                  int,        
    @n_pickslips_required   int ,    
    @n_starttcnt            INT,    
    @c_FirstTime            NVARCHAR(1),    
    @c_PrintedFlag          NVARCHAR(1),    
    @c_PickSlipNo           NVARCHAR(20),    
    @c_storerkey            NVARCHAR(20) ,  
    @c_wvudf02              NVARCHAR(20)   
      
   SELECT @n_starttcnt=@@TRANCOUNT, @n_continue=1, @b_success=0, @n_err=0, @c_errmsg=''    
       
       
 CREATE TABLE #TEMP_WAVPICKSUM002    
  ( OrderKey          NVARCHAR(10) NULL,    
  WaveKey           NVARCHAR(50) NULL,  --     
  Qty               INT,       
  Pickheaderkey     NVARCHAR(20) NULL,        
  Storerkey         NVARCHAR(20) NULL,    
  LocAisle          NVARCHAR(10),  
  PLOC              NVARCHAR(10),  
  SKU               NVARCHAR(20),  
  SDESCR            NVARCHAR(80),  
  LOTT02            NVARCHAR(18),  
  LOTT03            NVARCHAR(18),  
  LOTT04            NVARCHAR(10),  
  OriWaveKey        NVARCHAR(10) NULL  
  )    
    
      
  --check wave status. if wave userdefine02 <> 'GRS postdata done' ignore printing  
  
   SET @c_wvudf02 =''  
  
   SELECT @c_wvudf02 = WV.userdefine02  
   FROM WAVE WV (NOLOCK)  
   WHERE WV.wavekey = @c_wavekey  
  
   IF @c_wvudf02<>'GRS postdata done'   
   BEGIN    
      SELECT @n_continue = 3     
      GOTO FAILURE    
   END    
  
   -- Check if wavekey existed    
 IF EXISTS(SELECT 1 FROM PICKHEADER (NOLOCK)    
     WHERE WaveKey = @c_wavekey    
     AND   Zone = '8')    
 BEGIN    
  SELECT @c_FirstTime = N'N'    
  SELECT @c_PrintedFlag = N'Y'    
 END    
 ELSE    
 BEGIN    
  SELECT @c_FirstTime = N'Y'    
  SELECT @c_PrintedFlag = N'N'    
 END    
  
  IF @c_PreGenRptData = 'Y'    
  BEGIN     
       BEGIN TRAN    
       -- Uses PickType as a Printed Flag    
       UPDATE PICKHEADER WITH (ROWLOCK)    
       SET PickType = '1',    
         TrafficCop = NULL    
       WHERE WaveKey = @c_wavekey    
       AND Zone = '8'    
       AND PickType = '0'    
    
       SELECT @n_err = @@ERROR    
         IF @n_err <> 0    
         BEGIN    
            SELECT @n_continue = 3    
            IF @@TRANCOUNT >= 1    
            BEGIN    
               ROLLBACK TRAN    
               GOTO FAILURE    
            END    
         END    
         ELSE    
         BEGIN    
            IF @@TRANCOUNT > 0    
            BEGIN    
               COMMIT TRAN    
            END    
            ELSE    
            BEGIN    
               SELECT @n_continue = 3    
               ROLLBACK TRAN    
               GOTO FAILURE    
            END    
         END      
   END   
   
      
  INSERT INTO #TEMP_WAVPICKSUM002    
  SELECT     
            ORDERS.OrderKey AS Orderkey,    
            c.UDF03 + wave.wavekey AS Wavekey,      
            SUM(PICKD.qty) AS Qty,    
            (SELECT PICKHEADER.PickHeaderKey FROM PICKHEADER (NOLOCK)    
            WHERE PICKHEADER.Wavekey = @c_wavekey    
            AND PICKHEADER.OrderKey = ORDERS.OrderKey    
            AND PICKHEADER.ZONE = '8')     
            ,ORDERS.storerkey AS Storerkey    
            ,LOC.LocAisle AS LocAisle    
            ,PICKD.Loc AS loc    
            ,PICKD.sku AS sku    
            ,sku.DESCR AS sdescr    
            ,ISNULL(LOTT.Lottable02,'') AS LOTT02  
            ,ISNULL(LOTT.Lottable03,'') AS LOTT03  
            ,CONVERT(NVARCHAR(10),LOTT.Lottable04,111) AS LOTT04     
            , wave.wavekey AS oriwavekey  
         FROM ORDERS (NOLOCK)      
         JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey=ORDERS.orderkey    
            JOIN WAVEDETAIL (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey     
            JOIN WAVE (NOLOCK) ON WAVE.WaveKey = WAVEDETAIL.WaveKey     
         -- JOIN PICKHEADER (NOLOCK) ON PICKHEADER.wavekey = WAVEDETAIL.wavekey AND PICKHEADER.orderkey = WAVEDETAIL.OrderKey    
            JOIN SKU (NOLOCK) ON SKU.StorerKey = OD.StorerKey AND SKU.SKU = OD.SKU     
            JOIN dbo.PICKDETAIL PICKD WITH (NOLOCK) ON PICKD.OrderKey = OD.OrderKey AND PICKD.OrderLineNumber = OD.OrderLineNumber   
                                                   AND PICKD.Storerkey = OD.StorerKey AND PICKD.sku = OD.sku  
            JOIN dbo.LOTATTRIBUTE LOTT WITH (NOLOCK) ON LOTT.lot=PICKD.lot   
            JOIN LOC (NOLOCK) ON LOC.LOC = PICKD.LOC     
            LEFT JOIN dbo.CODELKUP C (NOLOCK) ON C.listname  = 'WAVETYPE' AND c.code = Wave.WaveType AND c.Storerkey = ORDERS.storerkey   
          --                             AND c.UDF01 = 'Wave' AND c.Code2 = Wave.WaveType  
         WHERE wave.WaveKey = @c_wavekey     
         GROUP BY ORDERS.OrderKey,wave.wavekey,orders.storerkey,  
                  LOC.LocAisle,PICKD.Loc,PICKD.sku,sku.DESCR,    
         ORDERS.BuyerPO,--,PICKHEADER.PickHeaderKey     
         ORDERS.UserDefine09,ORDERS.C_City,ORDERS.C_Company,    
         ISNULL(LOTT.Lottable02,''),ISNULL(LOTT.Lottable03,'') ,CONVERT(NVARCHAR(10),LOTT.Lottable04,111),c.UDF03   
         ORDER BY wave.wavekey, ORDERS.OrderKey   
  
   
   IF @c_PreGenRptData = 'Y'    
   BEGIN    
       
     
       SELECT @n_pickslips_required = COUNT(DISTINCT OrderKey)    
       FROM #TEMP_WAVPICKSUM002    
       WHERE ISNULL(RTRIM(Pickheaderkey),'') = ''     
    
       IF @@ERROR <> 0    
       BEGIN    
        GOTO FAILURE    
       END    
       ELSE IF @n_pickslips_required > 0    
       BEGIN    
        EXECUTE nspg_GetKey 'PICKSLIP', 9, @c_pickheaderkey OUTPUT, @b_success OUTPUT, @n_err  OUTPUT, @c_errmsg OUTPUT, 0, @n_pickslips_required    
    
        INSERT INTO PICKHEADER (PickHeaderKey, OrderKey, WaveKey, PickType, Zone, TrafficCop)    
        SELECT 'P' + RIGHT ( REPLICATE ('0', 9) +    
        dbo.fnc_LTrim( dbo.fnc_RTrim(    
        STR(CAST(@c_pickheaderkey AS INT) + (SELECT COUNT(DISTINCT OrderKey)    
                     FROM #TEMP_WAVPICKSUM002 AS Rank    
                     WHERE Rank.OrderKey < #TEMP_WAVPICKSUM002.OrderKey    
                AND ISNULL(RTRIM(Rank.Pickheaderkey),'') = '' )     
          ) -- str    
          )) -- dbo.fnc_RTrim    
          , 9)    
         , OrderKey, OriWaveKey, '0', '8', ''    
        FROM #TEMP_WAVPICKSUM002    
        WHERE ISNULL(RTRIM(Pickheaderkey),'') = ''   
        GROUP By OriWaveKey, OrderKey    
    
        UPDATE #TEMP_WAVPICKSUM002    
        SET Pickheaderkey = PICKHEADER.PickHeaderKey    
        FROM PICKHEADER (NOLOCK)    
        WHERE PICKHEADER.WaveKey = #TEMP_WAVPICKSUM002.OriWaveKey    
        AND   PICKHEADER.OrderKey = #TEMP_WAVPICKSUM002.OrderKey    
        AND   PICKHEADER.Zone = '8'    
        AND   ISNULL(RTRIM(#TEMP_WAVPICKSUM002.Pickheaderkey),'') = ''   
       END    
    
       GOTO SUCCESS    
END  
ELSE  
BEGIN  
  GOTO SUCCESS    
END  
    
    
 FAILURE:    
 DELETE FROM #TEMP_WAVPICKSUM002    
 SUCCESS:    
  
 -- Do Auto Scan-in when Configkey is setup.    
 SET @c_StorerKey = ''    
 SET @c_PickSlipNo = ''    
    
   SELECT DISTINCT @c_StorerKey = StorerKey    
   FROM #TEMP_WAVPICKSUM002 (NOLOCK)    
  
    IF @c_PreGenRptData = 'Y'    
    BEGIN    
       IF EXISTS (SELECT 1 FROM STORERCONFIG (NOLOCK) WHERE CONFIGKEY = 'AUTOSCANIN'    
             AND SValue = '1' AND StorerKey = @c_StorerKey)    
       BEGIN    
        DECLARE C_AutoScanPickSlip CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
        SELECT DISTINCT Pickheaderkey    
          FROM #TEMP_WAVPICKSUM002 (NOLOCK)    
    
        OPEN C_AutoScanPickSlip    
        FETCH NEXT FROM C_AutoScanPickSlip INTO @c_PickSlipNo    
    
        WHILE @@FETCH_STATUS <> -1    
        BEGIN    
         IF NOT EXISTS (SELECT 1 FROM PICKINGINFO (NOLOCK) Where PickSlipNo = @c_PickSlipNo)    
         BEGIN    
          INSERT INTO PICKINGINFO (PickSlipNo, ScanInDate, PickerID, ScanOutDate)    
          VALUES (@c_PickSlipNo, GetDate(), sUser_sName(), NULL)    
    
          IF @@ERROR <> 0    
          BEGIN    
           SELECT @n_continue = 3    
           SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 61900    
           SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) +    
                  ': Insert PickingInfo Failed. (ISP_RPT_WV_WAVPICKSUM_002)' + ' ( ' +    
                  ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '    
          END    
         END -- PickSlipNo Does Not Exist    
    
         FETCH NEXT FROM C_AutoScanPickSlip INTO @c_PickSlipNo    
        END    
        CLOSE C_AutoScanPickSlip    
        DEALLOCATE C_AutoScanPickSlip    
       END -- Configkey is setup    
  
    END  
     
    --IF @c_PreGenRptData = ''    
    --BEGIN    
          SELECT DISTINCT '' AS ordekey, TRIM(tp.WaveKey) AS wavekey, SUM(tp.Qty) AS qty,  '' AS Pickheaderkey,    
             tp.Storerkey, tp.LocAisle, tp.PLOC, tp.SKU, tp.SDESCR,    
             tp.LOTT02, tp.LOTT03,     
             tp.LOTT04,tp.OriWaveKey  
          FROM #TEMP_WAVPICKSUM002 AS tp    
          group by tp.WaveKey,tp.Storerkey, tp.LocAisle, tp.PLOC, tp.SKU, tp.SDESCR,    
             tp.LOTT02, tp.LOTT03,     
             tp.LOTT04 ,tp.OriWaveKey  
          ORDER BY tp.OriWaveKey,tp.LocAisle  
   -- END                    
  
  
     IF OBJECT_ID('tempdb..#TEMP_WAVPICKSUM002') IS NOT NULL    
      DROP TABLE #TEMP_WAVPICKSUM002    
      
    
 END 

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON ISP_RPT_WV_WAVPICKSUM_002 TO [NSQL]
GO  
GRANT EXECUTE ON [ISP_RPT_WV_WAVPICKSUM_002] TO LogiReportRoleWM 
GO 

   
   