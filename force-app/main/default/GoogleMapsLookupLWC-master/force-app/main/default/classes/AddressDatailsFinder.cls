public with sharing class AddressDatailsFinder {
    public List<String> html_attributions;
    public Result result;
    public String status;

    public class Result {
        public Geometry geometry;
    }

    public class Geometry {
        public Location location;
        public Viewport viewport;
    }

    public class Location {
        public String lat;
        public String lng;
    }

    public class Viewport {
        public Northeast northeast;
        public Southwest southwest;
    }

    public class Northeast {
        public String lat;
        public String lng;
    }

    public class Southwest {
        public String lat;
        public String lng;
    }

    public static Location parse(String json) {
        AddressDatailsFinder addressDatailsFinder = (AddressDatailsFinder) System.JSON.deserialize(json, AddressDatailsFinder.class);
        Result res = addressDatailsFinder.result;
        Geometry geometry = res.geometry;
        Location location = geometry.location;
        return location;
	}
}
