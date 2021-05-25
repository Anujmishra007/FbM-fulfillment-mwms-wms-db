IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnc_ASNExceptionGetOverdue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
   DROP FUNCTION [dbo].[fnc_ASNExceptionGetOverdue]
END

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Function: dbo.fnc_ASNExceptionGetOverdue                             */
/* Creation Date: 12-MAY-2021                                           */
/* Copyright: LF Logistics                                              */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose:  WMS-16957 - [CN]Nike_Phoeix_B2C_Exceed_Exception_Tracking  */
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
/* Date        Author    Ver Purposes                                   */
/* 2021-05-12  Wan      1.0   Created                                   */
/************************************************************************/
CREATE FUNCTION dbo.fnc_ASNExceptionGetOverdue 
(
   @n_RowRef      BIGINT
,  @c_documentno  NVARCHAR(10)
)
RETURNS @t_Overdue TABLE  
(  RowRef         BIGINT
,  Documentno     NVARCHAR(10)
,  [Status]       NVARCHAR(20) 
)       
AS
BEGIN   
   DECLARE  
           @c_Receiptkey      NVARCHAR(10)   = ''
         , @c_Overdue         NVARCHAR(20)   = ''
         , @dt_Userdefine06   DATETIME       

   SELECT TOP 1 @c_ReceiptKey = di.Key1 
   FROM DocStatusTrack AS dst WITH (NOLOCK)  
   JOIN DocInfo AS di WITH (NOLOCK) ON di.TableName  = 'RECEIPT'
                                       AND di.Key3 = dst.Userdefine01
                                       AND di.StorerKey = dst.Storerkey
   WHERE dst.RowRef = @n_RowRef
   AND dst.DocumentNo= @c_DocumentNo
   AND dst.TableName = 'ASNException'
   ORDER BY di.AddDate DESC
   
   SELECT @dt_Userdefine06 = r.UserDefine06
   FROM RECEIPT AS r WITH (NOLOCK)
   WHERE r.ReceiptKey = @c_ReceiptKey

   IF DATEDIFF(DAY, @dt_Userdefine06, GETDATE()) > 0 
   BEGIN
      SET @c_Overdue = N'¼Ó¼±£¡'
   END

   EXIT_FUNCTION: 
   INSERT INTO @t_Overdue ( RowRef, DocumentNo, [Status] ) 
   VALUES ( @n_RowRef, @c_DocumentNo, @c_Overdue )

   RETURN
END -- procedure
GO

GRANT SELECT ON dbo.fnc_ASNExceptionGetOverdue TO NSQL
