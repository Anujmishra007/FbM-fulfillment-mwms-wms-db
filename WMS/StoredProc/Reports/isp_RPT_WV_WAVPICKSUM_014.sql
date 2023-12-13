      
/***************************************************************************/          
/* Stored Procedure: isp_RPT_WV_WAVPICKSUM_014                             */          
/* Creation Date: 19-SEP-2023                                              */          
/* Copyright: Maersk                                                       */          
/* Written by: CSCHONG                                                     */          
/*                                                                         */          
/* Purpose: WMS-23714                                                      */          
/*                                                                         */          
/* Called By: RPT_WV_WAVPICKSUM_014                                        */          
/*                                                                         */          
/* GitLab Version: 1.0                                                     */          
/*                                                                         */          
/* Version: 1.0                                                            */          
/*                                                                         */          
/* Data Modifications:                                                     */          
/*                                                                         */          
/* Updates:                                                                */          
/* Date            Author   Ver  Purposes                                  */      
/* 19-SEP-2023     CSCHONG  1.0  DevOps Combine Script                     */       
/* 03-NOV-2023     CSCHONG  1.1  WMS-23966 add reportcfg (CS01)            */  
/* 29-NOV-2023     CSCHONG  1.2  WMS-23966 fix pagenumber issue (CS02)     */  
/***************************************************************************/                    
                    
CREATE OR ALTER  PROC [dbo].[isp_RPT_WV_WAVPICKSUM_014]                               
  --    @c_Wavekey        NVARCHAR(10)    
  --   ,@c_loadkey        NVARCHAR(20)   
     @c_orderkey        NVARCHAR(20)      
  --  ,@c_putawayzone     NVARCHAR(10)
                                       
AS                                
BEGIN                                
   SET NOCOUNT ON         
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF                        
                         
        
DECLARE  @c_pickheaderkey      NVARCHAR(10),      
         @n_continue           INT,      
         @c_errmsg             NVARCHAR(255),      
         @b_success            INT,      
         @n_err                INT,      
         @c_sku                NVARCHAR(20),      
         @n_qty                INT,      
         @c_loc                NVARCHAR(10),      
         @n_cases              INT,      
         @n_perpallet          INT,      
         @c_storer             NVARCHAR(15),      
       --  @c_orderkey           NVARCHAR(10),      
         @c_ConsigneeKey       NVARCHAR(15),      
         @c_Company            NVARCHAR(45),      
         @c_Addr1              NVARCHAR(45),      
         @c_Addr2              NVARCHAR(45),      
         @c_Addr3              NVARCHAR(45),      
         @c_PostCode           NVARCHAR(15),      
         @c_Route              NVARCHAR(10),      
         @c_Route_Desc         NVARCHAR(60), -- RouteMaster.Desc      
         @c_TrfRoom            NVARCHAR(5),  -- LoadPlan.TrfRoom      
         @c_Notes1             NVARCHAR(200),      
         @c_Notes2             NVARCHAR(200),      
         @c_SkuDesc            NVARCHAR(60),      
         @n_CaseCnt            INT,      
         @n_PalletCnt          INT,      
         @c_ReceiptTm          NVARCHAR(20),      
         @c_PrintedFlag        NVARCHAR(1),      
         @c_UOM                NVARCHAR(10),      
         @n_UOM3               INT,      
         @c_Lot                NVARCHAR(10),      
         @c_StorerKey          NVARCHAR(15),      
         @c_Zone               NVARCHAR(1),      
         @n_PgGroup            INT,      
         @n_TotCases           INT,      
         @n_RowNo              INT,    
         @c_PrevSKU            NVARCHAR(20),      
         @n_SKUCount           INT,      
         @c_Carrierkey         NVARCHAR(60),      
         @c_VehicleNo          NVARCHAR(10),      
         @c_firstorderkey      NVARCHAR(10),      
         @c_superorderflag     NVARCHAR(1),      
         @c_firsttime          NVARCHAR(1),      
         @c_logicalloc         NVARCHAR(18),      
         @c_Lottable01         NVARCHAR(18),      
         @c_Lottable02         NVARCHAR(18),      
         @c_Lottable03         NVARCHAR(18),      
         @d_Lottable04         DATETIME,      
         @d_Lottable05         DATETIME,      
         @n_packpallet         INT,      
         @n_packcasecnt        INT,      
         @c_externorderkey     NVARCHAR(30),      
         @n_pickslips_required INT,      
         @dt_deliverydate      DATETIME,      
         @c_buyerpo            NVARCHAR(20),          
         @c_SHOWBUYERPO        NVARCHAR(5) ,      
         @c_PickSlipNo         NVARCHAR(10),      
         @c_PreGenRptData      NVARCHAR(10) = ''          
      
