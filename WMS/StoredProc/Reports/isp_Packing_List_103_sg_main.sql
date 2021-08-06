IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Packing_List_103_sg_main]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_Packing_List_103_sg_main]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_Packing_List_103_sg_main                            */
/* Creation Date: 03-AUG-2021                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Mingle                                                   */
/*                                                                      */
/* Purpose:  WMS-17356                                                  */
/*        :                                                             */
/* Called By: r_dw_packing_list_sg_main                                 */
/*          :                                                           */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/************************************************************************/

CREATE PROC [dbo].[isp_Packing_List_103_sg_main] (  
   @c_MBOLKey  NVARCHAR(21)   
  ,@c_type     NVARCHAR(10)   = ''
  ,@c_ShipType NVARCHAR(10)   = ''  
)   
AS   
BEGIN  
   SET NOCOUNT ON  
  -- SET ANSI_WARNINGS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET ANSI_DEFAULTS OFF  

   SELECT DISTINCT MBOL.Mbolkey AS mbolkey,
                   Shiptype = @c_ShipType,
                   ORDERS.type AS ordertype
   FROM MBOL WITH (NOLOCK)
   INNER JOIN MBOLDETAIL WITH (NOLOCK) ON (MBOL.MBOLKey = MBOLDETAIL.MBOLKey)  
   INNER JOIN ORDERS WITH (NOLOCK) ON (ORDERS.OrderKey = MBOLDETAIL.OrderKey)
   WHERE MBOL.Mbolkey = @c_mbolkey
   GROUP BY MBOL.Mbolkey,ORDERS.type

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_Packing_List_103_sg_main] TO nSQL 
GO

