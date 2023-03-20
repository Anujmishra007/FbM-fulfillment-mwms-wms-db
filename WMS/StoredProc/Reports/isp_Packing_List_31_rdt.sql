SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store Procedure: isp_Packing_List_31_rdt                                   */
/* Creation Date: 16-Aug-2016                                                 */
/* Copyright: IDS                                                             */
/* Written by: CSCHONG                                                        */
/*                                                                            */
/* Purpose: WMS-397 - Levis - new Post print packing list                     */
/*                                                                            */
/*                                                                            */
/* Called By:  r_dw_packing_list_31_rdt                                       */
/*                                                                            */
/* PVCS Version: 1.4                                                          */
/*                                                                            */
/* Version: 1.0                                                               */
/*                                                                            */
/* Data Modifications:                                                        */
/*                                                                            */
/* Updates:                                                                   */
/* Date        Author   Ver.  Purposes                                        */
/* 28-MAR-2017 Wan01    1.1   WMS-1448 - Levis - CR for ECOM packing list     */
/* 03-JUL-2017 CSCHONG  1.2   MMS-2287 - Revise field logic (CS01)            */
/* 09-Apr-2021 CSCHONG  1.3   WMS-16024 PB-Standardize TrackingNo (CS02)      */
/* 18-MAY-2022 mingle   1.3   MMS-19552 - Modify logic (ML01)                 */
/* 16-Mar-2023 WLChooi  1.4   WMS-21976 - Modify mapping (WL01)               */
/* 16-Mar-2023 WLChooi  1.4   DevOps Combine Script                           */
/******************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Packing_List_31_rdt]
(
   @c_Orderkey NVARCHAR(10)
 , @c_labelno  NVARCHAR(20)
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_WARNINGS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_MCompany       NVARCHAR(45)
         , @c_Externorderkey NVARCHAR(30)
         , @c_C_Addresses    NVARCHAR(200)
         , @c_loadkey        NVARCHAR(10)
         , @c_Userdef03      NVARCHAR(20)
         , @c_salesman       NVARCHAR(30)
         , @c_phone1         NVARCHAR(18)
         , @c_contact1       NVARCHAR(30)
         , @n_TTLQty         INT
         , @c_shippername    NVARCHAR(45)
         , @c_Sku            NVARCHAR(20)
         , @c_Size           NVARCHAR(5)
         , @c_PickLoc        NVARCHAR(10)
         , @n_NoOfLine       INT
         , @c_getOrdKey      NVARCHAR(10)

   SET @n_NoOfLine = 6
   SET @c_getOrdKey = N'' --(CS01)

   CREATE TABLE #PACKLIST30
   (
      c_Contact1  NVARCHAR(30)  NULL
    , C_Addresses NVARCHAR(200) NULL
    , OHNotes2    NVARCHAR(200) NULL
    , OrdAddDate  NVARCHAR(10)  NULL
    , RptTitle    NVARCHAR(200) NULL
    , PickLOC     NVARCHAR(10)  NULL
    , SKUSize     NVARCHAR(10)  NULL
    , ORDUdef04   NVARCHAR(20)  NULL
    , MSKU        NVARCHAR(20)  NULL
    , Pqty        INT
    , OrderKey    NVARCHAR(10)  NULL
    , Style       NVARCHAR(20)  NULL
    , Shipperkey  NVARCHAR(15)  NULL
    , SDescr      NVARCHAR(150) NULL
    , ORDUdef01   NVARCHAR(20)  NULL
    , RecGrp      INT
    , M_Company   NVARCHAR(45)  NULL --(Wan01)
   )

   /*CS01 Start*/
   IF EXISTS (  SELECT 1
                FROM ORDERS WITH (NOLOCK)
                WHERE OrderKey = @c_Orderkey)
   BEGIN
      SET @c_getOrdKey = @c_Orderkey
   END
   ELSE
   BEGIN
      SELECT DISTINCT @c_getOrdKey = OrderKey
      FROM PackHeader AS ph WITH (NOLOCK)
      WHERE ph.PickSlipNo = @c_Orderkey
   END
   /*CS01 END*/

   INSERT INTO #PACKLIST30 (c_Contact1, C_Addresses, OHNotes2, OrdAddDate, RptTitle, PickLOC, SKUSize, ORDUdef04, MSKU
                          , Pqty, OrderKey, Style, Shipperkey, SDescr, ORDUdef01, RecGrp, M_Company --(Wan01)
   )
   SELECT ISNULL(OH.C_contact1, '')
        , (OH.C_Address2 + OH.C_Address3 + OH.C_Address4)
        , ISNULL(OH.Notes2, '')
        , CONVERT(NVARCHAR(10), OH.OrderDate, 111)
        , C.UDF01
        , PD.Loc
        , S.Size
        , ISNULL(OH.TrackingNo, '')
        , S.MANUFACTURERSKU
        , PD.Qty
        , OH.OrderKey --CS02
        , S.Style
        --/*CS01 star*/
        --CASE WHEN OH.shipperkey = 'SF' THEN N'顺丰速运'
        --     WHEN OH.shipperkey = 'EMS' THEN N'邮政速递'
        --     WHEN OH.shipperkey = 'JDEX' THEN N'京东快递'
        -- ELSE '' END AS Shipperkey    ,
        --/*CS01 End*/
        , CASE WHEN ISNULL(C2.Description, '') <> '' THEN ISNULL(C2.Description, '')
               ELSE OH.ShipperKey END --ML01
        , S.DESCR
        , ISNULL(OH.UserDefine01, '')
        , (ROW_NUMBER() OVER (PARTITION BY PD.OrderKey
                              ORDER BY PD.Loc ASC) - 1) / @n_NoOfLine
        , M_Company = ISNULL(TRIM(OH.ExternOrderKey), '') --(Wan01)   --WL01
   FROM ORDERS OH WITH (NOLOCK)
   JOIN ORDERDETAIL ORDDET WITH (NOLOCK) ON ORDDET.OrderKey = OH.OrderKey
   JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey = OH.OrderKey AND PD.OrderLineNumber = ORDDET.OrderLineNumber
   JOIN SKU S WITH (NOLOCK) ON S.Sku = PD.Sku AND S.StorerKey = PD.Storerkey
   JOIN STORER STO WITH (NOLOCK) ON OH.ShipperKey = STO.StorerKey
   LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.LISTNAME = 'LVPLT' AND C.Storerkey = '18385' AND C.Long = OH.UserDefine03
   LEFT JOIN CODELKUP C2 WITH (NOLOCK) ON  C2.LISTNAME = 'ShiType'
                                       AND C2.Storerkey = S.StorerKey
                                       AND C2.Code = OH.ShipperKey --ML01
   WHERE PD.OrderKey = @c_getOrdKey --@c_orderkey                                --(CS01)
   AND   PD.CaseID = CASE WHEN ISNULL(@c_labelno, '') <> '' THEN @c_labelno
                          ELSE PD.CaseID END
   ORDER BY PD.Loc

   SELECT c_Contact1
        , C_Addresses
        , OHNotes2
        , OrdAddDate
        , RptTitle
        , PickLOC
        , SKUSize
        , ORDUdef04
        , MSKU
        , Pqty
        , OrderKey
        , Style
        , Shipperkey
        , SDescr
        , ORDUdef01
        , RecGrp
        , UPPER(M_Company) --(Wan01)   --WL01
   FROM #PACKLIST30
   ORDER BY PickLOC

END
GO
GRANT EXECUTE ON [dbo].[isp_Packing_List_31_rdt] TO [NSQL]
GO