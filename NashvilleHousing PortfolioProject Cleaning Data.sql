/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, Convert(date, SaleDate)
From PortfolioProject..NashvilleHousing

--If leave it like this is wont actually update SO we do the Alter Table step followed by the rest of the below setps
-- Then change the column name in the 1st Select statement query
Update NashvilleHousing
Set SaleDate = Convert(date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)



--Populate Property Address data

--We used this query to see where there are NULL values for Property Address
Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--We used next two queries to populate an address where there is NULL.
--ISNULL checks that the first parameter is null, and replaces it w/ second parameter
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--This updates the above query
--After running this query, rerun the above query to check if it did it correctly
Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject..NashvilleHousing

--The -1 in this query removes the comma after the address
--This below queries are to split PropertyAddress
Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity= Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

Select * 
From NashvilleHousing


--The below queries are to split OwnerAddress
Select OwnerAddress 
From NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity= PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState= PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--Removing Duplicates
--Using a CTE

With RowNumCTE  As(
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)

--To actually remove duplicates comment out select * and order by, and uncomment delete and run CTE
--Do reverse of above comment to check for duplicate rows in row_num 1st
Select *
--Delete
From RowNumCTE
Where row_num >1
Order by PropertyAddress



--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate