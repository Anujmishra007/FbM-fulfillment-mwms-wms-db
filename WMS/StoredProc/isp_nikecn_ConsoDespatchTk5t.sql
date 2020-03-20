IF (OBJECTPROPERTY(OBJECT_ID('dbo.isp_nikecn_ConsoDespatchTkt5'), 'ISPROCEDURE') IS NOT NULL)
   DROP PROCEDURE dbo.isp_nikecn_ConsoDespatchTkt5
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/      
/* Stored Procedure: isp_nikecn_ConsoDespatchTkt5                       */      
/* Creation Date: 10-SEP-2013                                           */      
/* Copyright: LF                                                        */      
/* Written by:                                                          */      
/*                                                                      */      
/* Purpose: 288194-NIKE CN NIKE CRW Carton Label                        */      
/*                                                                      */      
/* Called By: r_dw_despatch_ticket_nikecn5                              */      
/*            modified from isp_nikecn_ConsoDespatchTkt                 */      
/*                          r_dw_despatch_ticket_nikecn3                */      
/* PVCS Version: 2.1                                                    */      
/*                                                                      */      
/* Version: 5.4                                                         */      
/*                                                                      */      
/* Data Modifications:                                                  */      
/*                                                                      */      
/* Updates:                                                             */      
/* Date         Author  Ver   Purposes                                  */      
/* 16-MAR-2015  CSCHONG 1.0   Change the logic to get the extorder(CS01)*/      
/* 14-JAN-2016  CSCHONG 1.1   SOS#360542  (CS02)                        */      
/* 31-MAY-2016  SPChin  1.2   TS00048233 - Bug Fixed                    */      
/* 29-Aug-2016  NJOW01  1.3   376073-Show extra info on label           */      
/* 23-Sep-2017  Wan04   1.4   WMS-942 - CN Nike CRW Carton Label CR     */      
/* 12-Apr-2017  CSCHONG 1.5   WMS-1604 - Change field mapping (CS03)    */      
/* 31-Dec-2017  JHTAN   1.6   Request to show only 10 char LabelNo(JH01)*/       
/* 15-JAN-2018  CSCHONG 1.7   WMS-3744-revised report logic (CS04)      */      
/* 10-APR-2018  JyhBin  1.7 Allow to print blank refno                  */      
/* 11-APR-2018  CSCHONG 1.8   WMS-4474 - add new field (CS05)           */      
/* 17-MAY-2018  CSCHONG 1.9   Fix cartonno >10 issue (CS06)             */      
/* 27-JUL-2018  CSCHONG 2.0   Scripts tunning (CS07)                    */      
/* 23-AUG-2018  CSCHONG 2.1   Performance tunning (CS08)                */      
/* 27-SEP-2018  CSCHONG 2.2   script tunning (CS09)                     */      
/* 29-OCT-2018  CSCHONG 2.3   Performance tunning (CS10)                */      
/* 15-NOV-2018  WLCHOOI 2.4   Change input parameters, add new          */    
/*                            logic(WL01)                               */  
/* 28-Jan-2019  TLTING_ext 1.5 enlarge externorderkey field length      */    
/************************************************************************/      
      
CREATE PROC [dbo].[isp_nikecn_ConsoDespatchTkt5]      
   --@c_pickslipno     NVARCHAR(10),        
   --@n_StartCartonNo  INT = 0,        
   --@n_EndCartonNo    INT = 0,        
   --@c_StartLabelNo   NVARCHAR(20) = '',        
   --@c_EndLabelNo     NVARCHAR(20) = '',        
   --@c_RefNo          NVARCHAR(20) = ''          --(CS04)        
    
   --WL01 START    
   @c_Wavekey   NVARCHAR(20),    
   @c_IntVechicle  NVARCHAR(60)='',    
   @c_VAS    NVARCHAR(250)='',    
   @c_PickZone   NVARCHAR(20)='',    
   @c_CaseID   NVARCHAR(20)=''    
   --WL01 END        
AS      
BEGIN      
      
   SET NOCOUNT ON      
   SET ANSI_NULLS OFF      
   SET QUOTED_IDENTIFIER OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF      
      
   DECLARE @c_externOrderkey            NVARCHAR(50)     --tlting_ext  
          ,@c_LoadKey                   NVARCHAR(10)      
          ,@i_ExtCnt                    INT      
          ,@i_LineCnt                   INT      
          ,@SQL                         NVARCHAR(1000)      
          ,@nMaxCartonNo                INT      
          ,@nCartonNo                   INT      
          ,@nSumPackQty                 INT      
          ,@nSumPickQty                 INT      
          ,@c_ConsigneeKey NVARCHAR(15)--SOS# 174296      
          ,@c_Company                   NVARCHAR(45)      
          ,@c_Address1                  NVARCHAR(45)      
          ,@c_Address2                  NVARCHAR(45)      
          ,@c_Address3                  NVARCHAR(45)      
          ,@c_City                      NVARCHAR(45)      
          ,@d_DeliveryDate              DATETIME      
          ,@c_Orderkey                  NVARCHAR(10) --NJOW01      
          ,@c_Storerkey                 NVARCHAR(15) --(Wan01)      
          ,@c_ShowQty_Cfg               NVARCHAR(10) --(Wan01)      
          ,@c_ShowOrdType_Cfg           NVARCHAR(10) --(Wan02)      
          ,@c_susr4                     NVARCHAR(10) --(Wan03)      
          ,@c_Stop                      NVARCHAR(10)      
          ,@c_showfield                 NVARCHAR(1) --(CS02)      
          ,@c_showCRD                   NVARCHAR(1) --(CS02)      
          ,@c_ShippingFilterByRefNo     NVARCHAR(20) --(CS04)      
          ,@nRowRef                     INT --(CS04)      
          ,@nExcludeCarton              INT --(CS04)      
          ,@n_GetCartonNo               INT --(CS04)      
          ,@n_cntRefno                  INT --(CS05)      
          ,@c_GetPSlipno                NVARCHAR(20) --(CS05)      
          ,@c_GetRefno                  NVARCHAR(20) --(CS05)      
          ,@c_site                      NVARCHAR(30) --(CS05)      
          ,@n_GetMaxCarton              INT --(CS05)        
    ,@c_facility                  NVARCHAR(10) --(CS08)      
    ,@c_Pickslipno    NVARCHAR(20)    
 --   ,@n_StartCartonNo  INT = 0     
 --   ,@n_EndCartonNo    INT = 0     
    ,@c_StartLabelNo   NVARCHAR(20) = ''      
    ,@c_EndLabelNo     NVARCHAR(20) = ''      
    ,@c_RefNo          NVARCHAR(20) = ''    
    ,@c_showcartontype NVARCHAR(1)   = 'N' --WL01    
    ,@c_Discrete NVARCHAR(1)--WL01    
    ,@c_Conso NVARCHAR(1)--WL01    
    ,@c_sku NVARCHAR(40)--WL01    
    ,@c_OrdOrdKey NVARCHAR(10) --WL01    
    
   SET @c_Storerkey = ''                     
   SET @c_ShowQty_Cfg = ''                   
   SET @c_ShowOrdType_Cfg = ''               
   SET @c_susr4 = ''                         
   SET @c_showfield = 'N'                    
   SET @c_showCRD = ''                       
   SET @c_ShippingFilterByRefNo = ''         
   SET @nExcludeCarton = 1        
   SET @c_Discrete = ''    
   SET @c_Conso = ''     
      
   --SELECT @c_Orderkey = Orderkey       
   --      ,@c_Storerkey     = ISNULL(RTRIM(Storerkey) ,'')      
   --FROM   PACKHEADER(NOLOCK)      
   --WHERE  Pickslipno       = @c_Pickslipno     
       
   --WL01 START    
   SELECT @c_Storerkey = ISNULL(RTRIM(Orders.Storerkey) ,'')       
   from WAVEDETAIL (nolock)    
   JOIN Orders (nolock) on Orders.Orderkey = WAVEDETAIL.Orderkey    
   where WAVEDETAIL.Wavekey = @c_wavekey    
     
  CREATE TABLE #TMPPICKSLIPNO(    
 wavekey NVARCHAR(20)    
   ,pickslipno NVARCHAR(20)    
   ,orderkey NVARCHAR(10)    
   ,LoadKey NVARCHAR(10)    
   ,Discrete NVARCHAR(10)    
   ,Conso NVARCHAR(10)    
   ,OrdOrdKey NVARCHAR(10)    
   ,SKU NVARCHAR(20)    
   ,VAS NVARCHAR(1)    
   )    
    
   INSERT INTO #TMPPICKSLIPNO(wavekey,pickslipno,ORDERKEY,LoadKey,Discrete,Conso,OrdOrdKey,SKU,vas)    
   SELECT DISTINCT WAVEDETAIL.wavekey,Pickheader.Pickheaderkey,PACKHEADER.ORDERKEY,PackHeader.LoadKey    
    ,CASE WHEN ISNULL(PACKHEADER.ORDERKEY,'') <> '' AND ISNULL(PackHeader.LoadKey,'') <> '' --check discrete    
     THEN 'Y' ELSE 'N' END    
    ,CASE WHEN ISNULL(PACKHEADER.ORDERKEY,'') = '' AND ISNULL(PackHeader.LoadKey,'') <> '' --check conso    
     THEN 'Y' ELSE 'N' END    
    ,Orders.Orderkey    
    --,CASE WHEN ISNULL(OrderDetailRef.Orderkey, '') = '' AND ISNULL(OrderDetailRef.Orderkey, '') = ''THEN 'N' ELSE 'Y' END    
    ,PACKDETAIL.SKU    
    ,'N'    
   FROM Pickheader (NOLOCK)     
   JOIN orders (NOLOCK) on (orders.loadkey = pickheader.externorderkey)    
   JOIN wavedetail (NOLOCK) on (wavedetail.orderkey = orders.orderkey)    
   JOIN PACKHEADER (NOLOCK) ON (Pickheader.Pickheaderkey = PACKHEADER.PICKSLIPNO)    
   JOIN PACKDETAIL (NOLOCK) ON (PACKDETAIL.PICKSLIPNO = PACKHEADER.PICKSLIPNO)    
   LEFT JOIN PICKDETAIL (NOLOCK) ON PICKDETAIL.orderkey = ORDERS.OrderKey      
   LEFT JOIN LOC WITH (NOLOCK) ON LOC.loc=PICKDETAIL.Loc      