DECLARE @c_PrevOrderKey NVARCHAR(10),      
         @n_Pallets     INT,      
         @n_Cartons     INT,      
         @n_Eaches      INT,      
         @n_UOMQty      INT,      
         @c_InvoiceNo   NVARCHAR(10) ,  
         @c_PgGroup     INT,      
         @n_TTLPage     INT = 1    
         , @n_NoOfLine               INT                
         , @n_RowNum                 INT               
         , @n_initialflag            INT = 1        
         , @n_ctnord                 INT = 1        
         , @c_ChgGrp                 NVARCHAR(1) = 'N'      
         , @n_maxRec                 INT    
        -- , @c_loadkey                NVARCHAR(20)      --CS02    
         , @c_PrevLoadKey            NVARCHAR(10)      --CS02      
         , @c_Putawayzone            NVARCHAR(10)      --CS02
         , @c_prevPutawayzone        NVARCHAR(10)      --CS02    
         , @c_UpdGrp                 NVARCHAR(1) = 'N' --CS02       
         , @c_UpdPage                NVARCHAR(1) = 'N' --CS02
         , @n_CurrPageGrp            INT               --CS02
         , @n_CtnCurrGrp             INT               --CS02     
         , @n_ctnputawayzone         INT               --CS02   
         , @c_lastLine               NVARCHAR(1)       --CS02
         --CS01b S
          ,@n_lineno       INT   --to make sure line no exceed nooflne
          ,@n_ChkTTLPage   INT   --to check current total page
          ,@n_FinalTTLPage INT  --to check final total page
          ,@n_PageRecGrp   INT  -- curent 
          ,@n_NewPageNo    INT
          ,@n_GetPageno    INT
          ,@c_resetline    NVARCHAR(1) ='N'
          ,@c_resetPageGrp    NVARCHAR(1) ='N'
          ,@n_prepggrp     INT     = 1
          ,@n_TTLRec       INT     = 0     
          ,@c_lastRec      NVARCHAR(1) = 'N'
          ,@n_pageno       INT
         --CS01b E 
  
  
   IF @c_PreGenRptData = '0' SET @c_PreGenRptData = ''      
      
 DECLARE   @c_DataWindow    NVARCHAR(60) = 'RPT_WV_WAVPICKSUM_014'          
         , @c_RetVal        NVARCHAR(255)        
         , @c_GeStorerkey   NVARCHAR(15) = ''      
         , @c_Type          NVARCHAR(1) = '1'        
      
  
SET @n_NoOfLine = 4   
     
   SELECT TOP 1 @c_GeStorerkey = Storerkey      
   FROM ORDERS (NOLOCK)         
  -- WHERE Userdefine09 = @c_Wavekey      
   WHERE orderkey = @c_orderkey
      
      
 IF ISNULL(@c_GeStorerkey,'') <> ''          
   BEGIN          
          
         EXEC [dbo].[isp_GetCompanyInfo]          
                  @c_Storerkey  = @c_storerkey          
               ,  @c_Type       = @c_Type          
               ,  @c_DataWindow = @c_DataWindow          
               ,  @c_RetVal     = @c_RetVal           OUTPUT          
           
   END          
      
      
      
DECLARE @n_starttcnt INT      
      
SELECT @n_starttcnt = @@TRANCOUNT      
SELECT @n_pickslips_required = 0   
      
WHILE @@TRANCOUNT > 0      
BEGIN      
   COMMIT TRAN      
END      
      
