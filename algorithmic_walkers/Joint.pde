//joint class - creates the structure of the joint pieces between the links

class Joint{
  
  ArrayList<UVertexList> vlists;//storage
  ArrayList<JointSection> sections;
  int numConnections;
  
  Joint(PVector location, int num, float centerWidth, int copies){
    
    vlists = new ArrayList<UVertexList>();
    sections = new ArrayList<JointSection>();
    numConnections = num;
    
    calculateGeometry(location, centerWidth, copies);
  }
  
  void calculateGeometry(PVector location, float centerWidth, int copies){
    
    float totalWidth = getTotalWidth(copies, centerWidth);
    float[] ends = {location.x - totalWidth/2, location.x + totalWidth/2};
    
    //calculate ends
    for (int i=0;i<2;i++){
      UVertexList vlist = new UVertexList();
      for (int j=0;j<resolution;j++){
        float theta = j*TWO_PI/resolution;
        vlist.add(ends[i], location.y + jointBevelRad*sin(theta), location.z + jointBevelRad*cos(theta));
      }
      vlist.close();
      vlists.add(vlist); 
    }
    
    //calculate joint sections
    float xOffset = 0;
    for (int l=0;l<copies;l++){
      for (int k=0;k<numConnections;k++){
        PVector sectionLoc = new PVector(ends[0] + xOffset, location.y, location.z);
        UVertexList lastList = new UVertexList();
        if (k==0 && l==0){
          lastList.add(vlists.get(0));
        } else {
          lastList.add(sections.get(sections.size()-1).getConnectingVertices());
        }
        sections.add(new JointSection(lastList, sectionLoc));
        xOffset += jointWidth + jointBevelWidth;
      }
      xOffset += centerWidth;
    }
  }
  
  float getTotalWidth(int copies, float centerWidth){
    return copies*(jointBevelWidth*(numConnections + 1) + jointWidth*numConnections) + centerWidth*(copies-1) -jointBevelWidth;
  }
  
  UGeometry getGeometry(){
    
    UGeometry geo = new UGeometry();
    
    for (JointSection section : sections){
      geo.add(section.getGeometry());
    }
    
    //close ends
    geo.quadStrip(vlists.get(1),sections.get(sections.size()-1).getConnectingVertices());
    geo.triangleFan(vlists.get(0), true, true);
    geo.triangleFan(vlists.get(1), true, false);
    
    sections = null;//remove from memory
    
    return geo;
  }
}
