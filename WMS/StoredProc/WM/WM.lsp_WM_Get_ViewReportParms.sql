IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_WM_Get_ViewReportParms]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_WM_Get_ViewReportParms]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: lsp_WM_Get_ViewReportParms                              */
/* Creation Date: 05-SEP-2018                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: LFWM-1115 - View Report Set Up Clarification                */
/*                                                                      */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/
CREATE PROC [WM].[lsp_WM_Get_ViewReportParms]
           @c_ModuleID           NVARCHAR(30) = 'ViewReport'
         , @c_ReportID           NVARCHAR(10)
         , @c_UserName           NVARCHAR(128) 
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
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

   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] 
            @c_UserName = @c_UserName  OUTPUT 
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
                
   EXECUTE AS LOGIN = @c_UserName
   
   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END

   DECLARE @dt_today       DATETIME
      , @dt_now            DATETIME
      , @dt_startofmonth   DATETIME 
      , @dt_endofmonth     DATETIME 
      , @dt_startofyear    DATETIME
      , @dt_endtofyear     DATETIME  
      , @c_today_d         NVARCHAR(10) = ''
      , @c_now_d           NVARCHAR(10) = ''
      , @c_startofmonth_d  NVARCHAR(10) = '' 
      , @c_endofmonth_d    NVARCHAR(10) = '' 
      , @c_startofyear_d   NVARCHAR(10) = ''
      , @c_endtofyear_d    NVARCHAR(10) = ''  
      , @c_today_dt        NVARCHAR(19) = ''
      , @c_now_dt          NVARCHAR(19) = ''
      , @c_startofmonth_dt NVARCHAR(19) = '' 
      , @c_endofmonth_dt   NVARCHAR(19) = '' 
      , @c_startofyear_dt  NVARCHAR(19) = ''
      , @c_endtofyear_dt   NVARCHAR(19) = ''  

   SET @dt_today           = GETDATE()
   --SET @dt_today         = CONVERT(DATETIME, CONVERT(NVARCHAR(10), @dt_now, 120))
   SET @dt_startofmonth  = DATEFROMPARTS ( YEAR(@dt_today), MONTH(@dt_today), '01' )
   SET @dt_endofmonth    = DATETIMEFROMPARTS ( YEAR(@dt_today), MONTH(@dt_today), DAY(EOMONTH(@dt_today)), '23', '59', '59','0' )
   SET @dt_startofyear   = DATEFROMPARTS ( YEAR(@dt_today), '01', '01' )
   SET @dt_endtofyear    = DATETIMEFROMPARTS ( YEAR(@dt_today), '12', '31', '23', '59', '59','0' )

   SET @c_today_d         = CONVERT(NVARCHAR(10), @dt_today, 120)
   SET @c_now_d           = CONVERT(NVARCHAR(10), @dt_today, 120)
   SET @c_startofmonth_d  = CONVERT(NVARCHAR(10), @dt_startofmonth, 120) 
   SET @c_endofmonth_d    = CONVERT(NVARCHAR(10), @dt_endofmonth, 120)
   SET @c_startofyear_d   = CONVERT(NVARCHAR(10), @dt_startofyear, 120)
   SET @c_endtofyear_d    = CONVERT(NVARCHAR(10), @dt_endtofyear, 120)   

   SET @c_today_dt        = CONVERT(NVARCHAR(10), @dt_today, 120)
   SET @c_now_dt          = CONVERT(NVARCHAR(19), @dt_today, 120)
   SET @c_startofmonth_dt = CONVERT(NVARCHAR(19), @dt_startofmonth, 120) 
   SET @c_endofmonth_dt   = CONVERT(NVARCHAR(19), @dt_endofmonth, 120)
   SET @c_startofyear_dt  = CONVERT(NVARCHAR(19), @dt_startofyear, 120)
   SET @c_endtofyear_dt   = CONVERT(NVARCHAR(19), @dt_endtofyear, 120)   

   SELECT  Rpt_id
         , Parm_No
         , parm_label
         , Parm_default_string   = CASE WHEN parm_datatype = 'date' AND Parm_default = 'now'             THEN @c_now_d
                                        WHEN parm_datatype = 'date' AND Parm_default = 'today'           THEN @c_today_d
                                        WHEN parm_datatype = 'date' AND Parm_default = 'startofmonth'    THEN @c_startofmonth_d
                                        WHEN parm_datatype = 'date' AND Parm_default = 'endofmonth'      THEN @c_endofmonth_d
                                        WHEN parm_datatype = 'date' AND Parm_default = 'startofyear'     THEN @c_startofyear_d
                                        WHEN parm_datatype = 'date' AND Parm_default = 'endofyear'       THEN @c_endtofyear_d 
                                        WHEN parm_datatype = 'datetime' AND Parm_default = 'now'         THEN @c_now_dt
                                        WHEN parm_datatype = 'datetime' AND Parm_default = 'today'       THEN @c_today_dt
                                        WHEN parm_datatype = 'datetime' AND Parm_default = 'startofmonth'THEN @c_startofmonth_dt
                                        WHEN parm_datatype = 'datetime' AND Parm_default = 'endofmonth'  THEN @c_endofmonth_dt
                                        WHEN parm_datatype = 'datetime' AND Parm_default = 'startofyear' THEN @c_startofyear_dt
                                        WHEN parm_datatype = 'datetime' AND Parm_default = 'endofyear'   THEN @c_endtofyear_dt
                                        WHEN parm_datatype = 'datetime'                                  THEN @c_now_dt  
                                        --WHEN parm_datatype = 'string' AND CHARINDEX('Storer',Parm_label) > 0 AND  @c_RestrictStorerkey <> '' THEN @c_RestrictStorerkey
                                        ELSE ISNULL(RTRIM(Parm_default),'') 
                                        END
         , parm_datatype
         , Style
         , Display
         , [Data]
         , Attributes
   FROM PBSRPT_PARMS (NOLOCK) 
   WHERE Rpt_id = @c_ReportID
   AND Rpt_Id NOT IN ('BAL01', 'BAL01NEW')
   ORDER BY parm_no

   EXIT_SP:
END -- procedure
GO
GRANT EXECUTE ON [WM].[lsp_WM_Get_ViewReportParms] TO nSQL 
GO
