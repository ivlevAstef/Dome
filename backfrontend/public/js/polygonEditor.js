//ymaps.ready(init);

ymaps.ready(function () {
    var myMap = new ymaps.Map('map', {
        center: [55.751432, 37.716621],
        zoom: 10,
        controls: []
    });
    
    var myPolygon = new ymaps.Polygon([
        [
            [55.75, 37.50],
            [55.80, 37.60],
            [55.75, 37.70],
            [55.70, 37.70],
            [55.70, 37.50]
        ],
        [
            [55.75, 37.52],
            [55.75, 37.68],
            [55.65, 37.60]
        ]
    ]);

    myMap.geoObjects.add(myPolygon);
    
    myPolygon.editor.startDrawing()

    myPolygon.geometry.events.add('change', function () {
       console.log(myPolygon.geometry.getCoordinates().toString()); 
    });
});