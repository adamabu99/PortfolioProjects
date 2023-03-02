--CLEANING DATA IN SQL QUERIES

SELECT *
FROM [Portfolio Project]..NashvilleHousing

-- Standardize Date format

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM [Portfolio Project]..NashvilleHousing

--The changes are updated to the data

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

--Another way to make Changes to the database
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted
From [Portfolio Project]..NashvilleHousing

--Populate Property address data 

SELECT *
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress is null
--This shows where PropertyAddress is null

SELECT *
FROM [Portfolio Project]..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID
-- We see that if the ParcelID is the same the PropertAddress is also the same


--We will do a self join to fix this
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


--Updating the changes into the database
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

-- Breaking Address into individual columns 9address, city, state)

SELECT PropertyAddress
From [Portfolio Project]..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM [Portfolio Project]..NashvilleHousing

--Create two new columns and add the new address values

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCityName nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCityName = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--	Splitting Owner Address the way we split Property address

SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM [Portfolio Project]..NashvilleHousing

-- Update and add this values to the table

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


--Changing Y and N to Yes  and No in 'Sold as Vacant' field 

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM [Portfolio Project]..NashvilleHousing

--Add this update to the table

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Removing Duplicates

WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) AS Row_num
FROM [Portfolio Project]..NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE Row_num > 1
--ORDER BY PropertyAddress




--DELETE unused columns

SELECT *
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, PropertySplitCity

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN SaleDate

