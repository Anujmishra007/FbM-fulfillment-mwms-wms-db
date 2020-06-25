IF EXISTS (SELECT name FROM dbo.sysobjects WHERE name = 'isp_RCM_ASN_NIKECN_1M1C_PA' AND type = 'P')
   DROP PROC isp_RCM_ASN_NIKECN_1M1C_PA
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
  
/************************************************************************/  
/* Stored Procedure: isp_RCM_ASN_NIKECN_1M1C_PA                         */  
/* Creation Date: 28-May-2019                                           */  
/* Copyright: LFL                                                       */  
/* Written by: WLChooi                                                  */  
/*                                                                      */  
/* Purpose: WMS-9180 NIKE 1M1C ASN Unlock Suggest PA Loc                */  
/*                                                                      */  
/* Called By: ASN Dynamic RCM configure at listname 'RCMConfig'         */   
/*                                                                      */  
/* Parameters:                                                          */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver.  Purposes                                */  
/* 2020-Apr-28  WLChooi   1.1   WMS-13065 - Cannot Unlock if No PA      */
/*                              Records (WL01)                          */
/************************************************************************/  
  
CREATE PROCEDURE isp_RCM_ASN_NIKECN_1M1C_PA  
   @c_Receiptkey NVARCHAR(10),     
   @b_success  int OUTPUT,  
   @n_err      int OUTPUT,  
   @c_errmsg   NVARCHAR(225) OUTPUT,  
   @c_code     NVARCHAR(30)=''  
