--*************************************************************************--
-- Title: Assignment06
-- Author: SDuvall
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2025-11-18,SDuvall,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SDuvall')
	 Begin 
	  Alter Database [Assignment06DB_SDuvall] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SDuvall;
	 End
	Create Database Assignment06DB_SDuvall;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SDuvall;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
/*
Select * From Categories; --View contents of original table
go
*/

GO

--Categories base view code

CREATE VIEW vCategories --Create base view of Categories table
	WITH SCHEMABINDING
	AS 
	SELECT CategoryID, CategoryName FROM dbo.Categories;
GO

SELECT * FROM vCategories; --Compare both the actual table and the new base view to ensure they match
SELECT * FROM Categories;
GO

--Products base view code
/*
Select * From Products; --View contents of original table
go
*/

CREATE VIEW vProducts --Create base view of Products table
	WITH SCHEMABINDING
	AS 
	SELECT ProductID, ProductName, CategoryID, UnitPrice FROM dbo.Products;
GO

SELECT * FROM vProducts; --Compare both the actual table and the new base view to ensure they match
SELECT * FROM Products;
GO

--Employees base view code
/*
Select * From Employees; --View contents of original table
go
*/

CREATE VIEW vEmployees --Create base view of Employees table
	WITH SCHEMABINDING
	AS 
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID FROM dbo.Employees;
GO

SELECT * FROM vEmployees; --Compare both the actual table and the new base view to ensure they match
SELECT * FROM Employees;
GO

--Inventories base view code
/*
Select * From Inventories; --View contents of actual table
go
*/

CREATE VIEW vInventories --Create base view of Employees table
	WITH SCHEMABINDING
	AS 
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count] FROM dbo.Inventories;
GO

SELECT * FROM vInventories; --Compare both the actual table and the new base view to ensure they match
SELECT * FROM Inventories;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Permissions for Categories
DENY SELECT ON Categories TO PUBLIC; --Set permissions to force users into using view and not the actual table.
GRANT SELECT ON vCategories TO PUBLIC;
GO

--Permissions for Products
DENY SELECT ON Products TO PUBLIC; --Set permissions to force users into using view and not the actual table.
GRANT SELECT ON vProducts TO PUBLIC;
GO

--Permissions for Employees
DENY SELECT ON Employees TO PUBLIC; --Set permissions to force users into using view and not the actual table.
GRANT SELECT ON vEmployees TO PUBLIC;
GO

--Permissions for Inventories
DENY SELECT ON Inventories TO PUBLIC; --Set permissions to force users into using view and not the actual table.
GRANT SELECT ON vInventories TO PUBLIC;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/*
SELECT * FROM vCategories; --View all of the data to understand what's in the table views
SELECT * FROM vProducts;
GO

SELECT [CategoryName] FROM vCategories; -- Viewing specific columns needed from table views for final result
SELECT [ProductName], [UnitPrice] FROM vProducts;
GO

SELECT [CategoryName], [ProductName], [UnitPrice] -- Join the two table views into one with the specific columns of interest
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID;
GO


SELECT [CategoryName] -- Order results
    , [ProductName] 
    , [UnitPrice] 
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
ORDER BY [CategoryName], [ProductName];
GO


CREATE VIEW vProductsByCategories -- Rename view to match final Select statement desired
	AS 
	SELECT [CategoryName] 
    , [ProductName] 
    , [UnitPrice] 
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID;
GO
*/

GO --Add Order By clause to final Select statement because this clause is not allowed when creating views
SELECT * FROM [dbo].[vProductsByCategories] 
	ORDER BY [CategoryName], [ProductName]; 
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

/*
SELECT * FROM vProducts; --View all of the data to understand what's in the table views
SELECT * FROM vInventories;
GO

SELECT [ProductName] FROM vProducts; -- Viewing specific columns needed from table views for final result
SELECT [InventoryDate], [Count] FROM vInventories;
GO

SELECT [ProductName], [InventoryDate], [Count] -- Join the two table view into one with the specific columns of interest
	FROM vProducts AS p JOIN vInventories AS i
	ON p.ProductID = i.ProductID;
GO

SELECT [ProductName]  -- Order results
    ,[InventoryDate] 
    ,[Count] 
	FROM vProducts AS p JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	ORDER BY [ProductName], [InventoryDate], [Count];
GO

CREATE VIEW vInventoriesByProductsByDates -- Rename view to match final Select statement desired
	AS 
	SELECT [ProductName]  
    ,[InventoryDate] 
    ,[Count] 
	FROM vProducts AS p JOIN vInventories AS i
	ON p.ProductID = i.ProductID;
GO
*/

