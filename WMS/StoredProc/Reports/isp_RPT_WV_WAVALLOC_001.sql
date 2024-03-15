SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*************************************************************************/
/* Stored Procedure: isp_RPT_WV_WAVALLOC_001                             */
/* Creation Date: 12-Mar-2024                                            */
/* Copyright: MAERSK                                                     */
/* Written by: WLChooi                                                   */
/*                                                                       */
/* Purpose: UWP-16692 - WAVALLOC New Report for PUMA CHILE               */
/*                                                                       */
/* Called By: RPT_WV_WAVALLOC_001                                        */
/*                                                                       */
/* GitHub Version: 1.0                                                   */
/*                                                                       */
/* Version: 5.4                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author  Ver   Purposes                                    */
/* 12-Mar-2024 WLChooi 1.0   DevOps Combine Script                       */
/*************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_WV_WAVALLOC_001] @c_Wavekey NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   SET NOCOUNT ON

   DECLARE @b_debug           INT
         , @n_StartTCnt       INT
         , @n_continue        INT = 1
         , @b_success         INT = 1
         , @n_err             INT = 0
         , @c_errmsg          NVARCHAR(255) = ''

   SELECT @n_StartTCnt = @@TRANCOUNT

   SELECT SKU.PACKKey
        , ORDERDETAIL.StorerKey
        , ORDERDETAIL.OrderKey
        , ORDERDETAIL.ExternOrderKey
        , ORDERDETAIL.OrderLineNumber
        , ORDERDETAIL.OpenQty
        , ORDERDETAIL.QtyAllocated
        , ORDERDETAIL.OriginalQty
        , ORDERDETAIL.Sku
        , ORDERDETAIL.ManufacturerSku
        , PACK.CaseCnt
        , WAVEDETAIL.WaveKey
        , ORDERDETAIL.UOM
        , SKU.PackQtyIndicator
        , ORDERDETAIL.Lottable02
        , SKU.BUSR7
        , VarQty = (ORDERDETAIL.QtyAllocated - ORDERDETAIL.OpenQty) 
        , TotalVarQty = (SELECT SUM(OD.QtyAllocated - OD.OpenQty)
                         FROM ORDERDETAIL OD (NOLOCK)
                         WHERE OD.OrderKey = ORDERDETAIL.OrderKey)
        , Group1 = (WAVEDETAIL.WaveKey + ORDERDETAIL.OrderKey)
        , DiffSku = IIF(ORDERDETAIL.ManufacturerSku = ORDERDETAIL.Sku, 'N', 'Y')
        , CurrentDateTime = [dbo].[fnc_ConvSFTimeZone](ORDERS.StorerKey, ORDERS.Facility, GETDATE())
   FROM WAVEDETAIL (NOLOCK)
   JOIN ORDERS (NOLOCK) ON (ORDERS.OrderKey = WAVEDETAIL.OrderKey)
   JOIN ORDERDETAIL (NOLOCK) ON (ORDERDETAIL.OrderKey = ORDERS.OrderKey)
   JOIN SKU (NOLOCK) ON (SKU.StorerKey = ORDERDETAIL.StorerKey) 
                    AND (SKU.Sku = ORDERDETAIL.Sku)
   JOIN PACK (NOLOCK) ON (SKU.PACKKey = PACK.PackKey)
   WHERE (ORDERDETAIL.OriginalQty <> ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked)
   AND   (ORDERDETAIL.ShippedQty = 0)
   AND   (ORDERS.[Status] = '1')
   AND   (WAVEDETAIL.WaveKey = @c_Wavekey)
   ORDER BY ORDERDETAIL.OrderKey, ORDERDETAIL.OrderLineNumber

END