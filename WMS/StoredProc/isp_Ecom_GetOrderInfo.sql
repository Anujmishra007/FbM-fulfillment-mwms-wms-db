IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Ecom_GetOrderInfo]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_Ecom_GetOrderInfo]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_Ecom_GetOrderInfo                                   */
/* Creation Date: 14-JUN-2019                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: Performance Tune                                            */
/*        :                                                             */
/* Called By: ECOM PackHeader - ue_saveend                              */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/
CREATE PROC isp_Ecom_GetOrderInfo
           @c_Orderkey   NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT            = @@TRANCOUNT
         , @n_Continue        INT            = 1

   WHILE @@TRANCOUNT > 0 
   BEGIN
      COMMIT TRAN
   END

   SELECT ORDERS.Orderkey
      ,ORDERS.ExternOrderkey
      ,ORDERS.LoadKey
      ,ORDERS.ConsigneeKey
      ,ORDERS.ShipperKey
      ,ORDERS.SalesMan
      ,ORDERS.Route
      ,ORDERS.UserDefine03
      ,ORDERS.UserDefine04
      ,ORDERS.UserDefine05
      ,ORDERS.Status
      ,ORDERS.SOStatus
      ,TrackingNo = CASE WHEN ISNULL(RTRIM(TrackingNo),'') <> '' THEN TrackingNo ELSE ISNULL(RTRIM(UserDefine04),'') END
   FROM ORDERS WITH (NOLOCK)
   WHERE Orderkey = @c_Orderkey

QUIT_SP:
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_Ecom_GetOrderInfo] TO nSQL 
GO
