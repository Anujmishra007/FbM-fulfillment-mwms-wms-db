SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_idsStkTrfDocDetail] AS SELECT * FROM idsStkTrfDocDetail WITH (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_idsStkTrfDocDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_idsStkTrfDocDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_idsStkTrfDocDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_idsStkTrfDocDetail] TO [NSQL]
GO