--   LEFT JOIN ORDERDETAILREF (NOLOCK) ON (ORDERDETAILREF.ORDERKEY = ORDERS.ORDERKEY) AND ORDERDETAILREF.SKU = ORDERS.SKU    
   WHERE  wavedetail.wavekey = @c_Wavekey AND ORDERS.INTERMODALVEHICLE = @c_IntVechicle     
   AND LOC.PICKZONE = @c_PickZone  AND Pickdetail.CaseID = CASE WHEN @c_caseid <> '' THEN @c_caseid ELSE Pickdetail.CaseID END--WL01    
    
   DECLARE cur_vas CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
 SELECT pickslipno,OrdOrdKey,sku FROM #TMPPICKSLIPNO    
 OPEN cur_vas    
       
   FETCH FROM cur_vas INTO @c_pickslipno,@c_orderkey,@c_sku     
   WHILE @@FETCH_STATUS = 0    
   BEGIN     
  IF EXISTS( SELECT 1 FROM ORDERDETAILREF (NOLOCK) WHERE ORDERKEY = @c_orderkey AND PARENTSKU = @c_sku)    
  BEGIN    
   UPDATE #TMPPICKSLIPNO    
   SET VAS = 'Y'    
   WHERE PICKSLIPNO = @c_pickslipno AND OrdOrdKey = @c_orderkey AND SKU = @c_sku    
  END    
  FETCH FROM cur_vas INTO @c_pickslipno,@c_orderkey,@c_sku     
   END    
   CLOSE cur_vas    
   DEALLOCATE cur_vas    
    
 IF(@c_vas = 'Y')    
 DELETE FROM #TMPPICKSLIPNO WHERE VAS = 'N'    
    
 IF(@c_vas = 'N')    
 DELETE FROM #TMPPICKSLIPNO WHERE VAS = 'Y'    
      
 -- SELECT * FROM #TMPPICKSLIPNO    
  --WL01 END    
    
   SELECT @c_ShowQty_Cfg = ISNULL(RTRIM(SValue) ,'')      
   FROM   STORERCONFIG WITH (NOLOCK)      
   WHERE  Storerkey         = @c_Storerkey      
          AND Configkey     = 'DPTkt_NKCN3_CTNQty'      
      
   SELECT @c_ShowOrdType_Cfg = ISNULL(RTRIM(SValue) ,'')      
   FROM   STORERCONFIG WITH (NOLOCK)      
   WHERE  Storerkey         = @c_Storerkey      
          AND Configkey     = 'DPTkt_NKCN3_ORDType'      
      
   SELECT @c_susr4 = ISNULL(RTRIM(SUSR4) ,'')      
   FROM   STORER WITH (NOLOCK)      
   WHERE  Storerkey = @c_Storerkey      
      
   SELECT @c_showField = CASE WHEN ISNULL(CLR.Code,'') <> '' THEN 'Y' ELSE 'N' END      
   FROM Codelkup CLR (NOLOCK)      
   WHERE CLR.Storerkey = @c_Storerkey      
   AND CLR.Code = 'SHOWFIELD'      
   AND CLR.Listname = 'REPORTCFG'      
   AND CLR.Long = 'r_dw_despatch_ticket_nikecn5' AND ISNULL(CLR.Short,'') <> 'N'      
         
   SELECT @c_ShippingFilterByRefNo = Code2      
   FROM dbo.CODELKUP (NOLOCK)       
   WHERE Listname = 'REPORTCFG'      
   AND code = 'ShippingFilterByRefNo'      
   AND Storerkey = @c_Storerkey      
        
 --WL01     
   SELECT @c_showcartontype = CASE WHEN ISNULL(CLR1.Short,'') <> '' THEN 'Y' ELSE 'N' END      
   FROM Codelkup CLR1 (NOLOCK)      
   WHERE CLR1.Storerkey = @c_storerkey    
   AND CLR1.Code = 'showcartontype'      
   AND CLR1.Listname = 'REPORTCFG'      
   AND CLR1.Long = 'r_dw_despatch_ticket_nikecn5' AND ISNULL(CLR1.Short,'') <> 'N'     
    
   --NJOW01      
   CREATE TABLE #RESULT      
   (      
    ROWREF             INT NOT NULL IDENTITY(1 ,1) PRIMARY KEY      
   ,Wavekey     NVARCHAR(10) NULL    
      ,PickSlipNo         NVARCHAR(10) NULL      
      ,LoadKey            NVARCHAR(10) NULL      
      ,ROUTE              NVARCHAR(10) NULL      
      ,ConsigneeKey       NVARCHAR(15) NULL      
      ,DeliveryDate       DATETIME NULL      
      ,C_Company          NVARCHAR(45) NULL      
      ,C_Address1         NVARCHAR(45) NULL      
      ,C_Address2         NVARCHAR(45) NULL      
      ,C_Address3         NVARCHAR(45) NULL      
      ,C_City             NVARCHAR(45) NULL      
      ,xDockLane          NVARCHAR(10) NULL      
      ,LabelNo            NVARCHAR(20) NULL      
      ,CartonNo           INT NULL      
      ,ExtOrder1          NVARCHAR(80) NULL      
      ,ExtOrder2          NVARCHAR(80) NULL      
      ,ExtOrder3          NVARCHAR(80) NULL      
      ,ExtOrder4          NVARCHAR(80) NULL      
      ,ExtOrder5          NVARCHAR(80) NULL      
      ,ExtOrder6          NVARCHAR(80) NULL      
      ,ExtOrder7          NVARCHAR(80) NULL      
      ,ExtOrder8          NVARCHAR(80) NULL      
      ,ExtOrder9          NVARCHAR(80) NULL      
      ,ExtOrder10         NVARCHAR(80) NULL      
      ,TotalSku           INT NULL      
      ,TotalPcs           INT NULL      
      ,MaxCarton          NVARCHAR(10) NULL      
      ,ShowQtyCfg         NVARCHAR(10) NULL --(Wan01)      
      ,OrderType          NVARCHAR(10) NULL --(Wan02)      
      ,SUSR4              NVARCHAR(20) NULL --(Wan03)      
      ,STOP               NVARCHAR(10) NULL      
      ,ShowField          NVARCHAR(1) NULL --(CS02)      
      ,ShowCRD            NVARCHAR(1) NULL --(CS02)      
      ,CRD                NVARCHAR(10) NULL --(CS02)      
      ,ExtraInfo          NVARCHAR(20) NULL --NJOW01      
      ,TotalQtyPacked     INT NULL --(Wan04)      
      ,RefNo              NVARCHAR(20) NULL --(CS04)      
      ,RefNo2             NVARCHAR(30) NULL --(CS04)      
      ,SITELoadkey        NVARCHAR(30) NULL --(CS05)    
   ,UserDefine10    NVARCHAR(20) NULL--WL01    
   ,ShowCartonType   NVARCHAR(1) NULL--WL01    
   ,CartonType    NVARCHAR(20) NULL--WL01    
   )      
      
   CREATE INDEX IX_RESULT_01 on #RESULT ( LoadKey )      
   CREATE INDEX IX_RESULT_02 on #RESULT ( CartonNo )      
         
   /*CS04 Start*/      
   CREATE TABLE #CTNRESULT (    
   Wavekey  NVARCHAR(10) NULL,      
      PickSlipNo NVARCHAR(10) NULL,      
      RefNo      NVARCHAR(20) NULL,              
      RefNo2     NVARCHAR(30) NULL,             
      PCartonno  INT,      
      CtnSeq     INT,      
      MaxCtn     INT    )      
         
   /*CS04 END*/      
    
   --INSERT INTO TraceInfo (TraceName, TimeIn, Col1, Col2, Col3, Col4, Col5) -- SOS# 174296      
   --VALUES ('isp_nikecn_ConsoDespatchTkt5: ' + RTRIM(SUSER_SNAME()), GETDATE()      
   --      , @c_pickslipno, @n_StartCartonNo, @n_EndCartonNo      
   --      , @c_StartLabelNo, @c_EndLabelNo)      
    
   INSERT INTO TraceInfo (TraceName, TimeIn, Col1, Col2, Col3, Col4, Col5) -- SOS# 174296      
   VALUES ('isp_nikecn_ConsoDespatchTkt5: ' + RTRIM(SUSER_SNAME()), GETDATE()      
         , @c_Wavekey, @c_IntVechicle, @c_VAS      
         , @c_PickZone, @c_caseid)      
  
   --WL01 Start  
   SET @n_cntRefno = 0   
     
   SELECT @n_cntRefno = COUNT(DISTINCT c.code)   
   FROM CODELKUP C WITH (NOLOCK) where C.listname = 'ALLSorting'       
   AND C.Storerkey=@c_storerkey AND C.code2=@c_PickZone   
  
 DECLARE cur_pickslipno CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
 SELECT PICKSLIPNO,Discrete,Conso,OrdOrdKey,sku FROM #TMPPICKSLIPNO    
 OPEN cur_pickslipno    
       
   FETCH FROM cur_pickslipno INTO @c_pickslipno,@c_Discrete,@c_Conso,@c_OrdOrdKey,@c_sku     
   WHILE @@FETCH_STATUS = 0    
   BEGIN     
   IF (@c_Conso = 'Y' and @c_Discrete = 'N')   --Conso    
   BEGIN      
      /*CS 05 start*/      
   
         
   --   SELECT @n_cntRefno = COUNT(DISTINCT c.code)      
   --   FROM PackDetail (NOLOCK)      
   --   JOIN PackHeader (NOLOCK) ON ( PackDetail.PickSlipNo = PackHeader.PickSlipNo )      
   --  -- JOIN LoadplanDetail (NOLOCK) ON ( Packheader.Loadkey = LoadplanDetail.LoadKey )                   --CS10      
   --   JOIN ORDERS (NOLOCK) ON ( Orders.loadkey = PackHeader.loadkey )                                     --CS10      
   --   JOIN SKU (NOLOCK) ON ( PackDetail.Sku = SKU.Sku AND PackDetail.StorerKey = SKU.StorerKey )      
   --   LEFT JOIN PICKDETAIL PD (NOLOCK) ON PD.orderkey = ORDERS.OrderKey      
   --  -- LEFT JOIN LOC L WITH (NOLOCK) ON L.loc=pd.Loc      
   --   LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.listname = 'ALLSorting'       
   --        AND C.Storerkey=@c_storerkey AND C.code2=@c_PickZone    
   --   WHERE PackHeader.PickSlipNo = @c_pickslipno      
   --   --AND PackDetail.CartonNo BETWEEN CASE WHEN @n_StartCartonNo = 0 THEN 1 ELSE @n_StartCartonNo END AND      
   --   --                                CASE WHEN @n_EndCartonNo   = 0 THEN 9999 ELSE @n_EndCartonNo END      
   --AND PACKDETAIL.SKU = @c_sku    
  
   --SELECT @n_cntRefno  
    
    /*CS05 End*/      
      INSERT INTO #RESULT   ( Wavekey, PickSlipNo, LoadKey, Route, ConsigneeKey, DeliveryDate,      
                            C_Company,  C_Address1,  C_Address2,  C_Address3,  C_City,      
                            xDockLane,  LabelNo,  CartonNo,  ExtOrder1,  ExtOrder2,      
                            ExtOrder3,  ExtOrder4, ExtOrder5,  ExtOrder6,  ExtOrder7,      
                            ExtOrder8,  ExtOrder9, ExtOrder10, TotalSku,   TotalPcs,      
                            MaxCarton,  ShowQtyCfg, OrderType, SUSR4, Stop,         
                            ShowField,ShowCRD,CRD, ExtraInfo ,TotalQtyPacked                                          
                           , RefNo, RefNo2,SITELoadkey    
         ,UserDefine10, ShowCartonType, CartonType             --WL01                
                           )      
      
      SELECT @c_wavekey,    
         PackHeader.PickSlipNo,      
            PackHeader.LoadKey,      
            PackHeader.Route,      
            MAX(ORDERS.Consigneekey) as ConsigneeKey,      
            MAX(Orders.DeliveryDate) as DeliveryDate,      
            MAX(Orders.C_Company) as C_Company,      
            MAX(Orders.C_Address1) as C_Address1,      
            MAX(Orders.C_Address2) as C_Address2,      
            MAX(Orders.C_Address3) as C_Address3,      
            MAX(Orders.C_City) as C_City,      
            xDockLane = CASE WHEN MAX(ORDERS.xDockFlag) = '1' THEN      
               (SELECT StorerSODefault.xDockLane FROM StorerSODefault (NOLOCK)      
                WHERE StorerSODefault.StorerKey = MAX(ORDERS.StorerKey))      
               ELSE SPACE(10)      
               END,      
            PackDetail.LabelNo,      
            PackDetail.CartonNo,      
            ExtOrder1 = SPACE(80),      
            ExtOrder2 = SPACE(80),      
            ExtOrder3 = SPACE(80),      
            ExtOrder4 = SPACE(80),      
            ExtOrder5 = SPACE(80),      
            ExtOrder6 = SPACE(80),      
            ExtOrder7 = SPACE(80),      
            ExtOrder8 = SPACE(80),      
            ExtOrder9 = SPACE(80),      
            ExtOrder10 = SPACE(80),      
            COUNT(DISTINCT PACKDETAIL.Sku) AS TotalSku,         
            SUM(DISTINCT PACKDETAIL.Qty) AS TotalPcs,           
            MaxCarton = SPACE(10)      
         ,  ShowQtyCfg= @c_ShowQty_Cfg                       
         ,  OrderType = CASE WHEN @c_ShowOrdType_Cfg = '1' THEN Orders.Type ELSE '' END         
         ,  Plant = @c_Susr4      
         ,  MAX(Orders.Stop) as Stop      
         --(CS02) Start      
         ,  ShowField = @c_showField      
         , ShowCRD  = CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD'      
                      AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.Userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))    --Cs03      
                      <  LEFT(ORDERS.ExternPOKey,8))) THEN      
                      CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN      
                      'Y' ELSE 'N' END      
                      ELSE 'N' END      
         ,   CRD = CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4)) = 1 THEN      
                   CASE WHEN ISNUMERIC(REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) = 1 THEN                                                           --CS03      
                   CASE WHEN CONVERT(INT,LEFT(ORDERS.ExternPOKey,4)) < CONVERT(INT,REPLACE(substring(ORDERS.Userdefine10,6,5),'-',''))                 --Cs03      
               THEN CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.ExternPOKey,4),'-','')) + 1))) + '-'+ substring(ORDERS.ExternPOKey,5,2)      
                   + '-' + substring(ORDERS.ExternPOKey,7,2) ELSE      
              CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.ExternPOKey,4),'-',''))))) + '-'+ substring(ORDERS.ExternPOKey,5,2)      
                  + '-' + substring(ORDERS.ExternPOKey,7,2) END      
                   ELSE '' END      
                   ELSE '' END      
         , CASE WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'L' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'F' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'Q' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'L/QS'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'A' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN '1111'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'N' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN ''      
                WHEN Orders.UserDefine05 = 'LI' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
                WHEN Orders.UserDefine05 = 'RP' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
                ELSE '' END AS ExtraInfo            
        /*CS03 End*/              
         ,  TotalQtyPacked = (SELECT ISNULL(SUM(PD.Qty),0)                       --(Wan04)      
                                    FROM PACKDETAIL PD WITH (NOLOCK)             --(Wan04)      
                                    WHERE PD.PickSlipNo = PACKHEADER.PickSlipNo  --(Wan04)          
                                    AND PD.CartonNo = PACKDETAIL.CartonNo        --(Wan04)      
         )      
         , Packdetail.RefNo, PackDetail.RefNo2                                   --(CS04)      
         , CASE WHEN @n_cntRefno >1 THEN Packdetail.RefNo + '-' +PackHeader.LoadKey ELSE PackHeader.LoadKey END SITELoadkey   --(CS05)      
   , Orders.UserDefine10--WL01    
   , @c_showcartontype --WL01    
   , ISNULL(CartonList.Cartontype,'')--WL01    
   FROM Orders Orders WITH (NOLOCK)      
      JOIN OrderDetail OrderDetail WITH (NOLOCK) ON Orders.OrderKey = OrderDetail.OrderKey      
     -- JOIN LoadPlanDetail LoadPlanDetail WITH (NOLOCK) ON (Orders.OrderKey = LoadplanDetail.OrderKey)                       --(CS10)      
      JOIN Packheader Packheader WITH (NOLOCK) ON (Orders.LoadKey = Packheader.LoadKey)                                       --(CS10)      
      JOIN Packdetail Packdetail WITH (NOLOCK) ON (Packheader.Pickslipno = Packdetail.pickslipno AND OrderDetail.SKU = PackDetail.SKU)      
      LEFT OUTER JOIN STORER (NOLOCK) ON (STORER.StorerKey = Orders.consigneekey)                                                      --(CS02)      
      LEFT JOIN Pickdetail (NOLOCK) ON (Pickdetail.CaseID = Packdetail.labelno) --WL01    
   LEFT JOIN CartonListDetail (NOLOCK) ON CartonListDetail.PickDetailKey = Pickdetail.PickDetailKey --WL01    
   LEFT JOIN CartonList (NOLOCK) ON CartonList.CartonKey = CartonListDetail.CartonKey --WL01    
   LEFT JOIN LOC WITH (NOLOCK) ON LOC.loc=PICKDETAIL.Loc  --WL01    
   WHERE PackHeader.PickSlipNo = @c_pickslipno      
      --AND PackDetail.CartonNo BETWEEN CASE WHEN @n_StartCartonNo = 0 THEN 1 ELSE @n_StartCartonNo END AND      
      --                                CASE WHEN @n_EndCartonNo   = 0 THEN 9999 ELSE @n_EndCartonNo END    
   AND ORDERS.INTERMODALVEHICLE = @c_IntVechicle --WL01    
   AND LOC.PICKZONE = @c_PickZone  --WL01    
   AND ORDERS.OrderKey = @c_OrdOrdKey    
   AND PACKDETAIL.SKU = @c_sku--WL01    
   AND Pickdetail.CaseID = CASE WHEN @c_caseid <> '' THEN @c_caseid ELSE Pickdetail.CaseID END--WL01    
      --CS04 start      
       AND 1 = CASE WHEN @c_RefNo <> '' AND RefNo = @c_RefNo THEN 1      
         WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo <> '' AND RefNo <> @c_ShippingFilterByRefNo  THEN 1      
         WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo <> '' and Refno = '' AND RefNo <> @c_ShippingFilterByRefNo THEN  1      
        WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo = '' THEN 1 ELSE 0 END      
              
     --CS04 End                    
      GROUP BY PackHeader.PickSlipNo,      
               PackHeader.LoadKey,      
               PackHeader.Route,      
               PackDetail.LabelNo,      
               PackDetail.CartonNo      
           ,  CASE WHEN @c_ShowOrdType_Cfg = '1' THEN Orders.Type ELSE '' END                     --(Wan02)      
           ,  CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD'      
          AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.Userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))  --CS03      
          <  LEFT(ORDERS.ExternPOKey,8))) THEN      
          CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN      
          'Y' ELSE 'N' END      
          ELSE 'N' END    --TS00048233      
           ,  CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4)) = 1 THEN      
          CASE WHEN ISNUMERIC(REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) = 1 THEN                                                            --CS03      
          CASE WHEN CONVERT(INT,LEFT(ORDERS.ExternPOKey,4)) < CONVERT(INT,REPLACE(substring(ORDERS.Userdefine10,6,5),'-',''))                  --CS03      
          THEN CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.ExternPOKey,4),'-','')) + 1))) + '-'+ substring(ORDERS.ExternPOKey,5,2)      
        + '-' + substring(ORDERS.ExternPOKey,7,2) ELSE      
          CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.ExternPOKey,4),'-',''))))) + '-'+ substring(ORDERS.ExternPOKey,5,2)      
          + '-' + substring(ORDERS.ExternPOKey,7,2) END      
          ELSE '' END      
          ELSE '' END   --TS00048233      
           ,  STORER.SUSR1                                                                        --(CS02)      
         , CASE WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'L' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'F' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'Q' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'L/QS'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'A' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN '1111'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'N' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN ''      
                WHEN Orders.UserDefine05 = 'LI' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
                WHEN Orders.UserDefine05 = 'RP' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
                ELSE '' END             
           , Packdetail.RefNo, PackDetail.RefNo2                                                     --(CS04)      
     , Orders.UserDefine10 --WL01        
     , ISNULL(CartonList.Cartontype,'') --WL01        
    
                 
   END      
   ELSE      
   --IF (@c_Conso = 'N' and @c_Discrete = 'Y')   --DISCRETE    
   BEGIN  --NJOW01      
     -- SET @n_cntRefno = 0      
            
    --  SELECT @n_cntRefno = COUNT(DISTINCT c.code)      
    --      FROM ORDERS (NOLOCK)      
    --      JOIN PackDetail (NOLOCK) ON ( ORDERS.StorerKey = PackDetail.StorerKey )      
    --      JOIN PackHeader (NOLOCK) ON ( PackDetail.PickSlipNo = PackHeader.PickSlipNo      
    --                                AND Packheader.Orderkey = Orders.Orderkey      
    --                                AND Packheader.Loadkey = Orders.Loadkey      
    --                                AND Packheader.Consigneekey = Orders.Consigneekey )      
    --      LEFT JOIN PICKDETAIL PD (NOLOCK) ON PD.orderkey = ORDERS.OrderKey      
    --      LEFT JOIN LOC L WITH (NOLOCK) ON L.loc=pd.Loc      
    --      LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.listname = 'ALLSorting' AND      
    --      C.Storerkey=ORDERS.StorerKey AND C.code2=L.PickZone      
    --      WHERE PackHeader.PickSlipNo = @c_pickslipno      
    --      --AND PackDetail.CartonNo BETWEEN CASE WHEN @n_StartCartonNo = 0 THEN 1 ELSE @n_StartCartonNo END AND      
    --      --                            CASE WHEN @n_EndCartonNo   = 0 THEN 9999 ELSE @n_EndCartonNo END    
    --AND PACKDETAIL.SKU = @c_sku   --WL01      
   
    --select @n_cntRefno = COUNT(DISTINCT c.code)   
    --from CODELKUP C WITH (NOLOCK) where C.listname = 'ALLSorting'       
    --AND C.Storerkey=@c_storerkey AND C.code2=@c_PickZone     
                                                                     
      --CS05 END      
      INSERT INTO #RESULT  ( Wavekey, PickSlipNo, LoadKey, Route, ConsigneeKey, DeliveryDate,      
                            C_Company,  C_Address1,  C_Address2,  C_Address3,  C_City,      
                            xDockLane,  LabelNo,  CartonNo,  ExtOrder1,  ExtOrder2,      
                            ExtOrder3,  ExtOrder4, ExtOrder5,  ExtOrder6,  ExtOrder7,      
                            ExtOrder8,  ExtOrder9, ExtOrder10, TotalSku,   TotalPcs,      
                            MaxCarton,  ShowQtyCfg, OrderType, SUSR4, Stop,         
                            ShowField,ShowCRD,CRD, ExtraInfo                        
                           ,TotalQtyPacked                                          
                           ,RefNo, RefNo2,SITELoadkey       
         ,UserDefine10, ShowCartonType, CartonType        --WL01                     
                           )      
      SELECT @c_wavekey,    
   A.PickSlipNo,      
            Orders.LoadKey,      
            A.Route,      
            ORDERS.Consigneekey,      
            Orders.DeliveryDate,      
            Orders.C_Company,      
            Orders.C_Address1,      
            Orders.C_Address2,      
            Orders.C_Address3,      
            Orders.C_City,      
  xDockLane = CASE WHEN ORDERS.xDockFlag = '1' THEN      
               (SELECT StorerSODefault.xDockLane FROM StorerSODefault (NOLOCK)      
                WHERE StorerSODefault.StorerKey = ORDERS.StorerKey)      
               ELSE SPACE(10)      
               END,      
            PackDetail.LabelNo,      
            PackDetail.CartonNo,      
            ExtOrder1 = SPACE(80),      
            ExtOrder2 = SPACE(80),      
            ExtOrder3 = SPACE(80),      
            ExtOrder4 = SPACE(80),      
            ExtOrder5 = SPACE(80),      
            ExtOrder6 = SPACE(80),      
            ExtOrder7 = SPACE(80),      
            ExtOrder8 = SPACE(80),      
            ExtOrder9 = SPACE(80),      
            ExtOrder10 = SPACE(80),      
            COUNT(PACKDETAIL.Sku) AS TotalSku,         
            SUM(PACKDETAIL.Qty) AS TotalPcs,           
            MaxCarton = SPACE(10)      
         ,  ShowQtyCfg= @c_ShowQty_Cfg                    
         ,  OrderType = CASE WHEN @c_ShowOrdType_Cfg = '1' THEN Orders.Type ELSE '' END      
         ,  Plant = @c_Susr4      
         ,  Orders.Stop                                                                      
         ,  ShowField = @c_showField      
         , ShowCRD  = CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD'      
                      AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.Userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))         --Cs03      
                      <  LEFT(ORDERS.ExternPOKey,8))) THEN      
                      CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN      
                      'Y' ELSE 'N' END      
                      ELSE 'N' END      
         ,   CRD = CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4)) = 1 THEN      
                   CASE WHEN ISNUMERIC(REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) = 1 THEN                                                      --CS03      
                   CASE WHEN CONVERT(INT,LEFT(ORDERS.ExternPOKey,4)) < CONVERT(INT,REPLACE(substring(ORDERS.Userdefine10,6,5),'-',''))            --CS03      
                   THEN CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) + 1))) + '-'+ LEFT(ORDERS.ExternPOKey,2)   --CS03      
                   + '-' + substring(ORDERS.ExternPOKey,3,2) ELSE      
                   CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-',''))))) + '-'+ LEFT(ORDERS.ExternPOKey,2)             --CS03      
                   + '-' + substring(ORDERS.ExternPOKey,3,2) END      
                   ELSE '' END      
                   ELSE '' END      
        , CASE WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'L'  AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'F' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'Q' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'L/QS'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'A' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN '1111'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'N' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN ''      
                WHEN Orders.UserDefine05 = 'LI' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
                WHEN Orders.UserDefine05 = 'RP' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
                ELSE '' END AS ExtraInfo              
         , TotalQtyPacked = (SELECT ISNULL(SUM(PD.Qty),0)                
                     FROM PACKDETAIL PD WITH (NOLOCK)             
         WHERE PD.PickSlipNo = A.PickSlipNo                 
                     AND PD.CartonNo = PACKDETAIL.CartonNo               
                     )                                                   
        , Packdetail.RefNo, PackDetail.RefNo2                            
        , CASE WHEN @n_cntRefno > 1 THEN Packdetail.RefNo + '-' + Orders.LoadKey ELSE Orders.LoadKey END AS Siteloadkey    
  , Orders.UserDefine10 --WL01        
  , @c_showcartontype --WL01    
  , ISNULL(CartonList.Cartontype,'')      --WL01        
      FROM Orders Orders WITH (NOLOCK)      
      JOIN (      
      SELECT DISTINCT OD.OrderKey, OD.Sku, PH.Pickslipno, PH.Route      
      FROM OrderDetail OD WITH (NOLOCK)      
      JOIN PackHeader PH WITH (NOLOCK) ON (OD.OrderKey = PH.OrderKey)         
      WHERE PH.Pickslipno = @c_pickslipno      
      ) AS A      
      ON Orders.OrderKey = A.OrderKey      
      -- SOS# 248050 (End)      
      JOIN Packdetail Packdetail WITH (NOLOCK) ON (A.Pickslipno = Packdetail.pickslipno AND A.SKU = PackDetail.SKU)      
      LEFT OUTER JOIN STORER (NOLOCK) ON (STORER.StorerKey = Orders.consigneekey)                                                       --(CS02)      
      LEFT JOIN Pickdetail (NOLOCK) ON (Pickdetail.CaseID = Packdetail.labelno) --WL01    
   LEFT JOIN CartonListDetail (NOLOCK) ON CartonListDetail.PickDetailKey = Pickdetail.PickDetailKey --WL01    
   LEFT JOIN CartonList (NOLOCK) ON CartonList.CartonKey = CartonListDetail.CartonKey --WL01    
   LEFT JOIN LOC WITH (NOLOCK) ON LOC.loc=PICKDETAIL.Loc  --WL01    
      WHERE A.PickSlipNo = @c_pickslipno      
      --AND PackDetail.CartonNo BETWEEN CASE WHEN @n_StartCartonNo = 0 THEN 1 ELSE @n_StartCartonNo END AND      
      --                                CASE WHEN @n_EndCartonNo   = 0 THEN 9999 ELSE @n_EndCartonNo END    
   AND ORDERS.INTERMODALVEHICLE = @c_IntVechicle --WL01        
   AND LOC.PICKZONE = @c_PickZone  --WL01      
   AND ORDERS.OrderKey = @c_OrdOrdKey      
   AND PACKDETAIL.SKU = @c_sku    --WL01      
   AND Pickdetail.CaseID = CASE WHEN @c_caseid <> '' THEN @c_caseid ELSE Pickdetail.CaseID END--WL01      
      --CS04 start      
       AND 1 = CASE WHEN @c_RefNo <> '' AND RefNo = @c_RefNo THEN 1      
                 WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo <> '' AND RefNo <> @c_ShippingFilterByRefNo THEN 1      
                 WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo <> '' and Refno = '' AND RefNo <> @c_ShippingFilterByRefNo THEN  1      
                WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo = '' THEN 1 ELSE 0 END       
     --CS04 End                                        
      GROUP BY A.PickSlipNo,      
               Orders.LoadKey,      
               A.Route,      
               PackDetail.LabelNo,      
               PackDetail.CartonNo,      
               ORDERS.Consigneekey,      
               Orders.DeliveryDate,      
               Orders.C_Company,      
               Orders.C_Address1,      
               Orders.C_Address2,      
               Orders.C_Address3,      
               Orders.C_City,      
               Orders.Storerkey,      
               Orders.xDockFlag,      
               Orders.LoadKey,      
               CASE WHEN @c_ShowOrdType_Cfg = '1' THEN Orders.Type ELSE '' END,      
               Orders.Stop,                           
               CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD'      
          AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.Userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))        
          <  LEFT(ORDERS.ExternPOKey,8))) THEN                                                                                                      
          CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN                                                                                    
          'Y' ELSE 'N' END                                                                                                                          
          ELSE 'N' END,                                                                                                                             
                CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4)) = 1 THEN                                                                            
          CASE WHEN ISNUMERIC(REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) = 1 THEN                                                                 
          CASE WHEN CONVERT(INT,LEFT(ORDERS.ExternPOKey,4)) < CONVERT(INT,REPLACE(substring(ORDERS.Userdefine10,6,5),'-',''))                       
          THEN CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) + 1))) + '-'+ LEFT(ORDERS.ExternPOKey,2)              
          + '-' + substring(ORDERS.ExternPOKey,3,2) ELSE                                                                                            
          CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-',''))))) + '-'+ LEFT(ORDERS.ExternPOKey,2)                       
          + '-' + substring(ORDERS.ExternPOKey,3,2) END                                                                                             
          ELSE '' END      
          ELSE '' END,         
               STORER.SUSR1                                                                              
         , CASE WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'L' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'F' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'Q' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'L/QS'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'A' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN '1111'      
                WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'N' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN ''      
                WHEN Orders.UserDefine05 = 'LI' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
                WHEN Orders.UserDefine05 = 'RP' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
                ELSE '' END                
     /*CS03 End*/                 
     , Packdetail.RefNo, PackDetail.RefNo2    
  , Orders.UserDefine10 --WL01        
  , ISNULL(CartonList.Cartontype,'') --WL01        
         
    
    
 END    
    
    
 FETCH NEXT FROM cur_pickslipno INTO @C_PICKSLIPNO,@C_DISCRETE,@C_CONSO,@c_OrdOrdKey,@C_SKU      
 END    
    CLOSE cur_pickslipno      
    DEALLOCATE cur_pickslipno     
        
      
      
