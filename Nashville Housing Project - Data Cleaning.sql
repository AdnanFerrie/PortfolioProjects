/*

Data cleaning in Microsoft SQL Queries

*/

SELECT*
FROM PortfolioProjects.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------

-- Standardize Date format

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProjects..NashvilleHousing 
SET SaleDateConverted = CONVERT(DATE, SaleDate)

---------------------------------------------------------------

-- Populate Property Address data (Dealing with Null values)

SELECT *
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing B -- self join the Table
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress)) AS Address
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD ProperySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET ProperySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD ProperySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET ProperySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress))

SELECT *
FROM PortfolioProjects..NashvilleHousing


SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT *
FROM PortfolioProjects..NashvilleHousing

----------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" column

--SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
--FROM PortfolioProjects..NashvilleHousing
--GROUP BY SoldAsVacant
--ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

-------------------------------------------------------------------------------------

-- Remove Duplicate

-- Using CTE to remove Duplicate rows

WITH RowNUMCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY parcelID,
	             PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM PortfolioProjects..NashvilleHousing
--ORDER BY ParcelID
)
SELECT* 
--DELETE
FROM RowNUMCTE
WHERE row_num > 1
ORDER BY PropertyAddress

----------------------------------------------------------------------

-- Delete Unused Columns

SELECT*
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

