SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_PackListBySku23_rdt                                 */
/* Creation Date: 21-MAR-2022                                           */
/* Copyright: LF Logistics                                              */
/* Written by: CHONGCS                                                  */
/*                                                                      */
/* Purpose: WMS-19138 - CN Loreal Packing list_NEW                      */
/*        :                                                             */
/* Called By: r_dw_packing_list_By_Sku23_rdt                            */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver   Purposes                                 */
/* 21-MAR-2022  CHONGCS  1.0   Devops Scripts Comnbine                  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[isp_PackListBySku23_rdt]
           @c_PickSlipNo      NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt       INT
         , @n_Continue        INT
         , @n_MaxLineno       INT
         , @n_MaxRec          INT
         , @n_CurrentRec      INT
         , @n_Maxrecgrp       INT

   SET @n_StartTCnt = @@TRANCOUNT

   SET @n_MaxLineno = 10   

  CREATE TABLE #TMP_PICKLISTBYSKU23RDT (
    ExternOrderkey        NVARCHAR(50),
    ORDDate               DATETIME,
    SortBy                INT,
    RowNo                 INT,
    PickSlipNo            NVARCHAR(20),
    loadkey               NVARCHAR(20),
    ohudf03               NVARCHAR(20),
    SKU                   NVARCHAR(20),
    SDescr                NVARCHAR(80),
    st_BAdd3              NVARCHAR(45),
    st_notes1             NVARCHAR(4000),
    st_BAdd4              NVARCHAR(45),
    qty                   INT,
    Storerkey             NVARCHAR(20),
    Orderkey              NVARCHAR(20),
    recgrp                INT NULL,
    Contact               NVARCHAR(45),
    Altsku                NVARCHAR(20)
  )
  
INSERT INTO #TMP_PICKLISTBYSKU23RDT
(
    ExternOrderkey,
    ORDDate,
    SortBy,
    RowNo,
    PickSlipNo,
    loadkey,
    ohudf03,
    SKU,
    SDescr,
    st_BAdd3,
    st_notes1,
    st_BAdd4,
    qty,
    Storerkey,
    Orderkey,
    recgrp,
    Contact,
    Altsku
)

   SELECT  ExternOrderkey = ISNULL(RTRIM(OH.ExternOrderkey),'')
         , ORDDate = OH.OrderDate
         , SortBy = ROW_NUMBER() OVER ( ORDER BY PH.PickSlipNo
                                                ,OH.Storerkey
                                                ,OH.Orderkey
                                                ,RTRIM(PD.sku)
                                     )
         , RowNo  = ROW_NUMBER() OVER ( PARTITION BY PH.PickSlipNo,OH.Loadkey
                                        ORDER BY PH.PickSlipNo
                                                ,OH.Storerkey
                                                ,OH.Orderkey
                                                ,RTRIM(PD.sku)
                                      )
  --       , PrintTime      = GETDATE()
         , PH.PickSlipNo
         , OH.Loadkey
         , OHUDF03 = ISNULL(RTRIM(OH.UserDefine03),'')
         , SKU= RTRIM(PD.sku)
         , SDescr= ISNULL(RTRIM(sku.descr),'')
         , st_BAdd3  = ISNULL(RTRIM(ST.B_Address3),'')
         , ODNotst_notes1es2 = ISNULL(RTRIM(ST.notes1),'')
         , st_BAdd4  = ISNULL(RTRIM(ST.B_Address4),'')
         , Qty = ISNULL(SUM(PD.Qty),0)
         , OH.Storerkey
         , OH.Orderkey
         --, Recgrp = ROW_NUMBER() OVER ( PARTITION BY PH.PickSlipNo,ISNULL(RTRIM(ST.Company),'')
         --                               ORDER BY PH.PickSlipNo
         --                                       ,OH.Storerkey
         --                                       ,OH.Orderkey
         --                                       ,RTRIM(PD.sku)
         --                             )/(@n_MaxLineno+1)
         ,Recgrp = 1
         ,Contact = '***'
         ,SKU.ALTSKU
   FROM PACKHEADER PH WITH (NOLOCK)
   JOIN ORDERS     OH WITH (NOLOCK) ON (PH.orderkey = OH.orderkey)
   JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
   JOIN PICKDETAIL PD WITH (NOLOCK) ON (OD.Orderkey = PD.Orderkey AND OD.OrderLineNumber=PD.OrderLineNumber AND OD.SKU = PD.Sku)
   JOIN SKU       SKU WITH (NOLOCK) ON (PD.Storerkey= SKU.Storerkey)
                                    AND(PD.Sku = SKU.Sku)
   LEFT JOIN dbo.STORER ST WITH (NOLOCK) ON ST.StorerKey = OH.StorerKey -- AND ST.type='2'
   WHERE PH.PickSlipNo = @c_PickSlipNo
   GROUP BY PH.PickSlipNo
         ,  OH.Storerkey
         ,  OH.Loadkey
         ,  OH.Orderkey
         ,  ISNULL(RTRIM(OH.UserDefine03),'')
         ,  ISNULL(RTRIM(OH.ExternOrderkey),'')
         ,  OH.OrderDate
         ,  RTRIM(PD.sku)
         ,  ISNULL(RTRIM(sku.descr),'')
         ,  ISNULL(RTRIM(ST.B_Address3),'')
         ,  ISNULL(RTRIM(ST.B_Address4),'')
         ,  ISNULL(RTRIM(ST.notes1),'')
         ,  SKU.ALTSKU

    SET @n_Maxrecgrp = 1
    SET @n_MaxRec = 1

     SELECT ExternOrderkey,
             ORDDate,
             SortBy,
             RowNo,
             PickSlipNo,
             loadkey,
             ohudf03,
             SKU,
             SDescr,
             st_BAdd3,
             st_notes1,
             st_BAdd4,
             qty,
             Storerkey,
             Orderkey,
             recgrp,
             Contact,
             Altsku
   FROM #TMP_PICKLISTBYSKU23RDT
   ORDER BY PickSlipNo,Orderkey,sku

END -- procedure
GO
GRANT EXECUTE ON  [dbo].[isp_PackListBySku23_rdt] TO [NSQL]
GO
