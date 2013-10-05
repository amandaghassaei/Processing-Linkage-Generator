//leg class - contains all linkage and joint elements in a leg
  
class Leg {
  
  ArrayList<Joint> joints;
  ArrayList<Link> links;
  PVector[] vertices;
  
  Leg (PVector location, float theta, byte[] numConnections, float[] hingeWidths, boolean[][] linkCrossbars, int[][] connectionPos){
    
    joints = new ArrayList<Joint>();
    links = new ArrayList<Link>();
    vertices = calculator.calculateVerticesForAngle(theta);
    
    for (int i=0;i<vertices.length;i++){
//      if (i!=fixedHingeIndex && i!=crankVertIndex){//don't create hinges at crank and fixed hinges - these will be handled by LegGroup classsmmmmmm
        vertices[i].add(location);
        joints.add(new Joint(vertices[i], numConnections[i], hingeWidths[i], 2));
//      }
    }
    for (int j=0;j<vertexPairs.length;j++){
      byte[] pair = vertexPairs[j];
      float width1 = calculateLinkWidthFor(hingeWidths[pair[0]], connectionPos[j][0]);
      float width2 = calculateLinkWidthFor(hingeWidths[pair[1]], connectionPos[j][1]);
      links.add(new Link(vertices[pair[0]], vertices[pair[1]], width1, width2, linkCrossbars[j][0], linkCrossbars[j][1]));
    }
  }
  
  float calculateLinkWidthFor(float centerWidth, int position){
    return centerWidth - jointBevelWidth + 2*(position+1)*(jointBevelWidth + hingeWidth + spacing) + 2*(position)*spacing;
  }
  
  UGeometry getGeometry(){
    
    UGeometry geo = new UGeometry();
    
    for (Link link : links){
      geo.add(link.getGeometry());
    }
    links = null;//remove from memory
    for (Joint joint : joints){
      geo.add(joint.getGeometry());
    }
    joints = null;//remove from memory
    
    return geo;
  }
  
  PVector getFixedHingeVertex(){
    return vertices[fixedHingeIndex];
  }
  PVector getCrankVertex(){
    return vertices[crankVertIndex];
  }
  
}
