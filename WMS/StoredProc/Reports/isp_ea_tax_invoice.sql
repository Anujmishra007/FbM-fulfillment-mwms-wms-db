if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_ea_tax_invoice]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_ea_tax_invoice]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/* 14-Mar-2012 KHLim01   Update EditDate              */       

CREATE proc isp_ea_tax_invoice(
   @c_storerkey NVARCHAR(15),
   @c_inv_no NVARCHAR(10),
   @c_confirm NVARCHAR(1),
   @c_reprint NVARCHAR(1)
 
)
as
begin
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
declare @c_status NVARCHAR(1),
        @c_wms_inv NVARCHAR(10),
        @c_EAInvoiceKey NVARCHAR(10),
        @b_success int,
        @n_err int,
        @c_errmsg NVARCHAR(250),
        @c_ncounter_key NVARCHAR(30),
        @c_inv_found NVARCHAR(10)
        
if @c_reprint = 'Y'
   select @c_wms_inv = userdefine01, @c_status = status, @c_inv_found = invoiceno from orders(nolock)
   where userdefine01 = @c_inv_no
else
   select @c_wms_inv = userdefine01, @c_status = status, @c_inv_found = invoiceno from orders(nolock)
   where invoiceno = @c_inv_no

if @@rowcount=0
            select '','01-01-1900','','','','','','','','','','','','','','',0

if ((@c_wms_inv is null) or (@c_wms_inv='')) and (@c_inv_found is not null)
   begin
      if @c_confirm = 'Y'
         begin
            set @c_ncounter_key = dbo.fnc_LTrim(dbo.fnc_RTrim(@c_storerkey)) + 'InvoiceKey'
            EXECUTE nspg_getkey @c_ncounter_key , 10, @c_EAInvoiceKey OUTPUT, @b_success OUTPUT, @n_err OUTPUT, @c_errmsg OUTPUT
            if @b_success = 1  
               update orders
               set userdefine01 = @c_EAInvoiceKey, printflag = 'Y', userdefine02 = '1', trafficcop=null
                  ,EditDate = GETDATE() -- KHLim01
               where invoiceno = @c_inv_no
         end

      if @c_status = '5'
         begin
            select a.userdefine01, 
                   a.userdefine06,
                   a.b_company,
                   a.b_address1,
                   a.b_address2,
                   a.b_address3,
                   a.b_address4,
                   a.b_country,
                   a.b_zip,
                   a.externorderkey,
                   a.buyerpo,
                   a.pmtterm,
                   a.b_vat,
                   a.invoiceno,
                   d.b_company,
                   d.company,
						 case isnumeric(a.userdefine03)
							when 1 then cast(a.userdefine03 as decimal(10,2))
                   	else 0.00
						 end
            from orders a (nolock), storer d (nolock)
            where a.storerkey = d.storerkey
            and a.invoiceno = @c_inv_no
            and a.storerkey = @c_storerkey
         end  
      else if @c_status = '9'
         begin
            select a.userdefine01, 
                   a.userdefine06,
                   a.b_company,
                   a.b_address1,
                   a.b_address2,
                   a.b_address3,
                   a.b_address4,
                   a.b_country,
                   a.b_zip,
                   a.externorderkey,
                   a.buyerpo,
                   a.pmtterm,
                   a.b_vat, 
                   a.invoiceno,
                   d.b_company,
                   d.company,
                   case isnumeric(a.userdefine03)
							when 1 then cast(a.userdefine03 as decimal(10,2))
                   	else 0.00
						 end
            from orders a (nolock), storer d (nolock)
            where a.storerkey = d.storerkey
            and a.invoiceno = @c_inv_no
            and a.storerkey = @c_storerkey
         end
   end
else
   begin
      if @c_reprint = 'Y' and @c_confirm = 'N'
         begin
            if @c_status = '5'
               begin
                  select a.userdefine01, 
                         a.userdefine06,
                         a.b_company,
                         a.b_address1,
                         a.b_address2,
                         a.b_address3,
                         a.b_address4,
                         a.b_country,
                         a.b_zip,
                         a.externorderkey,
                         a.buyerpo,
                         a.pmtterm,
                         a.b_vat,
                         a.invoiceno,
                         d.b_company,
                         d.company,
                         case isnumeric(a.userdefine03)
									when 1 then cast(a.userdefine03 as decimal(10,2))
		                   	else 0.00
								 end
                  from orders a (nolock), storer d (nolock)
                  where a.storerkey = d.storerkey
                  and a.userdefine01 = @c_inv_no
                  and a.storerkey = @c_storerkey
               end  
            else if @c_status = '9'
               begin
                  select a.userdefine01, 
                         a.userdefine06,
                         a.b_company,
                         a.b_address1,
                         a.b_address2,
                         a.b_address3,
                         a.b_address4,
                         a.b_country,
                         a.b_zip,
                         a.externorderkey,
                         a.buyerpo,
                         a.pmtterm,
                         a.b_vat, 
                         a.invoiceno,
                         d.b_company,
                         d.company,
                         case isnumeric(a.userdefine03)
									when 1 then cast(a.userdefine03 as decimal(10,2))
	                   	 	else 0.00
						 		 end
                  from orders a (nolock), storer d (nolock)
                  where a.storerkey = d.storerkey
                  and a.userdefine01 = @c_inv_no
                  and a.storerkey = @c_storerkey
               end
         
            update orders
            set UserDefine02 = convert(NVARCHAR(20),(convert(integer, UserDefine02) + 1))
            where userdefine01 = @c_inv_no
         end
      else -- if @c_reprint <> 'Y' and @c_confirm <> 'N'
            select '','01-01-1900','','','','','','','','','','','','','','',0


   end
   
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON isp_ea_tax_invoice to nSQL
GO
