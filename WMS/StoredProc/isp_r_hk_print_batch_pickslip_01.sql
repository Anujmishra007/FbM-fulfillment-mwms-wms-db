if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_r_hk_print_batch_pickslip_01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_r_hk_print_batch_pickslip_01]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure: isp_r_hk_print_batch_pickslip_01                    */
/* Creation Date: 06-Dec-2017                                            */
/* Copyright: LFL                                                        */
/* Written by: Michael Lam (HK LIT)                                      */
/*                                                                       */
/* Purpose: Batch Pickslip                                               */
/*                                                                       */
/* Called By: RCM - Print Batch Pick Slips in LoadPlan                   */
/*            Datawidnow r_hk_print_batch_pickslip_01                    */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/*************************************************************************/

CREATE PROCEDURE [dbo].[isp_r_hk_print_batch_pickslip_01] (
       @c_loadkey  NVARCHAR(10)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt    INT

   SELECT @n_StartTCnt  = @@TRANCOUNT


   IF OBJECT_ID('tempdb..#TEMP_PICKDETAIL') IS NOT NULL
      DROP TABLE #TEMP_PICKDETAIL

   CREATE TABLE #TEMP_PICKDETAIL (
        PickSlipNo       NVARCHAR(10) NULL
      , Loadkey          NVARCHAR(10) NULL
      , Route            NVARCHAR(10) NULL
      , Route_Desc       NVARCHAR(60) NULL
      , TrfRoom          NVARCHAR(10) NULL
      , Notes1           NVARCHAR(80) NULL
      , Notes2           NVARCHAR(80) NULL
      , LOC              NVARCHAR(10) NULL
      , SKU              NVARCHAR(20) NULL
      , SkuDesc          NVARCHAR(60) NULL
      , Qty              INT          NULL
      , TempQty1         INT          NULL
      , TempQty2         INT          NULL
      , PrintedFlag      NVARCHAR(1)  NULL
      , Zone             NVARCHAR(1)  NULL
      , PgGroup          INT          NULL
      , RowNum           INT          NULL
      , Lot              NVARCHAR(10) NULL
      , VehicleNo        NVARCHAR(10) NULL
      , Lottable02       NVARCHAR(18) NULL
      , Lottable04       DATETIME     NULL
      , AllocatedCube    FLOAT        NULL
      , AllocatedWeight  FLOAT        NULL
      , ZoneDesc         NVARCHAR(60) NULL
      , DeliveryDate     DATETIME     NULL
      , CaseCnt          INT          NULL
      , LogicalLocation  NVARCHAR(18) NULL
      , InnerPack        INT          NULL
      , AltSKU           NVARCHAR(20) NULL
      , Showfield        NVARCHAR(1)  NULL
      , SUSR3            NVARCHAR(30) NULL
      , Lottable06       NVARCHAR(30) NULL
      , Facility         NVARCHAR(5)  NULL
      , Delivery_Zone    NVARCHAR(30) NULL
      , ExternLoadkey    NVARCHAR(30) NULL
   )

   INSERT INTO #TEMP_PICKDETAIL
   EXEC nsp_GetPickSlipALL @c_loadkey

   UPDATE PIKDT
      SET Delivery_Zone = CASE WHEN ISNULL(LP.Route, '')=ISNULL(PIKDT.Delivery_Zone,'')
                               THEN ISNULL(LP.Route, '')
                               ELSE LTRIM(RTRIM(ISNULL(LP.Route, '')) +
                                    IIF(ISNULL(LP.Route,'')<>'' AND ISNULL(PIKDT.Delivery_Zone,'')<>'', ', ', '') +
                                    LTRIM(ISNULL(PIKDT.Delivery_Zone,'')))
                          END
     FROM #TEMP_PICKDETAIL PIKDT
     JOIN LOADPLAN LP (NOLOCK) ON PIKDT.Loadkey = LP.Loadkey

   SELECT *
   FROM #TEMP_PICKDETAIL

   DROP TABLE #TEMP_PICKDETAIL

   WHILE @@TRANCOUNT > @n_StartTCnt
   BEGIN
      COMMIT TRAN
   END
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO

GRANT EXECUTE ON isp_r_hk_print_batch_pickslip_01 TO NSQL
GO