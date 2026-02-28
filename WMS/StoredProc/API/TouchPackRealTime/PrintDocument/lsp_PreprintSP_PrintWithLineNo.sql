SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/***************************************************************************/
/* Stored Proc: [WM].[lsp_PreprintSP_PrintWithLineNo]                      */
/* Written by: YLI237                                                      */
/*                                                                         */
/* Purpose:   Set b_ContinuePrint after check with LineNo with             */
/*            @n_WMReportRowID                                             */
/*                                                                         */
/* Called By: lsp_WM_Print_Report                                          */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author   Ver   Purposes                                     */
/* 2026-01-27  YLI237   1.0   Initial Version                              */                                                                          
/***************************************************************************/

CREATE OR ALTER PROC [WM].[lsp_PreprintSP_PrintWithLineNo]
      @n_WMReportRowID BIGINT 
   ,@c_Parm1         NVARCHAR(60)      OUTPUT   
   ,@c_Parm2         NVARCHAR(60)      OUTPUT   
   ,@c_Parm3         NVARCHAR(60)      OUTPUT   
   ,@c_Parm4         NVARCHAR(60)      OUTPUT   
   ,@c_Parm5         NVARCHAR(60)      OUTPUT   
   ,@c_Parm6         NVARCHAR(60)      OUTPUT   
   ,@c_Parm7         NVARCHAR(60)      OUTPUT   
   ,@c_Parm8         NVARCHAR(60)      OUTPUT   
   ,@c_Parm9         NVARCHAR(60)      OUTPUT   
   ,@c_Parm10        NVARCHAR(60)      OUTPUT   
   ,@c_Parm11        NVARCHAR(60)      OUTPUT   
   ,@c_Parm12        NVARCHAR(60)      OUTPUT   
   ,@c_Parm13        NVARCHAR(60)      OUTPUT   
   ,@c_Parm14        NVARCHAR(60)      OUTPUT   
   ,@c_Parm15        NVARCHAR(60)      OUTPUT   
   ,@c_Parm16        NVARCHAR(60)      OUTPUT   
   ,@c_Parm17        NVARCHAR(60)      OUTPUT   
   ,@c_Parm18        NVARCHAR(60)      OUTPUT   
   ,@c_Parm19        NVARCHAR(60)      OUTPUT   
   ,@c_Parm20        NVARCHAR(60)      OUTPUT 
   ,@n_Noofparms     INT               OUTPUT   
   ,@b_ContinuePrint BIT               OUTPUT   
   ,@n_NoOfCopy      INT               OUTPUT   
   ,@c_PrinterID     NVARCHAR(30)      OUTPUT   
   ,@c_PrintData     NVARCHAR(4000)    OUTPUT 
   ,@b_Success       INT               OUTPUT 
   ,@n_Err           INT               OUTPUT 
   ,@c_ErrMsg        NVARCHAR(255)     OUTPUT 
   ,@c_UserName      NVARCHAR(30) =  ''
   ,@c_PrintSource   NVARCHAR(10) = 'WMReport' 
   ,@b_SCEPreView    INT          = 0     
   ,@n_JobID         INT          = 0  OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue     INT            = 1
         , @n_Cnt          INT            = 0
         , @n_NoOfKFParms  INT            = 0

         , @c_Udf01        NVARCHAR(60)   = ''
         , @c_Udf02        NVARCHAR(60)   = ''
         , @c_Udf03        NVARCHAR(60)   = ''
         , @c_Udf04        NVARCHAR(60)   = ''
         , @c_Udf05        NVARCHAR(60)   = ''
         , @c_Storerkey    NVARCHAR(15)   = ''
         , @c_ReprtID      NVARCHAR(10)   = ''

   DECLARE @c_SQL          NVARCHAR(MAX)  = ''
         , @c_SQLParms     NVARCHAR(MAX)  = ''
         , @c_Parm         NVARCHAR(60)   = ''
         , @c_ExtendParm1  NVARCHAR(60)   = ''
         , @c_ExtendParm2  NVARCHAR(60)   = ''
         , @c_ExtendParm3  NVARCHAR(60)   = ''
         , @c_ExtendParm4  NVARCHAR(60)   = ''
         , @c_ExtendParm5  NVARCHAR(60)   = ''
         , @c_ReportLineNo NVARCHAR(60)   = ''

   SET @b_Success = 1
   SET @n_Err     = 0
   SET @c_ErrMsg  = ''
   SET @b_ContinuePrint = 0

   SELECT @c_Storerkey = StorerKey
        , @c_ReprtID   = ReportID
        , @c_ReportLineNo = ReportLineNo
   FROM WMREPORTDETAIL WITH (NOLOCK)
   WHERE RowID = @n_WMReportRowID
   
   IF @c_Parm5 = @c_ReportLineNo
   BEGIN
      SET @b_ContinuePrint = 1
   END

    IF @n_JobID > 0
      BEGIN 
         Set @n_JobID = 0
      END

   EXIT_SP:

   IF @n_Continue = 3
   BEGIN
      SET @b_Success = 0
      SET @b_ContinuePrint = 0
   END
END
GO
