IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetPickSlipOrders96]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetPickSlipOrders96]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/      
/* Stored Proc : isp_GetPickSlipOrders96                                   */      
/* Creation Date:24/06/2019                                                */      
/* Copyright: IDS                                                          */      
/* Written by:                                                             */      
/*                                                                         */      
/* Purpose: WMS-10414 - SG - THGSG - Pickslip for Pick by Orders           */      
/*                                                                         */      
/*                                                                         */      
/* Usage:                                                                  */      
/*                                                                         */      
/* Local Variables:                                                        */      
/*                                                                         */      
/* Called By: r_dw_print_pickorder96                                       */      
/*                                                                         */      
/* PVCS Version: 1.1                                                       */      
/*                                                                         */      
/* Version: 5.4                                                            */      
/*                                                                         */      
/* Data Modifications:                                                     */      
/*                                                                         */      
/* Updates:                                                                */      
/* Date        Author      Ver   Purposes                                  */      
/*25-OCT-2019  WLChooi     1.1   WMS-10939 - Change sorting logic (WL01)   */    
/*11-Nov-2019  WLChooi     1.2   WMS-10939 - Sort by logicalloc (WL02)     */    
/*26-Nov-2019  CSCHONG     1.3   WMS-11219 - Add new field  (CS02)         */    
/*07-Feb-2020  CSCHONG     1.4   WMS-11990 - add new field (CS03)          */  
/*18-MAR-2020  CSCHONG     1.5   WMS-12474 - Add new field (CS04)          */  
/*20-APR-2020  WLChooi     1.6   INC1118265 - Show Complete LOC (WL03)     */
/*11-JUN-2020  CSCHONG     1.7   WMS-13626 - revised field mapping (CS05)  */
/***************************************************************************/      
      
CREATE PROC [dbo].[isp_GetPickSlipOrders96] (@c_loadkey NVARCHAR(10),   
                                             @c_Type NVARCHAR(10) = '') --WL01       
 AS      
 BEGIN      
   SET NOCOUNT ON       
   SET ANSI_NULLS OFF    
   SET QUOTED_IDENTIFIER OFF       
   SET CONCAT_NULL_YIELDS_NULL OFF      
    
