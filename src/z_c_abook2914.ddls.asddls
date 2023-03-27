@EndUserText.label: 'Consuption -ABooking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_ABOOK2914 
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
    _Carrier,
    _Customer,
    _Tavel: redirected to parent Z_C_ATRAVEL2914 

}
