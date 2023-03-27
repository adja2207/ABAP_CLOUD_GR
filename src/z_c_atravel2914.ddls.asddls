@EndUserText.label: 'Consuption - Approval Travel Root'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity Z_C_ATRAVEL2914  
  provider contract transactional_query
as projection on Z_I_TRAVEL2914
{
    key TravelId,
    AgencyId ,
    _Agency.Name       as AgencyName,
    CustomerId,
   _Customer.LastName as CustomerName,
    BeginDate,
    EndDate,
    BookingFee,
    TotalPrice,
    CurrencyCode,
    Description,
    OverallStatus,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    /* Associations */
    _Booking : redirected to composition child Z_C_ABOOK2914,
    _Agency,
    _Customer
}
