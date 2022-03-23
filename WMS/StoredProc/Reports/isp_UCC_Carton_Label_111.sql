SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_UCC_Carton_Label_111                                */
/* Creation Date: 02-MAR-2022                                           */
/* Copyright: LF Logistics                                              */
/* Written by: MINGLE                                                   */
/*                                                                      */
/* Purpose: WMS-19002- MYS¨CPRESTIGE¨CNew Carton UCCLabel for Prestige    */
/*                                                                      */
/*        :                                                             */
/* Called By: r_dw_ucc_carton_label_111                                 */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 02-MAR-2022 Mingle   1.0   Created(DevOps Combine Script).           */
/************************************************************************/
CREATE OR ALTER PROC isp_UCC_Carton_Label_111
            @c_StorerKey      NVARCHAR(15) 
         ,  @c_PickSlipNo     NVARCHAR(10) 
         ,  @c_StartCartonNo  NVARCHAR(10)     
         ,  @c_EndCartonNo    NVARCHAR(10)  
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT 

         ,@n_Maxline        INT
         ,@n_TTLCTN         INT
         ,@c_showttlctn     NVARCHAR(5)
         ,@c_getpickslipno  NVARCHAR(20)
         ,@c_getCartonno    NVARCHAR(5)
         ,@c_getWeight      FLOAT 
         
      
   CREATE TABLE #TMP_OD 
   (  Storerkey NVARCHAR(15)  NOT NULL DEFAULT('')
   ,  Sku       NVARCHAR(20)  NOT NULL DEFAULT('')
   ,  AltSku    NVARCHAR(20)  NOT NULL DEFAULT('')
   ) 

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1

   SET @n_Maxline = 9
   SET @n_TTLCTN = 1
   SET @c_getpickslipno = ''
   SET @c_getCartonno = ''
   SET @c_getWeight = ''

   IF EXISTS (SELECT 1 FROM PackDetail WITH (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo )
   BEGIN
     SET @c_getpickslipno = @c_PickSlipNo
   END 
   ELSE
   BEGIN
        SELECT @c_getpickslipno = PickSlipNo
               ,@c_getCartonno = CartonNo
        FROM PackDetail WITH (NOLOCK) WHERE Storerkey = @c_StorerKey AND dropid = @c_PickSlipNo     

       SET @c_StartCartonNo = @c_getCartonno
       SET @c_EndCartonNo = @c_getCartonno

   END

   SELECT @n_ttlctn = MAX(cartonno)
   FROM PACKDETAIL WITH (NOLOCK)
   WHERE Pickslipno = @c_getpickslipno    --CS01
   AND   Storerkey = @c_StorerKey 


   CREATE TABLE #TMP_LCartonLBL111 (
          rowid           int NOT NULL identity(1,1) PRIMARY KEY,
          Storerkey       NVARCHAR(20) NULL,
          OrdExtOrdKey    NVARCHAR(50) NULL,
          Consigneekey    NVARCHAR(45) NULL,
          cartonno        INT NULL,
          TTLCtn          INT NULL,
          SKUStyle        NVARCHAR(30) NULL,
          --SKUSize         NVARCHAR(10) NULL,
          --PDQty           INT,
          Facility        NVARCHAR(10) NULL,
          TTLQTY          INT,
          loadkey         NVARCHAR(20) NULL, 
          ExternPOKey     NVARCHAR(20) NULL,
          OHRoute         NVARCHAR(20) NULL,
          DropID          NVARCHAR(20) NULL,
          ST_Address1     NVARCHAR(45) NULL,
          ST_Address2     NVARCHAR(45) NULL,
          ST_Address3     NVARCHAR(45) NULL, 
          ST_Address4     NVARCHAR(45) NULL,
          ST_City         NVARCHAR(45) NULL, 
          ST_State        NVARCHAR(45) NULL, 
          ST_Zip          NVARCHAR(45) NULL,
          RecGrp          INT,
          Pickslipno      NVARCHAR(20) NULL,
          ST_Company      NVARCHAR(45) NULL,
          Labelno         NVARCHAR(20) NULL,
          HIDETTLCTN      NVARCHAR(5) NULL,
          SKUSize         NVARCHAR(10) NULL,
          OHNotes         NVARCHAR(250) NULL,
          HIDEFIELD       NVARCHAR(5) NULL,
          BuyerPO         NVARCHAR(20) NULL,
          showPOorPOKEY   NVARCHAR(5) NULL,
          C_Company       NVARCHAR(45) NULL,
          C_Address1      NVARCHAR(45) NULL,
          C_Address2      NVARCHAR(45) NULL,
          C_Address3      NVARCHAR(45) NULL,
          C_City          NVARCHAR(45) NULL,
          C_State         NVARCHAR(45) NULL,
          C_Zip           NVARCHAR(45) NULL,
          LottableValue   NVARCHAR(60) NULL,
          OHDeliveryDate  NVARCHAR(11),
          [Weight]        FLOAT NULL)

 CREATE TABLE #TMP_LCartonLBL111Date (
          rowid           int NOT NULL identity(1,1) PRIMARY KEY,
          Storerkey       NVARCHAR(20) NULL,
          OrdExtOrdKey    NVARCHAR(50) NULL,
          ODD_Date        DATETIME,
          OAD_Date        DATETIME,
          ODD             NVARCHAR(11),
          OAD             NVARCHAR(11),
          SLA             INT )
         

   insert into #TMP_LCartonLBL111 (Storerkey,OrdExtOrdKey,loadkey,OHRoute,Consigneekey,Facility,ttlqty,ExternPOKey,ST_Address1,
                                  ST_Address2,ST_Address3,ST_Address4,ST_City,ST_State,ST_Zip,DropID,cartonno,SKUStyle,TTLCtn,RecGrp,Pickslipno,
                                  ST_Company,labelno,HideTTLCTN,SKUSize,OHNotes,HIDEFIELD,BuyerPO,showPOorPOKEY,
                                  C_Company,C_Address1,C_Address2,C_Address3,C_City,C_State,C_Zip,LottableValue,OHDeliveryDate,[Weight])
   SELECT DISTINCT OH.Storerkey,OH.ExternOrderkey,OH.Loadkey,OH.Route,OH.Consigneekey,
          OH.Facility,sum(PD.qty),OH.ExternPOKey,ST.Address1,ST.Address2,ST.Address3,ST.Address4,
          ST.city,ST.state,ST.zip,PD.dropid , PD.CartonNo ,PD.SKU,@n_ttlctn,
          ROW_NUMBER() OVER ( PARTITION BY OH.ExternOrderkey,PD.CartonNo  
                           ORDER BY OH.ExternOrderkey,pd.cartonno ,pd.sku )/@n_Maxline + 1  as recgrp,PH.pickslipno,  
          ST.Company,PD.labelno, CASE WHEN ISNULL(CLR.Code,'') <> '' THEN 'Y' ELSE 'N' END AS Hidettlctn,s.Size ,
          ISNULL(OH.notes,'') AS OHNotes,CASE WHEN ISNULL(CLR1.Code,'') <> '' THEN 'Y' ELSE 'N' END AS HIDEFIELD,
          OH.BuyerPO,ISNULL(CLR2.SHORT,'') AS showPOorPOKEY,OH.C_Company,OH.C_Address1,OH.C_Address2,OH.C_Address3,
          OH.C_City,ISNULL(OH.C_State,''),OH.C_Zip,PD.LOTTABLEVALUE,CONVERT(NVARCHAR(11),OH.DeliveryDate,106),PIF.Weight
   FROM ORDERS OH WITH (NOLOCK)
   --JOIN ORDERDETAIL OD WITH (NOLOCK) 
   JOIN PackHeader PH WITH (NOLOCK) ON PH.Orderkey = OH.Orderkey
   JOIN PACKDETAIL PD WITH (NOLOCK) ON PD.Pickslipno = PH.pickslipno
   LEFT JOIN PACKINFO PIF WITH (NOLOCK) ON PIF.CartonNo = PD.CartonNo AND PIF.PickSlipNo = PH.PickSlipNo
   --LEFT JOIN STORER ST WITH (NOLOCK) ON ST.Storerkey = OH.Consigneekey 
   LEFT JOIN STORER ST WITH (NOLOCK) ON ST.Storerkey = OH.StorerKey
   LEFT JOIN SKU S WITH (NOLOCK) ON S.storerkey = PD.Storerkey AND S.SKU = PD.SKU 
   LEFT JOIN storersodefault SOD WITH (NOLOCK) ON SOD.storerkey = ST.Storerkey
   LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.listname = 'SLABYREGION' AND C.short=SOD.destination
   LEFT OUTER JOIN Codelkup CLR (NOLOCK) ON (OH.Storerkey = CLR.Storerkey AND CLR.Code = 'HIDETTLCTN'
                                       AND CLR.Listname = 'REPORTCFG' AND CLR.Long = 'r_dw_ucc_carton_label_111' AND ISNULL(CLR.Short,'') <> 'N')
   LEFT OUTER JOIN Codelkup CLR1 (NOLOCK) ON (OH.Storerkey = CLR1.Storerkey AND CLR1.Code = 'HIDEFIELD'
                                       AND CLR1.Listname = 'REPORTCFG' AND CLR1.Long = 'r_dw_ucc_carton_label_111' AND ISNULL(CLR1.Short,'') <> 'N')
   LEFT OUTER JOIN Codelkup CLR2 (NOLOCK) ON (OH.Storerkey = CLR2.Storerkey AND CLR2.Code = 'showPOorPOKEY'
                                       AND CLR2.Listname = 'REPORTCFG' AND CLR2.Long = 'r_dw_ucc_carton_label_111')
   WHERE PH.pickslipno = @c_getpickslipno
   AND OH.StorerKey = @c_storerkey
   AND PD.cartonno >= CASE WHEN @c_StartCartonNo <> '' THEN CAST(@c_StartCartonNo as INT) ELSE PD.cartonno END
   AND PD.cartonno <= CASE WHEN @c_EndCartonNo <> '' THEN CAST(@c_EndCartonNo as INT) ELSE PD.cartonno END
   GROUP BY OH.Storerkey,OH.ExternOrderkey,OH.Loadkey,OH.Route,OH.Consigneekey,
          OH.Facility,OH.ExternPOKey,ST.Address1,ST.Address2,ST.Address3,ST.Address4,
          ST.city,ST.state,ST.zip,PD.dropid , PD.CartonNo ,PD.SKU,PH.pickslipno,ST.company,PD.labelno,
          CASE WHEN ISNULL(CLR.Code,'') <> '' THEN 'Y' ELSE 'N' END ,s.Size,
          ISNULL(OH.notes,'') ,ISNULL(CLR1.Code,''),OH.BuyerPO,ISNULL(CLR2.SHORT,''),
          OH.C_Company,OH.C_Address1,OH.C_Address2,OH.C_Address3,OH.C_City,ISNULL(OH.C_State,''),OH.C_Zip,PD.LOTTABLEVALUE,OH.DeliveryDate,PIF.Weight
   order by PH.pickslipno ,OH.ExternOrderkey,PD.cartonno , pd.sku  


   INSERT INTO #TMP_LCartonLBL111Date (Storerkey,OrdExtOrdKey,ODD_Date,OAD_Date,ODD,OAD,SLA)
   SELECT DISTINCT OH.Storerkey,OH.ExternOrderkey,
                   CASE WHEN OH.StorerKey in ('Adidas') THEN CONVERT(DATETIME,OH.Userdefine03 ) 
                        ELSE OH.DeliveryDate END,OH.DeliveryDate,'','',
                   CASE WHEN ISNUMERIC(c.long) = 1 THEN CAST(C.long as INT) ELSE 0 END
   FROM ORDERS OH WITH (NOLOCK)
   --JOIN ORDERDETAIL OD WITH (NOLOCK) 
   JOIN PackHeader PH WITH (NOLOCK) ON PH.Orderkey = OH.Orderkey
   JOIN PACKDETAIL PD WITH (NOLOCK) ON PD.Pickslipno = PH.pickslipno
   LEFT JOIN STORER ST WITH (NOLOCK) ON ST.Storerkey = OH.Storerkey
   LEFT JOIN SKU S WITH (NOLOCK) ON S.storerkey = PD.Storerkey AND S.SKU = PD.SKU 
   LEFT JOIN storersodefault SOD WITH (NOLOCK) ON SOD.storerkey = ST.Storerkey
   LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.listname = 'SLABYREGION' AND C.short=SOD.destination
   where PH.pickslipno = @c_getpickslipno
   AND OH.StorerKey = @c_storerkey


update #TMP_LCartonLBL111Date
SET ODD = CASE WHEN storerkey = 'Skechers' THEN CONVERT(NVARCHAR(11),ODD_date - SLA,106) ELSE CONVERT(NVARCHAR(11),ODD_Date,106) END
   ,OAD = CASE WHEN storerkey in ('NIKEMY','JDSPORTSMY','TBLMY') THEN CONVERT(NVARCHAR(11),ODD_date + SLA,106) ELSE CONVERT(NVARCHAR(11),OAD_Date,106) END

QUIT_SP:
   
    SELECT a.loadkey,a.OrdExtOrdKey as externorderkey,a.TTLCtn as CtnCnt1,a.cartonno,a.DropID,a.SKUStyle as style,
           a.Storerkey,a.ttlqty as sizeqty,a.OHRoute,a.Consigneekey,a.Facility,a.ExternPOKey,a.ST_Address1,
           a.ST_Address2,a.ST_Address3,a.ST_Address4,a.ST_City,a.ST_State,a.ST_Zip,a.RecGrp,a.Pickslipno,
           REPLACE(b.ODD,' ' ,'-') AS ODD,REPLACE(b.OAD,' ' ,'-') AS OAD,a.ST_Company,a.labelno,
           a.HIDETTLCTN as hidettlctn,a.SKUSize AS skusize,a.OHNotes,a.HIDEFIELD,BuyerPO,showPOorPOKEY,
           a.C_Company,a.C_Address1,a.C_Address2,a.C_Address3,a.C_City,a.C_State,a.C_Zip,a.LottableValue,a.OHDeliveryDate,a.[Weight]
    FROM #TMP_LCartonLBL111 a
    JOIN #TMP_LCartonLBL111Date b on b.storerkey = a.storerkey and b.OrdExtOrdKey=a.OrdExtOrdKey 
    WHERE a.pickslipno = @c_getpickslipno
    AND a.StorerKey = @c_storerkey
    AND a.cartonno >= CASE WHEN @c_StartCartonNo <> '' THEN CAST(@c_StartCartonNo as INT) ELSE a.cartonno END
    AND a.cartonno <= CASE WHEN @c_EndCartonNo <> '' THEN CAST(@c_EndCartonNo as INT) ELSE a.cartonno END
    ORDER BY a.Pickslipno,a.OrdExtOrdKey,a.cartonno,a.SKUStyle

drop table #TMP_LCartonLBL111

drop table #TMP_LCartonLBL111Date  


END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_UCC_Carton_Label_111] TO nSQL 
GO



 --select * from CODELKUP (nolock) where LISTNAME = 'REPORTCFG' and Code = 'ADSCAN'
 --EXEC isp_UCC_Carton_Label_111 'prestige','P022132649','1','4'   
 --EXEC isp_UCC_Carton_Label_111 'prestige','P022133245','1','3'
 --EXEC isp_UCC_Carton_Label_111 'prestige','P022136993','1','1'

 --SELECT Weight
 --  FROM PACKINFO WITH (NOLOCK)
 --  WHERE Pickslipno = 'P000044452'
 --  AND Cartonno BETWEEN '1' AND '4'

 --  SELECT * FROM PACKINFO(NOLOCK) WHERE pickslipno = 'P022132649'

-- select dbo.fnc_DecryptPWD(usr_pwd),* from phtsecure..pl_usr (nolock)
--where usr_login like '%IT%'
--order by usr_pwd_date DESC

   