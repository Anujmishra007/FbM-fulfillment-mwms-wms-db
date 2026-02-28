ALTER TABLE [ODS].[PackSerialNo]
ADD [Barcode] NVARCHAR(500) NULL;

ALTER TABLE [ODS].[OrderInfo]
ADD [AutomationStatus] NVARCHAR(20) NULL CONSTRAINT [DF_OrderInfo_AutomationStatus] DEFAULT ('');

ALTER TABLE [OSA].[OrderInfo]
ADD [AutomationStatus] NVARCHAR(20) NULL CONSTRAINT [DF_OrderInfo_AutomationStatus] DEFAULT ('');

ALTER TABLE [OSA].[PackSerialNo]
ADD [Barcode] NVARCHAR(500) NULL;
