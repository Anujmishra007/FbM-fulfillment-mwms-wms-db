SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_Packing_List_142_rdt                                */
/* Creation Date: 06-Sep-2023                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose:WMS-23247 [TW] ADS PB Report Packing List_NEW                */
/*        :                                                             */
/* Called By: r_dw_packing_list_142_rdt                                 */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 06-Sep-2023  WLChooi   1.0 DevOps Combine Script                     */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Packing_List_142_rdt] @c_Pickslipno NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt     INT
         , @n_Continue      INT
         , @b_Success       INT
         , @n_Err           INT
         , @c_Errmsg        NVARCHAR(255)
   
   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_Errmsg = N''

   SELECT DISTINCT PH.Pickslipno
                 , IIF(ISNULL(OH.[Type],'') = 'ECOM', 'ECOM', 'NONEC') AS RptType
   FROM PACKHEADER PH (NOLOCK)
   JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = PH.OrderKey
   WHERE PH.PickSlipNo = @c_Pickslipno

END -- procedure  
GO
GRANT EXECUTE ON [dbo].[isp_Packing_List_142_rdt] TO NSQL
GO