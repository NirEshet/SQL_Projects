                   --- FIRST PROJECT 

USE MASTER 

GO

CREATE DATABASE SALES

GO

USE SALES

GO

CREATE TABLE CreditCard
( CreditCardID INT,
CardType NVARCHAR(50) NOT NULL,
CardNumber NVARCHAR(25) NOT NULL,
ExpMonth TINYINT NOT NULL,
ExpYear SMALLINT NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT Credit_Card_ID_PK PRIMARY KEY(CreditCardID)
)

GO

CREATE TABLE SalesTerritory
(TerritoryID INT,
Name NVARCHAR(50) NOT NULL,
countryRegionCode NVARCHAR(3) NOT NULL,
[Group] NVARCHAR(50) NOT NULL,
SalesYTD MONEY NOT NULL, 
SalesLastYear MONEY NOT NULL,
CostYTD MONEY NOT NULL,
CostLastYear MONEY NOT NULL,
RowGuid UNIQUEIDENTIFIER NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT Territory_ID_PK PRIMARY KEY(TerritoryID)
)

GO

CREATE TABLE SalesPerson
(BusinessEntityID INT,
TerritoryID INT,
SalesQuota MONEY,
Bonus MONEY NOT NULL,
CommissionPCT SMALLMONEY NOT NULL,
SalesYTD MONEY NOT NULL,
SalesLastYear MONEY NOT NULL,
RowGuid UNIQUEIDENTIFIER NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT Business_Entity_ID_PK PRIMARY KEY(BusinessEntityID),
CONSTRAINT Business_Entity_ID_FK FOREIGN KEY(TerritoryID)
									REFERENCES SalesTerritory(TerritoryID)
)

GO

CREATE TABLE Customer
( CustomerID INT,
PersonID INT,
StoreID INT,
TerritoryID INT,
AccountNumber VARCHAR(100) NOT NULL,
Rowguid UNIQUEIDENTIFIER NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT Customer_ID_PK PRIMARY KEY(CustomerID),
CONSTRAINT Customer_ID_ID_FK FOREIGN KEY(TerritoryID)
									REFERENCES SalesTerritory(TerritoryID)
)

GO

CREATE TABLE Address
( AddressID INT NOT NULL,
AddressLine1 NVARCHAR(60) NOT NULL,
AddressLine2 NVARCHAR(60),
Ciry NVARCHAR(30) NOT NULL,
StatEprovinceID INT NOT NULL,
PostalCode NVARCHAR(15) NOT NULL,
SpatialLocation GEOGRAPHY ,
RowGuid UNIQUEIDENTIFIER ,
ModifiedDate DATETIME ,
CONSTRAINT Address_ID_PK PRIMARY KEY(AddressID)
)

GO

CREATE TABLE ShipMethod
( ShipMethodID INT,
Name NVARCHAR(50) NOT NULL,
ShipBase MONEY NOT NULL,
ShipRate MONEY NOT NULL,
RowGuid UNIQUEIDENTIFIER NOT NULL,
ModifiedDate DATETIME  NOT NULL,
CONSTRAINT ShipMethod_ID_PK PRIMARY KEY(ShipMethodID)
)

GO

CREATE TABLE CurrencyRate
( CurrencyRateID INT,
CurrencyRateDate DATETIME NOT NULL,
FromCurrencyCode NCHAR(3) NOT NULL,
ToCurrencyCode NCHAR(3) NOT NULL,
AverageRate MONEY NOT NULL,
EndOfDayRate MONEY NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT Currency_Rate_ID_PK PRIMARY KEY(CurrencyRateID)
)

GO