--Add Order By clause to final Select statement because this clause is not allowed when creating views
SELECT * FROM [dbo].[vInventoriesByProductsByDates] 
	ORDER BY [ProductName], [InventoryDate], [Count];
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

/*
SELECT * FROM vInventories; --View all of the data to understand what's in the table views
SELECT * FROM vEmployees;
GO

SELECT [InventoryDate] FROM vInventories; -- Viewing specific columns needed from table views for final result
SELECT [EmployeeFirstName], [EmployeeLastName] FROM vEmployees;
GO

SELECT [InventoryDate], [EmployeeFirstName], [EmployeeLastName] -- Join the two table views into one with the specific columns of interest
	FROM vInventories AS i JOIN vEmployees AS e
	ON i.EmployeeID = e.EmployeeID;
GO

SELECT [InventoryDate], [EmployeeFirstName], [EmployeeLastName] -- Order the results
	FROM vInventories AS i JOIN vEmployees AS e
	ON i.EmployeeID = e.EmployeeID
ORDER BY [InventoryDate] ASC;
GO

SELECT  DISTINCT [InventoryDate]  -- Tidy up the results to make them clear
    ,([EmployeeFirstName] + ' ' + [EmployeeLastName]) AS 'EmployeeName'
	FROM vInventories AS i JOIN vEmployees AS e
	ON i.EmployeeID = e.EmployeeID
    ORDER BY [InventoryDate] ASC;
GO

CREATE VIEW vInventoriesByEmployeesByDates -- Rename view to match final Select statement desired
	AS 
	SELECT  DISTINCT [InventoryDate]  
    ,([EmployeeFirstName] + ' ' + [EmployeeLastName]) AS 'EmployeeName'
	FROM vInventories AS i JOIN vEmployees AS e
	ON i.EmployeeID = e.EmployeeID;
GO
*/

--Add Order By clause to final Select statement because this clause is not allowed when creating views
SELECT * FROM [dbo].[vInventoriesByEmployeesByDates] 
	ORDER BY [InventoryDate] ASC;
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

/*
SELECT * FROM vCategories; --View all of the data to understand what's in the table views
SELECT * FROM vProducts; 
SELECT * FROM vInventories;
GO

SELECT [CategoryName] FROM vCategories; -- Viewing specific columns needed from table views for final result
SELECT [ProductName] FROM vProducts; 
SELECT [InventoryDate], [Count] FROM vInventories;
GO

SELECT [CategoryName], [ProductName], [InventoryDate], [Count] -- Join all of the table views into one with the specific columns of interest
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID;
GO

SELECT [CategoryName] -- Order the results
    , [ProductName]
    , [InventoryDate]
    , [Count]
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID
    ORDER BY [CategoryName] ASC, [ProductName] ASC, [InventoryDate] ASC, [Count] DESC;
GO

CREATE VIEW vInventoriesByProductsByCategories  -- Rename view to match final Select statement desired
	AS
	SELECT [CategoryName]
    , [ProductName]
    , [InventoryDate]
    , [Count]
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID;
GO
*/

--Add Order By clause to final Select statement because this clause is not allowed when creating views
SELECT * From [dbo].[vInventoriesByProductsByCategories] 
	ORDER BY [CategoryName] ASC, [ProductName] ASC, [InventoryDate] ASC, [Count] DESC;
GO


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/*
SELECT * FROM vCategories; --View all of the data to understand what's in the table views
SELECT * FROM vProducts; 
SELECT * FROM vInventories;
SELECT * FROM vEmployees;
GO

SELECT [CategoryName] FROM vCategories; -- Viewing specific columns needed from table views for final result
SELECT [ProductName] FROM vProducts; 
SELECT [InventoryDate], [Count] FROM vInventories
SELECT [EmployeeFirstName], [EmployeeLastName] FROM vEmployees;
GO

-- Join all of the table views into one with the specific columns of interest
SELECT [CategoryName], [ProductName], [InventoryDate], [Count], [EmployeeFirstName], [EmployeeLastName]
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	JOIN vEmployees as e
	ON i.EmployeeID = e.EmployeeID
GO

SELECT [CategoryName] -- Order and tidy up the results
    , [ProductName]
    , [InventoryDate]
    , [Count]
	, ([EmployeeFirstName] + ' ' + [EmployeeLastName]) AS 'EmployeeName'
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	JOIN vEmployees as e
	ON i.EmployeeID = e.EmployeeID
    ORDER BY [InventoryDate] ASC, [CategoryName] ASC, [ProductName] ASC, [EmployeeLastName] ASC;
GO

CREATE VIEW vInventoriesByProductsByEmployees -- Rename view to match final Select statement desired
	AS
	SELECT [CategoryName] 
    , [ProductName]
    , [InventoryDate]
    , [Count]
	, ([EmployeeFirstName] + ' ' + [EmployeeLastName]) AS 'EmployeeName'
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	JOIN vEmployees as e
	ON i.EmployeeID = e.EmployeeID  
GO
*/

