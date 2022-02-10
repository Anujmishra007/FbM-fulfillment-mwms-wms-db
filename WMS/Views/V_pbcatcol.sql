SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_pbcatcol] 
AS 
SELECT [pbc_tnam]
, [pbc_tid]
, [pbc_ownr]
, [pbc_cnam]
, [pbc_cid]
, [pbc_labl]
, [pbc_lpos]
, [pbc_hdr]
, [pbc_hpos]
, [pbc_jtfy]
, [pbc_mask]
, [pbc_case]
, [pbc_hght]
, [pbc_wdth]
, [pbc_ptrn]
, [pbc_bmap]
, [pbc_init]
, [pbc_cmnt]
, [pbc_edit]
, [pbc_tag]
FROM [pbcatcol] (NOLOCK) 
GO
GRANT DELETE ON  [dbo].[V_pbcatcol] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_pbcatcol] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_pbcatcol] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_pbcatcol] TO [NSQL]
GO
