IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_WM_Get_ReportID]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_WM_Get_ReportID]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Stored Proc: lsp_WM_Get_ReportID                                     */
/* Creation Date: 14-DEC-2018                                           */
/* Copyright: LF Logistics                                              */
/* Written by: CZTENG                                                   */
/*                                                                      */
/* Purpose: return reportID                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/

CREATE PROC [WM].[lsp_WM_Get_ReportID]
      @c_ModuleID           NVARCHAR(30)
    , @c_Storerkey          NVARCHAR(15)
    , @c_Facility           NVARCHAR(5)
    , @c_ReportType         NVARCHAR(30)
    , @c_ReportID           NVARCHAR(10)   OUTPUT
AS
BEGIN   
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF 

   DECLARE    
        @n_StartTCnt       INT  
      , @n_Continue        INT   
      , @n_err             INT  
      , @c_ErrMsg          NVARCHAR(255)  
  
   SET @n_StartTCnt = @@TRANCOUNT  
   SET @n_Continue = 1  
   SET @n_err      = 0  
   SET @c_errmsg   = ''  

   SET @c_ReportID = ISNULL(@c_ReportID,'')

   SELECT @c_ReportID = ISNULL(WMRH.ReportID,'')
   FROM dbo.WMREPORT WMRH WITH (NOLOCK)  
   WHERE WMRH.ReportType = @c_ReportType
   AND WMRH.ModuleID = @c_ModuleID 
   AND EXISTS (   SELECT 1   
                  FROM WM.fnc_Get_WMReportDetail (WMRH.ReportID, @c_Storerkey, @c_Facility, '', '', 'N')  
              )

   EXIT_SP:
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [WM].[lsp_WM_Get_ReportID] TO nSQL 
GO