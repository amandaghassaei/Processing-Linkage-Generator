//jointSection class - the unit piece of the middle of the joint

class JointSection{
  
  ArrayList<UVertexList> vlists;//storage
  
  JointSection(UVertexList connectingList, PVector location){
    
    vlists = new ArrayList<UVertexList>();
    vlists.add(connectingList);
    calculateGeometry(location);
  }
  
  void calculateGeometry(PVector location){
    
    float xOffset = 0;
    for (int i=0;i<4;i++){
      UVertexList vlist = new UVertexList();
      float rad = 0;
      switch (i){
        case 0:
        rad = jointBevelRad;
        xOffset += jointBevelWidth;
        break;
        case 1:
        rad = jointRad;
        break;
        case 2:
        rad = jointRad;
        xOffset += jointWidth;
        break;
        case 3:
        rad = jointBevelRad;
        break;
      }
      for (int j=0;j<resolution;j++){
        float theta = j*TWO_PI/resolution;
        vlist.add(location.x + xOffset, location.y + rad*sin(theta), location.z + rad*cos(theta));
      }
      vlist.close();
      vlists.add(vlist);
    }
  }
  
  UGeometry getGeometry(){
    
    UGeometry geo = new UGeometry();

    for (int i=1;i<vlists.size();i++){
      geo.quadStrip(vlists.get(i),vlists.get(i-1));
    }
    return geo;
  }
  
  UVertexList getConnectingVertices(){
    
    return vlists.get(vlists.size()-1);//return last element in vlists
  }
}
