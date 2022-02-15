SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/***************************************************************************/
/* View: BI.V_ChannelITran                                                 */
/* https://jiralfl.atlassian.net/browse/WMS-17256                          */
/* Creation Date: 11-Jun-2021                                              */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author    Ver.  Purposes                                   */
/* 11-Jun-2021  KSheng    1.0   Created                                    */
/***************************************************************************/
CREATE VIEW [BI].[V_ChannelITran] 
AS
SELECT * FROM ChannelITran WITH (NOLOCK)
GO

GRANT SELECT ON [BI].[V_ChannelITran] TO JReportRole
GO