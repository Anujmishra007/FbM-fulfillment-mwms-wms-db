  IF EXISTS ( SELECT * FROM sys.objects WHERE  object_id = OBJECT_ID(N'[RDT].[rdtHandleMsgQueue]') 
AND OBJECTPROPERTY(object_id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [RDT].[rdtHandleMsgQueue]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
    
/******************************************************************************/      
/* Copyright: IDS                                                             */      
/*                                                                            */      
/* Purpose: Valid the username and password in the message queue              */     
/* Updates:                                                                   */      
/* Date         Author   Rev  Purposes                                        */      
/* 2020-06-24   YeeKung  1.0  Created                                         */      
/******************************************************************************/      
      
CREATE PROC RDT.rdtHandleMsgQueue (      
   @InMobile   INT,      
   @cActionKey NVARCHAR( 3),    
   @nMsgQueueNo INT            OUTPUT,       
   @nErrNo     INT             OUTPUT,      
   @cErrMsg    NVARCHAR( 1024) OUTPUT      
)      
AS      
SET NOCOUNT ON      
SET QUOTED_IDENTIFIER OFF      
SET ANSI_NULLS OFF      
SET CONCAT_NULL_YIELDS_NULL OFF      
    
   DECLARE   @cJobPosition  NVARCHAR(20),    
             @cUsername     NVARCHAR(20),    
             @cPassword     NVARCHAR(20),    
             @nMsgQStatus   NVARCHAR(1),    
             @cUserID       NVARCHAR(20),    
             @cFacility     NVARCHAR(20),    
             @cStorerkey    NVARCHAR(20),    
             @nFunc         NVARCHAR(10),    
             @nRowCOUNT     INT    
    
   DECLARE @tPosition AS VARIABLETABLE    
    
   SET @nErrNo=0    
            
   SELECT @nMsgQStatus = Status,    
          @cJobPosition=line14              
   FROM  RDT.rdtMsgQueue (NOLOCK)            
   WHERE MsgQueueNo = @nMsgQueueNo            
   AND   Mobile = @InMobile    
  
   SET @nRowCOUNT=@@ROWCOUNT  
    
   INSERT INTO @tPosition (Variable,value)    
   SELECT 'OPSPosition',*             
   FROM STRING_SPLIT(@cJobPosition,'/')    
    
   SELECT   @cusername=I_FIELD19,    
            @cPassword=I_FIELD20,    
            @cUserID= username,    
            @cStorerkey=storerkey,    
            @cFacility=facility,    
            @nFunc=Func    
   FROM RDT.RDTMOBREC (NOLOCK)    
   WHERE mobile=@InMobile    
          
   IF ISNULL(@cJobPosition,'')<>'' AND @nMsgQStatus = '1'  and @cJobPosition<>'0'    
   BEGIN    
      IF ISNULL(@cusername,'')='' OR ISNULL(@cPassword,'')=''    
      BEGIN    
         SET @nErrNo='9999'    
         SET @cErrMsg='INV IDPWD'    
         GOTO QUIT    
      END    
    
      IF (@cActionKey = 'NO' AND @nMsgQStatus = '1')    
      BEGIN    
         SET @nErrNo='9999'    
         SET @cErrMsg='INV IDPWD'    
         GOTO QUIT    
      END     
    
      IF NOT EXISTS (SELECT *     
                     FROM RDT.RDTUSER R WITH (NOLOCK) JOIN    
                     @tPosition Pos ON R.OPSPosition=POS.Value    
                     WHERE username= @cusername    
                     AND password=@cPassword)    
      BEGIN    
         SET @nErrNo='9999'    
         SET @cErrMsg='INV IDPWD'    
         GOTO QUIT    
      END     
    
      UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET              
      EditDate = GETDATE(),             
      MsgQueueNo = 0            
      WHERE  Mobile = @InMobile          
             
      IF @@ERROR <>''    
      BEGIN    
         SET @nErrNo='9999'    
      END      
    
      -- EventLog    
      EXEC RDT.rdt_STD_EventLog    
         @cActionType = '6', -- Sign-in    
         @cUserID     = @cUserID,    
         @nMobileNo   = @InMobile,    
         @nFunctionID = @nFunc,    
         @cFacility   = @cFacility,    
         @cStorerKey  = @cStorerkey,    
         @cRefno1     = @cUsername    
            
      -- RDT 2.0 - Delete MsgQueue (Vicky01) - Start            
      DELETE FROM  RDT.rdtMsgQueue            
      WHERE MsgQueueNo = @nMsgQueueNo            
         AND Mobile = @InMobile            
      -- RDT 2.0 - Delete MsgQueue (Vicky01) - End       
             
      IF @@ERROR <>''    
      BEGIN    
         SET @nErrNo='9999'    
      END      
                 
      SET @nMsgQueueNo = 0      
             
    
   END    
            
   ELSE IF (@cActionKey = 'NO' AND @nMsgQStatus = '1') OR @nRowCOUNT = 0 -- ENTER            
   BEGIN            
      UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET              
         EditDate = GETDATE(),             
         MsgQueueNo = 0            
      WHERE  Mobile = @InMobile          
             
      IF @@ERROR <>''    
      BEGIN    
         SET @nErrNo='9999'    
      END      
            
      -- RDT 2.0 - Delete MsgQueue (Vicky01) - Start            
      DELETE FROM  RDT.rdtMsgQueue            
      WHERE MsgQueueNo = @nMsgQueueNo            
         AND Mobile = @InMobile            
      -- RDT 2.0 - Delete MsgQueue (Vicky01) - End       
             
      IF @@ERROR <>''    
      BEGIN    
         SET @nErrNo='9999'    
      END      
                 
      SET @nMsgQueueNo = 0            
   END     
    
   GOTO QUIT    
    
QUIT:    
   IF @nErrNo <> 0    
   BEGIN      
      UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET      
         EditDate = GETDATE(),      
         ErrMsg = @cErrMsg      
      WHERE Mobile = @InMobile      
   END     
GO
SET QUOTED_IDENTIFIER OFF  
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  rdt.rdtHandleMsgQueue TO NSQL
GO
