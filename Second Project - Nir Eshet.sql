---Second Project - Nir Eshet


---1

SELECT PP.ProductID, PP.Name, PP.Color, PP.ListPrice, PP.Size
FROM [Production].[Product] PP LEFT JOIN [Sales].[SalesOrderDetail] SOD
	ON PP.ProductID = SOD.ProductID
WHERE SOD.SalesOrderID IS NULL


---2

update sales.customer set personid=customerid
 where customerid <=290
update sales.customer set personid=customerid+1700
 where customerid >= 300 and customerid<=350
update sales.customer set personid=customerid+1700
 where customerid >= 352 and customerid<=701

GO

SELECT SC.CustomerID ,ISNULL(PP.LastName , 'Unknown') AS "LastName"
	,ISNULL(PP.FirstName , 'Unknown') AS "FirstName"
FROM [Sales].[Customer] SC LEFT JOIN [Person].[Person] PP
	ON SC.PersonID=PP.BusinessEntityID
	LEFT JOIN SALES.SalesOrderHeader SOH
	ON SOH.CustomerID=SC.CustomerID
WHERE SOH.SalesOrderID IS NULL
ORDER BY CustomerID


---3

SELECT TOP(10) SC.CustomerID ,PP.FirstName, PP.LastName
	, COUNT(SC.CustomerID) AS "CountOfOrders"
FROM [Sales].[Customer] SC JOIN [Person].[Person] PP
	ON SC.PersonID=PP.BusinessEntityID
	JOIN [Sales].[SalesOrderHeader] SO
	ON SO.CustomerID=SC.CustomerID
GROUP BY SC.CustomerID ,PP.FirstName, PP.LastName
ORDER BY CountOfOrders DESC


 ---4

SELECT PP.FirstName,PP.LastName,E.JobTitle,E.HireDate,
		(SELECT COUNT(*)
		FROM HumanResources.Employee 
		WHERE JobTitle = E.JobTitle) AS CountOfTitle
FROM HumanResources.Employee E JOIN [Person].[Person] PP
ON E.BusinessEntityID=PP.BusinessEntityID
ORDER BY E.JobTitle


---5

SELECT O.SalesOrderID , O.CustomerID , O.LastName , O.FirstName
,O.[Last Order],O.[Previous Offer]
FROM (
	SELECT SOH.SalesOrderID , SC.CustomerID , PP.LastName , PP.FirstName
	,LAG(SOH.OrderDate,1)OVER(PARTITION BY SC.PersonID ORDER BY SOH.OrderDate) AS "Previous Offer"
	,RANK()OVER(PARTITION BY SC.PersonID ORDER BY OrderDate DESC) AS RN
	,SOH.OrderDate AS "Last Order"
	FROM SALES.SalesOrderHeader SOH JOIN SALES.Customer SC
		ON SC.CustomerID=SOH.CustomerID
	JOIN PERSON.Person PP
	ON PP.BusinessEntityID=SC.PersonID
	) O
WHERE RN=1


---6

WITH TBL
AS
(
SELECT YEAR(SOH.OrderDate)AS "Year",SOH.SalesOrderID , PP.LastName,PP.FirstName
		,SUM(SOD.LineTotal) AS TOTAL
FROM SALES.SalesOrderHeader SOH JOIN SALES.Customer CS
			ON SOH.CustomerID=CS.CustomerID
			JOIN Person.Person PP
			ON PP.BusinessEntityID=CS.PersonID
			JOIN SALES.SalesOrderDetail SOD
			ON SOD.SalesOrderID=SOH.SalesOrderID
			GROUP BY YEAR(SOH.OrderDate),SOH.SalesOrderID , PP.LastName,PP.FirstName
)
,TBL2
AS
(
SELECT * ,ROW_NUMBER()OVER(PARTITION BY TBL.Year ORDER BY TOTAL DESC)AS RN
FROM TBL
)
SELECT TBL2.Year , TBL2.SalesOrderID , TBL2.LastName 
, TBL2.FirstName , TBL2.TOTAL
FROM TBL2
WHERE RN=1