--BEGIN TRAN      
   CREATE TABLE #temp_pickdet      
      (     PickSlipNo     NVARCHAR(10)   NULL                                 
         ,  LoadKey        NVARCHAR(10)                                      
         ,  OrderKey       NVARCHAR(10)                                      
         ,  ConsigneeKey   NVARCHAR(15)                                      
         ,  Company        NVARCHAR(45)                                      
         ,  Addr1          NVARCHAR(45)   NULL                                 
         ,  Addr2          NVARCHAR(45)   NULL                                 
         ,  Addr3          NVARCHAR(45)   NULL                                 
         ,  PostCode       NVARCHAR(15)   NULL                                 
         ,  Route          NVARCHAR(10)   NULL                                 
         ,  Route_Desc     NVARCHAR(60)   NULL  -- RouteMaster.Desc            
         ,  TrfRoom        NVARCHAR(5)    NULL  -- LoadPlan.TrfRoom            
         ,  Notes1         NVARCHAR(200)  NULL                                 
         ,  Notes2         NVARCHAR(200)  NULL                                 
         ,  LOC            NVARCHAR(10)   NULL                                 
         ,  SKU     NVARCHAR(20)                                      
         ,  SkuDesc        NVARCHAR(60)                                      
         ,  Qty            INT                                               
         ,  TempQty1       INT                                               
         ,  TempQty2       INT                                               
         ,  PrintedFlag    NVARCHAR(1)    NULL                                 
         ,  Zone           NVARCHAR(1)                                       
         ,  PgGroup        INT                                               
         ,  RowNum         INT                                               
         ,  Lot            NVARCHAR(10)                                      
         ,  Carrierkey     NVARCHAR(60)   NULL                                 
         ,  VehicleNo      NVARCHAR(10)   NULL                                 
         ,  Lottable01     NVARCHAR(18)   NULL                                 
         ,  Lottable02     NVARCHAR(18)   NULL                   
         ,  Lottable03     NVARCHAR(18)   NULL                                 
         ,  Lottable04     DATETIME       NULL                                 
         ,  Lottable05     DATETIME       NULL                                 
         ,  packpallet     INT                                               
         ,  packcasecnt    INT                                               
         ,  externorderkey NVARCHAR(50)   NULL                                 
         ,  LogicalLoc     NVARCHAR(18)   NULL                                 
         ,  DeliveryDate   DATETIME       NULL                                 
         ,  Uom            NVARCHAR(10)                                      
         ,  InvoiceNo      NVARCHAR(10)   NULL                                 
         ,  Ovas           CHAR(30)       NULL                                 
         ,  Putawayzone    NVARCHAR(10)   NULL         
         ,  Storerkey      NVARCHAR(15)   NULL                                 
         ,  PickByCase     INT            NULL               
         ,  SysQty         INT           
         ,  ORDGRP         NVARCHAR(20)   NULL      
         ,  LOTT12         NVARCHAR(30)   NULL      
         ,  LOTLot12       NVARCHAR(30)   NULL      
         ,  BatchNo        NVARCHAR(60)   NULL      
         ,  BatchNo2       NVARCHAR(60)   NULL      
         ,  SerialNo       NVARCHAR(60)   NULL       
         ,  SerialNo2      NVARCHAR(60)   NULL      
         ,  PackUOM1       NVARCHAR(20)   NULL      
         ,  PackUOM2       NVARCHAR(20)   NULL      
         ,  PackUOM3       NVARCHAR(20)   NULL       
         ,  PInnerPack     FLOAT         
         ,  PUOM3Qty       INT      
         ,  buyerpo        NVARCHAR(20)   NULL          
         ,  SHOWBUYERPO    NVARCHAR(5)    NULL         
         ,  SHOWFIELD      NVARCHAR(5)    NULL           
         ,  wavekey        NVARCHAR(20)   NULL  
         ,  TTLPAGE        INT         
         ,  ShowPageNo     NVARCHAR(1)   
         ,  PageNo         INT                       --CS01b     
         ,  NewPageNo      INT                       --CS01b
         )      
      
    
   -- Use Zone as a UOM Picked 1 - Pallet, 2 - Case, 6 - Each, 8 - By Order      
   IF EXISTS ( SELECT 1      
               FROM PickHeader (NOLOCK)      
               JOIN Orders (NOLOCK) ON PickHeader.ExternOrderKey = Orders.Loadkey AND PickHeader.Orderkey = Orders.Orderkey    
               WHERE orders.orderkey = @c_orderkey--Orders.UserDefine09 = @c_Wavekey      
               AND Zone = '3' AND DATEADD(MINUTE,1,PickHeader.adddate) < GETDATE())    --CS02a    
   BEGIN      
      SELECT @c_firsttime = 'N'      
      SELECT @c_PrintedFlag = 'Y'      
   END      
   ELSE      
   BEGIN      
      SELECT @c_firsttime = 'Y'      
      SELECT @c_PrintedFlag = 'N'      
      
      IF @c_PreGenRptData=''      
      BEGIN      
          SET @c_PreGenRptData='Y'      
      END      
      
   END -- Record Not Exists      
      
   INSERT INTO #temp_pickdet     
         (  PickSlipNo      
         ,  LoadKey      
         ,  OrderKey      
         ,  Storerkey      
         ,  ConsigneeKey      
         ,  Company    
         ,  Addr1      
         ,  Addr2      
         ,  PgGroup      
         ,  Addr3      
         ,  PostCode      
         ,  Route      
         ,  Route_Desc      
         ,  TrfRoom      
         ,  Notes1      
         ,  RowNum      
         ,  Notes2      
         ,  LOC      
         ,  SKU      
         ,  SkuDesc      
         ,  Qty      
         ,  TempQty1      
         ,  TempQty2      
         ,  PrintedFlag      
         ,  Zone      
         ,  Lot      
         ,  CarrierKey      
         ,  VehicleNo      
         ,  Lottable01      
         ,  Lottable02      
         ,  Lottable03      
         ,  Lottable04      
         ,  Lottable05      
         ,  packpallet      
         ,  packcasecnt      
         ,  externorderkey               
         ,  LogicalLoc      
         ,  DeliveryDate      
         ,  UOM      
         ,  InvoiceNo      
         ,  Ovas      
         ,  Putawayzone      
         ,  SysQty      
         ,  ORDGRP,LOTT12,LOTLot12,BatchNo,BatchNo2,SerialNo,SerialNo2      
         ,  PackUOM1,PackUOM2,PackUOM3,PInnerPack,PUOM3Qty      
         ,  buyerpo           
         ,  SHOWBUYERPO      
         ,  SHOWFIELD    
         ,  wavekey , TTLPAGE,ShowPageNo,PageNo,NewPageNo,PickByCase                --CS01      --CS02  --CS01b
         )      
   SELECT PICKHEADER.PickHeaderkey      AS Pickslipno       
         ,ORDERS.Loadkey                              AS LoadKey       
         ,PICKDETAIL.OrderKey      
         ,ORDERS.Storerkey                            AS Storerkey      
         ,ISNULL(RTRIM(ORDERS.BillToKey), '')         AS ConsigneeKey      
         ,ISNULL(RTRIM(ORDERS.c_Company), '')         AS Company      
         ,ISNULL(RTRIM(ORDERS.C_Address1), '')        AS Addr1      
         ,ISNULL(RTRIM(ORDERS.C_Address2), '')        AS Addr2      
         ,0                                           AS PgGroup      
         ,ISNULL(RTRIM(ORDERS.C_Address3), '')        AS Addr3      
         ,ISNULL(RTRIM(ORDERS.C_Zip), '')             AS PostCode      
         ,ISNULL(RTRIM(ORDERS.Route), '')             AS Route      
         ,ISNULL(RTRIM(ROUTEMASTER.Descr), '')        AS  Route_Desc      
         ,ISNULL(RTRIM(ORDERS.Door), '')              AS TrfRoom      
         ,CONVERT(NVARCHAR(200), ISNULL(RTRIM(ORDERS.Notes), ''))    AS Notes1      
         , (ROW_NUMBER() OVER (PARTITION BY Orders.UserDefine09,ORDERS.Loadkey,PICKDETAIL.OrderKey   ORDER BY   
                      Orders.UserDefine09,ORDERS.Loadkey,PICKDETAIL.OrderKey  ,ISNULL(RTRIM(LOC.Putawayzone),'') ,ISNULL(RTRIM(LOC.LogicalLocation), '')))      AS RowNo      
         ,CONVERT(NVARCHAR(200), ISNULL(RTRIM(ORDERS.Notes2), ''))   AS Notes2      
         ,ISNULL(RTRIM(PICKDETAIL.loc), '')           AS loc      
         ,ISNULL(RTRIM(PICKDETAIL.sku), '')           AS Sku      
         ,ISNULL(RTRIM(SKU.Descr), '')                AS SkuDesc      
         ,ISNULL(SUM(PICKDETAIL.qty),0)               AS Qty      
         ,CASE PICKDETAIL.UOM      
            WHEN '1' THEN PACK.Pallet      
            WHEN '2' THEN PACK.CaseCnt      
            WHEN '3' THEN PACK.InnerPack      
            ELSE 1      
          END                                         AS UOMQty      
         ,0                                           AS TempQty2      
     --CS02a S
         --,ISNULL(( SELECT DISTINCT      
         --          'Y'      
         --          FROM PickHeader (NOLOCK)      
         --          WHERE ExternOrderKey = ORDERS.Loadkey AND Orderkey = ORDERS.Orderkey    
         --          AND Zone = '3'      
         --        ), 'N')                              AS PrintedFlag  
         ,@c_PrintedFlag --CS02a E    
         ,'3'                                         AS Zone      
         ,ISNULL(RTRIM(PICKDETAIL.Lot),'')            AS Lot      
         ,''                                 AS CarrierKey      
         ,''                                          AS VehicleNo      
         ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable01),'')   AS Lottable01      
         ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable02),'')   AS Lottable02      
         ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable03),'')   AS Lottable03      
         ,LOTATTRIBUTE.Lottable04 AS Lottable04      
         ,ISNULL(LOTATTRIBUTE.Lottable05, '19000101') AS Lottable05      
         ,ISNULL(PACK.Pallet,0)                    AS Pallet      
         ,ISNULL(PACK.CaseCnt,0)                   AS CaseCnt      
         ,ISNULL(RTRIM(ORDERS.ExternOrderKey),'')  AS ExternOrderKey      
         ,ISNULL(RTRIM(LOC.LogicalLocation), '')   AS LogicalLocation      
         ,ISNULL(ORDERS.DeliveryDate, '19000101')  AS DeliveryDate      
         ,ISNULL(RTRIM(PACK.PackUOM3),'')          AS PackUOM3      
         ,ISNULL(RTRIM(ORDERS.InvoiceNo),'')       AS InvoiceNo      
         ,ISNULL(RTRIM(SKU.Ovas),'')               AS Ovas      
         ,ISNULL(RTRIM(LOC.Putawayzone),'')        AS Putawayzone      
         ,ISNULL(LOTxLOCxID.Qty,0)                 AS SysQty      
         ,ISNULL(ORDERS.Ordergroup,'')             AS ORDGRP      
         ,ISNULL(RTRIM(OD.Lottable12),'')   AS Lottable12      
         ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable12),'')   AS LOTLot12         
         ,(ISNULL(RTRIM(OD.Lottable08),'') +ISNULL(RTRIM(OD.Lottable09),'') ) AS BatchNo       
         ,(ISNULL(RTRIM(LOTATTRIBUTE.Lottable08),'') +ISNULL(RTRIM(LOTATTRIBUTE.Lottable09),'') ) AS BatchNo2         
         ,(ISNULL(RTRIM(OD.Lottable10),'') +ISNULL(RTRIM(OD.Lottable11),'') ) AS SerialNo      
         ,(ISNULL(RTRIM(LOTATTRIBUTE.Lottable10),'') +ISNULL(RTRIM(LOTATTRIBUTE.Lottable11),'') ) AS SerialNo2         
         ,PACK.PackUOM1 ,PACK.PackUOM2,PACK.PackUOM3,ISNULL(Pack.InnerPack,0),ISNULL(Pack.Qty,0)      
         ,ISNULL(ORDERS.buyerpo,'') AS buyerpo           
         ,ISNULL(CL.SHORT,'') AS SHOWBUYERPO      
         ,ISNULL(CL1.SHORT,'') AS SHOWFIELD      
         , Orders.UserDefine09 AS Wavekey  
         , 0  
         ,ISNULL(CL2.SHORT,'N') AS SHOWPAGENO                              --CS02  
         ,CAST(((ROW_NUMBER() OVER (PARTITION BY ORDERS.Loadkey,PICKDETAIL.OrderKey  
                                    ORDER BY ORDERS.Loadkey,PICKDETAIL.OrderKey  ,ISNULL(RTRIM(LOC.Putawayzone),'') ,
                                    ISNULL(RTRIM(LOC.LogicalLocation), ''))) -1) /@n_NoOfLine as int)+1 AS pageno    --CS01b
         ,0                   --CS01b
         ,ISNULL(CASE WHEN CL3.Code = 'PickByCase' THEN 1 ELSE 0 END,0)  AS PickByCase
         FROM LOADPLANDETAIL WITH (NOLOCK)      
         JOIN ORDERS        WITH (NOLOCK) ON ( ORDERS.Orderkey = LoadPlanDetail.Orderkey )      
         JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = ORDERS.orderkey      
         JOIN STORER        WITH (NOLOCK) ON ( ORDERS.StorerKey = Storer.StorerKey )   
         JOIN PICKHEADER   WITH (NOLOCK)  ON PickHeader.ExternOrderKey = Orders.Loadkey AND PICKHEADER.OrderKey = Orders.Orderkey     
         LEFT OUTER JOIN ROUTEMASTER WITH (NOLOCK) ON ( ROUTEMASTER.Route = ORDERS.Route )      
         JOIN PICKDETAIL    WITH (NOLOCK) ON ( PICKDETAIL.OrderKey = ORDERS.Orderkey AND PICKDETAIL.OrderLineNumber = OD.OrderLineNumber)      
         JOIN LOTATTRIBUTE  WITH (NOLOCK) ON ( PICKDETAIL.Lot = LOTATTRIBUTE.Lot )      
         JOIN SKU           WITH (NOLOCK) ON ( Sku.StorerKey = PICKDETAIL.StorerKey )      
                                          AND( Sku.Sku = PICKDETAIL.Sku )      
         JOIN PACK          WITH (NOLOCK) ON ( SKU.Packkey = PACK.Packkey )      
         JOIN LOC           WITH (NOLOCK) ON ( PICKDETAIL.LOC = LOC.LOC )      
         JOIN LOTxLOCxID    WITH (NOLOCK) ON ( PICKDETAIL.LOC = LOTxLOCxID.LOC AND PICKDETAIL.LOT = LOTxLOCxID.LOT AND PICKDETAIL.ID = LOTxLOCxID.ID )      
         LEFT JOIN CODELKUP CL WITH (NOLOCK) ON (CL.LISTNAME = 'REPORTCFG' AND CL.CODE = 'SHOWBUYERPO'         
                                             AND CL.LONG = 'RPT_WV_WAVPICKSUM_014' AND CL.STORERKEY = ORDERS.STORERKEY )      
         LEFT JOIN CODELKUP CL1 WITH (NOLOCK) ON (CL1.LISTNAME = 'REPORTCFG' AND CL1.CODE = 'SHOWFIELD'         
                                              AND CL1.LONG = 'RPT_WV_WAVPICKSUM_014' AND CL1.STORERKEY = ORDERS.STORERKEY )      
         --CS02 S  
         LEFT JOIN CODELKUP CL2 WITH (NOLOCK) ON (CL2.LISTNAME = 'REPORTCFG' AND CL2.CODE = 'NOTSHOWWAVEPAGE'         
                                              AND CL2.LONG = 'RPT_WV_WAVPICKSUM_014' AND CL2.STORERKEY = ORDERS.STORERKEY )   
         LEFT JOIN CODELKUP CL3 WITH (NOLOCK) ON ( CL3.ListName = 'REPORTCFG' )      
                                    AND( CL3.Storerkey= ORDERS.Storerkey )      
                                    AND( CL3.Long = 'RPT_LP_PLISTN_041')      
                                    AND( CL3.Short <> 'N' OR  CL3.Short IS NULL )  
         --CS02 E  
         WHERE PICKDETAIL.Status >= '0'        
        -- AND Orders.UserDefine09 = @c_Wavekey      
         AND Orders.orderkey = @c_orderkey
       --  AND Orders.loadkey = @c_loadkey 
      -- AND LOC.Putawayzone = @c_putawayzone
         GROUP BY PICKHEADER.PickHeaderkey,PICKDETAIL.OrderKey      
         ,ORDERS.Storerkey      
         ,ISNULL(RTRIM(ORDERS.BillToKey), '')      
         ,ISNULL(RTRIM(ORDERS.c_Company), '')      
         ,ISNULL(RTRIM(ORDERS.C_Address1), '')      
         ,ISNULL(RTRIM(ORDERS.C_Address2), '')      
         ,ISNULL(RTRIM(ORDERS.C_Address3), '')      
         ,ISNULL(RTRIM(ORDERS.C_Zip), '')      
         ,ISNULL(RTRIM(ORDERS.Route), '')      
         ,ISNULL(RTRIM(ROUTEMASTER.Descr), '')      
         ,ISNULL(RTRIM(ORDERS.Door), '')      
         ,CONVERT(NVARCHAR(200), ISNULL(RTRIM(ORDERS.Notes), ''))      
         ,CONVERT(NVARCHAR(200), ISNULL(RTRIM(ORDERS.Notes2), ''))      
         ,ISNULL(RTRIM(PICKDETAIL.loc), '')      
         ,ISNULL(RTRIM(PICKDETAIL.sku), '')      
         ,ISNULL(RTRIM(SKU.Descr), '')      
         ,CASE PICKDETAIL.UOM      
            WHEN '1' THEN PACK.Pallet      
            WHEN '2' THEN PACK.CaseCnt      
            WHEN '3' THEN PACK.InnerPack      
            ELSE 1      
          END      
         ,ISNULL(RTRIM(PICKDETAIL.Lot),'')      
         ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable01),'')      
         ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable02),'')      
         ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable03),'')      
         ,LOTATTRIBUTE.Lottable04      
         ,ISNULL(LOTATTRIBUTE.Lottable05, '19000101')      
         ,ISNULL(PACK.Pallet,0)      
         ,ISNULL(PACK.CaseCnt,0)      
         ,ISNULL(RTRIM(ORDERS.ExternOrderKey),'')      
         ,ISNULL(RTRIM(LOC.LogicalLocation), '')      
         ,ISNULL(ORDERS.DeliveryDate, '19000101')      
         ,ISNULL(RTRIM(PACK.PackUOM3),'')      
         ,ISNULL(RTRIM(ORDERS.InvoiceNo),'')      
         ,ISNULL(RTRIM(SKU.ovas),'')      
         ,ISNULL(RTRIM(LOC.Putawayzone),'')      
         ,ISNULL(LOTxLOCxID.Qty,0)      
         ,ISNULL(ORDERS.Ordergroup,'')                
         ,ISNULL(RTRIM(OD.Lottable12),'') ,ISNULL(RTRIM(OD.Lottable08),'')      
         ,ISNULL(RTRIM(OD.Lottable09),''),ISNULL(RTRIM(OD.Lottable10),''),ISNULL(RTRIM(OD.Lottable11),'')      
         ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable12),'') ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable08),'')        
         ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable09),''),ISNULL(RTRIM(LOTATTRIBUTE.Lottable10),''),ISNULL(RTRIM(LOTATTRIBUTE.Lottable11),'')        
         ,PACK.PackUOM1 ,PACK.PackUOM2,PACK.PackUOM3,ISNULL(Pack.InnerPack,0),ISNULL(Pack.Qty,0)       
         ,ISNULL(ORDERS.buyerpo,'')          
         ,ISNULL(CL.SHORT,'')               
         ,ISNULL(CL1.SHORT,'')       
         ,ORDERS.Loadkey --CCH    
         ,ORDERS.Orderkey --CCH    
         ,Orders.UserDefine09   --CS01  
         ,ISNULL(CL2.SHORT,'N')  --CS02  
         ,ISNULL(CASE WHEN CL3.Code = 'PickByCase' THEN 1 ELSE 0 END,0)  
       ORDER BY ORDERS.Loadkey,CASE WHEN ISNULL(RTRIM(ORDERS.c_Company), '')  <> '' THEN 1 ELSE 0 END,ORDERS.Orderkey,
                ISNULL(RTRIM(LOC.Putawayzone),''),ISNULL(RTRIM(LOC.LogicalLocation), '') ,ISNULL(RTRIM(PICKDETAIL.loc), '')      
         ,ISNULL(RTRIM(PICKDETAIL.sku), '') ,ISNULL(RTRIM(LOTATTRIBUTE.Lottable01),'') 

    --SELECT * FROM #temp_pick WHERE OrderKey='0006877126' AND Putawayzone='AC-RCKO-HI'

  
   --IF ISNULL(@c_PreGenRptData,'') IN ('','0')      --CS02 S
   --BEGIN      
