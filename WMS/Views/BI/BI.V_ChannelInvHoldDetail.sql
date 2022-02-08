SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/***************************************************************************/
/* View: BI.V_ChannelInvHoldDetail                                         */
/* https://jiralfl.atlassian.net/browse/WMS-17256                          */
/* Creation Date: 11-Jun-2021                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author    Ver.  Purposes                                   */
/* 11-Jun-2021  ZiWei    1.0   Created                                     */
/***************************************************************************/

CREATE OR ALTER VIEW [Bi].[V_ChannelInvHoldDetail] 
AS SELECT * FROM ChannelInvHoldDetail WITH (NOLOCK)
GO

GRANT SELECT ON Bi.V_ChannelInvHoldDetail TO JreportRole
GO

--Select top 10* FROM Bi.V_ChannelInvHoldDetail;