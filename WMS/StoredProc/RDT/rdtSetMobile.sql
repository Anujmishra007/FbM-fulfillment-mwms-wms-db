IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdtSetMobile]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdtSetMobile]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Procedure: rdtSetMobile                                       */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Called By:                                                           */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Rev  Author   Purposes                                   */  
/* 22-Nov-2007 1.3  Shong    SOS90411 Display error in another screen   */  
/* 07-Dec-2011 1.4  TLTING   Reset Mobile# after 9000                   */  
/* 02-Oct-2015 1.5  Ung      Performance tuning for CN Nov 11           */
/************************************************************************/  
  
CREATE PROC [RDT].[rdtSetMobile] (  
   @nMobile     int  OUTPUT,  
   @cInMessage  NVARCHAR(1024),  
   @nFunction   int  OUTPUT,  
   @nScn        int  OUTPUT,  
   @nStep       int  OUTPUT,  
   @nMsgQueueNo int  OUTPUT,   
   @nErrNo      int  OUTPUT,  
   @cErrMsg     NVARCHAR(1024) OUTPUT  
)  
AS  
   SET NOCOUNT ON   -- SQL 2005 Standard  
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
         
   DECLARE @nKey      int,  
           @cLang     NVARCHAR(3),  
           @nMenu     int,  
           @CheckMobile int,  
           @nTMobile    INT  
  
   SET @CheckMobile = 0  
  
   SELECT @nMobile = ISNULL(Mobile, 0),  
          @nFunction = Func,  
          @nScn      = Scn,  
          @nStep     = Step,  
          @CheckMobile = ISNULL(Mobile, 0),    
          @nMsgQueueNo = ISNULL(MsgQueueNo, 0)   
   FROM   RDT.RDTMOBREC (NOLOCK)  
   WHERE  Mobile = @nMobile  
  
   IF @nMobile =0  OR @nMobile IS NULL  or @CheckMobile =0  
   BEGIN  
      SELECT @nMobile = MAX(Mobile)  
      FROM   RDT.RDTMOBREC (NOLOCK)  
     
      IF @nMobile IS NULL OR @nMobile = 0  
         SELECT @nMobile = 1  
      ELSE  
      BEGIN   
         IF @nMobile > 9000  
         BEGIN  
            SET @CheckMobile = 0  
            SET @nTMobile = 500  
            WHILE @CheckMobile = 0  
            BEGIN  
               GOTO ReRun_MobileNo  
               GoBack_ReRun_MobileNo:  
               IF @CheckMobile = 0  
               BEGIN  
                  SET @nTMobile = @nTMobile + 500  
               END  
            END  
            SET @nMobile = @CheckMobile  
         END   
         SELECT @nMobile = @nMobile + 1           
      END  
        
      SELECT @cLang = 'ENG',  
             @nMenu = 0,  
             @nFunction = 0,  
             @nScn      = 0,  
             @nStep     = 0,  
             @nKey      = 1  
     
      BEGIN TRAN  

      IF NOT EXISTS(SELECT 1 FROM RDT.RDTXML_Root (NOLOCK) WHERE Mobile = @nMobile)
         INSERT INTO RDT.RDTXML_Root (mobile) VALUES (@nMobile)
     
      INSERT INTO RDT.RDTMOBREC(  
          Mobile,        Func,          Scn,           Step,         Menu,  
          InputKey)  
      VALUES(@nMobile,   @nFunction,    @nScn,         @nStep,       @nMenu,  
             @nKey)  
     
      IF @@ERROR <> 0  
      BEGIN  
         SELECT @nErrNo = @@ERROR  
         SELECT @cErrMsg = 'Insert into RDTMOBREC Failed! '  
         ROLLBACK  
      END  
      ELSE  
      BEGIN  
         COMMIT TRAN  
      END  
   END
      
   RETURN  
     
ReRun_MobileNo:     
BEGIN  
   SET @CheckMobile = 0  
   SELECT @CheckMobile = ISNULL(MAX(Mobile), 0)  
   FROM   RDT.RDTMOBREC (NOLOCK)   
   WHERE  Mobile < @nTMobile    
  
   IF @CheckMobile IS NULL OR @CheckMobile = 0  
   BEGIN  
      SELECT @CheckMobile = 1  
   END  
  
   -- Do not assign if the range is small. avoid + 1 hit max  
   IF @CheckMobile > @nTMobile - 10  
   BEGIN   
      SET @CheckMobile = 0  
   END   
     
   GOTO GoBack_ReRun_MobileNo  
END  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE on [RDT].[rdtSetMobile] to nSQL
GO
