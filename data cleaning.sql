/*

Cleaning Data in SQL Queries

*/



Select *
From NashvilleHousing

-- Standardize Date Format

Select SaleDate,CONVERT(date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

-- Populate Property Address data
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
From NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing
Where PropertyAddress is not null

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as LENGTH
From NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))


Select *
From NashvilleHousing

Select PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order By SoldAsVacant

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'ÝES'
WHEN SoldASVacant = 'N' Then 'No'
ELSE SoldAsVacant
END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'ÝES'
WHEN SoldASVacant = 'N' Then 'No'
ELSE SoldAsVacant
END

-- Remove Duplicates
With RowNumCTE AS(

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num >1


-- Delete Unused Columns

Select *
From NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing

Drop Column TaxDistrict,OwnerAddress,PropertyAddress,SaleDate 

