--data cleaning in sql

select *
from PortfolioProject..NashvilleHousing

----------------------------------------------------------------

--standardize date format

select SaleDate,CONVERT(date,SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

----------------------------------------------------------------------

--populate property address

select PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
--order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is  null


update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is  null


select PropertyAddress
from [PortfolioProject]..NashvilleHousing
where PropertyAddress is null

---------------------------------------------------------------------------------

--breaking out address into individual columns

select PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing

--splitting owner address

select OwnerAddress
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null

select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--change y and n to yes and no in "sold as vacant" column

select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select 
case
     when  SoldAsVacant ='N' then 'No'
	 when  SoldAsVacant = 'Y' then 'Yes'
	 else SoldAsVacant
end
from PortfolioProject..NashvilleHousing


update NashvilleHousing
set SoldAsVacant =  
case
     when  SoldAsVacant ='N' then 'No'
	 when  SoldAsVacant = 'Y' then 'Yes'
	 else SoldAsVacant
end

-----------------------------------------------------------------------------------------------

--Remove duplicates

with rownumCTE as(

select *,
ROW_NUMBER() over 
                (partition by parcelid,
				propertyaddress,
				saledate,
				saleprice,
				legalreference
				order by 
				uniqueid) as row_num
from PortfolioProject..NashvilleHousing
)

select *
from rownumCTE
where row_num > 1
order by ParcelID

-----------------------------------------------------------------------------------------

--delete unused columns 

alter table PortfolioProject..NashvilleHousing
drop column PropertyAddress,Saledate,TaxDistrict,OwnerAddress

select *
from PortfolioProject..NashvilleHousing