DECLARE @c_pickheaderkey    NVARCHAR(10),      
        @n_continue         int,      
        @c_errmsg           NVARCHAR(255),      
        @b_success          int,      
        @n_err              int,      
        @c_sku              NVARCHAR(20),      
        @n_qty              int,      
        @c_loc              NVARCHAR(10),      
        @n_cases            int,      
        @n_perpallet        int,      
        @c_storer           NVARCHAR(15),      
        @c_orderkey         NVARCHAR(10),      
        @c_ConsigneeKey     NVARCHAR(15),      
        @c_Company          NVARCHAR(45),      
        @c_Addr1            NVARCHAR(45),      
        @c_Addr2            NVARCHAR(45),      
        @c_Addr3            NVARCHAR(45),      
        @c_PostCode         NVARCHAR(15),      
        @c_Route            NVARCHAR(10),      
        @c_Route_Desc       NVARCHAR(60), -- RouteMaster.Desc      
        @c_TrfRoom          NVARCHAR(5),  -- LoadPlan.TrfRoom      
        @c_Notes1           NVARCHAR(60),      
        @c_Notes2           NVARCHAR(60),      
        @c_SkuDesc          NVARCHAR(60),      
        @n_CaseCnt          int,      
        @n_PalletCnt        int,      
        @c_ReceiptTm        NVARCHAR(20),      
        @c_PrintedFlag      NVARCHAR(1),      
        @c_UOM              NVARCHAR(10),      
        @n_UOM3             int,      
        @c_Lot              NVARCHAR(10),      
        @c_StorerKey        NVARCHAR(15),      
        @c_Zone             NVARCHAR(1),      
        @n_PgGroup          int,      
        @n_TotCases         int,      
        @n_RowNo            int,      
        @c_PrevSKU          NVARCHAR(20),      
        @n_SKUCount         int,      
        @c_Carrierkey       NVARCHAR(60),      
        @c_VehicleNo        NVARCHAR(10),      
        @c_firstorderkey    NVARCHAR(10),      
        @c_superorderflag   NVARCHAR(1),      
        @c_firsttime        NVARCHAR(1),      
        @c_logicalloc       NVARCHAR(18),      
        @c_Lottable02       NVARCHAR(10), -- SOS14561      
        @d_Lottable04       datetime,      
        @n_packpallet       int,      
        @n_packcasecnt      int,      
        @c_externorderkey   NVARCHAR(30),        
        @n_pickslips_required int,        
        @c_areakey          NVARCHAR(10),      
        @c_skugroup         NVARCHAR(10) -- SOS144415       
                        
    DECLARE @c_PrevOrderKey NVARCHAR(10),      
            @n_Pallets      int,      
            @n_Cartons      int,      
            @n_Eaches       int,      
            @n_UOMQty       int      
    
   IF @c_Type = 'H1'    
   BEGIN    
      SELECT DISTINCT WD.Wavekey, LPD.Loadkey    
      FROM WAVEDETAIL WD (NOLOCK)    
      JOIN LOADPLANDETAIL LPD (NOLOCK) ON LPD.ORDERKEY = WD.ORDERKEY    
      WHERE Loadkey = @c_loadkey    
    
      GOTO QUIT_SP    
   END    
                
    CREATE TABLE #TEMP_PICK96     
    ( LoadKey       NVARCHAR(10) NULL,    
      PickSlipNo    NVARCHAR(10) NULL,      
      StorerKey     NVARCHAR(20),        
      LOC           NVARCHAR(30) NULL,      
      SKU           NVARCHAR(20),      
      OrderKey      NVARCHAR(10) NULL,    
      LocPickZone   NVARCHAR(10) NULL,    
      Qty           int,    
      LogicalLoc    NVARCHAR(18) NULL,  --WL02    
      ReprintFlag   NVARCHAR(1)  NULL, --CS02    
      Altsku        NVARCHAR(20) NULL,  --CS02    
      PUOM3         NVARCHAR(10) NULL,  --CS03 
      CASEID        NVARCHAR(20) NULL, --CS05
      Wavekey       NVARCHAR(10) NULL  --CS05
    --PickerID      NVARCHAR(15) NULL  --CS04  
     )       --CS01      
    
     --WL01 START    
     CREATE TABLE #TEMP_PICK96_LOC(    
      PickSlipNo    NVARCHAR(10)  NULL,    
      Loc           NVARCHAR(250) NULL    
     )    
    
     CREATE TABLE #TEMPTABLELOC(    
      rowid           int NOT NULL identity(1,1),    
      PickSlipNo      NVARCHAR(10)  NULL,    
      FirstLoc        NVARCHAR(100) NULL,    
      SecondLoc       NVARCHAR(100) NULL,    
      ThirdLoc        NVARCHAR(100) NULL    
     )    
     --WL01 END    
  
  --CS04 START  
  
  CREATE TABLE #TEMP_PICK96ID     
    ( LoadKey       NVARCHAR(10) NULL,   
      rowid         INT,     
         OrderKey      NVARCHAR(10) NULL,    
         PickSlipNo    NVARCHAR(10)  NULL,   
         PICKERNo      INT )  
  
  --CS04 END    
    
  --CS02 START    
    
   IF EXISTS(SELECT 1 FROM PickHeader (NOLOCK) WHERE ExternOrderKey = @c_loadkey AND Zone = '3' and PickType='1')    
   BEGIN    
         SELECT @c_PrintedFlag = 'Y'    
      END    
   ELSE    
   BEGIN    
         SELECT @c_PrintedFlag = 'N'    
   END    
            
       INSERT INTO #TEMP_PICK96      
            (LoadKey,PickSlipNo, Storerkey, LOC,SKU,OrderKey,    
             LocPickZone,Qty, LogicalLoc,ReprintFlag,Altsku,PUOM3,CASEID,Wavekey) --WL02   --CS02  --CS03   --CS04  --CS05
        SELECT DISTINCT @c_LoadKey as LoadKey,    
         (SELECT PICKHEADERKEY FROM PICKHEADER WITH (NOLOCK)      
                   WHERE ExternOrderKey = @c_LoadKey       
                   AND OrderKey = PickDetail.OrderKey       
                   AND ZONE = '3'),    
      Pickdetail.storerkey,    
      PickDetail.loc,     
      PickDetail.sku,                           
      PickDetail.OrderKey,                                   
      LocPickZone = ISNULL(Loc.Pickzone,''),           
      SUM(PickDetail.qty) as Qty,    
      LOC.LogicalLocation               --WL02        
     ,@c_PrintedFlag,ISNULL(Sku.ALTSKU,'')        --CS02     
     ,P.PackUOM3                                  --CS03  
      ,pickdetail.caseid as caseid                --CS05
      ,(wd.wavekey) as wavekey                    --CS05  
 -- ,'PK' + space(2) + CAST(T96D.PICKERNo as nvarchar(8))                   
  
     FROM pickdetail (nolock)      
     join orders (nolock)      
      on pickdetail.orderkey = orders.orderkey      
     join loadplandetail (nolock)      
      on pickdetail.orderkey = loadplandetail.orderkey      
     join orderdetail (nolock)      
      on pickdetail.orderkey = orderdetail.orderkey and pickdetail.orderlinenumber = orderdetail.orderlinenumber         
     join storer (nolock)      
      on pickdetail.storerkey = storer.storerkey      
     join sku (nolock)      
      on pickdetail.sku = sku.sku and pickdetail.storerkey = sku.storerkey      
     join loc (nolock)      
      on pickdetail.loc = loc.loc   
     join PACK P (NOLOCK) ON P.Packkey = sku.Packkey  --CS03      
     join wavedetail wd (nolock) on wd.orderkey = orders.orderkey        --CS05 
  -- join #TEMP_PICK96ID T96D ON T96D.LoadKey = LoadPlanDetail.LoadKey and T96D.OrderKey= PickDetail.OrderKey  
     WHERE PickDetail.Status >= '0'        
          AND LoadPlanDetail.LoadKey = @c_LoadKey      
     GROUP BY PickDetail.OrderKey,                                  
              PickDetail.loc,         
              Pickdetail.storerkey,     
              PickDetail.sku,                               
              ISNULL(Loc.Pickzone,''),    
              LOC.LogicalLocation             --WL02       
             ,ISNULL(Sku.ALTSKU,'')           --CS02    
             ,P.PackUOM3                      --CS03    
             ,pickdetail.caseid               --CS05
             ,(wd.wavekey)                    --CS05
   -- , CAST(T96D.PICKERNo as nvarchar(8))   --CS04    
      
    --select * from #TEMP_PICK96  
    --goto QUIT_SP   
      
     BEGIN TRAN        
     -- Uses PickType as a Printed Flag        
     UPDATE PickHeader with (RowLOck)    -- tlting01    
      SET PickType = '1', TrafficCop = NULL       
     WHERE ExternOrderKey = @c_LoadKey       
     AND Zone = '3'       
     SELECT @n_err = @@ERROR        
     IF @n_err <> 0         
     BEGIN        
         SELECT @n_continue = 3        
         IF @@TRANCOUNT >= 1        
         BEGIN        
             ROLLBACK TRAN        
         END        
     END        
     ELSE BEGIN        
         IF @@TRANCOUNT > 0         
         BEGIN        
             COMMIT TRAN        
         END        
         ELSE BEGIN        
             SELECT @n_continue = 3        
             ROLLBACK TRAN        
         END        
     END        
     SELECT @n_pickslips_required = Count(DISTINCT OrderKey)       
     FROM #TEMP_PICK96      
     WHERE PickSlipNo IS NULL      
     IF @@ERROR <> 0      
     BEGIN      
         GOTO FAILURE      
     END      
     ELSE IF @n_pickslips_required > 0      
     BEGIN      
    
         EXECUTE nspg_GetKey 'PICKSLIP', 9, @c_pickheaderkey OUTPUT, @b_success OUTPUT, @n_err  OUTPUT, @c_errmsg OUTPUT, 0, @n_pickslips_required      
         INSERT INTO PICKHEADER (PickHeaderKey,    OrderKey, ExternOrderKey, PickType, Zone, TrafficCop)      
             SELECT 'P' + RIGHT ( REPLICATE ('0', 9) +       
             dbo.fnc_LTrim( dbo.fnc_RTrim(      
                STR(       
                   CAST(@c_pickheaderkey AS int) + ( select count(distinct orderkey)       
                                                     from #TEMP_PICK96 as Rank       
                                                     WHERE Rank.OrderKey < #TEMP_PICK96.OrderKey )       
                    ) -- str      
                    )) -- dbo.fnc_RTrim      
                 , 9)       
              , OrderKey, LoadKey, '0', '3', ''      
             FROM #TEMP_PICK96 WHERE PickSlipNo IS NULL      
             GROUP By LoadKey, OrderKey      
         UPDATE #TEMP_PICK96      
         SET PickSlipNo = PICKHEADER.PickHeaderKey      
         FROM PICKHEADER (NOLOCK)      
         WHERE PICKHEADER.ExternOrderKey = #TEMP_PICK96.LoadKey      
         AND   PICKHEADER.OrderKey = #TEMP_PICK96.OrderKey      
         AND   PICKHEADER.Zone = '3'      
         AND   #TEMP_PICK96.PickSlipNo IS NULL      
     END      
  
  
     GOTO SUCCESS      
 FAILURE:      
     DELETE FROM #TEMP_PICK96     
SUCCESS:    
   --WL01 Start      
   INSERT INTO #TEMP_PICK96_LOC    
   SELECT b.PickSlipNo,    
          --CAST(STUFF((SELECT TOP 3 ',' + RTRIM(a.Loc) FROM #TEMP_PICK96 a where a.PickSlipNo = b.PickSlipNo ORDER BY a.PickSlipNo, a.Loc FOR XML PATH('')),1,1,'' ) AS NVARCHAR(250)) AS Loc              --WL02    
          CAST(STUFF((SELECT TOP 3 ',' + RTRIM(a.LogicalLoc) FROM #TEMP_PICK96 a where a.PickSlipNo = b.PickSlipNo ORDER BY a.PickSlipNo, a.LogicalLoc FOR XML PATH('')),1,1,'' ) AS NVARCHAR(250)) AS Loc  --WL02    
   FROM #TEMP_PICK96 b    
   GROUP BY b.PickSlipNo    
    
   IF @c_Type = 'B'    
      SELECT * FROM #TEMP_PICK96_LOC    
    
   INSERT INTO #TEMPTABLELOC (PickSlipNo ,    
                              FirstLoc   ,    
                              SecondLoc  ,    
                              ThirdLoc   )    
   SELECT PickSlipNo,     
          (SELECT substring(COLVALUE,1,3) + space(2) +substring(COLVALUE,4,1) + space(2) +substring(COLVALUE,5,6) FROM dbo.fnc_delimsplit (',',Loc) WHERE SeqNo = 1) AS FirstLoc   ,   --WL03    
          (SELECT substring(COLVALUE,1,3) + space(2) +substring(COLVALUE,4,1) + space(2) +substring(COLVALUE,5,6) FROM dbo.fnc_delimsplit (',',Loc) WHERE SeqNo = 2) AS SecondLoc  ,   --WL03    
          (SELECT substring(COLVALUE,1,3) + space(2) +substring(COLVALUE,4,1) + space(2) +substring(COLVALUE,5,6) FROM dbo.fnc_delimsplit (',',Loc) WHERE SeqNo = 3) AS ThirdLoc       --WL03
   FROM #TEMP_PICK96_LOC    
   order by FirstLoc,     
            SecondLoc,    
            ThirdLoc    
        
  --CS04 START  
  
   INSERT INTO #TEMP_PICK96ID (Loadkey,rowid,Orderkey,pickslipno,PICKERNo)  
   SELECT DISTINCT T96.loadkey,tl.rowid,T96.orderkey,T96.pickslipno,((Row_Number() OVER (PARTITION BY T96.LoadKey ORDER BY tl.rowid Asc)-1)/8 +1) as recgrp  
   FROM  #TEMP_PICK96 T96  
   JOIN #TEMPTABLELOC TL on tl.pickslipno = T96.pickslipno   
   GROUP BY T96.loadkey,tl.rowid,T96.orderkey,T96.pickslipno  
   ORDER BY tl.rowid  
  
     
  --CS04 END  
       
   IF @c_Type = 'B'    
      SELECT * FROM #TEMPTABLELOC    
    
    
   SELECT t1.LoadKey,    
          t1.PickSlipNo,      
          t1.StorerKey,        
          substring(LOC,1,3) + space(2) +substring(LOC,4,1) + space(2) +substring(LOC,5,6) as loc, --WL03
          SKU        ,      
          t1.OrderKey   ,    
          LocPickZone,    
          Qty    
         ,ReprintFlag,Altsku                   --CS02         
         ,PUOM3                                --CS03     
         ,'PK' + space(2) + CAST(t3.PICKERNo as nvarchar(8))  as PickerID    --CS04   
         ,t1.CASEID as caseid                                                --CS05
         ,t1.Wavekey as wavekey                                              --CS05
   FROM #TEMP_PICK96 t1    
   JOIN #TEMPTABLELOC t2 ON t2.PickSlipNo = t1.PickSlipNo   
   JOIN #TEMP_PICK96ID t3 ON t3.rowid = t2.rowid
   WHERE ISNULL(t1.CASEID,'') <> ''   
   --ORDER BY pickslipno,loadkey,orderkey,loc    
  -- ORDER BY t2.rowid, loc         --WL02    
   ORDER BY t2.rowid, t1.LogicalLoc --WL02    
   --WL01 End      
          
   DROP Table #TEMP_PICK96     
QUIT_SP: --WL01     
END    
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

GRANT EXECUTE ON isp_GetPickSlipOrders96 TO NSQL
GO

