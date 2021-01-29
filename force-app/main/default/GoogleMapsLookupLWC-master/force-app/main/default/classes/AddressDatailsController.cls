public with sharing class AddressDatailsController {
    @AuraEnabled(cacheable=true)
    public static String detailsSearch(String place_id) {
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=' + place_id +'&fields=geometry&key=' + getKey();
        AddressDatailsFinder.Location resp = getAddressDatails(url);
        return JSON.serialize(resp);
    }

    public static AddressDatailsFinder.Location getAddressDatails(string strURL) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        String responseBody = res.getBody();
        AddressDatailsFinder.Location location = AddressDatailsFinder.parse(responseBody);
        return location;
    }

    public static string getKey() {
        return 'AIzaSyBtVA65U63XZUgg0pkTPaZS2h9MFBBFWSY';
    }
}
