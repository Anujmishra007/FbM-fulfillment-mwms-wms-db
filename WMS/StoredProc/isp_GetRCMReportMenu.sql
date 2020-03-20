IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetRCMReportMenu]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetRCMReportMenu]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: isp_GetRCMReportMenu                                        */
/* Creation Date: 20-MAY-2016                                           */
/* Copyright: LF Logistics                                              */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:  d_dw_rcmreport_menu                                      */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/************************************************************************/
CREATE PROC [isp_GetRCMReportMenu] 
            @c_Storerkey      NVARCHAR(10)
         ,  @c_UserID         NVARCHAR(30)
         ,  @c_ComputerName   NVARCHAR(30)
         ,  @c_Reporttypes    NVARCHAR(255)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT 
         , @b_Success         INT
         , @n_Err             INT
         , @c_ErrMsg          NVARCHAR(255)

         , @c_RCMUsingUserID  NVARCHAR(10)
   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1

   CREATE TABLE #TMP_RPTTYPE
      ( ReportType   NVARCHAR(10) NULL 
      , ComputerName NVARCHAR(30) NULL )

   INSERT INTO #TMP_RPTTYPE
      ( ReportType )     
   SELECT ColValue
   FROM fnc_DelimSplit (',',@c_Reporttypes)

   EXECUTE nspGetRight 
            ''                   -- facility
        ,   @c_StorerKey         -- Storerkey
        ,   ''                   -- Sku
        ,   'RCMUsingUserID'     -- Configkey
        ,   @b_Success        OUTPUT
        ,   @c_RCMUsingUserID OUTPUT
        ,   @n_Err            OUTPUT
        ,   @c_ErrMsg         OUTPUT


   UPDATE #TMP_RPTTYPE
        SET ComputerName = CASE WHEN CL.ListName IS NOT NULL OR @c_RCMUsingUserID = '1' 
                                THEN @c_userid ELSE @c_ComputerName END
   FROM #TMP_RPTTYPE RT
   LEFT JOIN CODELKUP CL WITH (NOLOCK) ON  (CL.ListName = 'RCMBYUSER')
                                       AND (RT.ReportType = CL.Code)
                                       AND (CL.Storerkey = @c_Storerkey)

   SELECT  RT.ReportType
         , Description= CL.Description + 
                        CASE WHEN Row_Number() OVER (PARTITION by RT.ReportType ORDER BY RT.ReportType) = 2  
                        THEN ' (ALL)' ELSE'' END 
         , Event_Name = 'ue_print_' + LOWER(RTRIM(RT.ReportType)) 
                      + CASE WHEN Row_Number() OVER (PARTITION by RT.ReportType ORDER BY RT.ReportType) = 2  
                        THEN '_all' ELSE'' END 
   FROM #TMP_RPTTYPE RT
   JOIN RCMREPORT RCMR ON (RT.ReportType = RCMR.ReportType)
                       AND(RT.ComputerName = RCMR.ComputerName)
   LEFT JOIN CODELKUP  CL   ON (CL.listname = 'RCMREPORT')
                           AND(RCMR.ReportType = CL.Code)
   WHERE RCMR.Storerkey = @c_Storerkey
   ORDER BY RT.ReportType

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetRCMReportMenu] TO nSQL 
GO
