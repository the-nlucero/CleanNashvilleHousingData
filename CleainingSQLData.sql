/* Cleaning Data in SQL Queries */
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

/* Standardize Date Format */
SELECT 
	 SaleDateConverted
	,CONVERT(Date, SaleDate) 
FROM PortfolioProject.dbo.NashvilleHousing


--Update New Column Created
ALTER TABLE NashVilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) 

/* Populate Property Address Data */
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID



SELECT 
	 a.ParcelID
	,a.PropertyAddress
	,b.ParcelID
	,b.PropertyAddress
	,ISNULL(a.PropertyAddress, b.PropertyAddress) --WE WANT a replaced with b

FROM PortfolioProject.dbo.NashvilleHousing a

JOIN PortfolioProject.dbo.NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a

JOIN PortfolioProject.dbo.NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

WHERE a.PropertyAddress is null

/* Breaking Out Address into Individual Columns (Address, City, State) LONG WAY*/
SELECT 
	 PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

--Retreive Desired Results
SELECT 
	  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address -- -1 Gets rid of comma placement
	 ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address -- +1 Prints After Comma
FROM PortfolioProject.dbo.NashvilleHousing

--Update Address With Values
ALTER TABLE NashVilleHousing
Add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--Update City With Values
ALTER TABLE NashVilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


/* Breaking Out Address into Individual Columns (Address, City, State) SHORT WAY*/
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

Select 
	 OwnerAddress
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) --We are replaceing our search from a period to to comma
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

--Update (SHORTER WAY) Table
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



/* Change Y and N to Yes and No within "SoldAsVacant " Field */
SELECT 
	 DISTINCT(SoldAsVacant)
	,COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT 
	 SoldAsVacant
	,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		  WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END


/* Remove Duplicates */

WITH RowNUMCTE AS (


SELECT 
	 *
	,ROW_NUMBER() OVER 
	(
	PARTITION BY 
		 ParcelID
		,PropertyAddress
		,SalePrice
		,SaleDate
		,LegalReference
	ORDER BY UniqueID
	) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNUMCTE
WHERE row_num > 1


/* Delete Unused Columns */
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN 
	 OwnerAddress
	,SaleDate


