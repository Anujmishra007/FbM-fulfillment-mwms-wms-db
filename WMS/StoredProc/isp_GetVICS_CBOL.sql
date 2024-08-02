SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: isp_GetVICS_CBOL                                   */
/* Creation Date: 28-May-2024                                           */
/* Copyright: Maersk Logistics                                          */
/* Written by: Shong                                                    */
/*                                                                      */
/* Purpose: UWP-21211 - Analysis: CBOL Migration from Exceed to MWMS V2 */
/*        :                                                             */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 28-May-2024 Shong    1.1   Create                                    */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_GetVICS_CBOL]
(
    @n_CBOLKey BIGINT, 
    @c_Facility NVARCHAR(5), 
    @c_StorerKey NVARCHAR(15),
    @c_VICS_CBOL NVARCHAR(30) OUTPUT
)
AS
BEGIN
	DECLARE @n_MPOCFlag   INT = 0, 
           @c_SQL        NVARCHAR(4000) = N'',
           @c_Code       NVARCHAR(30) = N'', 
           @c_Operator   NVARCHAR(10) = N'',
           @c_TableName  NVARCHAR(50) = N'',
           @c_Department NVARCHAR(20) = N'',
           @c_ColumnName NVARCHAR(60) = N'';

   DECLARE @n_Length INT = 0,
           @n_Index INT,
           @c_VICBillNumber_Aut NVARCHAR(30), 
           @c_SUSR1 NVARCHAR(30),
           @c_KeyName NVARCHAR(30), 
           @c_StartNumber NVARCHAR(20), 
           @c_EndNumber   NVARCHAR(20),
           @n_StartNumber INT, 
           @n_EndNumber   INT, 
           @n_Odd INT, 
           @n_Even INT, 
           @n_CheckDigit INT

      DECLARE @c_KeyString NVARCHAR(25),
              @b_Success INT,
              @n_err INT,
              @c_errmsg NVARCHAR(250),
              @n_RunNoLen INT = 0
              
   SELECT 
      @c_SUSR1 = MAX(Storer.SUSR1)
	FROM MBOL WITH (NOLOCK)
   JOIN MBOLDETAIL WITH (NOLOCK) ON (MBOL.Mbolkey = MBOLDETAIL.Mbolkey)
	JOIN ORDERS WITH (NOLOCK) ON (ORDERS.OrderKey = MBOLDETAIL.OrderKey)
	JOIN STORER WITH (NOLOCK) ON (Storer.StorerKey = ORDERS.StorerKey)
	WHERE MBOL.CBOLKey = @n_CBOLKey

	IF ISNULL(RTRIM(@c_SUSR1),'') ='' 	
		SET @c_SUSR1 = '0400000' 
	ELSE
		SET @n_Length = 7 - LEN(@c_SUSR1)
		
	IF @n_Length > 0  
   BEGIN 
		SET @n_Index = 1
			
      WHILE @n_Index <= @n_Length 
      BEGIN
         SET @c_SUSR1 = '0' + @c_SUSR1  

         SET @n_Index = @n_Index + 1
      END
	END 


	IF Try_Convert(INT, @c_SUSR1) IS NOT NULL
   BEGIN
      SET @c_SUSR1 = '0400000' 
   END
	
	SET @c_VICS_CBOL = TRIM(@c_SUSR1) + '000'  + RIGHT('000000' + CAST(@n_CBOLKey AS VARCHAR(10)), 6) 
	
	SELECT @c_VICBillNumber_Aut = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'VicBillNumber')
	
	IF ISNULL(@c_VICBillNumber_Aut, '') <> ''  
   BEGIN
		SELECT  
         @c_KeyName=Code, 
         @c_StartNumber = ISNULL(UDF01,'0'), 
         @c_EndNumber = ISNULL(UDF02,'0')
		FROM CODELKUP (NOLOCK)
		WHERE Listname = @c_VICBillNumber_Aut
       		
		IF ISNULL(TRIM(@c_KeyName),'') <> '' 
      BEGIN			
		   SET @n_StartNumber = ISNULL(Try_Convert(INT, @c_StartNumber), 1)

         SET @n_EndNumber = ISNULL(Try_Convert(INT, @c_StartNumber), 9999999999)
      END

      EXEC dbo.nspg_GetKeyMinMax
         @keyname = @c_KeyName, 
         @fieldlength = 17,   
         @Min = @n_StartNumber,
         @Max = @n_EndNumber,
         @keystring = @c_KeyString OUTPUT,  
         @b_Success = @b_Success OUTPUT,  
         @n_err = @n_err OUTPUT,          
         @c_errmsg = @c_errmsg OUTPUT,    
         @b_resultset = 0 

				
		IF ISNULL(TRIM(@c_KeyString), '') <> ''
      BEGIN
			SET @n_RunNoLen = 17 - LEN(TRIM(@c_SUSR1)) - 1
			SET @c_VICS_CBOL = TRIM(@c_SUSR1) + RIGHT(TRIM(@c_KeyString), @n_RunNoLen)                
      END
   END -- IF ISNULL(@c_VICBillNumber_Aut, '')

   SET @n_RunNoLen = LEN(@c_VICS_CBOL)

	IF @n_RunNoLen > 0 
   BEGIN
		SET @n_Index = 1
		WHILE @n_Index <= @n_RunNoLen
      BEGIN

			IF @n_Index % 2 > 0 
				SET @n_Odd = @n_Odd + CAST(SUBSTRING( @c_VICS_CBOL, @n_Index , 1) AS INT)   -- Add all digit in Add Placement
			ELSE
				SET @n_Even = @n_Even + CAST(SUBSTRING( @c_VICS_CBOL, @n_Index , 1) AS INT)   -- Add all digit in Even Placement

			SET @n_Index = @n_Index + 1             
      END       
   END
	
	SET @n_CheckDigit = 10 - (( @n_Odd + (@n_Even * 3) ) % 10 )
	
	IF @n_CheckDigit = 10 
      SET @n_CheckDigit = 0	

	SET @c_VICS_CBOL = @c_VICS_CBOL + CAST(@n_CheckDigit AS VARCHAR(10))
   

   QUIT_FNC:
END
GO
GRANT EXECUTE ON [dbo].[isp_GetVICS_CBOL] TO [nSQL]
GO