--SELECT PickSlipNo      
--         , LoadKey      
--         , OrderKey      
--         , ConsigneeKey      
--         , Company     
--         , LOC 
--         , Putawayzone 
--         , PgGroup      
--         , RowNum       
--         , TTLPAGE  
--         , Addr1      
--         , Addr2      
--         , Addr3      
--         , PostCode      
--         , Route      
--         , Route_Desc      
--         , TrfRoom      
--         , Notes1      
--         , Notes2           
--         , SKU      
--         , SkuDesc      
--         , CASE WHEN PickByCase = 1 AND PackCaseCnt > 0 THEN (Qty % PackCaseCnt)      
--                          ELSE Qty END AS Qty      
--         , TempQty1      
--         , TempQty2      
--         , PrintedFlag      
--         , Zone      
        
--         , Lot      
--         , Carrierkey      
--         , VehicleNo      
--         , Lottable01      
--         , Lottable02      
--         , Lottable03      
--         , Lottable04      
--         , Lottable05      
--         , packpallet      
--         , packcasecnt      
--         , externorderkey      
--         , LogicalLoc      
--         , DeliveryDate      
--         , Uom      
--         , InvoiceNo      
--         , Ovas      
     
--         , PickByCase      
--         , CASE WHEN PickByCase = 1 AND PackCaseCnt > 0 THEN FLOOR(Qty / PackCaseCnt)      
--                          ELSE 0 END AS qtycase      
--         , Qty AS qtypicked      
--         , SysQty      
--         , ORDGRP,LOTT12,lotlOT12,BatchNo,BatchNo2,SerialNo,SerialNo2      
--         , PackUOM1 ,PackUOM2,PackUOM3,ISNULL(PInnerPack,0),ISNULL(PUOM3Qty,0)      
--         , buyerpo           
--         , SHOWBUYERPO       
--         , SHOWFIELD      
--         , ISNULL(@c_Retval,'') AS Logo      

--         , ShowPageNo         --CS02  
--         ,trim(substring( notes1,1,100)) +  
--           CASE WHEN len(notes1) > 100 THEN +CHAR(13)+CHAR(10) + substring(notes1,101,100) ELSE '' END +   
--          CASE WHEN len(notes2) > 0 THEN CHAR(13)+substring(notes2,1,100)ELSE '' END +   
--          CASE WHEN len(notes2) > 100 THEN CHAR(13)+substring(notes2,101,100) ELSE '' END AS OHNotes 
--   FROM #temp_pickdet      
--   ORDER BY loadkey,CASE WHEN Company <> '' THEN 1 ELSE 0 END,OrderKey,RowNum,PgGroup,Putawayzone,LogicalLoc,loc,sku,Lottable01
----CS02 E
   SELECT PickSlipNo      
         , LoadKey      
         , OrderKey      
         , ConsigneeKey      
         , Company      
         , Addr1      
         , Addr2      
         , Addr3      
         , PostCode      
         , Route      
         , Route_Desc      
         , TrfRoom      
         , Notes1      
         , Notes2      
         , LOC      
         , SKU      
         , SkuDesc      
         , CASE WHEN PickByCase = 1 AND PackCaseCnt > 0 THEN (Qty % PackCaseCnt)      
                          ELSE Qty END AS Qty      
         , TempQty1      
         , TempQty2      
         , PrintedFlag      
         , Zone      
      --   , PgGroup      
         ,ROW_NUMBER() OVER (PARTITION BY PickSlipNo  
                                     ORDER BY PickSlipNo,LoadKey,OrderKey)   /(@n_NoOfLine+1)+1 AS PgGroup 
         , RowNum      
         , Lot      
         , Carrierkey      
         , VehicleNo      
         , Lottable01      
         , Lottable02      
         , Lottable03      
         , Lottable04      
         , Lottable05      
         , packpallet      
         , packcasecnt      
         , externorderkey      
         , LogicalLoc      
         , DeliveryDate      
         , Uom      
         , InvoiceNo      
         , Ovas      
         , Putawayzone      
         , PickByCase      
         , CASE WHEN PickByCase = 1 AND PackCaseCnt > 0 THEN FLOOR(Qty / PackCaseCnt)      
                          ELSE 0 END AS qtycase      
         , Qty AS qtypicked      
         , SysQty      
         , ORDGRP,LOTT12,lotlOT12,BatchNo,BatchNo2,SerialNo,SerialNo2      
         , PackUOM1 ,PackUOM2,PackUOM3,ISNULL(PInnerPack,0) ,ISNULL(PUOM3Qty,0)     
         , buyerpo           
         , SHOWBUYERPO       
         , SHOWFIELD      
         , ISNULL(@c_Retval,'') AS Logo      
         , TTLPAGE  
         , ShowPageNo         --CS02  
         ,trim(substring( notes1,1,100)) +  
           CASE WHEN len(notes1) > 100 THEN +CHAR(13)+CHAR(10) + substring(notes1,101,100) ELSE '' END +   
          CASE WHEN len(notes2) > 0 THEN CHAR(13)+substring(notes2,1,100)ELSE '' END +   
          CASE WHEN len(notes2) > 100 THEN CHAR(13)+substring(notes2,101,100) ELSE '' END AS OHNotes 
,recgrp = ROW_NUMBER() OVER (PARTITION BY PickSlipNo
                                      ORDER BY PickSlipNo,LoadKey,OrderKey)   /@n_NoOfLine+1
   FROM #temp_pickdet    
   ORDER BY loadkey,CASE WHEN Company <> '' THEN 1 ELSE 0 END,OrderKey,RowNum,PgGroup,Putawayzone,LogicalLoc,loc,sku,Lottable01
   --END      
      
   IF OBJECT_ID('tempdb..#temp_pickdet') IS NOT NULL      
      DROP TABLE #temp_pickdet        
           
  
   WHILE @@TRANCOUNT < @n_starttcnt          
   BEGIN          
      BEGIN TRAN          
   END       
END   
GO
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVPICKSUM_014] TO NSQL
GO  
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVPICKSUM_014] TO LogiReportRoleWM 
GO