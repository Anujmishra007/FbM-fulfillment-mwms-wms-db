IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetDmanifest_Dsum03]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetDmanifest_Dsum03]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Store Procedure:  isp_GetDmanifest_Dsum03                            */  
/* Creation Date:08-JAN-2018                                            */  
/* Copyright: IDS                                                       */  
/* Written by: CSCHONG                                                  */  
/*                                                                      */  
/* Purpose:  WMS-3692                                                   */  
/*                                                                      */  
/* Input Parameters: mbolkey                                            */  
/*                                                                      */  
/* Output Parameters:                                                   */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By:  r_dw_danifest_sum03                                      */  
/*                                                                      */  
/* PVCS Version: 1.1                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/* 2018-Mar-05  CSCHONG  1.0  WMS-3979-revised field mapping (CS01)     */  
/* 2018-Jun-18  SPChin   1.1  INC0254077 - Bug Fixed                    */  
/* 2018-Aug-01  NJOW01   1.2  WMS-5655 Change estimate uploading time   */  
/* 2018-Nov-22  WLCHOOI  1.3  WMS-7090 Add new zone setup (WL01)	      */  
/* 2020-Jun-09  WLChooi  1.4  Performance Tunning (WL02)                */
/************************************************************************/  
  
CREATE PROC [dbo].[isp_GetDmanifest_Dsum03] (  
         @c_mbolKey      NVARCHAR(20)   
        ,@c_Zone         NVARCHAR(20)  
)  
AS  
BEGIN  
  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
  
 DECLARE  @n_cntRefno           INT                    --(CS01)     
     ,@c_site               NVARCHAR(30)           --(CS01)   
     ,@c_storerkey          NVARCHAR(20)           --(CS01)    
     ,@c_qtyPick            int  --(vince)  
     ,@c_qtyPack            int  --(vince)  
     ,@n_err        INT --(vince)  
     ,@c_CodeCityLdTime     NVARCHAR(30) = 'CityLdTime'   --WL02
       
   SET @n_err = 0  --(vince)  
  
 IF ISNULL(@c_Zone,'') <> ''  
 BEGIN     
  SELECT  SUM(b.Qty) pick_qty,  
          a.LOADKEY pick_load   
  INTO #tmp_PICKQTYBYLOAD   
  FROM dbo.ORDERS (nolock) a   --INC0254077  
  JOIN dbo.PICKDETAIL (nolock) b ON a.OrderKey=b.OrderKey --AND a.Sku=b.Sku            --INC0254077  
  JOIN loc (nolock) c ON b.Loc=c.Loc  
  JOIN dbo.CODELKUP (nolock) d ON c.PickZone=d.code2  
  WHERE a.MBOLKey=@c_mbolKey AND D.Code=@c_Zone   
  AND d.LISTNAME='allsorting' AND a.StorerKey=d.Storerkey  
  GROUP BY a.LOADKEY  
  
   SELECT LoadKey,  
          PickSlipNo  
  INTO #tmp_loadPSN  
  FROM dbo.PackHeader (nolock)   
   WHERE LoadKey IN (SELECT LoadKey from orders (NOLOCK) WHERE MBOLKey=@c_mbolKey)  
  
  SELECT SUM(cc.Qty) pack_qty ,aa.LOADKEY pack_load   
  INTO #tmp_PACKQTYBYLOAD   
  FROM dbo.#tmp_loadPSN (nolock) aa   
  jOIN dbo.PackDetail (nolock)  cc ON aa.PickSlipNo=cc.PickSlipNo   
  WHERE CC.RefNo=@c_Zone  
  GROUP BY aa.LOADKEY ,aa.LOADKEY  
    
   --vince end   
     
    /*Cs01 Start*/  
    SET @n_cntRefno = 1  
      
    SELECT @c_storerkey =Storerkey  
    FROM ORDERS WITH (NOLOCK)  
    WHERE mbolkey = @c_mbolKey       
      
    SELECT ISNULL(COUNT(DISTINCT c.code),1) AS cntRefno,  
           dbo.ORDERS.LoadKey AS loadkey   
    INTO #tmp_byload  
   FROM  MBOL (NOLOCK)   
    JOIN ORDERS (NOLOCK)ON (MBOL.Mbolkey = Orders.Mbolkey)  
   LEFT JOIN PICKDETAIL PD (NOLOCK) ON PD.orderkey = ORDERS.OrderKey  
   LEFT JOIN LOC L WITH (NOLOCK) ON L.loc=pd.Loc  
   LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.listname = 'ALLSorting' AND  
                                         C.Storerkey=ORDERS.StorerKey AND C.code2=L.PickZone   
   WHERE ( MBOL.MbolKey = @c_mbolKey)  
   GROUP BY dbo.ORDERS.LoadKey   
    
  /*CS01 End*/    
     
  SELECT DISTINCT CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.AddWho ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.MbolKey ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.BookingReference ELSE '' END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.OtherReference ELSE '' END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.PlaceOfLoading ELSE '' END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.PlaceOfDischarge ELSE '' END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.EffectiveDate ELSE '' END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.CarrierKey ELSE '' END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.Vessel ELSE '' END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.VoyageNumber ELSE '' END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.DRIVERName ELSE '' END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.Editdate ELSE '' END ,    
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.ConsigneeKey ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.ExternOrderKey ELSE ''  END,    
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Address1 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Address2 ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Address3 ELSE '' END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Address4 ELSE '' END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Contact1 ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Contact2 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Phone1 ELSE ''END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Phone2 ELSE '' END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Fax1 ELSE '' END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Fax2 ELSE ''END ,  
       CASE WHEN TBL.cntRefno>1 THEN  @c_Zone + '-' + ORDERS.Loadkey ELSE ORDERS.Loadkey END AS loadkey,   --CS01--ORDERS.Loadkey,  
       CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.DeliveryDate ELSE '' END,  
       CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.Grossweight ELSE ''END ,  
       CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.Capacity ELSE ''END ,   
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.Loadkey ELSE '' END AS OHLOAD,   --CS01--ORDERS.Loadkey,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.Facility ELSE '' END,  
         1 AS CartonNo,  
         '' AS Pickslipno,  
         '' AS pickzone,  
         '0' AS FWQTY,  
         '0' AS APPQTY,  
         '0' AS EQQTY,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN Orders.C_Company ELSE '' END,  
         ETA =CASE WHEN  bb.pick_qty=cc.pack_qty THEN   
                   (         
                     CASE WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 0 THEN  --NJOW01  
                              DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))  
                          WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 1  THEN --NJOW01  
                             CASE WHEN DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10)) >= CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) THEN   
                               DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))   
                                 ELSE CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) END    
                        WHEN CLC.Short IS NULL OR ISNUMERIC(CLC.Short) <> 1 THEN MBOL.EditDate    
                         ELSE CASE WHEN Orders.Intermodalvehicle = 'ILOE' THEN   
                                 DATEADD(HOUR, CEILING(CAST(CLC.Short AS REAL)), CONVERT(DATETIME,CONVERT(CHAR(8),MBOL.EditDate,112))+1)  
                               ELSE  
                                 DATEADD(DAY, CEILING(CAST(CLC.Short AS REAL)), MBOL.EditDate )  
                               END  
                     END  
                   )   
                  ELSE '' END,  /* Added ETA = ETD (MBOL.EditDate) + LeadTime */       
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN CAST(ORDERS.Notes AS CHAR(255)) ELSE '' END AS Notes,   
        CASE WHEN  bb.pick_qty=cc.pack_qty THEN  ISNULL(RTRIM(CAST(STORER.notes1 AS CHAR(255))), '') + SPACE(1) + ISNULL(RTRIM(CAST(STORER.notes2 AS CHAR(255))),'') ELSE '' END AS Remarks,  
    /*(substring(STORER.notes1,1,16) + SPACE(1) + substring(STORER.notes2,1,16)) as Remarks,*/     
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_City ELSE '' END,  
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN Orders.intermodalvehicle ELSE '' END,   
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN CODELKUP.Short ELSE '' END AS Domain,  
        ShowField = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN ISNULL(CLR.Code,'') <> '' THEN 'Y' ELSE 'N' END) ELSE '' END  ,  
        ShowCRD  = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD' AND ISNULL(ORDERS.userdefine10,'') <> ''  
                     AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))   
                  <  LEFT(ORDERS.ExternPOKey,8))) THEN   
                CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN   
               -- CASE WHEN CONVERT(INT,REPLACE)  
                'Y' ELSE 'N' END  
                ELSE 'N' END  ) ELSE '' END,  
        CASE WHEN  bb.pick_qty=cc.pack_qty THEN  SUBSTRING(ORDERS.ExternPOKey,1,4) + '-' + SUBSTRING(ORDERS.ExternPOKey,5,2) + '-' + SUBSTRING(ORDERS.ExternPOKey,7,2) ELSE '' END CRD,   
     LP =CASE WHEN  bb.pick_qty=cc.pack_qty THEN ( CASE WHEN @c_Zone ='CRW' THEN CLR2.NOTES2   
                WHEN @c_Zone = 'CRWP' THEN CLR2.NOTES WHEN @c_Zone = 'ECTR' THEN CLR2.NOTES2 ELSE '' END ) ELSE '' END,        --CS01 --WL01 
     CT = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN  @c_Zone ='CRW' THEN  CLR1.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR1.NOTES WHEN @c_Zone = 'ECTR' THEN CLR1.NOTES2 ELSE '' END ) ELSE '' END,  --WL01 
     TL =CASE WHEN  bb.pick_qty=cc.pack_qty THEN ( CASE WHEN @c_Zone ='CRW' THEN CLR3.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR3.NOTES WHEN @c_Zone = 'ECTR' THEN CLR3.NOTES2 ELSE '' END ) ELSE '' END,  --WL01 
     FX = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN @c_Zone ='CRW' THEN CLR4.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR4.NOTES WHEN @c_Zone = 'ECTR' THEN CLR4.NOTES2 ELSE '' END ) ELSE '' END,  --WL01 
    [SITE] = @c_Zone                                         --CS01   
        FROM  MBOL (NOLOCK)  
        JOIN MBOLDETAIL (NOLOCK) ON (MBOL.Mbolkey = MBOLDETAIL.Mbolkey )     
        JOIN ORDERS (NOLOCK)ON (MBOLDETAIL.Orderkey = Orders.Orderkey)  
        LEFT OUTER JOIN PICKHEADER (NOLOCK) ON (ORDERS.Loadkey = PICKHEADER.ExternOrderkey)  
     LEFT OUTER JOIN CODELKUP CLC (NOLOCK) ON (CLC.LONG = ORDERS.Facility AND   
              CLC.Description = ORDERS.c_City AND  
              CLC.ListName = @c_CodeCityLdTime AND   --WL02   
                                          CAST(CLC.Notes AS CHAR(30)) = Orders.intermodalvehicle)   
    LEFT OUTER JOIN CODELKUP (NOLOCK) ON (CODELKUP.Listname = 'STRDOMAIN' AND  
          CODELKUP.Code = ORDERS.StorerKey)   
    LEFT OUTER JOIN STORER (NOLOCK) ON (STORER.StorerKey = ORDERS.ConsigneeKey)  
              LEFT OUTER JOIN Codelkup CLR (NOLOCK) ON (ORDERS.Storerkey = CLR.Storerkey AND CLR.Code = 'SHOWFIELD'                                          
                                        AND CLR.Listname = 'REPORTCFG' AND CLR.Long = 'r_dw_dmanifest_sum03' AND ISNULL(CLR.Short,'') <> 'N')  
    LEFT OUTER JOIN CODELKUP CLR1 (NOLOCK) ON (ORDERS.Storerkey = CLR1.Storerkey AND CLR1.Listname = 'REPORTCFG'    
            AND CLR1.Long = 'r_dw_dmanifest_sum03' AND CLR1.Code = 'ShowCTName' AND ISNULL(CLR1.Short,'') <> 'N')  
    LEFT OUTER JOIN CODELKUP CLR2 (NOLOCK) ON (ORDERS.Storerkey = CLR2.Storerkey AND CLR2.Listname = 'REPORTCFG'    
            AND CLR2.Long = 'r_dw_dmanifest_sum03' AND CLR2.Code = 'ShowLPName' AND ISNULL(CLR2.Short,'') <> 'N')  
    LEFT OUTER JOIN CODELKUP CLR3 (NOLOCK) ON (ORDERS.Storerkey = CLR3.Storerkey AND CLR3.Listname = 'REPORTCFG'    
            AND CLR3.Long = 'r_dw_dmanifest_sum03' AND CLR3.Code = 'ShowTLName' AND ISNULL(CLR3.Short,'') <> 'N')  
    LEFT OUTER JOIN CODELKUP CLR4 (NOLOCK) ON (ORDERS.Storerkey = CLR4.Storerkey AND CLR4.Listname = 'REPORTCFG'    
            AND CLR4.Long = 'r_dw_dmanifest_sum03' AND CLR4.Code = 'ShowFXName' AND ISNULL(CLR4.Short,'') <> 'N')     
      LEFT JOIN #tmp_byload TBL ON orders.LoadKey=TBL.loadkey      ---vince01       
         LEFT JOIN #tmp_PICKQTYBYLOAD bb ON    orders.LoadKey=bb.pick_load   
    LEFT JOIN #tmp_PACKQTYBYLOAD cc ON    orders.LoadKey=cc.pack_load                                                  
       WHERE ( MBOL.MbolKey = @c_mbolKey)  
       --AND PACKDETAIL.StorerKey = @c_storerkey           --CS01  
       AND   PICKHEADER.Pickheaderkey IS NULL  
  UNION ALL  
   SELECT DISTINCT CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.AddWho ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.MbolKey ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.BookingReference ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.OtherReference ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.PlaceOfLoading ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.PlaceOfDischarge ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.EffectiveDate ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.CarrierKey ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.Vessel ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.VoyageNumber ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.DRIVERName ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.Editdate ELSE ''  END,    
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.ConsigneeKey ELSE ''  END,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.ExternOrderKey ELSE ''  END,    
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Address1 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Address2 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Address3 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Address4 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Contact1 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Contact2 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Phone1 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Phone2 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Fax1 ELSE ''  END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_Fax2 ELSE ''  END,  
       CASE WHEN TBL.cntRefno> 1  THEN  @c_Zone + '-' + ORDERS.Loadkey ELSE ORDERS.Loadkey END AS loadkey,   --CS01--ORDERS.Loadkey,  
       CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.DeliveryDate ELSE ''  END,  
       CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.Grossweight ELSE ''  END,  
       CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.Capacity ELSE ''  END,   
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.Loadkey  ELSE ''  END AS OHLOAD,   --CS01--ORDERS.Loadkey,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.Facility ELSE ''  END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN Packdetail.CartonNo  ELSE ''  END AS CartonNo ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN Packdetail.Pickslipno  ELSE ''  END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN Pickheader.Zone  ELSE ''  END AS PickZone,  
         (SELECT SUM(packdetail.qty)   
    FROM packdetail(NOLOCK),sku(NOLOCK) WHERE packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku AND sku.skugroup = 'FOOTWEAR'  
    AND packdetail.Storerkey =PackHeader.Storerkey AND packdetail.Pickslipno =PackHeader.Pickslipno  AND PACKDETAIL.RefNo = @c_Zone)   AS FWQTY,  
        (SELECT SUM(packdetail.qty)  
    FROM packdetail(NOLOCK),sku(NOLOCK) WHERE packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku AND sku.skugroup = 'APPAREL'  
    AND packdetail.Storerkey =PackHeader.Storerkey AND packdetail.Pickslipno =PackHeader.Pickslipno  AND PACKDETAIL.RefNo = @c_Zone)   AS APPQTY,  
          (SELECT SUM(packdetail.qty)   
    FROM packdetail(NOLOCK),sku(NOLOCK) WHERE packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku AND sku.skugroup = 'EQUIPMENT'  
    AND packdetail.Storerkey =PackHeader.Storerkey AND packdetail.Pickslipno =PackHeader.Pickslipno  AND PACKDETAIL.RefNo = @c_Zone)   AS EQQTY,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN Orders.C_company ELSE ''  END ,  
        ETA =CASE WHEN  bb.pick_qty=cc.pack_qty THEN(  
                CASE WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 0 THEN  --NJOW01  
                        DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))   
                     WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 1  THEN --NJOW01  
                    CASE WHEN DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10)) >= CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) THEN   
                        DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))  
                    ELSE CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) END    
                  WHEN CLC.Short IS NULL OR ISNUMERIC(CLC.Short) <> 1 THEN MBOL.EditDate    
                 ELSE CASE WHEN Orders.Intermodalvehicle = 'ILOE' THEN   
                           DATEADD(HOUR, CEILING(CAST(CLC.Short AS REAL)), CONVERT(DATETIME,CONVERT(CHAR(8),MBOL.EditDate,112))+1)  
                           ELSE  
                           DATEADD(DAY, CEILING(CAST(CLC.Short AS REAL)), MBOL.EditDate )  
                           END  
             END)ELSE '' END  , /* Added ETA = ETD (MBOL.EditDate) + LeadTime */  
   CASE WHEN  bb.pick_qty=cc.pack_qty THEN CAST(ORDERS.Notes AS CHAR(255))  ELSE ''  END AS Notes,    
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN RTRIM(CAST(STORER.notes1 AS CHAR(255))) + SPACE(1) + RTRIM(CAST(STORER.notes2 AS CHAR(255)))  ELSE ''  END AS Remarks,  
    /* (substring(STORER.notes1,1,16) + SPACE(1) + substring(STORER.notes2,1,16)) as Remarks, */    
   CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_City ELSE ''  END ,   
   CASE WHEN  bb.pick_qty=cc.pack_qty THEN Orders.intermodalvehicle ELSE ''  END ,   
   CASE WHEN  bb.pick_qty=cc.pack_qty THEN CODELKUP.Short ELSE ''  END ,  
         ShowField = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN ISNULL(CLR.Code,'') <> '' THEN 'Y' ELSE 'N' END) ELSE '' END  ,  
         ShowCRD  = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD' AND ISNULL(ORDERS.userdefine10,'') <> ''  
                     AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))   
                  <  LEFT(ORDERS.ExternPOKey,8))) THEN   
                CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN   
               -- CASE WHEN CONVERT(INT,REPLACE)  
                'Y' ELSE 'N' END  
                ELSE 'N' END  ) ELSE '' END,  
          CASE WHEN  bb.pick_qty=cc.pack_qty THEN  SUBSTRING(ORDERS.ExternPOKey,1,4) + '-' + SUBSTRING(ORDERS.ExternPOKey,5,2) + '-' + SUBSTRING(ORDERS.ExternPOKey,7,2) ELSE ''  END CRD ,             
     LP =CASE WHEN  bb.pick_qty=cc.pack_qty THEN ( CASE WHEN @c_Zone ='CRW' THEN CLR2.NOTES2   
                WHEN @c_Zone = 'CRWP' THEN CLR2.NOTES WHEN @c_Zone = 'ECTR' THEN CLR2.NOTES2 ELSE '' END ) ELSE '' END,        --CS01  --WL01 
     CT = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN  @c_Zone ='CRW' THEN  CLR1.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR1.NOTES WHEN @c_Zone = 'ECTR' THEN CLR1.NOTES2 ELSE '' END ) ELSE '' END,  --WL01 
     TL =CASE WHEN  bb.pick_qty=cc.pack_qty THEN ( CASE WHEN @c_Zone ='CRW' THEN CLR3.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR3.NOTES WHEN @c_Zone = 'ECTR' THEN CLR3.NOTES2 ELSE '' END ) ELSE '' END,  --WL01 
     FX = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN @c_Zone ='CRW' THEN CLR4.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR4.NOTES WHEN @c_Zone = 'ECTR' THEN CLR4.NOTES2 ELSE '' END ) ELSE '' END,  --WL01 
   [SITE] = @c_Zone--CASE WHEN @n_cntRefno>1 THEN @c_Zone  ELSE '' END                                                       --CS01  
         FROM  MBOL (NOLOCK)  
         JOIN MBOLDETAIL (NOLOCK) ON (MBOL.Mbolkey = MBOLDETAIL.Mbolkey )     
         INNER JOIN ORDERS (NOLOCK)ON (MBOLDETAIL.Orderkey = Orders.Orderkey)  
         INNER JOIN PACKHEADER (NOLOCK) ON (ORDERS.Storerkey = PACKHEADER.Storerkey AND ORDERS.Orderkey = PACKHEADER.Orderkey)  
         INNER JOIN PACKDETAIL (NOLOCK) ON (PACKHEADER.Storerkey = PACKDETAIL.Storerkey AND PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno)   
         INNER JOIN PICKHEADER (NOLOCK) ON (PACKHEADER.Pickslipno = PICKHEADER.Pickheaderkey)  
      LEFT OUTER JOIN CODELKUP CLC (NOLOCK) ON (CLC.LONG = ORDERS.Facility AND   
                 CLC.Description = ORDERS.c_City AND  
                 CLC.ListName = @c_CodeCityLdTime AND   --WL02   
                                             CAST(CLC.Notes AS CHAR(30)) = Orders.intermodalvehicle)   
      LEFT OUTER JOIN CODELKUP (NOLOCK) ON (CODELKUP.Listname = 'STRDOMAIN' AND  
            CODELKUP.Code = ORDERS.StorerKey)   
         LEFT OUTER JOIN STORER (NOLOCK) ON (STORER.StorerKey = ORDERS.ConsigneeKey)  
         LEFT OUTER JOIN Codelkup CLR (NOLOCK) ON (ORDERS.Storerkey = CLR.Storerkey AND CLR.Code = 'SHOWFIELD'                                          
                                          AND CLR.Listname = 'REPORTCFG' AND CLR.Long = 'r_dw_dmanifest_sum03' AND ISNULL(CLR.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR1 (NOLOCK) ON (ORDERS.Storerkey = CLR1.Storerkey AND CLR1.Listname = 'REPORTCFG'    
              AND CLR1.Long = 'r_dw_dmanifest_sum03' AND CLR1.Code = 'ShowCTName' AND ISNULL(CLR1.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR2 (NOLOCK) ON (ORDERS.Storerkey = CLR2.Storerkey AND CLR2.Listname = 'REPORTCFG'    
              AND CLR2.Long = 'r_dw_dmanifest_sum03' AND CLR2.Code = 'ShowLPName' AND ISNULL(CLR2.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR3 (NOLOCK) ON (ORDERS.Storerkey = CLR3.Storerkey AND CLR3.Listname = 'REPORTCFG'    
              AND CLR3.Long = 'r_dw_dmanifest_sum03' AND CLR3.Code = 'ShowTLName' AND ISNULL(CLR3.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR4 (NOLOCK) ON (ORDERS.Storerkey = CLR4.Storerkey AND CLR4.Listname = 'REPORTCFG'    
             AND CLR4.Long = 'r_dw_dmanifest_sum03' AND CLR4.Code = 'ShowFXName' AND ISNULL(CLR4.Short,'') <> 'N')   
        LEFT JOIN #tmp_byload TBL ON orders.LoadKey=TBL.loadkey      ---vince01      
       LEFT JOIN #tmp_PICKQTYBYLOAD bb ON    orders.LoadKey=bb.pick_load   
      LEFT JOIN #tmp_PACKQTYBYLOAD cc ON    orders.LoadKey=cc.pack_load                                                    
    WHERE ( MBOL.MbolKey = @c_mbolKey)  
    AND PACKDETAIL.RefNo = @c_Zone  
    AND PACKDETAIL.StorerKey = @c_storerkey           --CS01  
    AND   ( RTRIM(PICKHEADER.OrderKey) IS NOT NULL AND RTRIM(PICKHEADER.OrderKey) <> '')   
  UNION ALL  
  SELECT   
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.AddWho  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.MbolKey  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.BookingReference  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.OtherReference  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.PlaceOfLoading  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.PlaceOfDischarge  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.EffectiveDate  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.CarrierKey  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.Vessel  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.VoyageNumber  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.DRIVERName  ELSE '' END ,     
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.Editdate  ELSE '' END ,    
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.ConsigneeKey)  ELSE '' END ,     
         '' AS ExternOrderKey,    
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Address1)  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Address2)  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Address3)  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Address4)  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Contact1)  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Contact2)  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Phone1)  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Phone2)  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Fax1)  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(ORDERS.C_Fax2)  ELSE '' END ,  
       CASE WHEN TBL.cntRefno> 1 THEN  @c_Zone + '-' + ORDERS.Loadkey ELSE ORDERS.Loadkey END AS loadkey,--ORDERS.Loadkey,  --CS01  
       CASE WHEN  bb.pick_qty=cc.pack_qty THEN  MAX(ORDERS.DeliveryDate)  ELSE '' END ,  
       CASE WHEN  bb.pick_qty=cc.pack_qty THEN  SUM(ORDERS.Grossweight)  ELSE '' END ,  
       CASE WHEN  bb.pick_qty=cc.pack_qty THEN SUM(ORDERS.Capacity)  ELSE '' END ,   
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.Loadkey   ELSE '' END AS OHLOAD,--ORDERS.Loadkey,  --CS01  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN MBOL.Facility  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN Packdetail.CartonNo  ELSE ''  END AS CartonNo ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN PackHeader.Pickslipno  ELSE '' END ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN Pickheader.Zone   ELSE '' END ,   
          (SELECT SUM(packdetail.qty)   
        FROM packdetail(NOLOCK),sku(NOLOCK) WHERE packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku AND sku.skugroup = 'FOOTWEAR'  
        AND packdetail.Storerkey =PackHeader.Storerkey AND packdetail.Pickslipno =PackHeader.Pickslipno  AND PACKDETAIL.RefNo = @c_Zone )    AS FWQTY,  
         (SELECT SUM(packdetail.qty)  
       FROM packdetail(NOLOCK),sku(NOLOCK) WHERE packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku AND sku.skugroup = 'APPAREL'  
       AND packdetail.Storerkey =PackHeader.Storerkey AND packdetail.Pickslipno =PackHeader.Pickslipno  AND PACKDETAIL.RefNo = @c_Zone)    AS APPQTY,  
         (SELECT SUM(packdetail.qty)   
       FROM packdetail(NOLOCK),sku(NOLOCK) WHERE packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku AND sku.skugroup = 'EQUIPMENT'  
       AND packdetail.Storerkey =PackHeader.Storerkey AND packdetail.Pickslipno =PackHeader.Pickslipno  AND PACKDETAIL.RefNo = @c_Zone )    AS EQQTY,  
          CASE WHEN  bb.pick_qty=cc.pack_qty THEN MAX(Orders.C_company)  ELSE '' END ,  
          ETA =CASE WHEN  bb.pick_qty=cc.pack_qty THEN(  
                CASE WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 0 THEN  --NJOW01  
                       DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))   
                     WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 1  THEN --NJOW01  
                    CASE WHEN DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10)) >= CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) THEN   
                        DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))  
                    ELSE CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) END    
                 WHEN CLC.Short IS NULL OR ISNUMERIC(CLC.Short) <> 1 THEN MBOL.EditDate    
                ELSE CASE WHEN Orders.Intermodalvehicle = 'ILOE' THEN   
                          DATEADD(HOUR, CEILING(CAST(CLC.Short AS REAL)), CONVERT(DATETIME,CONVERT(CHAR(8),MBOL.EditDate,112))+1)  
                          ELSE  
                          DATEADD(DAY, CEILING(CAST(CLC.Short AS REAL)), MBOL.EditDate )   
                          END  
              END)ELSE '' END  ,  /* Added ETA = ETD (MBOL.EditDate) + LeadTime */  
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN CAST(ORDERS.Notes AS CHAR(255))  ELSE '' END  AS Notes,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN RTRIM(CAST(STORER.notes1 AS CHAR(255))) + SPACE(1) + RTRIM(CAST(STORER.notes2 AS CHAR(255))) ELSE '' END AS Remarks,  
      /* (substring(STORER.notes1,1,16) + SPACE(1) + substring(STORER.notes2,1,16)) as Remarks, */    
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN ORDERS.C_City  ELSE '' END ,   
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN Orders.intermodalvehicle  ELSE '' END ,   
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN CODELKUP.Short  ELSE '' END ,  
         ShowField = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN ISNULL(CLR.Code,'') <> '' THEN 'Y' ELSE 'N' END) ELSE '' END  ,  
         ShowCRD  = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD' AND ISNULL(ORDERS.userdefine10,'') <> ''  
                     AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))   
                  <  LEFT(ORDERS.ExternPOKey,8))) THEN   
                CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN   
               -- CASE WHEN CONVERT(INT,REPLACE)  
                'Y' ELSE 'N' END  
                ELSE 'N' END  ) ELSE '' END,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN  SUBSTRING(ORDERS.ExternPOKey,1,4) + '-' + SUBSTRING(ORDERS.ExternPOKey,5,2) + '-' + SUBSTRING(ORDERS.ExternPOKey,7,2)  ELSE '' END CRD ,   
     LP =CASE WHEN  bb.pick_qty=cc.pack_qty THEN ( CASE WHEN @c_Zone ='CRW' THEN CLR2.NOTES2   
                WHEN @c_Zone = 'CRWP' THEN CLR2.NOTES WHEN @c_Zone = 'ECTR' THEN CLR2.NOTES2 ELSE '' END ) ELSE '' END,        --CS01 --WL01  
     CT = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN  @c_Zone ='CRW' THEN  CLR1.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR1.NOTES WHEN @c_Zone = 'ECTR' THEN CLR1.NOTES2 ELSE '' END ) ELSE '' END,  --WL01 
     TL =CASE WHEN  bb.pick_qty=cc.pack_qty THEN ( CASE WHEN @c_Zone ='CRW' THEN CLR3.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR3.NOTES WHEN @c_Zone = 'ECTR' THEN CLR3.NOTES2 ELSE '' END ) ELSE '' END, --WL01  
     FX = CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN @c_Zone ='CRW' THEN CLR4.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR4.NOTES WHEN @c_Zone = 'ECTR' THEN CLR4.NOTES2 ELSE '' END ) ELSE '' END,  --WL01 
      [SITE] = @c_Zone--CASE WHEN @n_cntRefno>1 THEN @c_Zone  ELSE '' END                                                       --CS01         
         FROM  MBOL (NOLOCK)  
         JOIN MBOLDETAIL (NOLOCK) ON (MBOL.Mbolkey = MBOLDETAIL.Mbolkey )     
         INNER JOIN ORDERS (NOLOCK)ON (MBOLDETAIL.Orderkey = Orders.Orderkey)  
         INNER JOIN PACKHEADER (NOLOCK) ON (ORDERS.Storerkey = PACKHEADER.Storerkey AND ORDERS.Loadkey = PACKHEADER.Loadkey)  
         INNER JOIN PACKDETAIL (NOLOCK) ON (PACKHEADER.Storerkey = PACKDETAIL.Storerkey AND PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno)   
         INNER JOIN PICKHEADER (NOLOCK) ON (PACKHEADER.Pickslipno = PICKHEADER.Pickheaderkey)  
      LEFT OUTER JOIN CODELKUP CLC (NOLOCK) ON (CLC.LONG = ORDERS.Facility AND   
                 CLC.Description = ORDERS.c_City AND  
                 CLC.ListName = @c_CodeCityLdTime AND   --WL02   
                                             CAST(CLC.Notes AS CHAR(30)) = Orders.intermodalvehicle)   
      LEFT OUTER JOIN CODELKUP (NOLOCK) ON (CODELKUP.Listname = 'STRDOMAIN' AND  
            CODELKUP.Code = ORDERS.StorerKey)   
      LEFT OUTER JOIN STORER (NOLOCK) ON (STORER.StorerKey = ORDERS.ConsigneeKey)   
                 LEFT OUTER JOIN Codelkup CLR (NOLOCK) ON (ORDERS.Storerkey = CLR.Storerkey AND CLR.Code = 'SHOWFIELD'                                          
                                          AND CLR.Listname = 'REPORTCFG' AND CLR.Long = 'r_dw_dmanifest_sum03' AND ISNULL(CLR.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR1 (NOLOCK) ON (ORDERS.Storerkey = CLR1.Storerkey AND CLR1.Listname = 'REPORTCFG'    
              AND CLR1.Long = 'r_dw_dmanifest_sum03' AND CLR1.Code = 'ShowCTName' AND ISNULL(CLR1.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR2 (NOLOCK) ON (ORDERS.Storerkey = CLR2.Storerkey AND CLR2.Listname = 'REPORTCFG'    
              AND CLR2.Long = 'r_dw_dmanifest_sum03' AND CLR2.Code = 'ShowLPName' AND ISNULL(CLR2.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR3 (NOLOCK) ON (ORDERS.Storerkey = CLR3.Storerkey AND CLR3.Listname = 'REPORTCFG'    
              AND CLR3.Long = 'r_dw_dmanifest_sum03' AND CLR3.Code = 'ShowTLName' AND ISNULL(CLR3.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR4 (NOLOCK) ON (ORDERS.Storerkey = CLR4.Storerkey AND CLR4.Listname = 'REPORTCFG'    
           AND CLR4.Long = 'r_dw_dmanifest_sum03' AND CLR4.Code = 'ShowFXName' AND ISNULL(CLR4.Short,'') <> 'N')      
       LEFT JOIN #tmp_byload TBL ON orders.LoadKey=TBL.loadkey      ---vince01      
     LEFT JOIN #tmp_PICKQTYBYLOAD bb ON    orders.LoadKey=bb.pick_load   
      LEFT JOIN #tmp_PACKQTYBYLOAD cc ON    orders.LoadKey=cc.pack_load                                                    
   WHERE ( MBOL.MbolKey = @c_mbolKey)  
   AND PACKDETAIL.RefNo = @c_Zone  
   AND PACKDETAIL.StorerKey = @c_storerkey           --CS01  
   AND   ( RTRIM(PackHeader.OrderKey) IS NULL OR RTRIM(PackHeader.OrderKey) = '')   
   GROUP BY PackHeader.Storerkey, PackHeader.Pickslipno,  
         Packdetail.CartonNo,  
         MBOL.AddWho,     
         MBOL.MbolKey,     
         MBOL.BookingReference,     
         MBOL.OtherReference,     
         MBOL.PlaceOfLoading,     
         MBOL.PlaceOfDischarge,     
         MBOL.EffectiveDate,     
         MBOL.CarrierKey,     
         MBOL.Vessel,     
         MBOL.VoyageNumber,     
         MBOL.DRIVERName,     
         MBOL.Editdate,    
         ORDERS.Loadkey,  
         MBOL.Facility,  
         Pickheader.Zone,  
      MBOL.EditDate,  
      CLC.Short,  
      CAST(ORDERS.Notes AS CHAR(255)),    
         RTRIM(CAST(STORER.notes1 AS CHAR(255))) + SPACE(1) + RTRIM(CAST(STORER.notes2 AS CHAR(255))),  
      ORDERS.C_City,  
      Orders.intermodalvehicle,   
      CODELKUP.Short,  
         ORDERS.Userdefine01,  
         ORDERS.Userdefine04,  
         ORDERS.ExternPOKey,  
         ISNULL(CLR.Code,''),  
         ISNULL(STORER.SUSR1,'') ,  
         CASE WHEN  bb.pick_qty=cc.pack_qty THEN  SUBSTRING(ORDERS.ExternPOKey,1,4) + '-' + SUBSTRING(ORDERS.ExternPOKey,5,2) + '-' + SUBSTRING(ORDERS.ExternPOKey,7,2)  ELSE '' END,  
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN ( CASE WHEN @c_Zone ='CRW' THEN CLR2.NOTES2   
                WHEN @c_Zone = 'CRWP' THEN CLR2.NOTES WHEN @c_Zone = 'ECTR' THEN CLR2.NOTES2 ELSE '' END ) ELSE '' END,        --CS01  
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN  @c_Zone ='CRW' THEN  CLR1.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR1.NOTES WHEN @c_Zone = 'ECTR' THEN CLR1.NOTES2 ELSE '' END ) ELSE '' END,  
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN ( CASE WHEN @c_Zone ='CRW' THEN CLR3.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR3.NOTES WHEN @c_Zone = 'ECTR' THEN CLR3.NOTES2 ELSE '' END ) ELSE '' END,  
      CASE WHEN  bb.pick_qty=cc.pack_qty THEN (CASE WHEN @c_Zone ='CRW' THEN CLR4.NOTES2   
          WHEN @c_Zone = 'CRWP' THEN CLR4.NOTES WHEN @c_Zone = 'ECTR' THEN CLR4.NOTES2 ELSE '' END ) ELSE '' END,  
   /*CS01 End*/  
         ORDERS.userdefine10   
         ,CASE WHEN TBL.cntRefno>1 THEN  @c_Zone + '-' + ORDERS.Loadkey ELSE ORDERS.Loadkey END  ---vince01  
       ,bb.pick_qty,cc.pack_qty  
 END  
 ELSE  
 BEGIN  
    SELECT DISTINCT MBOL.AddWho,     
            MBOL.MbolKey,     
            MBOL.BookingReference,     
            MBOL.OtherReference,     
            MBOL.PlaceOfLoading,     
            MBOL.PlaceOfDischarge,     
            MBOL.EffectiveDate,     
            MBOL.CarrierKey,     
            MBOL.Vessel,     
            MBOL.VoyageNumber,     
            MBOL.DRIVERName,     
            MBOL.Editdate,    
            ORDERS.ConsigneeKey,     
            ORDERS.ExternOrderKey,    
            ORDERS.C_Address1,  
            ORDERS.C_Address2,  
            ORDERS.C_Address3,  
            ORDERS.C_Address4,  
            ORDERS.C_Contact1,  
            ORDERS.C_Contact2,  
            ORDERS.C_Phone1,  
            ORDERS.C_Phone2,  
            ORDERS.C_Fax1,  
            ORDERS.C_Fax2,  
            ORDERS.Loadkey,  
          ORDERS.DeliveryDate,  
          ORDERS.Grossweight,  
          ORDERS.Capacity,   
            ORDERS.Loadkey AS OHLOAD,  
            MBOL.Facility,  
            1 as CartonNo,  
            '' as Pickslipno,  
            '' as pickzone,  
            '0' as FWQTY,  
            '0' as APPQTY,  
            '0' as EQQTY,  
            Orders.C_Company,  
           ETA = CASE WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 0 THEN  --NJOW01  
                            DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))  
                       WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 1  THEN --NJOW01  
                            CASE WHEN DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10)) >= CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) THEN   
                                DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))   
                            ELSE CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) END    
                     WHEN CLC.Short IS NULL OR ISNUMERIC(CLC.Short) <> 1 THEN MBOL.EditDate    
                    ELSE CASE WHEN Orders.Intermodalvehicle = 'ILOE' THEN   
                              DateAdd(hour, Ceiling(Cast(CLC.Short as real)), CONVERT(datetime,convert(char(8),MBOL.EditDate,112))+1)  
                            ELSE  
                              DateAdd(day, Ceiling(Cast(CLC.Short as real)), MBOL.EditDate )  
                            END  
               END, /* Added ETA = ETD (MBOL.EditDate) + LeadTime */       
      CAST(ORDERS.Notes as Char(255)) as Notes,   
            ISNULL(RTRIM(CAST(STORER.notes1 as Char(255))), '') + SPACE(1) + ISNULL(RTRIM(CAST(STORER.notes2 as Char(255))),'') as Remarks,  
       /*(substring(STORER.notes1,1,16) + SPACE(1) + substring(STORER.notes2,1,16)) as Remarks,*/     
      ORDERS.C_City,  
      Orders.intermodalvehicle,   
      CODELKUP.Short AS Domain,  
            ShowField = CASE WHEN ISNULL(CLR.Code,'') <> '' THEN 'Y' ELSE 'N' END ,  
            ShowCRD  = CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD' AND ISNULL(ORDERS.userdefine10,'') <> ''  
                        AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))   
                     < LEFT(ORDERS.ExternPOKey,8))) THEN   
                   CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN   
                  -- CASE WHEN CONVERT(INT,REPLACE)  
                   'Y' ELSE 'N' END  
                   ELSE 'N' END ,  
            CRD = substring(ORDERS.ExternPOKey,1,4) + '-' + substring(ORDERS.ExternPOKey,5,2) + '-' + substring(ORDERS.ExternPOKey,7,2),               
      LP = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR2.NOTES2 ELSE CLR2.NOTES END,  
      CT = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR1.NOTES2 ELSE CLR1.NOTES END,  
      TL = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR3.NOTES2 ELSE CLR3.NOTES END,  
      FX = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR4.NOTES2 ELSE CLR4.NOTES END,  
      [SITE] = ''       --(CS01)  
           FROM  MBOL (NOLOCK)  
            JOIN MBOLDETAIL (NOLOCK) ON (MBOL.Mbolkey = MBOLDETAIL.Mbolkey )     
            JOIN ORDERS (NOLOCK)ON (MBOLDETAIL.Orderkey = Orders.Orderkey)  
            LEFT OUTER JOIN PICKHEADER (NOLOCK) ON (ORDERS.Loadkey = PICKHEADER.ExternOrderkey)  
      LEFT OUTER JOIN CODELKUP CLC (NOLOCK) ON (CLC.LONG = ORDERS.Facility AND   
                 CLC.Description = ORDERS.c_City AND  
                 CLC.ListName = @c_CodeCityLdTime AND   --WL02   
                                             CAST(CLC.Notes AS char(30)) = Orders.intermodalvehicle)   
      LEFT OUTER JOIN CODELKUP (NOLOCK) ON (CODELKUP.Listname = 'STRDOMAIN' AND  
            CODELKUP.Code = ORDERS.StorerKey)   
      LEFT OUTER JOIN STORER (NOLOCK) ON (STORER.StorerKey = ORDERS.ConsigneeKey)  
            LEFT OUTER JOIN Codelkup CLR (NOLOCK) ON (ORDERS.Storerkey = CLR.Storerkey AND CLR.Code = 'SHOWFIELD'                                          
                                          AND CLR.Listname = 'REPORTCFG' AND CLR.Long = 'r_dw_dmanifest_sum03' AND ISNULL(CLR.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR1 (NOLOCK) ON (ORDERS.Storerkey = CLR1.Storerkey AND CLR1.Listname = 'REPORTCFG'    
              AND CLR1.Long = 'r_dw_dmanifest_sum03' AND CLR1.Code = 'ShowCTName' AND ISNULL(CLR1.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR2 (NOLOCK) ON (ORDERS.Storerkey = CLR2.Storerkey AND CLR2.Listname = 'REPORTCFG'    
              AND CLR2.Long = 'r_dw_dmanifest_sum03' AND CLR2.Code = 'ShowLPName' AND ISNULL(CLR2.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR3 (NOLOCK) ON (ORDERS.Storerkey = CLR3.Storerkey AND CLR3.Listname = 'REPORTCFG'    
              AND CLR3.Long = 'r_dw_dmanifest_sum03' AND CLR3.Code = 'ShowTLName' AND ISNULL(CLR3.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR4 (NOLOCK) ON (ORDERS.Storerkey = CLR4.Storerkey AND CLR4.Listname = 'REPORTCFG'    
              AND CLR4.Long = 'r_dw_dmanifest_sum03' AND CLR4.Code = 'ShowFXName' AND ISNULL(CLR4.Short,'') <> 'N')                                           
      WHERE ( MBOL.MbolKey = @c_mbolKey)  
      AND   PICKHEADER.Pickheaderkey IS NULL  
     UNION ALL  
/*    Pack by Single Order */  
     SELECT DISTINCT MBOL.AddWho,     
            MBOL.MbolKey,     
            MBOL.BookingReference,     
            MBOL.OtherReference,     
            MBOL.PlaceOfLoading,     
            MBOL.PlaceOfDischarge,     
            MBOL.EffectiveDate,     
            MBOL.CarrierKey,     
            MBOL.Vessel,     
            MBOL.VoyageNumber,     
            MBOL.DRIVERName,     
            MBOL.Editdate,    
            ORDERS.ConsigneeKey,     
            ORDERS.ExternOrderKey,    
            ORDERS.C_Address1,  
            ORDERS.C_Address2,  
            ORDERS.C_Address3,  
            ORDERS.C_Address4,  
            ORDERS.C_Contact1,  
            ORDERS.C_Contact2,  
            ORDERS.C_Phone1,  
            ORDERS.C_Phone2,  
            ORDERS.C_Fax1,  
            ORDERS.C_Fax2,  
            ORDERS.Loadkey,  
         ORDERS.DeliveryDate,  
         ORDERS.Grossweight,  
         ORDERS.Capacity,   
            ORDERS.Loadkey AS OHLOAD,  
            MBOL.Facility,  
            Packdetail.CartonNo as CartonNo,  
            Packdetail.Pickslipno ,  
            Pickheader.Zone as PickZone,  
            (select sum(packdetail.qty)   
       from packdetail(nolock),sku(nolock) where packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku and sku.skugroup = 'FOOTWEAR'  
       and packdetail.Storerkey =PackHeader.Storerkey and packdetail.Pickslipno =PackHeader.Pickslipno ) AS FWQTY,  
            (select sum(packdetail.qty)  
       from packdetail(nolock),sku(nolock) where packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku and sku.skugroup = 'APPAREL'  
       and packdetail.Storerkey =PackHeader.Storerkey and packdetail.Pickslipno =PackHeader.Pickslipno ) AS APPQTY,  
            (select sum(packdetail.qty)   
       from packdetail(nolock),sku(nolock) where packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku and sku.skugroup = 'EQUIPMENT'  
       and packdetail.Storerkey =PackHeader.Storerkey and packdetail.Pickslipno =PackHeader.Pickslipno ) AS EQQTY,  
            Orders.C_company,  
           ETA = CASE WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 0 THEN  --NJOW01  
                          DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))  
                       WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 1  THEN --NJOW01  
                          CASE WHEN DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10)) >= CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) THEN   
                             DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))  
                          ELSE CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) END    
                     WHEN CLC.Short IS NULL OR ISNUMERIC(CLC.Short) <> 1 THEN MBOL.EditDate    
                    ELSE CASE WHEN Orders.Intermodalvehicle = 'ILOE' THEN   
                              DateAdd(hour, Ceiling(Cast(CLC.Short as real)), CONVERT(datetime,convert(char(8),MBOL.EditDate,112))+1)  
                              ELSE  
                              DateAdd(day, Ceiling(Cast(CLC.Short as real)), MBOL.EditDate )  
                            END  
               END,  /* Added ETA = ETD (MBOL.EditDate) + LeadTime */  
      CAST(ORDERS.Notes as Char(255)) as Notes,    
            RTRIM(CAST(STORER.notes1 as Char(255))) + SPACE(1) + RTRIM(CAST(STORER.notes2 as Char(255))) as Remarks,  
       /* (substring(STORER.notes1,1,16) + SPACE(1) + substring(STORER.notes2,1,16)) as Remarks, */    
      ORDERS.C_City,   
      Orders.intermodalvehicle,   
      CODELKUP.Short,  
            ShowField = CASE WHEN ISNULL(CLR.Code,'') <> '' THEN 'Y' ELSE 'N' END ,  
            ShowCRD  = CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD' AND ISNULL(ORDERS.userdefine10,'') <> ''  
                        AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))   
                     <  LEFT(ORDERS.ExternPOKey,8))) THEN   
                   CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN   
                  -- CASE WHEN CONVERT(INT,REPLACE)  
                   'Y' ELSE 'N' END  
                   ELSE 'N' END  ,  
            CRD = substring(ORDERS.ExternPOKey,1,4) + '-' + substring(ORDERS.ExternPOKey,5,2) + '-' + substring(ORDERS.ExternPOKey,7,2),             
      LP = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR2.NOTES2 ELSE CLR2.NOTES END,  
      CT = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR1.NOTES2 ELSE CLR1.NOTES END,  
      TL = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR3.NOTES2 ELSE CLR3.NOTES END,  
      FX = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR4.NOTES2 ELSE CLR4.NOTES END,  
      [SITE] = ''       --(CS01)  
            FROM  MBOL (NOLOCK)  
            JOIN MBOLDETAIL (NOLOCK) ON (MBOL.Mbolkey = MBOLDETAIL.Mbolkey )     
            INNER JOIN ORDERS (NOLOCK)ON (MBOLDETAIL.Orderkey = Orders.Orderkey)  
            INNER JOIN PACKHEADER (NOLOCK) ON (ORDERS.Storerkey = PACKHEADER.Storerkey AND ORDERS.Orderkey = PACKHEADER.Orderkey)  
            INNER JOIN PACKDETAIL (NOLOCK) ON (PACKHEADER.Storerkey = PACKDETAIL.Storerkey AND PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno)   
            INNER JOIN PICKHEADER (NOLOCK) ON (PACKHEADER.Pickslipno = PICKHEADER.Pickheaderkey)  
      LEFT OUTER JOIN CODELKUP CLC (NOLOCK) ON (CLC.LONG = ORDERS.Facility AND   
                 CLC.Description = ORDERS.c_City AND  
                 CLC.ListName = @c_CodeCityLdTime AND   --WL02  
                                             CAST(CLC.Notes AS char(30)) = Orders.intermodalvehicle)   
      LEFT OUTER JOIN CODELKUP (NOLOCK) ON (CODELKUP.Listname = 'STRDOMAIN' AND  
            CODELKUP.Code = ORDERS.StorerKey)   
            LEFT OUTER JOIN STORER (NOLOCK) ON (STORER.StorerKey = ORDERS.ConsigneeKey)  
            LEFT OUTER JOIN Codelkup CLR (NOLOCK) ON (ORDERS.Storerkey = CLR.Storerkey AND CLR.Code = 'SHOWFIELD'                                          
                                          AND CLR.Listname = 'REPORTCFG' AND CLR.Long = 'r_dw_dmanifest_sum03' AND ISNULL(CLR.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR1 (NOLOCK) ON (ORDERS.Storerkey = CLR1.Storerkey AND CLR1.Listname = 'REPORTCFG'    
              AND CLR1.Long = 'r_dw_dmanifest_sum03' AND CLR1.Code = 'ShowCTName' AND ISNULL(CLR1.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR2 (NOLOCK) ON (ORDERS.Storerkey = CLR2.Storerkey AND CLR2.Listname = 'REPORTCFG'    
              AND CLR2.Long = 'r_dw_dmanifest_sum03' AND CLR2.Code = 'ShowLPName' AND ISNULL(CLR2.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR3 (NOLOCK) ON (ORDERS.Storerkey = CLR3.Storerkey AND CLR3.Listname = 'REPORTCFG'    
              AND CLR3.Long = 'r_dw_dmanifest_sum03' AND CLR3.Code = 'ShowTLName' AND ISNULL(CLR3.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR4 (NOLOCK) ON (ORDERS.Storerkey = CLR4.Storerkey AND CLR4.Listname = 'REPORTCFG'    
              AND CLR4.Long = 'r_dw_dmanifest_sum03' AND CLR4.Code = 'ShowFXName' AND ISNULL(CLR4.Short,'') <> 'N')                                          
      WHERE ( MBOL.MbolKey = @c_mbolKey)  
      AND   ( RTRIM(PICKHEADER.OrderKey) IS NOT NULL AND RTRIM(PICKHEADER.OrderKey) <> '')   
     UNION ALL  
/*    Pack by Same ShipTo Orders */  
     SELECT MBOL.AddWho,     
            MBOL.MbolKey,     
            MBOL.BookingReference,     
            MBOL.OtherReference,     
            MBOL.PlaceOfLoading,     
     MBOL.PlaceOfDischarge,     
            MBOL.EffectiveDate,     
            MBOL.CarrierKey,     
            MBOL.Vessel,     
            MBOL.VoyageNumber,     
            MBOL.DRIVERName,     
            MBOL.Editdate,    
            MAX(ORDERS.ConsigneeKey),     
            '' AS ExternOrderKey,    
            MAX(ORDERS.C_Address1),  
            MAX(ORDERS.C_Address2),  
            MAX(ORDERS.C_Address3),  
            MAX(ORDERS.C_Address4),  
            MAX(ORDERS.C_Contact1),  
            MAX(ORDERS.C_Contact2),  
            MAX(ORDERS.C_Phone1),  
            MAX(ORDERS.C_Phone2),  
            MAX(ORDERS.C_Fax1),  
            MAX(ORDERS.C_Fax2),  
            ORDERS.Loadkey,  
      MAX(ORDERS.DeliveryDate),  
      SUM(ORDERS.Grossweight),  
      SUM(ORDERS.Capacity),   
            ORDERS.Loadkey AS OHLOAD,  
            MBOL.Facility,  
            Packdetail.CartonNo,  
            PackHeader.Pickslipno,  
            Pickheader.Zone ,   
            (select sum(packdetail.qty)   
       from packdetail(nolock),sku(nolock) where packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku and sku.skugroup = 'FOOTWEAR'  
       and packdetail.Storerkey =PackHeader.Storerkey and packdetail.Pickslipno =PackHeader.Pickslipno ) AS FWQTY,  
            (select sum(packdetail.qty)  
       from packdetail(nolock),sku(nolock) where packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku and sku.skugroup = 'APPAREL'  
       and packdetail.Storerkey =PackHeader.Storerkey and packdetail.Pickslipno =PackHeader.Pickslipno ) AS APPQTY,  
            (select sum(packdetail.qty)   
       from packdetail(nolock),sku(nolock) where packdetail.Storerkey = sku.Storerkey  AND packdetail.sku = sku.sku and sku.skugroup = 'EQUIPMENT'  
       and packdetail.Storerkey =PackHeader.Storerkey and packdetail.Pickslipno =PackHeader.Pickslipno ) AS EQQTY,  
            MAX(Orders.C_company),  
           ETA = CASE WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 0 THEN  --NJOW01  
                          DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))   
                       WHEN ISDATE(ORDERS.Userdefine10) = 1 AND ISNUMERIC(ISNULL(ORDERS.Userdefine01,'0')) = 1 AND ISDATE(LEFT(ORDERS.ExternPokey,8)) = 1  THEN --NJOW01  
                          CASE WHEN DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10)) >= CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) THEN   
                             DATEADD(DAY, CONVERT(INT, ISNULL(ORDERS.Userdefine01,'0')), CONVERT(DATETIME, ORDERS.Userdefine10))  
                          ELSE CONVERT(DATETIME, LEFT(ORDERS.ExternPokey,8)) END    
                      WHEN CLC.Short IS NULL OR ISNUMERIC(CLC.Short) <> 1 THEN MBOL.EditDate    
                     ELSE CASE WHEN Orders.Intermodalvehicle = 'ILOE' THEN   
                               DateAdd(hour, Ceiling(Cast(CLC.Short as real)), CONVERT(datetime,convert(char(8),MBOL.EditDate,112))+1)  
                               ELSE  
                               DateAdd(day, Ceiling(Cast(CLC.Short as real)), MBOL.EditDate )  
                            END  
               END,  /* Added ETA = ETD (MBOL.EditDate) + LeadTime */  
      CAST(ORDERS.Notes as Char(255)) as Notes,  
            RTRIM(CAST(STORER.notes1 as Char(255))) + SPACE(1) + RTRIM(CAST(STORER.notes2 as Char(255))) As Remarks,  
         /* (substring(STORER.notes1,1,16) + SPACE(1) + substring(STORER.notes2,1,16)) as Remarks, */    
      ORDERS.C_City,   
      Orders.intermodalvehicle,   
      CODELKUP.Short,  
            ShowField = CASE WHEN ISNULL(CLR.Code,'') <> '' THEN 'Y' ELSE 'N' END ,  
            ShowCRD  = CASE WHEN ((ISNULL(STORER.SUSR1,'') = 'CRD' AND ISNULL(ORDERS.userdefine10,'') <> ''  
                        AND (LEFT(REPLACE(CONVERT(NVARCHAR(10),(CONVERT(DATETIME,ORDERS.userdefine10) + CONVERT(INT,ORDERS.Userdefine01)),111),'/',''),8))   
                     <  LEFT(ORDERS.ExternPOKey,8))) THEN   
                   CASE WHEN ISNUMERIC(LEFT(ORDERS.ExternPOKey,4))=1 THEN   
                  -- CASE WHEN CONVERT(INT,REPLACE)  
                   'Y' ELSE 'N' END  
                   ELSE 'N' END  ,  
            CRD = substring(ORDERS.ExternPOKey,1,4) + '-' + substring(ORDERS.ExternPOKey,5,2) + '-' + substring(ORDERS.ExternPOKey,7,2),   
      LP = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR2.NOTES2 ELSE CLR2.NOTES END,  
      CT = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR1.NOTES2 ELSE CLR1.NOTES END,  
      TL = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR3.NOTES2 ELSE CLR3.NOTES END,  
      FX = CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR4.NOTES2 ELSE CLR4.NOTES END,  
      [SITE] = ''       --(CS01)        
            FROM  MBOL (NOLOCK)  
            JOIN MBOLDETAIL (NOLOCK) ON (MBOL.Mbolkey = MBOLDETAIL.Mbolkey )     
            INNER JOIN ORDERS (NOLOCK)ON (MBOLDETAIL.Orderkey = Orders.Orderkey)  
            INNER JOIN PACKHEADER (NOLOCK) ON (ORDERS.Storerkey = PACKHEADER.Storerkey AND ORDERS.Loadkey = PACKHEADER.Loadkey)  
            INNER JOIN PACKDETAIL (NOLOCK) ON (PACKHEADER.Storerkey = PACKDETAIL.Storerkey AND PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno)   
            INNER JOIN PICKHEADER (NOLOCK) ON (PACKHEADER.Pickslipno = PICKHEADER.Pickheaderkey)  
      LEFT OUTER JOIN CODELKUP CLC (NOLOCK) ON (CLC.LONG = ORDERS.Facility AND   
                 CLC.Description = ORDERS.c_City AND  
                 CLC.ListName = @c_CodeCityLdTime AND   --WL02   
                                             CAST(CLC.Notes AS char(30)) = Orders.intermodalvehicle)   
      LEFT OUTER JOIN CODELKUP (NOLOCK) ON (CODELKUP.Listname = 'STRDOMAIN' AND  
            CODELKUP.Code = ORDERS.StorerKey)   
      LEFT OUTER JOIN STORER (NOLOCK) ON (STORER.StorerKey = ORDERS.ConsigneeKey)   
                 LEFT OUTER JOIN Codelkup CLR (NOLOCK) ON (ORDERS.Storerkey = CLR.Storerkey AND CLR.Code = 'SHOWFIELD'                                          
                                          AND CLR.Listname = 'REPORTCFG' AND CLR.Long = 'r_dw_dmanifest_sum03' AND ISNULL(CLR.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR1 (NOLOCK) ON (ORDERS.Storerkey = CLR1.Storerkey AND CLR1.Listname = 'REPORTCFG'    
              AND CLR1.Long = 'r_dw_dmanifest_sum03' AND CLR1.Code = 'ShowCTName' AND ISNULL(CLR1.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR2 (NOLOCK) ON (ORDERS.Storerkey = CLR2.Storerkey AND CLR2.Listname = 'REPORTCFG'    
              AND CLR2.Long = 'r_dw_dmanifest_sum03' AND CLR2.Code = 'ShowLPName' AND ISNULL(CLR2.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR3 (NOLOCK) ON (ORDERS.Storerkey = CLR3.Storerkey AND CLR3.Listname = 'REPORTCFG'    
              AND CLR3.Long = 'r_dw_dmanifest_sum03' AND CLR3.Code = 'ShowTLName' AND ISNULL(CLR3.Short,'') <> 'N')  
      LEFT OUTER JOIN CODELKUP CLR4 (NOLOCK) ON (ORDERS.Storerkey = CLR4.Storerkey AND CLR4.Listname = 'REPORTCFG'    
              AND CLR4.Long = 'r_dw_dmanifest_sum03' AND CLR4.Code = 'ShowFXName' AND ISNULL(CLR4.Short,'') <> 'N')                                             
      WHERE ( MBOL.MbolKey = @c_mbolKey)  
      AND   ( RTRIM(PackHeader.OrderKey) IS NULL OR RTRIM(PackHeader.OrderKey) = '')   
      GROUP BY PackHeader.Storerkey, PackHeader.Pickslipno,  
       Packdetail.CartonNo,  
            MBOL.AddWho,     
            MBOL.MbolKey,     
            MBOL.BookingReference,     
            MBOL.OtherReference,     
            MBOL.PlaceOfLoading,     
            MBOL.PlaceOfDischarge,     
            MBOL.EffectiveDate,     
            MBOL.CarrierKey,     
            MBOL.Vessel,     
            MBOL.VoyageNumber,     
            MBOL.DRIVERName,     
            MBOL.Editdate,    
            ORDERS.Loadkey,  
            MBOL.Facility,  
            Pickheader.Zone,  
      MBOL.EditDate,  
      CLC.Short,  
      CAST(ORDERS.Notes as Char(255)),    
            RTRIM(CAST(STORER.notes1 as Char(255))) + SPACE(1) + RTRIM(CAST(STORER.notes2 as Char(255))),  
      ORDERS.C_City,  
      Orders.intermodalvehicle,   
      CODELKUP.Short,  
            ORDERS.Userdefine01,  
            ORDERS.Userdefine04,  
            ORDERS.ExternPOKey,  
            ISNULL(CLR.Code,''),  
            ISNULL(STORER.SUSR1,'') ,  
            substring(ORDERS.ExternPOKey,1,4) + '-' + substring(ORDERS.ExternPOKey,5,2) + '-' + substring(ORDERS.ExternPOKey,7,2),  
      CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR2.NOTES2 ELSE CLR2.NOTES END,  
      CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR1.NOTES2 ELSE CLR1.NOTES END,  
      CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR3.NOTES2 ELSE CLR3.NOTES END,  
      CASE WHEN ISNULL(ORDERS.Userdefine02,'')='' THEN CLR4.NOTES2 ELSE CLR4.NOTES END  
            ,ORDERS.userdefine10               
       
 END      
END  
SET QUOTED_IDENTIFIER OFF  
GO
GRANT EXECUTE ON [dbo].[isp_GetDmanifest_Dsum03] TO nSQL 
GO