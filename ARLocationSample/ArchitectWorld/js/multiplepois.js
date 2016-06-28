// implementation of AR-Experience (aka "World")
var World = {

	initiallyLoadedData: false,// データロードは１回のみ

	// マーカーのアセット
	markerDrawable_idle: null,
	markerDrawable_selected: null,

	markerList: [],

	currentMarker: null, //　選択中のマーカー

	loadPoisFromJsonData: function loadPoisFromJsonDataFn(poiData) {
		World.markerList = [];

		World.markerDrawable_idle = new AR.ImageResource("assets/marker_idle.png");
		World.markerDrawable_selected = new AR.ImageResource("assets/marker_selected.png");

        for (var currentPlaceNr = 0; currentPlaceNr < poiData.length; currentPlaceNr++) {
			var singlePoi = {
				"id": poiData[currentPlaceNr].id,
				"latitude": parseFloat(poiData[currentPlaceNr].latitude),
				"longitude": parseFloat(poiData[currentPlaceNr].longitude),
				"altitude": parseFloat(poiData[currentPlaceNr].altitude),
				"title": poiData[currentPlaceNr].name,
				"description": poiData[currentPlaceNr].description
			};
			World.markerList.push(new Marker(singlePoi));
		}

		World.updateStatusMessage(currentPlaceNr + ' places loaded');
	},

	// updates status message shon in small "i"-button aligned bottom center
	updateStatusMessage: function updateStatusMessageFn(message, isWarning) {

		var themeToUse = isWarning ? "e" : "c";
		var iconToUse = isWarning ? "alert" : "info";

		$("#status-message").html(message);
		$("#popupInfoButton").buttonMarkup({
			theme: themeToUse
		});
		$("#popupInfoButton").buttonMarkup({
			icon: iconToUse
		});
	},

	// location updates, fired every time you call architectView.setLocation() in native environment
	locationChanged: function locationChangedFn(lat, lon, alt, acc) {
        if (!World.initiallyLoadedData) {
			World.requestDataFromLocal(lat, lon);
			World.initiallyLoadedData = true;
		}
	},

	// fired when user pressed maker in cam
	onMarkerSelected: function onMarkerSelectedFn(marker) {

		// deselect previous marker
		if (World.currentMarker) {
			if (World.currentMarker.poiData.id == marker.poiData.id) {
				return;
			}
			World.currentMarker.setDeselected(World.currentMarker);
		}

		// highlight current one
		marker.setSelected(marker);
		World.currentMarker = marker;
	},

	// screen was clicked but no geo-object was hit
	onScreenClick: function onScreenClickFn() {
		if (World.currentMarker) {
			World.currentMarker.setDeselected(World.currentMarker);
		}
	},

	// request POI data
	requestDataFromLocal: function requestDataFromLocalFn(centerPointLatitude, centerPointLongitude) {
		var poisToCreate = 10;
		var poiData = [];

        for (var i = 0, length = jsonData.length; i < length; i++) {
            var distance = World.getDistance(jsonData[i].latitude, centerPointLatitude, jsonData[i].longitude, centerPointLongitude);
            //if (distance > 500.0) continue;  // 0.5km（＝500m）以上先のPOIデータは破棄します。
            var distanceString = (distance > 999) ? ((distance / 1000).toFixed(2) + " km") : (Math.round(distance) + " m");

            poiData.push({
                         //"id":          "dmy",
                         "longitude":   (jsonData[i].longitude),
                         "latitude":    (jsonData[i].latitude),
                         "altitude":    50.0 +  Math.floor( Math.random() * 11 ) *5, // 標高については、とりあえず50mを基準と、ランダムに重ならないよいうにしました
                         "description":  (distanceString),
                         "name": (jsonData[i].name)
                         });
		}
		World.loadPoisFromJsonData(poiData);
	},
    getDistance: function (targetLatitude, centerPointLatitude, targetLongtitude, centerPointLongitude) {
        // 参考：http://www.movable-type.co.uk/scripts/latlong.html
        var Δφ = (centerPointLatitude - targetLatitude) * Math.PI / 180;
        var Δλ = (centerPointLongitude - targetLongtitude) * Math.PI / 180;
        var a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) + Math.cos(targetLatitude * Math.PI / 180) * Math.cos(centerPointLatitude * Math.PI / 180) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return 6371e3 * c
    },

};

AR.context.onLocationChanged = World.locationChanged;
AR.context.onScreenClick = World.onScreenClick;