--  SELECT '2',* FROM #RESULT AS r      
        
   --DECLARE @nCartonIndex int      
      
   --IF @n_StartCartonNo <> 0 AND  @n_EndCartonNo <> 0      
   --BEGIN      
   --   SET @nCartonIndex = @n_StartCartonNo      
   --   WHILE @nCartonIndex <= @n_EndCartonNo      
   --   BEGIN      
   --   IF NOT EXISTS(SELECT 1 FROM #RESULT      
   --                 WHERE PickSlipNo = @c_pickslipno      
   --                 AND CartonNo = @nCartonIndex      
   --   )      
   --      BEGIN      
   --         SET ROWCOUNT 1      
   --            IF ISNULL(@c_Orderkey,'') = ''      
   --            BEGIN      
   --               INSERT INTO #RESULT  ( PickSlipNo, LoadKey, Route, ConsigneeKey, DeliveryDate,      
   --                         C_Company,  C_Address1,  C_Address2,  C_Address3,  C_City,      
   --                         xDockLane,  LabelNo,  CartonNo,  ExtOrder1,  ExtOrder2,      
   --                         ExtOrder3,  ExtOrder4, ExtOrder5,  ExtOrder6,  ExtOrder7,      
   --                         ExtOrder8,  ExtOrder9, ExtOrder10, TotalSku,   TotalPcs,      
   --                         MaxCarton,  ShowQtyCfg, OrderType, SUSR4, Stop,                
   --                         ShowField,ShowCRD,CRD, ExtraInfo       
   --                        ,TotalQtyPacked                                                 
   --                        )       
   --               SELECT      
   --               PackHeader.PickSlipNo,      
   --               PackHeader.LoadKey,      
   --               PackHeader.Route,      
   --               MAX(ORDERS.Consigneekey) as ConsigneeKey,      
   --               MAX(Orders.DeliveryDate) as DeliveryDate,      
   --               MAX(Orders.C_Company) as C_Company,      
   --               MAX(Orders.C_Address1) as C_Address1,      
   --               MAX(Orders.C_Address2) as C_Address2,      
   --               MAX(Orders.C_Address3) as C_Address3,      
   --               MAX(Orders.C_City) as C_City,      
   --               xDockLane = CASE WHEN MAX(ORDERS.xDockFlag) = '1' THEN      
   --               (  SELECT StorerSODefault.xDockLane FROM StorerSODefault (NOLOCK)      
   --                  WHERE StorerSODefault.StorerKey = MAX(ORDERS.StorerKey)  )      
   --                  ELSE SPACE(10)      
   --                  END,      
   --               @c_StartLabelNo AS LabelNo,      
   --               @nCartonIndex AS CartonNo,      
   --               ExtOrder1 = SPACE(80),      
   --               ExtOrder2 = SPACE(80),      
   --               ExtOrder3 = SPACE(80),      
   --               ExtOrder4 = SPACE(80),      
   --               ExtOrder5 = SPACE(80),      
   --               ExtOrder6 = SPACE(80),      
   --               ExtOrder7 = SPACE(80),      
   --               ExtOrder8 = SPACE(80),      
   --               ExtOrder9 = SPACE(80),      
   --               ExtOrder10 = SPACE(80),      
   --               0 AS TotalSku,      -- (YokeBeen01)      
   --               0 AS TotalPcs,      -- (YokeBeen01)      
   --               MaxCarton = SPACE(80)      
   --            ,  ShowQtyCfg= @c_ShowQty_Cfg      
   --            ,  OrderType = CASE WHEN @c_ShowOrdType_Cfg = '1' THEN Orders.Type ELSE '' END      --(Wan02)                    --(Wan01)      
   --            ,  Plant = @c_Susr4 --(Wan03)      
   --            ,  MAX(Orders.Stop) as Stop      
   --            --(CS02) Start      
   --           ,  ShowField = @c_showField      
   --           ,  ShowCRD  = CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD'      
   --                         AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.Userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))    --CS03      
   --                         <  LEFT(ORDERS.ExternPOKey,8))) THEN      
   --                         CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN      
   --                         'Y' ELSE 'N' END      
   --                         ELSE 'N' END      
   --           ,   CRD = CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4)) = 1 THEN      
   --                CASE WHEN ISNUMERIC(REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) = 1 THEN      
   --                CASE WHEN CONVERT(INT,LEFT(ORDERS.ExternPOKey,4)) < CONVERT(INT,REPLACE(substring(ORDERS.Userdefine10,6,5),'-',''))      
   --                THEN CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) + 1))) + '-'+ LEFT(ORDERS.ExternPOKey,2)      
   --                + '-' + substring(ORDERS.ExternPOKey,3,2) ELSE      
   --                CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-',''))))) + '-'+ LEFT(ORDERS.ExternPOKey,2)                           --Cs03      
   --                + '-' + substring(ORDERS.ExternPOKey,3,2) END      
   --                ELSE '' END      
   --                ELSE '' END                         
   --         , CASE WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'L' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
   --          WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'F' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
   --          WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'Q' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'L/QS'      
   --          WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'A' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN '1111'      
   --          WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'N' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN ''      
   --          WHEN Orders.UserDefine05 = 'LI' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
   --          WHEN Orders.UserDefine05 = 'RP' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
   --          ELSE '' END AS ExtraInfo         --CS03 End                  
   --          ,  0 AS TotalQtyPacked                 -- (Wan04)        
   --          FROM PackHeader (NOLOCK)      
   ---- JOIN LoadplanDetail (NOLOCK) ON PackHeader.LoadKey = LoadplanDetail.LoadKey             --(CS10)      
   -- JOIN Orders (NOLOCK) ON Orders.loadkey = PackHeader.loadkey          --(CS02)       --(CS10)      
   -- LEFT JOIN STORER (NOLOCK) ON STORER.StorerKey = Orders.ConsigneeKey      
   -- WHERE PackHeader.PickSlipNo = @c_pickslipno       
   -- --AND  PackHeader.LoadKey = LoadplanDetail.LoadKey AND     --CS10      
   -- --Orders.OrderKey = LoadplanDetail.OrderKey      
   -- --AND STORER.StorerKey = Orders.ConsigneeKey              --(CS02)     
   -- GROUP BY PackHeader.PickSlipNo,      
   --  PackHeader.LoadKey,      
   --  PackHeader.Route,      
   --  CASE WHEN @c_ShowOrdType_Cfg = '1' THEN Orders.Type ELSE '' END,          --(Wan02)      
   --  CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD'      
   --               AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.Userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))    --CS03      
   --               <  LEFT(ORDERS.ExternPOKey,8))) THEN      
   --               CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN      
   --               'Y' ELSE 'N' END      
   --               ELSE 'N' END, --TS00048233      
   --                     CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4)) = 1 THEN      
   --               CASE WHEN ISNUMERIC(REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) = 1 THEN      
   --               CASE WHEN CONVERT(INT,LEFT(ORDERS.ExternPOKey,4)) < CONVERT(INT,REPLACE(substring(ORDERS.Userdefine10,6,5),'-',''))      
   --               THEN CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) + 1))) + '-'+ LEFT(ORDERS.ExternPOKey,2)      
   --               + '-' + substring(ORDERS.ExternPOKey,3,2) ELSE      
   --               CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-',''))))) + '-'+ LEFT(ORDERS.ExternPOKey,2)                        --CS03      
   --               + '-' + substring(ORDERS.ExternPOKey,3,2) END      
   --               ELSE '' END      
   --               ELSE '' END,    --TS00048233      
   --               STORER.SUSR1          
   --           , CASE WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'L' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
   --            WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'F' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
   --            WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'Q' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'L/QS'      
   --            WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'A' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN '1111'      
   --            WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'N' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN ''      
   --            WHEN Orders.UserDefine05 = 'LI' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
   --            WHEN Orders.UserDefine05 = 'RP' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
   --            ELSE '' END           --CS03 End      
                     
   --            --SELECT * FROM #RESULT AS r      
   --         END      
   --           ELSE      
   --            BEGIN  --NJOW01      
   --               INSERT INTO #RESULT  ( PickSlipNo, LoadKey, Route, ConsigneeKey, DeliveryDate,      
   --                         C_Company,  C_Address1,  C_Address2,  C_Address3,  C_City,      
   --                         xDockLane,  LabelNo,  CartonNo,  ExtOrder1,  ExtOrder2,      
   --                         ExtOrder3,  ExtOrder4, ExtOrder5,  ExtOrder6,  ExtOrder7,      
   --                         ExtOrder8,  ExtOrder9, ExtOrder10, TotalSku,   TotalPcs,      
   --                         MaxCarton,  ShowQtyCfg, OrderType, SUSR4, Stop,     --(Wan01), (Wan02)Add ORderType, (Wan03) Add SUSR4      
   --                         ShowField,ShowCRD,CRD, ExtraInfo                                       --(CS02)      
   --                        ,TotalQtyPacked                                                         --(Wan04)      
   --                      --  ,RefNo, RefNo2                                                          --(CS04)      
   --                        )      
   --               SELECT      
   --               PackHeader.PickSlipNo,      
   --               Orders.LoadKey,      
   --               PackHeader.Route,      
   --               ORDERS.Consigneekey,      
   --               Orders.DeliveryDate,      
   --               Orders.C_Company,      
   --               Orders.C_Address1,      
   --               Orders.C_Address2,      
   --               Orders.C_Address3,      
   --               Orders.C_City,      
   --               xDockLane = CASE WHEN ORDERS.xDockFlag = '1' THEN      
   --               (  SELECT StorerSODefault.xDockLane FROM StorerSODefault (NOLOCK)      
   --                  WHERE StorerSODefault.StorerKey = ORDERS.StorerKey )      
   --                  ELSE SPACE(10)      
   --                  END,      
   --               @c_StartLabelNo AS LabelNo,      
   --               @nCartonIndex AS CartonNo,      
   --               ExtOrder1 = SPACE(80),      
   --               ExtOrder2 = SPACE(80),      
   --               ExtOrder3 = SPACE(80),      
   --               ExtOrder4 = SPACE(80),      
   --               ExtOrder5 = SPACE(80),      
   --               ExtOrder6 = SPACE(80),      
   --               ExtOrder7 = SPACE(80),      
   --               ExtOrder8 = SPACE(80),      
   --               ExtOrder9 = SPACE(80),      
   --               ExtOrder10 = SPACE(80),      
   --               0 AS TotalSku,      -- (YokeBeen01)      
   --               0 AS TotalPcs,      -- (YokeBeen01)      
   --               MaxCarton = SPACE(80)      
   --            ,  ShowQtyCfg= @c_ShowQty_Cfg      
   --            ,  OrderType = CASE WHEN @c_ShowOrdType_Cfg = '1' THEN Orders.Type ELSE '' END           
   --            ,  Plant = @c_Susr4      
   --            ,  Orders.Stop                                                                     
   --           ,  ShowField = @c_showField      
   --           ,  ShowCRD  = CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD'      
   --                         AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.Userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))         --CS03      
   --                         <  LEFT(ORDERS.ExternPOKey,8))) THEN      
   --                         CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN      
   --                   'Y' ELSE 'N' END      
   --                         ELSE 'N' END      
   --           ,   CRD =  CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4)) = 1 THEN      
   --                      CASE WHEN ISNUMERIC(REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) = 1 THEN      
   --                      CASE WHEN CONVERT(INT,LEFT(ORDERS.ExternPOKey,4)) < CONVERT(INT,REPLACE(substring(ORDERS.Userdefine10,6,5),'-',''))      
   --                      THEN CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) + 1))) + '-'+ LEFT(ORDERS.ExternPOKey,2)      
   --                      + '-' + substring(ORDERS.ExternPOKey,3,2) ELSE      
   --                      CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-',''))))) + '-'+ LEFT(ORDERS.ExternPOKey,2)                       
   --                      + '-' + substring(ORDERS.ExternPOKey,3,2) END      
   --                      ELSE '' END      
   --                      ELSE '' END      
   --             , CASE WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'L' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
   --          WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'F' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
   --          WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'Q' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'L/QS'      
   --          WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'A' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN '1111'      
   --          WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'N' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN ''      
   --          WHEN Orders.UserDefine05 = 'LI' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
   --          WHEN Orders.UserDefine05 = 'RP' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
   --          ELSE '' END AS ExtraInfo              
   --,  0 AS TotalQtyPacked              
   --FROM PackHeader (NOLOCK)      
   --JOIN Orders (NOLOCK) ON Packheader.Orderkey = Orders.Orderkey      
   --LEFT JOIN STORER (NOLOCK) ON (STORER.StorerKey = Orders.ConsigneeKey)                     
   --WHERE PackHeader.PickSlipNo = @c_pickslipno      
   --GROUP BY PackHeader.PickSlipNo,      
   --  PackHeader.LoadKey,      
   --  PackHeader.Route,      
   --  ORDERS.Consigneekey,      
   --  Orders.DeliveryDate,      
   --  Orders.C_Company,      
   --  Orders.C_Address1,      
   --  Orders.C_Address2,      
   --  Orders.C_Address3,      
   --  Orders.C_City,      
   --  Orders.Storerkey,      
   --  Orders.xDockFlag,      
   --  Orders.LoadKey,      
   --  CASE WHEN @c_ShowOrdType_Cfg = '1' THEN Orders.Type ELSE '' END,                
   --  Orders.Stop,      
   --  CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD'      
   --               AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.Userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))             
   --               <  LEFT(ORDERS.ExternPOKey,8))) THEN      
   --               CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN      
   --               'Y' ELSE 'N' END      
   --               ELSE 'N' END,        
   --            CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4)) = 1 THEN      
   --               CASE WHEN ISNUMERIC(REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) = 1 THEN      
   --               CASE WHEN CONVERT(INT,LEFT(ORDERS.ExternPOKey,4)) < CONVERT(INT,REPLACE(substring(ORDERS.Userdefine10,6,5),'-',''))      
   --               THEN CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-','')) + 1))) + '-'+ LEFT(ORDERS.ExternPOKey,2)      
   --               + '-' + substring(ORDERS.ExternPOKey,3,2) ELSE      
   --               CONVERT(NVARCHAR(4),((CONVERT(INT,REPLACE(LEFT(ORDERS.Userdefine10,4),'-',''))))) + '-'+ LEFT(ORDERS.ExternPOKey,2)                           
   --               + '-' + substring(ORDERS.ExternPOKey,3,2) END       
   --               ELSE '' END      
   --               ELSE '' END,         
   --                        STORER.SUSR1           
   --     , CASE WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'L' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
   --                 WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'F' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
   --                 WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'Q' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'L/QS'      
   --                 WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'A' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN '1111'      
   --                 WHEN SUBSTRING(ORDERS.ExternPokey,9,1) = 'N' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN ''      
   --                 WHEN Orders.UserDefine05 = 'LI' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'LI'      
   --                 WHEN Orders.UserDefine05 = 'RP' AND ISNULL(STORER.Susr2,'') = 'CRW' THEN 'RP'      
   --                 ELSE '' END           
   --            END      
   --         SET ROWCOUNT 0      
   --      END      
      
   --      SET @nCartonIndex = @nCartonIndex + 1      
   --   END      
   --END -- If start carton and end carton <> 0      
    
    --WL01    
    DECLARE cur_pickslipno1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
 SELECT PICKSLIPNO,Discrete,Conso FROM #TMPPICKSLIPNO    
 OPEN cur_pickslipno1    
       
 FETCH FROM cur_pickslipno1 INTO @c_pickslipno,@c_Discrete,@c_Conso     
 WHILE @@FETCH_STATUS = 0    
 BEGIN    
    IF (@c_Conso = 'Y' and @c_Discrete = 'N')   --Conso     
   --IF ISNULL(@c_Orderkey,'') = ''      
      DECLARE Ext_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT O.ExternOrderkey, O.Loadkey, Ph.Pickslipno      
      FROM   ORDERS O (NOLOCK)      
      JOIN   LoadPlanDetail Ld (NOLOCK) ON O.Loadkey = Ld.Loadkey AND O.Orderkey = Ld.Orderkey      
      JOIN   PackHeader Ph (NOLOCK) ON Ph.Loadkey = Ld.Loadkey    
   JOIN   WAVEDETAIL (NOLOCK) on (WAVEDETAIL.orderkey = O.orderkey)      
      WHERE  Ph.Pickslipno = @c_PickSlipNo      
  -- WHERE WAVEDETAIL.Wavekey = @c_wavekey    
      ORDER BY O.ExternOrderkey            
   ELSE  --NJOW01      
      DECLARE Ext_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT O.ExternOrderkey, O.Loadkey,Ph.Pickslipno      
      FROM   ORDERS O (NOLOCK)      
      JOIN   PackHeader Ph (NOLOCK) ON O.Orderkey = Ph.Orderkey    
   JOIN   WAVEDETAIL (NOLOCK) on (WAVEDETAIL.orderkey = O.orderkey)        
      WHERE  Ph.Pickslipno = @c_PickSlipNo      
  -- WHERE WAVEDETAIL.Wavekey = @c_wavekey    
      ORDER BY O.ExternOrderkey      
      
   OPEN Ext_cur      
      
  SELECT @i_ExtCnt  = 1      
   SELECT @i_LineCnt = 0      
      
   FETCH NEXT FROM Ext_cur INTO @c_externOrderkey, @c_LoadKey, @c_pickslipno      
      
   WHILE @@FETCH_STATUS = 0      
   BEGIN      
      IF @i_ExtCnt = 10  -- SOS147156, Change from 11 to 10      
      BREAK      
            
      SELECT @i_ExtCnt  = @i_ExtCnt + 1      
      SELECT @i_LineCnt = @i_LineCnt + 1      
      SELECT @SQL = "UPDATE #RESULT SET ExtOrder" + RTRIM(LTRIM(@i_LineCnt)) + " = '" + RTRIM(LTRIM(@c_externOrderkey)) + "' "      
                     + "WHERE Pickslipno = '" + RTRIM(@c_pickslipno) + "' AND WAVEKEY = '" + RTRIM(@c_wavekey)    
      + "' AND Loadkey = '" + RTRIM(@c_LoadKey) + "' "     
    
      EXEC (@SQL)      
      
      FETCH NEXT FROM Ext_cur INTO @c_externOrderkey, @c_LoadKey,@c_pickslipno      
   END      
   CLOSE Ext_cur      
   DEALLOCATE Ext_cur    
    
   FETCH FROM cur_pickslipno1 INTO @c_pickslipno,@c_Discrete,@c_Conso    
   END     
   CLOSE cur_pickslipno1      
   DEALLOCATE cur_pickslipno1     
      
   SET @nSumPackQty = 0      
   SET @nSumPickQty = 0      
   SET @nExcludeCarton = 1      
       
    DECLARE CUR_CTNRESULT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR        
      SELECT DISTINCT PICKSLIPNO FROM #TMPPICKSLIPNO        
   WHERE VAS = @c_VAS        
 OPEN CUR_CTNRESULT    
    
 FETCH FROM CUR_CTNRESULT INTO @c_PickSlipNo    
 WHILE @@FETCH_STATUS = 0    
 BEGIN    
    /*CS04 start*/      
    INSERT INTO #CTNRESULT ( Wavekey,PickSlipNo, RefNo, RefNo2, PCartonno, CtnSeq, MaxCtn )      
    SELECT DISTINCT @c_wavekey,PickSlipNo,RefNo,refno2,cartonno,Row_number() OVER (PARTITION BY PickSlipNo,RefNo ORDER BY cartonno),0      
    FROM packdetail (NOLOCK)      
    WHERE PickSlipNo=@c_PickSlipNo       
    GROUP BY  PickSlipNo,RefNo,refno2,cartonno      
    ORDER BY CartonNo     
    FETCH NEXT FROM CUR_CTNRESULT INTO @c_PickSlipNo    
 END    
 CLOSE CUR_CTNRESULT      
    --DEALLOCATE cur_pickslipno     
     
 SET @c_pickslipno = ''    
    
    OPEN CUR_CTNRESULT     
 FETCH FROM CUR_CTNRESULT INTO @c_PickSlipNo    
    
 WHILE @@FETCH_STATUS = 0    
 BEGIN    
    IF @c_ShippingFilterByRefNo = ''      
    BEGIN      
      SELECT @nMaxCartonNo = MAX(CartonNo) FROM PackDetail WITH (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo     
    END      
    ELSE      
    BEGIN            
      SET @nMaxCartonNo = 0      
          
      DECLARE CUR_SITE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR        
       SELECT DISTINCT Pickslipno,refno         
       FROM   #CTNRESULT         
      -- WHERE Pickslipno = @c_pickslipno     
       WHERE Wavekey = @c_wavekey    
        
      OPEN CUR_SITE         
           
      FETCH NEXT FROM CUR_SITE INTO @c_GetPSlipno,@c_GetRefno          
           
      WHILE @@FETCH_STATUS <> -1        
      BEGIN             
         SELECT @nMaxCartonNo = CASE WHEN @c_ShippingFilterByRefNo <> ''       
                                     AND @c_RefNo <> ''       
                                     AND convert(int,RefNo2) <> ''       
                                     AND RefNo <> @c_ShippingFilterByRefNo        
                                     THEN COUNT(DISTINCT  CONVERT(INT,RefNo2))       
                                     ELSE MAX(CONVERT(INT,CtnSeq))       
                                END   --CS06      
         FROM #CTNRESULT WITH (NOLOCK)       
         WHERE PickSlipNo = @c_GetPSlipno       
         AND refno=@c_GetRefno         
         AND 1 = CASE WHEN @c_RefNo <> '' AND RefNo = @c_RefNo THEN 1      
                      WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo <> '' AND RefNo <> @c_ShippingFilterByRefNo THEN 1      
                      WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo = '' THEN 1       
                      ELSE 0       
                 END      
         GROUP BY PCartonno,RefNo,convert(int,RefNo2)      
         
         UPDATE #CTNRESULT      
         SET MaxCtn = @nMaxCartonNo      
         WHERE pickslipno = @c_GetPSlipno      
         AND refno = @c_GetRefno      
         
         SET @nMaxCartonNo = 0      
         
         FETCH NEXT FROM CUR_SITE INTO @c_GetPSlipno,@c_GetRefno         
      END         
   CLOSE CUR_SITE      
   DEALLOCATE CUR_SITE     
 END    
 FETCH FROM CUR_CTNRESULT INTO @c_PickSlipNo    
 END          
 CLOSE CUR_CTNRESULT      
    DEALLOCATE CUR_CTNRESULT     
       
  DECLARE CTN_CUR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
    SELECT CASE WHEN @c_ShippingFilterByRefNo <> '' and RefNo2 <> '' THEN CONVERT(INT,RefNo2)                         
    ELSE CartonNo  END,       
    ROWREF,refno, PickSlipNo      
    FROM #RESULT WITH (NOLOCK)      
    --WHERE PickSlipNo = @c_PickSlipNo      
 WHERE Wavekey = @c_Wavekey    
    AND 1 = CASE WHEN @c_RefNo <> '' AND RefNo = @c_RefNo THEN 1      
          WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo <> '' AND RefNo <> @c_ShippingFilterByRefNo THEN 1      
         WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo <> '' and Refno = '' AND RefNo <> @c_ShippingFilterByRefNo THEN  1      
        WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo = '' THEN 1 ELSE 0 END      
   ORDER BY 1                      
                                                                    
   OPEN CTN_CUR      
   FETCH NEXT FROM CTN_CUR INTO @nCartonNo , @nRowRef ,@c_site, @c_PickSlipNo      
      
   WHILE @@FETCH_STATUS <> -1      
   BEGIN      
          
         
    SET @n_GetCartonNo = 0         
    SET @n_GetMaxCarton = 1      
          
    IF @c_ShippingFilterByRefNo <> ''      
    BEGIN      
      SELECT @n_GetCartonNo = CtnSeq      
         ,@n_GetMaxCarton = CONVERT(INT,MaxCtn)      
      FROM #CTNRESULT      
      WHERE PickSlipNo=@c_pickslipno      
      AND CtnSeq = @nCartonNo      
      AND refno=@c_site      
            
    END      
    ELSE      
    BEGIN      
      SET @n_GetCartonNo = @nCartonNo      
    END       
       
       
      IF  @n_GetCartonNo = @n_GetMaxCarton      
      BEGIN      
         SET @nSumPackQty = 0      
         SET @nSumPickQty = 0      
               
      
         SELECT @nSumPackQty = SUM(expQTY) FROM PackDetail WITH (NOLOCK)      
         WHERE PickSlipNo = @c_PickSlipNo      
         AND refno = @c_site       
    
  --WL01 START    
         --IF ISNULL(@c_Orderkey,'') = ''      
   SELECT @c_Conso = CONSO    
    ,@c_Discrete = Discrete     
  FROM #TMPPICKSLIPNO WHERE PickSlipNo = @c_PickSlipNo --AND VAS = @c_VAS    
    
   IF (@c_conso = 'Y' AND @c_Discrete = 'N')    
         BEGIN      
            SELECT @c_LoadKey = LoadKey       
            FROM PackHeader WITH (NOLOCK)      
            WHERE PickSlipNo = @c_PickSlipNo      
   --WL01 END    
    --CS08 start      
    SET @c_facility = ''      
      
    SELECT @c_facility = Facility      
    FROM LOADPLAN WITH (NOLOCK)      
    WHERE loadkey = @c_LoadKey      
      
    --CS08 End      
          /*  SELECT @nSumPickQty = SUM(PD.QTY)    --CS09      
            FROM PICKDETAIL pd WITH (NOLOCK)      
            JOIN LoadPlanDetail ld WITH (NOLOCK) ON  ld.OrderKey = pd.OrderKey      
            WHERE  ld.LoadKey = @c_LoadKey      
            AND EXISTS(SELECT 1      
                FROM LOC l WITH (NOLOCK)       
                JOIN CODELKUP cl(NOLOCK) ON cl.LISTNAME = 'ALLSorting'       
                WHERE l.Loc = pd.Loc       
                AND cl.code2 = l.PickZone       
                AND cl.Storerkey = pd.Storerkey       
                AND cl.Code = @c_site      
      AND l.facility = @c_facility )       --(CS08)       
      */ -- CS09       
    --CS09 Start        
    SELECT @nSumPickQty =  SUM(PD.QTY)       
            FROM     LoadPlanDetail ld WITH (NOLOCK)        
            JOIN Orders O WITH (NOLOCK) ON  ld.OrderKey = O.OrderKey      
            JOIN Orderdetail od WITH (NOLOCK) ON  O.OrderKey = od.OrderKey      
            JOIN  PICKDETAIL pd WITH (NOLOCK) ON pd.OrderKey = od.OrderKey and pd.OrderLineNumber = od.OrderLineNumber      
            JOIN  LOC LOC (NOLOCK) ON LOC.Loc = pd.Loc      
            WHERE  LD.LoadKey = @c_LoadKey   AND LOC.facility = @c_facility      
            AND EXISTS(SELECT 1      
                FROM  CODELKUP cl(NOLOCK)       
                WHERE cl.LISTNAME = N'ALLSorting'       
                AND cl.Code = @c_site       
                AND cl.code2 = LOC.PickZone       
                AND cl.Storerkey = O.Storerkey)       
                      
         --CS09 End         
         END      
         ELSE      
         BEGIN  --NJOW01      
        SELECT @nSumPickQty = SUM(PD.QTY)      
            FROM PickDetail PD WITH (NOLOCK)      
            WHERE PD.Orderkey = @c_Orderkey      
         END      
    
         IF  @n_GetCartonNo = @n_GetMaxCarton AND @nSumPackQty = @nSumPickQty      
         BEGIN      
            UPDATE #RESULT SET MaxCarton = ISNULL(RTRIM(Cast(@n_GetCartonNo AS NVARCHAR( 5))), 0)       
                     + '/' + ISNULL(RTRIM(Cast(@n_GetCartonNo AS NVARCHAR( 5))), 0)      
            WHERE ROWREF = @nRowRef       
         END      
         ELSE      
         BEGIN      
            UPDATE #RESULT SET MaxCarton = @n_GetCartonNo      
            WHERE ROWREF = @nRowRef       
         END      
      END      
      ELSE      
      BEGIN      
         UPDATE #RESULT SET MaxCarton = @n_GetCartonNo      
         WHERE ROWREF = @nRowRef                                     
      END      
      FETCH NEXT FROM CTN_CUR INTO @nCartonNo, @nRowRef  ,@c_site , @c_PickSlipNo        
   END      
   CLOSE CTN_CUR      
   DEALLOCATE CTN_CUR     
     
   -- SELECT distinct PICKSLIPNO,Loadkey,Discrete,Conso FROM #TMPPICKSLIPNO   
  
  --WL01 START    
  DECLARE cur_pickslipno2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
  SELECT distinct PICKSLIPNO,Discrete,Conso FROM #TMPPICKSLIPNO    
 -- WHERE VAS = @c_VAS    
  OPEN cur_pickslipno2    
      
  FETCH FROM cur_pickslipno2 INTO @c_pickslipno,@c_Discrete,@c_Conso     
  WHILE @@FETCH_STATUS = 0    
  BEGIN    
   --IF ISNULL(@c_Orderkey,'') = ''    
   IF (@c_Conso = 'Y' and @c_Discrete = 'N')   --Conso       
   BEGIN      
      SET @c_LoadKey      = ''      
      SET @c_ConsigneeKey = ''      
      SET @c_Company      = ''      
      SET @c_Address1     = ''      
      SET @c_Address2     = ''      
      SET @c_Address3     = ''      
      SET @c_City         = ''      
      SET @d_DeliveryDate = ''      
      SET @c_Stop         = ''      
    
   DECLARE CUR_LOADKEY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
    
   SELECT DISTINCT PICKSLIPNO, LOADKEY    
   FROM #TMPPICKSLIPNO    
   --WHERE VAS = @c_VAS    
    
   OPEN CUR_LOADKEY    
    
   FETCH FROM CUR_LOADKEY INTO @c_pickslipno, @c_loadkey    
   WHILE @@FETCH_STATUS = 0        
  BEGIN    
    SELECT @c_ConsigneeKey = MAX(ISNULL(RTRIM(ConsigneeKey),''))      
    , @c_Company      = MAX(ISNULL(RTRIM(C_Company),''))      
    , @c_Address1     = MAX(ISNULL(RTRIM(C_Address1),''))      
    , @c_Address2     = MAX(ISNULL(RTRIM(C_Address2),''))      
    , @c_Address3     = MAX(ISNULL(RTRIM(C_Address3),''))      
    , @c_City         = MAX(ISNULL(RTRIM(C_City),''))      
    , @d_DeliveryDate = MAX(ISNULL(RTRIM(DeliveryDate),''))      
    , @c_Stop         = MAX(ISNULL(RTRIM(Stop),''))      
    FROM ORDERS WITH (NOLOCK)      
    WHERE LoadKey = @c_LoadKey      
      
    UPDATE #RESULT SET      
      ConsigneeKey = @c_ConsigneeKey      
    , C_Company    = @c_Company      
    , C_Address1   = @c_Address1      
    , C_Address2   = @c_Address2      
    , C_Address3   = @c_Address3      
    , C_City       = @c_City      
    , DeliveryDate = @d_DeliveryDate      
    , LoadKey      = @c_LoadKey      
    , Stop         = @c_Stop      
    WHERE PickSlipNo     = @c_pickslipno      
      -- SOS# 174296 (End)      
  FETCH NEXT FROM CUR_LOADKEY INTO @c_pickslipno, @c_loadkey    
  END    
  CLOSE CUR_LOADKEY      
  DEALLOCATE CUR_LOADKEY    
  END    
  --WL01 END    
   FETCH NEXT FROM cur_pickslipno2 INTO @c_pickslipno,@c_Discrete,@c_Conso     
   END      
   CLOSE cur_pickslipno2      
   DEALLOCATE cur_pickslipno2    
         
   SELECT DISTINCT PickSlipNo, LoadKey, Route, ConsigneeKey, DeliveryDate,      
                            C_Company,  C_Address1,  C_Address2,  C_Address3,  C_City,      
                            xDockLane,  RIGHT(LabelNo,10) AS LabelNo,  CartonNo,  ExtOrder1,  ExtOrder2,      
                            ExtOrder3,  ExtOrder4, ExtOrder5,  ExtOrder6,  ExtOrder7,      
                            ExtOrder8,  ExtOrder9, ExtOrder10, TotalSku,   TotalPcs,      
                            MaxCarton,  ShowQtyCfg, OrderType, SUSR4, Stop,      
                            ShowField,ShowCRD,CRD, ExtraInfo                     
                           ,TotalQtyPacked,RefNo, RefNo2, SITELoadkey     
         ,SUBSTRING(USERDEFINE10,6,2) AS [MONTH] --WL01    
         ,SUBSTRING(USERDEFINE10,9,2) AS [DAY],CartonType   --WL01     
         ,ShowCartonType   --WL01    
   FROM #RESULT      
   WHERE 1 = CASE WHEN @c_RefNo <> '' AND RefNo = @c_RefNo THEN 1      
                  WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo <> '' AND refno <> '' AND RefNo <> @c_ShippingFilterByRefNo THEN 1      
                  WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo <> '' and Refno = '' AND RefNo <> @c_ShippingFilterByRefNo THEN  1      
                  WHEN @c_RefNo = '' AND @c_ShippingFilterByRefNo = '' THEN 1       
                  ELSE 0      
             END      
  AND MaxCarton NOT LIKE '-%'       
  AND MaxCarton >'0'      
  ORDER BY CartonNo      
  
   DROP TABLE #RESULT      
   DROP TABLE #CTNRESULT      
END     
  