CREATE TABLE SalesOrderHeader
(SalesOrderID INT,
RevisionNumber TINYINT NOT NULL,
OrderDate DATETIME NOT NULL,
DueDate DATETIME NOT NULL,
ShipDate DATETIME , 
Status TINYINT NOT NULL,
OnlineOrderFlag BIT NOT NULL,
SalesOrderNumber NVARCHAR(25) NOT NULL,
PurchaseOrderNumber NVARCHAR(25),
AccountNumber NVARCHAR(15),
CustomerID INT NOT NULL,
SalesPersonID INT ,
TerritoryID INT,
BillToAaddressID INT NOT NULL,
ShipToAaddressID INT NOT NULL,
ShipMethodID INT NOT NULL,
CreditCardID INT,
CreditCardApprovalCode VARCHAR(15),
CURRENCYRATEID INT,
SubTotal MONEY NOT NULL,
TaxAMT MONEY NOT NULL,
Freight MONEY NOT NULL,
CONSTRAINT Sales_Order_ID_PK PRIMARY KEY(SalesOrderID),
CONSTRAINT Currency_Rate_ID_FK FOREIGN KEY(CurrencyRateID)
									REFERENCES CurrencyRate(CurrencyRateID),
CONSTRAINT Ship_To_Aaddress_ID_FK FOREIGN KEY(ShipMethodID)
									REFERENCES ShipMethod(ShipMethodID),
CONSTRAINT Customer_ID_FK FOREIGN KEY(CustomerID)
									REFERENCES Customer(CustomerID),
CONSTRAINT Territory_ID_FK FOREIGN KEY(TerritoryID)
									REFERENCES SalesTerritory(TerritoryID),
CONSTRAINT Sales_Person_ID_FK FOREIGN KEY(SalesPersonID)
									REFERENCES SalesPerson(BusinessEntityID),
CONSTRAINT Ship_To_Address_ID_FK FOREIGN KEY(ShipToAaddressID)
									REFERENCES Address(AddressID),
CONSTRAINT Credit_Card_ID_FK FOREIGN KEY(CreditCardID)
									REFERENCES CreditCard(CreditCardID)
)

GO


CREATE TABLE SpecialOfferProduct
( SpecialOfferID INT,
ProductID INT ,
Rowguid UNIQUEIDENTIFIER NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT Special_Offer_ID_Product_ID_PK PRIMARY KEY(SpecialOfferID,ProductID)
)

GO

CREATE TABLE SalesOrderDetail
( SalesOrderID INT  NOT NULL,
SalesOrderDetailID INT NOT NULL,
CARRIERTRACKINGNUMBER VARCHAR(25),
Orderqty SMALLINT NOT NULL,
ProductID INT NOT NULL,
SpecialOfferID INT NOT NULL,
Unitprice MONEY NOT NULL,
UnitpriceDiscount MONEY,
LineTotal INT NOT NULL,
RowGuid UNIQUEIDENTIFIER NOT NULL,
ModifiedDate DATETIME NOT NULL,
CONSTRAINT Sales_Order_ID_Sales_Order_Detial_ID_PK PRIMARY KEY(SalesOrderID,SalesOrderDetailID),
CONSTRAINT Sales_Order_ID_FK FOREIGN KEY(SalesOrderID)
										REFERENCES SalesOrderHeader(SalesOrderID),
CONSTRAINT Sales_Order_ID_Sales_Order_Detial_ID_FK FOREIGN KEY(SpecialOfferID,ProductID)
										REFERENCES SpecialOfferProduct(SpecialOfferID,ProductID)

)

GO

INSERT INTO SALES..CreditCard
SELECT *
FROM adventureworks2019.[Sales].[CreditCard]

GO

INSERT INTO SALES..SalesTerritory
SELECT *
FROM adventureworks2019.[Sales].[SalesTerritory]

GO

INSERT INTO SALES..SalesPerson
SELECT *
FROM adventureworks2019.[Sales].[SalesPerson]

GO

INSERT INTO SALES..Customer
SELECT *
FROM adventureworks2019.[Sales].[Customer]

GO

INSERT INTO SALES..Address
SELECT *
FROM adventureworks2019.[Person].[Address]

GO

INSERT INTO SALES..ShipMethod
SELECT *
FROM adventureworks2019.[Purchasing].[ShipMethod]

GO

INSERT INTO SALES..CurrencyRate
SELECT *
FROM adventureworks2019.[Sales].[CurrencyRate]

GO

INSERT INTO SALES..SalesOrderHeader
SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate
, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber,PurchaseOrderNumber
, AccountNumber, CustomerID, SalesPersonID, TerritoryID
, BillToAddressID, ShipToAddressID, ShipMethodID
, CreditCardID, CreditCardApprovalCode, CurrencyRateID
, SubTotal, TaxAmt, Freight
FROM adventureworks2019.[sales].[SalesOrderHeader]

GO

INSERT INTO SALES..SpecialOfferProduct
SELECT *
FROM adventureworks2019.[Sales].[SPECIALOFFERPRODUCT]

GO

INSERT INTO SALES..SalesOrderDetail
SELECT *
FROM adventureworks2019.[Sales].[SalesOrderDetail]

