SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/
/* Stored Procedure: isp_ptl_variance_report_01_rdt                      */
/* Creation Date: 21-May-2023                                            */
/* Copyright: MAERSK                                                     */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: WMS-22521 - CN PVH Variance Report                           */
/*                                                                       */
/* Called By: r_dw_ptl_variance_report_01_rdt                            */
/*                                                                       */
/* GitLab Version: 1.0                                                   */
/*                                                                       */
/* Version: 5.4                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author  Ver   Purposes                                    */
/* 21-May-2023 WLChooi 1.0   DevOps Combine Script                       */
/*************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_ptl_variance_report_01_rdt]
(
   @c_Storerkey NVARCHAR(15)
 , @c_Station   NVARCHAR(10)
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SELECT OH.LoadKey
        , PD.OrderKey
        , PTL.BatchKey
        , TRIM(PD.Sku) AS SKU
        , TRIM(PD.Loc) AS Loc
        , PD.Qty
        , RIGHT(TRIM(PTL.Position), 2) AS Position
        , PD.CaseID
   FROM PICKDETAIL PD (NOLOCK)
   JOIN RDT.rdtPTLPieceLog PTL (NOLOCK) ON PD.PickSlipNo = PTL.BatchKey AND PD.OrderKey = PTL.OrderKey
   JOIN ORDERS OH (NOLOCK) ON PD.OrderKey = OH.OrderKey
   WHERE PD.Storerkey = @c_Storerkey
   AND   PTL.Station = @c_Station
   AND   EXISTS (  SELECT 1
                   FROM PICKDETAIL PD2 (NOLOCK)
                   WHERE OH.StorerKey = PD2.Storerkey AND OH.OrderKey = PD2.OrderKey AND PD2.CaseID <> 'SORTED')
   ORDER BY PTL.Position
          , TRIM(PD.Sku)
END
GO
GRANT EXECUTE ON [dbo].[isp_ptl_variance_report_01_rdt] TO [NSQL]
GO