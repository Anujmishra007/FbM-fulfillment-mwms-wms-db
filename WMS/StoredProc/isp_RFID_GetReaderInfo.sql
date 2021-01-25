IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_RFID_GetReaderInfo]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_RFID_GetReaderInfo]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_RFID_GetReaderInfo                                  */
/* Creation Date: 2020-09-01                                            */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:  WMS-14739 - CN NIKE O2 WMS RFID Receiving Module           */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 09-OCT-2020 Wan      1.0   Created                                   */
/************************************************************************/
CREATE PROC isp_RFID_GetReaderInfo
           @c_ClientComputerName NVARCHAR(30) 
         , @c_Storerkey          NVARCHAR(15)
         , @c_RemoteEndPoint     NVARCHAR(30) = '' OUTPUT   -- Given by GIT 
         , @c_ReaderEndPoint     NVARCHAR(30) = '' OUTPUT   -- Provide/Setup by LIT
         , @c_DeviceID           NVARCHAR(20) = '' OUTPUT  
         , @c_AntennaID          NVARCHAR(20) = '' OUTPUT 
         , @n_DeviceTimeOut      INT          = 0  OUTPUT 
         , @n_ReceiveTimeOut     INT          = 0  OUTPUT   -- in miliseconds 
         , @n_TimerIdleInterval  INT          = 0  OUTPUT   -- in seconds 
         , @b_Success            INT          = 1  OUTPUT
         , @n_Err                INT          = 0  OUTPUT
         , @c_ErrMsg             NVARCHAR(255)= '' OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT = @@TRANCOUNT
         , @n_Continue        INT = 1

   SET @n_err      = 0
   SET @c_errmsg   = ''


   SELECT @n_ReceiveTimeOut    = ISNULL(CLST.UDF01,5000) 
         ,@n_TimerIdleInterval = ISNULL(CLST.UDF02,600) -- 60 x 10 min = 600 seconds 
   FROM CODELIST CLST (NOLOCK)
   WHERE CLST.ListName = 'RFIDReader'

   IF @n_ReceiveTimeOut IN ('', '0')
   BEGIN   
      SET @n_ReceiveTimeOut = 5000
   END 

   IF @n_TimerIdleInterval IN ('', '0')
   BEGIN   
      SET @n_TimerIdleInterval = 600
   END 

   SELECT TOP 1  @c_DeviceID      = CL.Code
         ,  @c_RemoteEndPoint= ISNULL(CL.UDF01,'')
         ,  @c_ReaderEndPoint= ISNULL(CL.UDF02,'')
         ,  @c_AntennaID     = ISNULL(CL.UDF03,'')
   FROM CODELKUP CL WITH (NOLOCK)
   WHERE CL.ListName = 'RFIDReader'
   AND   CL.Storerkey= @c_Storerkey
   AND   CL.Code2 = @c_ClientComputerName

   IF @@ROWCOUNT = 0
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 89010
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Communicate Device has not setup for Station:' + @c_ClientComputerName
                      + ' yet. (isp_RFID_GetReaderInfo)'
      GOTO QUIT_SP
   END

   IF @c_RemoteEndPoint = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 89020
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': RemoteEndPoint has not setup yet'
                      + '. (isp_RFID_GetReaderInfo)'
      GOTO QUIT_SP
   END

   IF @c_ReaderEndPoint = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 89030
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': ReaderEndPoint has not setup yet'
                      + '. (isp_RFID_GetReaderInfo)'
      GOTO QUIT_SP
   END

   IF @c_DeviceID = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 89040
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Device ID has not setup yet'
                      + '. (isp_RFID_GetReaderInfo)'
      GOTO QUIT_SP
   END

   IF @c_AntennaID = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 89050
      SET @c_ErrMsg   = 'NSQL' + CONVERT(CHAR(5),@n_Err) + ': Antenna ID has not setup yet'
                      + '. (isp_RFID_GetReaderInfo)'
      GOTO QUIT_SP
   END

QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_RFID_GetReaderInfo'
      --RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RFID_GetReaderInfo] TO nSQL 
GO
