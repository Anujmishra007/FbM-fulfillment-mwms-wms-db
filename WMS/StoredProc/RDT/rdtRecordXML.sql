if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdtRecordXML]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdtRecordXML]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: rdtRecordXML                                       */
/* Creation Date: 19-Dec-2004                                           */
/* Copyright: IDS                                                       */
/* Written by: Shong                                                    */
/*                                                                      */
/* Purpose: Set next screen or Menu when user enter the option in       */
/*          menu screen.                                                */
/*                                                                      */
/* Input Parameters: Mobile No                                          */
/*                                                                      */
/* Output Parameters: Error No and Error Message                        */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/*                                                                      */
/* Called By: rdtHandle                                                 */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/*                                                                      */
/*                                                                      */
/************************************************************************/

CREATE PROC RDT.rdtRecordXML
   @InMobile INT ,
   @cType    NVARCHAR( 3),
   @cXML     NVARCHAR( max)
AS
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET ANSI_NULLS OFF
   
   IF NOT EXISTS(SELECT 1 FROM RDT.rdtXML (NOLOCK) WHERE Mobile = @InMobile AND Type = @cType)
   BEGIN
        INSERT INTO RDT.[RDTXML] ([Mobile], [Type], [XML])
        VALUES(@InMobile, @cType, @cXML)
   END
   ELSE
   BEGIN
        UPDATE RDT.[RDTXML] WITH (ROWLOCK) SET [XML]=@cXML
        WHERE Mobile = @InMobile AND Type = @cType
   END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdtRecordXML TO NSQL
GO