--Add Order By clause to final Select statement because this clause is not allowed when creating views
SELECT * From [dbo].[vInventoriesByProductsByEmployees] 
	ORDER BY [InventoryDate] ASC, [CategoryName] ASC, [ProductName] ASC, [EmployeeName] ASC;
GO 


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

/*
SELECT * FROM vCategories; --View all of the data to understand what's in the table views
SELECT * FROM vProducts; 
SELECT * FROM vInventories;
SELECT * FROM vEmployees;
GO

SELECT [CategoryName] FROM vCategories; -- Viewing specific columns needed from table views for final result
SELECT [ProductName] FROM vProducts; 
SELECT [InventoryDate], [Count] FROM vInventories
SELECT [EmployeeFirstName], [EmployeeLastName] FROM vEmployees;
GO

SELECT [ProductName] -- Identify Chai and Chang products
	FROM vProducts
	WHERE [ProductName] LIKE 'Cha[i,n]%';
GO

SELECT [CategoryName] -- Join all of the table views into one with the specific columns and rows (for Chai and Chang products) of interest
	,[ProductName] 
	,[InventoryDate]
	,[Count]
	,[EmployeeFirstName]
	,[EmployeeLastName]
	FROM vCategories AS c INNER JOIN vProducts AS p
		ON c.CategoryID = p.CategoryID
    INNER JOIN vInventories AS i
		ON p.ProductID = i.ProductID
	INNER JOIN vEmployees as e
		ON i.EmployeeID = e.EmployeeID
	WHERE [ProductName] IN 
		(SELECT [ProductName] FROM vProducts WHERE [ProductName] LIKE 'Cha[i,n]%');
GO

SELECT [CategoryName] -- Order and tidy up the results
	,[ProductName]
	,[InventoryDate]
	,[Count]
	,([EmployeeFirstName] + ' ' + [EmployeeLastName]) AS 'EmployeeName'
	FROM vCategories AS c INNER JOIN vProducts AS p
		ON c.CategoryID = p.CategoryID
    INNER JOIN vInventories AS i
		ON p.ProductID = i.ProductID
	INNER JOIN vEmployees as e
		ON i.EmployeeID = e.EmployeeID
	WHERE [ProductName] IN 
		(SELECT [ProductName] FROM vProducts WHERE [ProductName] LIKE 'Cha[i,n]%')
ORDER BY [InventoryDate] ASC, [CategoryName] ASC, [ProductName] ASC;
GO

CREATE VIEW vInventoriesForChaiAndChangByEmployees -- Rename view to match final Select statement desired
	AS
	SELECT [CategoryName] 
	,[ProductName]
	,[InventoryDate]
	,[Count]
	,([EmployeeFirstName] + ' ' + [EmployeeLastName]) AS 'EmployeeName'
	FROM vCategories AS c INNER JOIN vProducts AS p
		ON c.CategoryID = p.CategoryID
    INNER JOIN vInventories AS i
		ON p.ProductID = i.ProductID
	INNER JOIN vEmployees as e
		ON i.EmployeeID = e.EmployeeID
	WHERE [ProductName] IN 
		(SELECT [ProductName] FROM vProducts WHERE [ProductName] LIKE 'Cha[i,n]%');
GO
*/

--Add Order By clause to final Select statement because this clause is not allowed when creating views
SELECT * FROM [dbo].[vInventoriesForChaiAndChangByEmployees]
	ORDER BY [InventoryDate] ASC, [CategoryName] ASC, [ProductName] ASC;
GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

