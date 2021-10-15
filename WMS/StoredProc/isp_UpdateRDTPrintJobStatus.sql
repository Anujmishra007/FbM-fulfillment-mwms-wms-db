IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_UpdateRDTPrintJobStatus]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_UpdateRDTPrintJobStatus]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_UpdateRDTPrintJobStatus                             */
/* Creation Date: 01-NOV-2018                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.4                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2018-11-11  Wan01    1.1   Fixed  to rollback                        */
/* 2019-03-12  Wan01    1.0   WM - Printing: Add Parm11 - Parm20        */
/* 2019-06-16  James    1.2   Comment commit tran before start          */
/*                            transaction (james01)                     */
/* 2020-11-23  Wan02    1.3   Fixed.Insert NULL to RDT.RDTPRINTJOB_LOG  */
/* 2021-07-28  Wan03    1.4   LFWM-2800 - RG UAT PB Report Print Preview*/
/*                            SP & sharedrive for PDF Storage           */
/* 2021-09-24  Wan03    1.4   DevOps Combine Script                     */
/************************************************************************/
CREATE PROC [dbo].[isp_UpdateRDTPrintJobStatus]
      @n_JobID          BIGINT
   ,  @c_JobStatus      NVARCHAR(10)
   ,  @c_JobErrMsg      NVARCHAR(255)
   ,  @b_Success        INT            = 1   OUTPUT
   ,  @n_Err            INT            = 0   OUTPUT
   ,  @c_ErrMsg         NVARCHAR(255)  = ''  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT 

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @b_Success  = 1

   SET @c_JobErrMsg = ISNULL(RTRIM(@c_JobErrMsg), '')          -- (Wan01)

   --( james01)
   /*
   WHILE @@TRANCOUNT > 0 
   BEGIN
      COMMIT TRAN
   END
   */
   IF @c_JobStatus IN ('5', '9')
   BEGIN
      BEGIN TRAN
         INSERT INTO RDT.RDTPRINTJOB_LOG
         (  [JobId]         
         ,  [JobName]       
         ,  [ReportID]      
         ,  [JobStatus]  
         ,  [JobErrMsg]     
         ,  [NextRun]       
         ,  [LastRun]       
         ,  [Datawindow]    
         ,  [NoOfParms]     
         ,  [Parm1]         
         ,  [Parm2]         
         ,  [Parm3]         
         ,  [Parm4]         
         ,  [Parm5]         
         ,  [Parm6]         
         ,  [Parm7]         
         ,  [Parm8]         
         ,  [Parm9]         
         ,  [Parm10]        
         ,  [Printer]       
         ,  [NoOfCopy]      
         ,  [Mobile]        
         ,  [TargetDB]      
         ,  [AddDate]       
         ,  [AddWho]        
         ,  [EditDate]      
         ,  [EditWho]       
         ,  [PrintCount]    
         ,  [PrintData]     
         ,  [JobType]       
         ,  [StorerKey]     
         ,  [ExportFileName]
         ,  [Parm11]        
         ,  [Parm12]        
         ,  [Parm13]        
         ,  [Parm14]        
         ,  [Parm15]        
         ,  [Parm16]        
         ,  [Parm17]        
         ,  [Parm18]        
         ,  [Parm19]        
         ,  [Parm20]        
         ,  [Function_ID] 
         ,  [ReportLineNo]
         ,  [PDFPreview]                                 --(Wan03)         
         )

      SELECT   [JobId]         
            ,  [JobName]       
            ,  [ReportID]      
            ,  @c_JobStatus     
            ,  @c_JobErrMsg  
            ,  [NextRun]       
            ,  [LastRun]       
            ,  Datawindow = ISNULL([Datawindow],'')    -- (Wan02) ,  [Datawindow]    
            ,  [NoOfParms]     
            ,  [Parm1]         
            ,  [Parm2]         
            ,  [Parm3]         
            ,  [Parm4]         
            ,  [Parm5]         
            ,  [Parm6]         
            ,  [Parm7]         
            ,  [Parm8]         
            ,  [Parm9]         
            ,  [Parm10]        
            ,  [Printer]       
            ,  [NoOfCopy]      
            ,  [Mobile]        
            ,  [TargetDB]      
            ,  [AddDate]       
            ,  [AddWho]        
            ,  GETDATE()     
            ,  SUSER_NAME()      
            ,  [PrintCount]     
            ,  [PrintData]       
            ,  [JobType]         
            ,  [StorerKey]     
            ,  [ExportFileName]   
            ,  [Parm11]        
            ,  [Parm12]        
            ,  [Parm13]        
            ,  [Parm14]        
            ,  [Parm15]        
            ,  [Parm16]        
            ,  [Parm17]        
            ,  [Parm18]        
            ,  [Parm19]        
            ,  [Parm20]  
            ,  [Function_ID] 
            ,  [ReportLineNo] 
            ,  [PDFPreview]                                 --(Wan04)   
      FROM RDT.RDTPRINTJOB WITH (NOLOCK)
      WHERE JobID = @n_JobId   
      
      SET @n_Err = @@ERROR
      
      IF @n_Err  <> 0
      BEGIN
         SET @n_Continue = 3
         SET @c_ErrMsg =  CONVERT(CHAR(5), @n_Err) 
         SET @n_Err = 62820
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + ': Insert record Into RDT.RDTPRINTJOB_LOG Fail - JobID:' + CAST(@n_JobId AS NVARCHAR) + '. (isp_UpdateRDTPrintJobStatus)'
                       + '(' + @c_ErrMsg + ')'
         GOTO QUIT_SP
      END  
      
      DELETE RDT.RDTPRINTJOB   
      WHERE JobID = @n_JobId   
      
      SET @n_Err = @@ERROR
      
      IF  @n_Err  <> 0
      BEGIN
         SET @n_Continue = 3
         SET @c_ErrMsg =  CONVERT(CHAR(5), @n_Err) 
         SET @n_Err = 62830
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) + ': Delete record from RDT.RDTPRINTJOB Fail. (isp_UpdateRDTPrintJobStatus)'
                       + '(' + @c_ErrMsg + ')'
         GOTO QUIT_SP
      END 
   END
QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT > 0 --@n_StartTCnt   (Wan01) 
      BEGIN
         ROLLBACK TRAN
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_UpdateRDTPrintJobStatus'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > 0
      BEGIN
         COMMIT TRAN
      END
   END

   WHILE @@TRANCOUNT <  @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_UpdateRDTPrintJobStatus] TO nSQL 
GO