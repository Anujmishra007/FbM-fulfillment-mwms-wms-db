IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[V_BTBShipment_Wave]')) 
   DROP VIEW [dbo].[V_BTBShipment_Wave]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* View: V_BTBShipment_Wave                                                */
/* Creation Date: 2020-06-18                                               */
/* Copyright: LF Logistics                                                 */
/* Written by: Wan                                                         */
/*                                                                         */
/* Purpose: WMS-13409-SG - Logitech - Back to Back Declaration for Form DE */
/*                                                                         */
/* Called By: d_dw_populate_btb_wave_grid &  d_dw_populate_btb_wave_query  */
/*          :                                                              */
/* GitLab Version: 1.0                                                     */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author   Ver   Purposes                                     */
/***************************************************************************/
CREATE VIEW [dbo].[V_BTBShipment_Wave]
AS 
SELECT WD.WAVEKEY
FROM WAVEDETAIL WD (NOLOCK)
JOIN PICKDETAIL PD (NOLOCK) ON PD.Orderkey = WD.Orderkey
GROUP BY WD.Wavekey
HAVING ISNULL(SUM(PD.Qty),0) > ( SELECT ISNULL(SUM(BSD.QtyExported),0)
                                 FROM BTB_SHIPMENTDETAIL BSD WITH (NOLOCK) 
                                 JOIN BTB_SHIPMENT BSH WITH (NOLOCK) ON BSD.BTB_ShipmentKey = BSH.BTB_ShipmentKey
                                 WHERE BSD.Wavekey = WD.Wavekey
                                 AND   BSH.[Status] = '9')
GO
GRANT SELECT ON [dbo].[V_BTBShipment_Wave] TO nSQL
GO   

 