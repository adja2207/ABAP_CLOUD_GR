@EndUserText.label: 'Consuption - Booking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_BOOK2914
  as projection on Z_I_BOOK2914
{

  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionID,
      FlightDate,
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _Tavel: redirected to parent Z_C_TRAVEL2914 ,
      _BookingSupplement: redirected to composition child Z_C_BKSUP2914,
    _Carrier,
    _Connection,
    _Customer
}