AS  
BEGIN   
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF    
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @n_continue int,  
           @n_cnt int,  
           @n_starttcnt int  
                 
   DECLARE @c_storerkey    NVARCHAR(15),  
           @c_doctype      NCHAR(1),  
           @n_RFPAQty      INT,  
           @n_QtyRecv      INT,  
           @c_PABookingKey NVARCHAR(30),
           @c_UserName     NVARCHAR(18) = SUSER_SNAME(),
           @n_Count        INT = 0   --WL01  
                
   SELECT @n_Continue = 1, @b_success = 1, @n_starttcnt=@@TRANCOUNT, @c_errmsg='', @n_err=0   
   
   --WL01 START
   SELECT @c_Storerkey = Storerkey
   FROM RECEIPT (NOLOCK) 
   WHERE Receiptkey = @c_Receiptkey

   SELECT @n_Count = COUNT(1) FROM RFPUTAWAY RFPA (NOLOCK)
   WHERE RFPA.Storerkey = @c_storerkey
   AND EXISTS (SELECT 1 FROM RECEIPTDETAIL RD (NOLOCK) WHERE RD.Storerkey = @c_Storerkey 
               AND RD.ToLoc = RFPA.FromLoc AND RD.receiptkey = @c_Receiptkey )

   IF @n_Count = 0
   BEGIN
      SELECT @n_continue = 3    
      SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38030   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': No PA, Cannot Roll Back (isp_RCM_ASN_NIKECN_1M1C_PA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '    
      GOTO ENDPROC  
   END
   --WL01 END
     
   SELECT @n_QtyRecv = SUM(RD.QtyReceived)   
   FROM RECEIPTDETAIL RD (NOLOCK) WHERE RD.RECEIPTKEY = @c_Receiptkey  
     
   SELECT @n_RFPAQty = SUM(RFPA.Qty)  
   FROM RFPUTAWAY RFPA (NOLOCK)  
   JOIN RECEIPTDETAIL RD (NOLOCK) ON RD.UserDefine10 = RFPA.PABookingKey AND RD.StorerKey = RFPA.StorerKey  
                                 AND RD.SKU = RFPA.SKU  
   WHERE RD.RECEIPTKEY = @c_Receiptkey  
     
   IF(@n_RFPAQty < @n_QtyRecv)  
   BEGIN  
      SELECT @n_continue = 3    
      SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 38000   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Cannot unlock as RFPutaway.Qty < Receiptdetail.QtyReceived (isp_RCM_ASN_NIKECN_1M1C_PA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '    
      GOTO ENDPROC  
   END  
   
   DECLARE cur_RECEIPTUDF CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
      SELECT DISTINCT Userdefine10  
      FROM RECEIPTDETAIL (NOLOCK)  
      WHERE Receiptkey = @c_Receiptkey  
      AND (Userdefine10 <> '' OR Userdefine10 IS NOT NULL)  
  
   OPEN cur_RECEIPTUDF    
            
   FETCH NEXT FROM cur_RECEIPTUDF INTO @c_PABookingKey  
            
   WHILE @@FETCH_STATUS = 0   
   BEGIN     
      BEGIN TRY --Unlock using PABookingKey  
         EXEC rdt.rdt_Putaway_PendingMoveIn   
              @cUserName        = @c_UserName  
           ,  @cType            = 'UNLOCK'   
           ,  @cStorerKey       = ''   
           ,  @cSKu             = ''  
           ,  @cFromLOT         = ''  
           ,  @cFromLOC         = ''              
           ,  @cFromID          = ''  
           ,  @cSuggestedLOC    = ''    
           ,  @nPutawayQTY      = 0  
           ,  @nPABookingKey    = @c_PABookingKey  
           ,  @nErrNo           = @n_Err          OUTPUT  
           ,  @cErrMsg          = @c_ErrMsg       OUTPUT  
      END TRY  
      BEGIN CATCH  
         SELECT @n_Continue = 3  
         SELECT @n_Err = 38010  
         SELECT @c_ErrMsg = ERROR_MESSAGE()  
         SELECT @c_ErrMsg = CONVERT(CHAR(5), @n_Err) + ': Error Executing rdt.rdt_Putaway_PendingMoveIn. PABookingKey: ' + RTRIM(@c_PABookingKey)  
                       + ' fail. <<' + @c_ErrMsg + '>> (isp_RCM_ASN_NIKECN_1M1C_PA)'  
         GOTO ENDPROC  
      END CATCH  
        
      BEGIN TRAN  
      --If success, update ReceiptDetail.UserDefine10 to blank  
      UPDATE RECEIPTDETAIL  
      SET UserDefine10 = ''  
      WHERE RECEIPTKEY = @c_Receiptkey AND UserDefine10 = @c_PABookingKey  
        
      IF @@ERROR <> 0   
      BEGIN   
         SELECT @n_Continue = 3  
         SELECT @n_Err = 38020  
         SELECT @c_ErrMsg = CONVERT(CHAR(5), @n_Err) + ': Error Update RECEIPTDETAIL Fail. (isp_RCM_ASN_NIKECN_1M1C_PA)'   
         GOTO ENDPROC   
      END   
       
      FETCH NEXT FROM cur_RECEIPTUDF INTO @c_PABookingKey  
   END           
   CLOSE cur_RECEIPTUDF  
   DEALLOCATE cur_RECEIPTUDF     
          
ENDPROC:   
   
   IF @n_continue=3  -- Error Occured - Process And Return  
  BEGIN  
     SELECT @b_success = 0  
     IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt  
     BEGIN  
        ROLLBACK TRAN  
     END  
  ELSE  
     BEGIN  
        WHILE @@TRANCOUNT > @n_starttcnt  
        BEGIN  
           COMMIT TRAN  
        END  
     END  
     execute nsp_logerror @n_err, @c_errmsg, 'isp_RCM_ASN_NIKECN_1M1C_PA'  
     RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
     RETURN  
  END  
  ELSE  
     BEGIN  
        SELECT @b_success = 1  
        WHILE @@TRANCOUNT > @n_starttcnt  
        BEGIN  
           COMMIT TRAN  
        END  
        RETURN  
     END      
END -- End PROC  
GO

GRANT EXECUTE ON isp_RCM_ASN_NIKECN_1M1C_PA TO NSQL 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO
