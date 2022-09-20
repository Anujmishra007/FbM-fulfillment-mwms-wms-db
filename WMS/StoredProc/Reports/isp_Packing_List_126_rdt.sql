SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Stored Proc: isp_Packing_List_126_rdt                                */
/* Creation Date: 12-JUL-2022                                           */
/* Copyright: LF Logistics                                              */
/* Written by: CHONGCS                                                  */
/*                                                                      */
/* Purpose: WMS-20126 - [CN] PVHSZ Ecom PackingList                     */
/*                                                                      */
/* Called By: r_dw_packing_list_126_rdt                                 */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 12-JUL-2022  CHONGCS   1.0 DevOps Combine Script                     */
/* 01-SEP-2022  CHONGCS   1.1 WMS-20126 revised field logic (CS01)      */
/* 19-SEP-2022  CHONGCS   1.2 WMS-20126 fix duplicate qty (CS02)        */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_Packing_List_126_rdt]
            @c_pickslipno    NVARCHAR(20)

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

  


   SELECT PH.PickSlipNo
        , ISNULL(OH.userdefine03,'') AS Logo
        , TRIM(ISNULL(OH.C_contact1,'')) + TRIM(ISNULL(OH.C_Contact2,'')) AS C_Contact
        , TRIM(ISNULL(OH.C_Address1,'')) + SPACE(1) + TRIM(ISNULL(OH.C_Address2,'')) + SPACE(1)  +
          TRIM(ISNULL(OH.C_Address3,'')) + SPACE(1) + TRIM(ISNULL(OH.C_Address4,''))  AS C_Address1 
        , TRIM(ISNULL(OH.C_Zip,'')) + SPACE(1) + TRIM(ISNULL(OH.C_City,''))  AS C_ZipCity
        , OH.ExternOrderKey
        , TRIM(ISNULL(OH.C_State,'')) + SPACE(1) + TRIM(ISNULL(OH.C_Country,''))  AS C_State
        , ISNULL(OD.notes,'') AS ODnotes                    --CS01 
        , ISNULL(OH.C_Phone1,'') AS CPhone
        , ISNULL(SKU.Size,'') AS Size
        , ISNULL(C.long,'') AS ShipFrom
        , ISNULL(C.UDF01,'') AS CustSrv
        , ISNULL(C.UDF02,'') AS CustSrvEmail
        , OD.SKU                           --CS02
        , PAD.Qty  AS qty                   --CS02
        , ISNULL(C.UDF03,'') AS CustSrvTel
        , ISNULL(C.UDF04,'') AS CustSrvHLH
        , ISNULL(C.UDF05,'') AS CustSrvWH
        , ISNULL(C.Notes,'') AS CustSrvWD
        , ISNULL(C.Notes2,'') AS CustSrvURL
        , ISNULL(OH.UserDefine01,'') AS ShpNo
        , CONVERT(nvarchar(10),OH.OrderDate,120) AS ORDDate
        , ISNULL(sku.descr,'') AS Sdescr
        , ISNULL(C1.long,'') AS RtnR1
        , ISNULL(C1.UDF01,'') AS RtnR2
        , ISNULL(C1.UDF02,'') AS RtnR3
        , ISNULL(C1.UDF03,'') AS RtnR4
        , ISNULL(C1.UDF04,'') AS RtnR5
        , ISNULL(C1.UDF05,'') AS RtnR6
        , ISNULL(C2.long,'') AS FN1
        , ISNULL(C2.Notes,'') AS FN2
        , ISNULL(C2.Notes2,'') AS FN3
   FROM ORDERS OH (NOLOCK)
   JOIN ORDERDETAIL OD (NOLOCK) ON OD.OrderKey = OH.OrderKey
   JOIN PACKHEADER PH (NOLOCK) ON PH.OrderKey = OH.OrderKey
   --JOIN PACKDETAIL PD (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo   --CS02
   CROSS APPLY (SELECT SUM(Qty) AS Qty FROM PACKDETAIL (NOLOCK) 
               WHERE PACKDETAIL.PickSlipNo = PH.PickSlipNo 
               AND PACKDETAIL.STORERKEY = od.STORERKEY AND PACKDETAIL.SKU = OD.SKU)  AS PAD --CS02
   JOIN STORER ST (NOLOCK) ON ST.StorerKey = OH.StorerKey
   JOIN SKU (NOLOCK) ON SKU.StorerKey = OD.StorerKey AND SKU.SKU = OD.SKU               --CS02
   LEFT JOIN dbo.CODELKUP C WITH (NOLOCK) ON C.Storerkey = OH.StorerKey and C.LISTNAME = 'PVHSZEPKL' and C.code = OH.userdefine03
   LEFT JOIN dbo.CODELKUP C1 WITH (NOLOCK) ON C1.Storerkey = OH.StorerKey and C1.LISTNAME = 'PVHSZEPKL' and C1.code = '00020'
   LEFT JOIN dbo.CODELKUP C2 WITH (NOLOCK) ON C2.Storerkey = OH.StorerKey and C2.LISTNAME = 'PVHSZEPKL' and C2.code ='00030'
   WHERE PH.PickSlipNo = @c_pickslipno
   AND oh.doctype ='E'
   GROUP BY PH.PickSlipNo
        , ISNULL(OH.userdefine03,'')
        , TRIM(ISNULL(OH.C_contact1,'')) + TRIM(ISNULL(OH.C_Contact2,'')) 
        , TRIM(ISNULL(OH.C_Address1,'')) + SPACE(1) + TRIM(ISNULL(OH.C_Address2,'')) + SPACE(1)  +
          TRIM(ISNULL(OH.C_Address3,'')) + SPACE(1) + TRIM(ISNULL(OH.C_Address4,'')) 
        , TRIM(ISNULL(OH.C_Zip,'')) + SPACE(1) + TRIM(ISNULL(OH.C_City,'')) 
        ,TRIM(ISNULL(OH.C_State,'')) + SPACE(1) + TRIM(ISNULL(OH.C_Country,'')) 
        ,ISNULL(OH.C_Phone1,''), ISNULL(C.long,''),ISNULL(C.UDF01,''),ISNULL(C.UDF02,'')
        ,ISNULL(C.UDF03,''),ISNULL(C.UDF04,''),ISNULL(C.UDF05,''),ISNULL(C.notes,''),ISNULL(C.Notes2,'')
        ,ISNULL(OH.UserDefine01,'') ,CONVERT(nvarchar(10),OH.OrderDate,120) ,ISNULL(sku.descr,'') 
        , ISNULL(C1.long,'') , ISNULL(C1.long,''),ISNULL(C1.udf01,''),ISNULL(C1.udf02,''),ISNULL(C1.udf03,'')
        ,ISNULL(C1.udf04,''),ISNULL(C1.udf05,'') ,ISNULL(C2.long,''),ISNULL(C2.Notes,''),ISNULL(C2.Notes2,'')
        ,OH.ExternOrderKey,ISNULL(OD.notes,''),ISNULL(SKU.size,''),OD.SKU,PAD.qty   --CS01    --CS02
   ORDER BY PH.PickSlipNo

END
GO
GRANT EXECUTE ON  [dbo].[isp_Packing_List_126_rdt] TO [NSQL]
GO
