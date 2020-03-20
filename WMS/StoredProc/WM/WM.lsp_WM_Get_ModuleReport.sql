IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_WM_Get_ModuleReport]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_WM_Get_ModuleReport]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: lsp_WM_Get_ModuleReport                                 */
/* Creation Date: 02-FEB-2018                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: LFWM-183:List of Labels, Document Print and Reports to be   */
/*          considered & DB procedute Details for the same              */
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
CREATE PROC [WM].[lsp_WM_Get_ModuleReport]
           @c_ModuleID           NVARCHAR(30)
         , @c_Storerkey          NVARCHAR(15)
         , @c_Facility           NVARCHAR(5)
         , @c_UserName           NVARCHAR(128) 
         , @c_ComputerName       NVARCHAR(30) 
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
   EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT
   
   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END

   IF NOT EXISTS (SELECT 1
                  FROM CODELKUP CL WITH (NOLOCK)
                  WHERE ListName = 'WMRptModID'
                  AND   Code = @c_ModuleID
                 )
   BEGIN
      INSERT INTO CODELKUP (ListName, Code, Description)
      VALUES ('WMRptModID', @c_ModuleID, @c_ModuleID)
   END

   SELECT WMRH.ReportID
      ,   WMRH.ReportTitle
      ,   WMRH.KeyFieldName1
      ,   KeyFieldName2 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName2),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName2),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel2,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName2),'')
                               ELSE ''
                               END
      ,   KeyFieldName3 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName3),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName3),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel3,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName3),'')
                               ELSE ''
                               END
      ,   KeyFieldName4 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName4),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName4),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel4,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName4),'')
                               ELSE ''
                               END
      ,   KeyFieldName5 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName5),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName5),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel5,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName5),'')
                               ELSE ''
                               END
      ,   KeyFieldName6 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName6),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName6),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel6,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName6),'')
                               ELSE ''
                               END
      ,   KeyFieldName7 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName7),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName7),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel7,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName7),'')
                               ELSE ''
                               END
      ,   KeyFieldName8 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName8),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName8),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel8,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName8),'')
                               ELSE ''
                               END
      ,   KeyFieldName9 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName9),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName9),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel9,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName9),'')
                               ELSE ''
                               END
      ,   KeyFieldName10 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName10),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName10),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel10,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName10),'')
                               ELSE ''
                               END
      ,   KeyFieldName11 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName11),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName11),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel11,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName11),'')
                               ELSE ''
                               END
      ,   KeyFieldName12 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName12),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName12),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel12,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName12),'')
                               ELSE ''
                               END
      ,   KeyFieldName13 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName13),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName13),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel13,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName13),'')
                               ELSE ''
                               END
      ,   KeyFieldName14 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName14),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName14),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel14,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName14),'')
                               ELSE ''
                               END
      ,   KeyFieldName15 = CASE WHEN ISNULL(CHARINDEX('.', WMRH.KeyFieldName15),0) > 0 
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName15),'')
                               WHEN ISNULL(WMRH.KeyFieldParmLabel15,'') <> ''
                               THEN ISNULL(RTRIM(WMRH.KeyFieldName15),'')
                               ELSE ''
                               END            
      ,   WMRH.ExtendedParm1 
      ,   WMRH.ExtendedParm2      
      ,   WMRH.ExtendedParm3
      ,   WMRH.ExtendedParm4
      ,   WMRH.ExtendedParm5
      ,   WMRH.ExtendedParmDefault1
      ,   WMRH.ExtendedParmDefault2
      ,   WMRH.ExtendedParmDefault3
      ,   WMRH.ExtendedParmDefault4
      ,   WMRH.ExtendedParmDefault5
      ,   NeedExtendedParm = CASE WHEN ISNULL(RTRIM(WMRH.ExtendedParm1),'') <> '' THEN 'Y' ELSE 'N' END
      ,   KeyFieldParmLabel1 = ISNULL(WMRH.KeyFieldParmLabel1,'')
      ,   KeyFieldParmLabel2 = ISNULL(WMRH.KeyFieldParmLabel2,'')
      ,   KeyFieldParmLabel3 = ISNULL(WMRH.KeyFieldParmLabel3,'')
      ,   KeyFieldParmLabel4 = ISNULL(WMRH.KeyFieldParmLabel4,'')
      ,   KeyFieldParmLabel5 = ISNULL(WMRH.KeyFieldParmLabel5,'')
      ,   KeyFieldParmLabel1 = ISNULL(WMRH.KeyFieldParmLabel1,'')
      ,   KeyFieldParmLabel6 = ISNULL(WMRH.KeyFieldParmLabel6,'')
      ,   KeyFieldParmLabel7 = ISNULL(WMRH.KeyFieldParmLabel7,'')
      ,   KeyFieldParmLabel8 = ISNULL(WMRH.KeyFieldParmLabel8,'')
      ,   KeyFieldParmLabel9 = ISNULL(WMRH.KeyFieldParmLabel9,'')
      ,   KeyFieldParmLabel10= ISNULL(WMRH.KeyFieldParmLabel10,'')
      ,   KeyFieldParmLabel11= ISNULL(WMRH.KeyFieldParmLabel11,'')
      ,   KeyFieldParmLabel12= ISNULL(WMRH.KeyFieldParmLabel12,'')
      ,   KeyFieldParmLabel13= ISNULL(WMRH.KeyFieldParmLabel13,'')
      ,   KeyFieldParmLabel14= ISNULL(WMRH.KeyFieldParmLabel14,'')
      ,   KeyFieldParmLabel15= ISNULL(WMRH.KeyFieldParmLabel15,'')
   FROM dbo.WMREPORT WMRH WITH (NOLOCK)
   WHERE WMRH.ModuleID = @c_ModuleID
   AND EXISTS (   SELECT 1 
                  FROM WM.fnc_Get_WMReportDetail (WMRH.ReportID, @c_Storerkey, @c_Facility, @c_UserName, @c_ComputerName, 'N')
               )
   EXIT_SP:
END -- procedure
GO
GRANT EXECUTE ON [WM].[lsp_WM_Get_ModuleReport] TO nSQL 
GO
