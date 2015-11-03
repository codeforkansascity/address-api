
var mapquestOSM = L.tileLayer("http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png", {
  maxZoom: 19,
  subdomains: ["otile1", "otile2", "otile3", "otile4"],
  attribution: 'Tiles courtesy of <a href="http://www.mapquest.com/" target="_blank">MapQuest</a> <img src="http://developer.mapquest.com/content/osm/mq_logo.png">. Map data (c) <a href="http://www.openstreetmap.org/" target="_blank">OpenStreetMap</a> contributors, CC-BY-SA.'
});

var map = L.map('mapdiv', {
  zoom: 10,
  center: [39.702222, -94.979378],
  layers: [mapquestOSM],
  zoomControl: false
});

new L.Control.Zoom({ position: 'bottomleft' }).addTo(map);

// API endpoint to get list of KC Neighborhoods
var addressAPINeighborhoods = "http://api.codeforkc.org/neighborhoods-geo/V0/99?city=KANSAS%20CITY&state=MO";
//var addressAPINeighborhoods = "data/KCNeighborhood.geojson";
var neighborhoodLayer = L.geoJson(null, {
    // http://leafletjs.com/reference.html#geojson-style
    style: function(feature) {
        return { color: '#f00' };
    }
});
var customLayer = omnivore.geojson(addressAPINeighborhoods, null, neighborhoodLayer)
    .on('ready', function() {
        map.fitBounds(neighborhoodLayer.getBounds());

        // After the 'ready' event fires, the GeoJSON contents are accessible
        // and you can iterate through layers to bind custom popups.
        neighborhoodLayer.eachLayer(function(layer) {
            // See the `.bindPopup` documentation for full details. This
            // dataset has a property called `name`: your dataset might not,
            // so inspect it and customize to taste.
            layer.bindPopup(layer.feature.properties.name);
        });
    })
    .addTo(map);
/*
var neighborhoodLayer = new L.GeoJSON(parse(addressAPINeighborhoods), {
    		style: function(feature) {
				return {color: feature.properties.color };
			},
			onEachFeature: function(feature, marker) {
				marker.bindPopup('<h4 style="color:'+feature.properties.color+'">'+ feature.properties.name +'</h4>');
			}
		});

	map.addLayer(neighborhoodLayer);
*/
    function searchByAjax(text, callResponse)//callback for 3rd party ajax requests
	{
		return $.ajax({
			url: addressAPINeighborhoods,	//read comments in search.php for more information usage
			type: 'GET',
			data: {q: text},
			dataType: 'json',
			success: function(json) {
				callResponse(json);
			}
		});
	}

	map.addControl( new L.Control.Search({sourceData: searchByAjax, text:'KCNeighborhood:', markerLocation: false}) );
    
    //Define JavaScript function to execute the HTTP get request
  function httpGet(theUrl){
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "GET", theUrl, false ); // false for synchronous request
    xmlHttp.send( null );
    return JSON.parse(xmlHttp.responseText);
  }
  //Use HTTP get function to get 2015 Crime data for KCMO (http://dev.socrata.com/foundry/#/data.kcmo.org/geta-wrqs)
  //Note: the default limit is 1000 data points
  /*
  var data = httpGet('https://data.kcmo.org/resource/geta-wrqs.json');
  //for each data point, create a marker with the lat lon coordinates and add to the map
  data.forEach(function(entry){
    var marker =  L.marker([entry.location_1.coordinates[1], entry.location_1.coordinates[0]])
      .bindPopup(entry.description + " " + entry.from_date).addTo(map);
  });
  */
      $.getJSON(addressAPINeighborhoods, function(json) {

		var geoLayer = L.geoJson(json).addTo(map);
		
		map
		.fitBounds( geoLayer.getBounds() )
		.setMaxBounds( geoLayer.getBounds().pad(0.5) );

		var geoList = new L.Control.GeoJSONList(geoLayer, {
			listItemBuild: function(layer) {
				var item = L.DomUtil.create('div','');
				item.innerHTML = L.Util.template('<b>{name}</b>', layer.feature.properties);
				return item;
			}
		});

		geoList.on('item-active', function(e) {
			$('#selection').text(JSON.stringify(e.layer.feature.properties));
            var neighborhoodname = encodeURIComponent(e.layer.feature.properties.name);
            var neighborhoodURL = "http://api.codeforkc.org//address-by-neighborhood/V0/" + neighborhoodname + "?city=&state=mo";
            $("#neighborhoodapi_endpt").html("<a target='_blank' href='http://api.codeforkc.org//address-by-neighborhood/V0/Broadway%20Gillham?city=' + neighborhoodname + '&state=mo'>" + neighborhoodURL + "</a>");
		});

		map.addControl(geoList);
		
	});
  
  /*
      var geoLayer = L.geoJson().addTo(map);
	
	var geoList = L.control.geoJsonSelector(geoLayer, {
		listItemBuild: function(layer) {
			var item = L.DomUtil.create('div','')
				props = layer.feature.properties,
				tags = props.tags,
				t = 'ID: '+props.id+'<br>';
			
			for(var p in tags)
				t += p+': '+tags[p]+'<br>';

			item.innerHTML = t;
			return item;
		}
	});

	geoList.on('item-active', function(e) {
		$('#selection').text( JSON.stringify(e.layer.feature.properties) );
	})
	.addTo(map);
	
	$('#geofilter').on('change', function(e) {

		$.ajax({
			data: this.value,
			type: 'post',
			dataType: 'json',
			url: 'http://overpass-api.de/api/interpreter',
			success: function(json) {

				map.removeLayer(geoLayer);

				var geojson = osmtogeojson(json);

				//console.log(geojson);

				geoLayer = L.geoJson(geojson).addTo(map);

				map.fitBounds( geoLayer.getBounds() );

				geoList.reload( geoLayer );
			}
		});
	}).trigger('change');
*/

    //Define basemaps \ overlays
    var Esri_WorldImagery = L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
    attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
});
var Stamen_Watercolor = L.tileLayer('http://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.png', {
    attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    subdomains: 'abcd',
	minZoom: 1,
	maxZoom: 16,
	ext: 'png'
});
var Stamen_Toner = L.tileLayer('http://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png', {
    attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
	subdomains: 'abcd',
	minZoom: 0,
	maxZoom: 20,
	ext: 'png'
});
var MapBox = L.tileLayer('http://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
    attribution: 'Imagery from <a href="http://mapbox.com/about/maps/">MapBox</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
	subdomains: 'abcd',
	id: '<your id>',
	accessToken: '<your accessToken>'
});
var Acetate_terrain = L.tileLayer('http://a{s}.acetate.geoiq.com/tiles/terrain/{z}/{x}/{y}.png', {
    attribution: '&copy;2012 Esri & Stamen, Data from OSM and Natural Earth',
	subdomains: '0123',
	minZoom: 2,
	maxZoom: 18
});
var OpenWeatherMap_Temperature = L.tileLayer('http://{s}.tile.openweathermap.org/map/temp/{z}/{x}/{y}.png', {
    maxZoom: 19,
	attribution: 'Map data &copy; <a href="http://openweathermap.org">OpenWeatherMap</a>',
	opacity: 0.5
});
    
    // Define basemaps
    var baseMaps = {
    "Imagery": Esri_WorldImagery,
    "NoColor": Stamen_Toner,
    "Terrain": Acetate_terrain,
    "Watercolor": Stamen_Watercolor,
};
// Define overlays
var overlayMaps = {
    "Temperature": OpenWeatherMap_Temperature
};

L.control.layers(baseMaps, overlayMaps, {position: 'topleft'}).addTo(map);
