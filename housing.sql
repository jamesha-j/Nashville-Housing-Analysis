--- Standardize Date Format

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM PortfolioProject.dbo.housing

UPDATE housing
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE housing
Add SaleDateConverted DATE;

UPDATE housing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDate FROM dbo.housing


--------------------------------------------------------------------------------------------------------------------

---Populate Propety Address data
SELECT PropertyAddress
FROM dbo.housing
WHERE PropertyAddress IS NULL

SELECT *
FROM dbo.housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.housing a
JOIN dbo.housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---Fixing NULL PropertyAddresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.housing a
JOIN dbo.housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------

---Breaking out Address into Individual Columns(Address,City,State)

SELECT PropertyAddress
FROM dbo.housing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

--- Removing commas from address after seperating
SELECT
SUBSTRING(PropertyAddress, -1,CHARINDEX(',',PropertyAddress)) AS Address,
CHARINDEX(',', PropertyAddress)
FROM dbo.housing

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM dbo.housing

ALTER TABLE housing
Add PropertySplitAddress NVARCHAR(255);

UPDATE housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE housing
Add PropertySplitCity NVARCHAR(255);

UPDATE housing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


SELECT *
FROM dbo.housing


--- Easier way to split up address
SELECT OwnerAddress
FROM dbo.housing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

FROM dbo.housing


ALTER TABLE housing
Add OwnerSplitAddress NVARCHAR(255);

UPDATE housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE housing
Add OwnerSplitCity NVARCHAR(255);

UPDATE housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE housing
Add OwnerSplitState NVARCHAR(255);

UPDATE housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--------------------------------------------------------------------------------------------------------------------


--- Change Y and N to Yes and NO in "Sold as Vacant" filed

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM dbo.housing

UPDATE dbo.housing
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

--------------------------------------------------------------------------------------------------------------------


---Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM dbo.housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--------------------------------------------------------------------------------------------------------------------


--- Delete Unused Columns
ALTER TABLE dbo.housing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict


ALTER TABLE dbo.housing
DROP COLUMN SaleDate


SELECT * 
FROM dbo.housing


