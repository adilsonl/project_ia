class Place{

  String name;
  double lat;
  double long;
  Place(this.name,this.lat,this.long);

  Map<String,dynamic> toMap(){
    return <String,dynamic>{
      "name":name,
      "lat":lat,
      "long":long
    };
  }

}