/*
SELECT * FROM vEmployees; --View all of the data to understand what's in the table view
GO

SELECT [EmployeeID], [EmployeeLastName] -- Identify who the Managers are and see their Manager IDs to show me what to look for
	FROM vEmployees
	WHERE [EmployeeID] IN
		(SELECT [ManagerID] FROM vEmployees);
GO

SELECT m.[EmployeeFirstName], m.[EmployeeLastName], e.[EmployeeFirstName], e.[EmployeeLastName]  -- Join columns together with self-join to match employees to managers
	FROM vEmployees AS m INNER JOIN vEmployees AS e
	ON m.ManagerID = e.EmployeeID;
GO

SELECT (m.[EmployeeFirstName] + ' ' + m.[EmployeeLastName]) as 'Manager' --Order and pretty up results
	,(e.[EmployeeFirstName] + ' ' + e.[EmployeeLastName]) as 'Employee' 
	FROM vEmployees AS m INNER JOIN vEmployees AS e
	ON e.ManagerID = m.EmployeeID
ORDER BY 1,2;
GO

CREATE VIEW vEmployeesByManager  -- Rename view to match final Select statement desired
	AS	
	SELECT (m.[EmployeeFirstName] + ' ' + m.[EmployeeLastName]) as 'Manager'
	,(e.[EmployeeFirstName] + ' ' + e.[EmployeeLastName]) as 'Employee' 
	FROM vEmployees AS m INNER JOIN vEmployees AS e
	ON e.ManagerID = m.EmployeeID
GO
*/

--Add Order By clause to final Select statement because this clause is not allowed when creating views
SELECT * FROM [dbo].[vEmployeesByManager]
	ORDER BY 1,2;
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

/*
SELECT * FROM vCategories; --View all of the data to understand what's in the basic views
SELECT * FROM vProducts; 
SELECT * FROM vInventories;
SELECT * FROM vEmployees;
GO

SELECT [EmployeeID], [EmployeeLastName] -- Identify who the Managers are and see their Manager IDs to show me what to look for
	FROM vEmployees
	WHERE [EmployeeID] IN
		(SELECT [ManagerID] FROM vEmployees);
GO

-- Join all of the table views into one 
SELECT c.CategoryID
	, c.CategoryName
	, p.ProductID
	, p.ProductName
	, p.UnitPrice
	, i.InventoryID
	, i.InventoryDate
	, e.EmployeeID
	, e.EmployeeFirstName
	, e.EmployeeLastName
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	JOIN vEmployees as e
	ON i.EmployeeID = e.EmployeeID
GO


SELECT c.CategoryID --Add in self-join to match employees to their managers
	, c.CategoryName
	, p.ProductID
	, p.ProductName
	, p.UnitPrice
	, i.InventoryID
	, i.InventoryDate
	, i.Count
	, e.EmployeeID
	,(e.[EmployeeFirstName] + ' ' + e.[EmployeeLastName]) as 'Employee' 
	,(m.[EmployeeFirstName] + ' ' + m.[EmployeeLastName]) as 'Manager'
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	INNER JOIN vEmployees as e
	ON i.EmployeeID = e.EmployeeID
	INNER JOIN vEmployees AS m 
	ON e.ManagerID = m.EmployeeID
GO

 
SELECT c.CategoryID  --Order and pretty up results
	, c.CategoryName
	, p.ProductID
	, p.ProductName
	, p.UnitPrice
	, i.InventoryID
	, i.InventoryDate
	, i.Count
	, e.EmployeeID
	,(e.[EmployeeFirstName] + ' ' + e.[EmployeeLastName]) as 'Employee' 
	,(m.[EmployeeFirstName] + ' ' + m.[EmployeeLastName]) as 'Manager'
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	INNER JOIN vEmployees as e
	ON i.EmployeeID = e.EmployeeID
	INNER JOIN vEmployees AS m 
	ON e.ManagerID = m.EmployeeID
ORDER BY 2, 4, 6, 10
GO

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees  -- Rename view to match final Select statement desired
	AS
	SELECT c.CategoryID
	, c.CategoryName
	, p.ProductID
	, p.ProductName
	, p.UnitPrice
	, i.InventoryID
	, i.InventoryDate
	, i.Count
	, e.EmployeeID
	,(e.[EmployeeFirstName] + ' ' + e.[EmployeeLastName]) as 'Employee' 
	,(m.[EmployeeFirstName] + ' ' + m.[EmployeeLastName]) as 'Manager'
	FROM vCategories AS c JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
    JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	INNER JOIN vEmployees as e
	ON i.EmployeeID = e.EmployeeID
	INNER JOIN vEmployees AS m 
	ON e.ManagerID = m.EmployeeID;
GO
*/
	
--Add Order By clause to final Select statement because this clause is not allowed when creating views
SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]
	ORDER BY 2, 4, 6, 10;
GO

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees];
GO

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/