SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: WMS                                                 */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: Dynamic lottable                                            */
/*                                                                      */
/* Date        Author   Rev   Purposes                                   */
/* 2023-11-17  Wan03    1.3   LFWM-4565 - Child ticket of 4355 - PROD CN */
/*                            ASNTradeReturn save document took very long*/
/*                            time                                       */
/*                            Performance tune                           */
/*                            Stucture Std as per WM.lsp_Post_Updated_Wrapper*/
/************************************************************************/
CREATE OR ALTER PROCEDURE [WM].[lsp_Post_Added_Receipt_STD]
      @c_StorerKey         NVARCHAR(15)
   ,  @c_RefKey1           NVARCHAR(50)  = '' 
   ,  @c_RefKey2           NVARCHAR(50)  = '' 
   ,  @c_RefKey3           NVARCHAR(50)  = '' 
   ,  @c_RefreshHeader     CHAR(1) = 'N' OUTPUT
   ,  @c_RefreshDetail     CHAR(1) = 'N' OUTPUT 
   ,  @b_Success           INT = 1 OUTPUT   
   ,  @n_Err               INT = 0 OUTPUT
   ,  @c_Errmsg            NVARCHAR(255) = ''  OUTPUT
   ,  @c_UserName          NVARCHAR(128) = '' 
AS
BEGIN
   --SET ANSI_NULLS ON                                                                             --(Wan03)
   --SET ANSI_PADDING ON                                                                           --(Wan03)
   --SET ANSI_WARNINGS ON                                                                          --(Wan03)
   --SET QUOTED_IDENTIFIER ON                                                                      --(Wan03)
   --SET CONCAT_NULL_YIELDS_NULL ON                                                                --(Wan03)
   --SET ARITHABORT ON                                                                             --(Wan03)
   SET NOCOUNT ON                                                                                  --(Wan03)
   SET ANSI_NULLS OFF                                                                              --(Wan03)
   SET QUOTED_IDENTIFIER OFF                                                                       --(Wan03)
   SET CONCAT_NULL_YIELDS_NULL OFF                                                                 --(Wan03)
      

   
   EXIT_SP:
  
END -- End Procedure
GO
GRANT EXECUTE ON [WM].[lsp_Post_Added_Receipt_STD] TO nSQL 
GO
