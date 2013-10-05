//link class - a rigid body between two vertices

class Link { 
  
  ArrayList<LinkHinge> hinges;//storage
  ArrayList<ArrayList> connectors;
  boolean[] crossbars = new boolean[2];
  
  Link (PVector end1, PVector end2, float width1, float width2, boolean crossbar1, boolean crossbar2){
    
    hinges = new ArrayList<LinkHinge>();
    connectors = new ArrayList<ArrayList>();
    
    crossbars[0] = crossbar1;
    crossbars[1] = crossbar2;
    
    float theta = calculateTheta(end1,end2);//angle of linkage
    
    PVector endA = end1.get();
    PVector endB = end2.get();
    PVector endC = end1.get();
    PVector endD = end2.get();
    
    endA.x -= width1/2;
    endC.x += width1/2 - hingeWidth;
    endB.x -= width2/2;
    endD.x += width2/2 - hingeWidth;

    addHinges(endA,endB,theta);
    addHinges(endC,endD,theta);
    
    calculateGeometry();
  }
  
  void calculateGeometry(){
    
    connectors.add(hinges.get(0).getConnectingVertices(true, true));
    connectors.add(hinges.get(1).getConnectingVertices(false, true));
    connectors.add(hinges.get(2).getConnectingVertices(true, false));
    connectors.add(hinges.get(3).getConnectingVertices(false, false));
  }
  
  void addHinges(PVector end1, PVector end2, float theta){
    hinges.add(new LinkHinge(end1,-(theta+PI/2)));
    hinges.add(new LinkHinge(end2,-(theta-PI/2)));
  }
  
  float calculateTheta(PVector end1, PVector end2){
    
    //calculate angle between the ends
    float diffY = end1.y - end2.y;
    float diffZ = end1.z - end2.z;
    return atan2(diffZ, diffY);
  }
  
  UGeometry getGeometry(){
    
    //draw hinges
    UGeometry geo = new UGeometry();
    for (LinkHinge hinge : hinges){
      geo.add(hinge.getGeometry());
    }
    hinges = null;//remove from memory
    
    //draw connections bewttn hinges
    geo.quadStrip((UVertexList)connectors.get(0).get(0), (UVertexList)connectors.get(0).get(1));
    geo.quadStrip((UVertexList)connectors.get(1).get(1), (UVertexList)connectors.get(1).get(0));
    geo.quadStrip((UVertexList)connectors.get(2).get(0), (UVertexList)connectors.get(2).get(1));
    geo.quadStrip((UVertexList)connectors.get(3).get(1), (UVertexList)connectors.get(3).get(0));

    geo.quadStrip((UVertexList)connectors.get(0).get(2), (UVertexList)connectors.get(1).get(2));
    geo.quadStrip((UVertexList)connectors.get(2).get(2), (UVertexList)connectors.get(3).get(2));
    
    geo.quadStrip((UVertexList)connectors.get(0).get(3), (UVertexList)connectors.get(0).get(4));
    geo.quadStrip((UVertexList)connectors.get(1).get(4), (UVertexList)connectors.get(1).get(3));
    geo.quadStrip((UVertexList)connectors.get(2).get(3), (UVertexList)connectors.get(2).get(4));
    geo.quadStrip((UVertexList)connectors.get(3).get(4), (UVertexList)connectors.get(3).get(3));  
   
   //draw cross bars or close holes
    if (crossbars[0]){
      geo.quadStrip((UVertexList)connectors.get(2).get(5), (UVertexList)connectors.get(0).get(5));
    } else {
      geo.triangleFan((UVertexList)connectors.get(2).get(5), true, true);
      geo.triangleFan((UVertexList)connectors.get(0).get(5), true, false);
    }
    if (crossbars[1]){
      geo.quadStrip((UVertexList)connectors.get(1).get(5), (UVertexList)connectors.get(3).get(5)); 
    } else {
      geo.triangleFan((UVertexList)connectors.get(1).get(5), true, true);
      geo.triangleFan((UVertexList)connectors.get(3).get(5), true, false); 
    }
    
    return geo;
  }
  
} 