---7

SELECT "MONTH", [2011],[2012],[2013],[2014]
FROM	(
		SELECT YEAR(SO.OrderDate) AS "YY" , MONTH(SO.OrderDate) AS "MONTH",SO.SalesOrderID
		FROM [Sales].[SalesOrderHeader] SO
		) O
PIVOT(COUNT(SalesOrderID) FOR YY IN([2011],[2012],[2013],[2014]) )PVT
ORDER BY "MONTH"


---8

WITH CTE
AS
(
SELECT
	YEAR(OrderDate) AS "Year"
	,MONTH(OrderDate) AS "Month"
	,SUM(SubTotal) AS "Sum_Price"
	,SUM(SUM(SubTotal)) OVER (PARTITION BY YEAR(OrderDate) ORDER BY MONTH(OrderDate)) AS "Money"
      FROM Sales.SalesOrderHeader
      GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT CTE.Year
,CASE WHEN CTE.Month IS NULL THEN 'Grand Total' ELSE CAST(CTE.Month AS VARCHAR(20)) END AS "Month"
,ROUND(CTE.Sum_Price,2) AS "Sum_Price"
,ROUND(MAX(CTE.Money),2) AS "Money"
FROM CTE
GROUP BY GROUPING SETS ((CTE.Year,CTE.Month,CTE.Sum_Price),CTE.Year)


---9

SELECT O.DepartmentName,O.[Employee'sID],O.[Employee'sFullName]
,O.HireDate,O.Seniority
,O.PreviousEmpName,O.PreviousEmpHDate,O.DiffDays
FROM
	(
	SELECT D.Name AS "DepartmentName"
	, E.BusinessEntityID AS "Employee'sID"
	, PP.FirstName+ ' '+PP.LastName AS "Employee'sFullName"
	, E.HireDate
	,DATEDIFF(MM,E.HireDate,GETDATE()) AS "Seniority"
	,LEAD(PP.FirstName+' '+PP.LastName,1)OVER(PARTITION BY D.DepartmentID ORDER BY E.HireDate DESC) AS "PreviousEmpName"
	,LEAD(E.HireDate,1)OVER(PARTITION BY D.DepartmentID ORDER BY E.HireDate DESC) AS "PreviousEmpHDate"
	,DATEDIFF(DD,LEAD(E.HireDate,1)OVER(PARTITION BY D.DepartmentID ORDER BY E.HireDate DESC),E.HireDate) AS "DiffDays"
	FROM [HumanResources].[Employee] E RIGHT JOIN [Person].[Person] PP
	ON E.BusinessEntityID=PP.BusinessEntityID
	JOIN [HumanResources].[EmployeeDepartmentHistory] DH
	ON DH.BusinessEntityID=E.BusinessEntityID
	JOIN [HumanResources].[Department] D
	ON DH.DepartmentID=D.DepartmentID
	WHERE DH.EndDate IS NULL
	)O

ORDER BY O.DepartmentName


---10

SELECT E.HireDate 
	  , DH.DepartmentID 
  	  ,STUFF( (SELECT 
			','+CONCAT(HE.BusinessEntityID ,' ', P.LastName ,' ', P.FirstName)
			FROM [HumanResources].[Employee] HE  JOIN [Person].[Person] P
			ON HE.BusinessEntityID=P.BusinessEntityID
			JOIN [HumanResources].[EmployeeDepartmentHistory] D
			ON HE.BusinessEntityID=D.BusinessEntityID	
			WHERE D.DepartmentID=DH.DepartmentID
			AND HE.HireDate=E.HireDate
			FOR XML PATH('')),1,1,' ' ) AS a
			
FROM [HumanResources].[EmployeeDepartmentHistory] DH  JOIN [HumanResources].[Employee] E
ON E.BusinessEntityID=DH.BusinessEntityID
WHERE DH.EndDate IS NULL
GROUP BY E.HireDate, DH.DepartmentID

