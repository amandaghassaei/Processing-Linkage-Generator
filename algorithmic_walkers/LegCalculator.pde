//leg calculator class - calculates geometry of leg from basic info

class LegCalculator{
  
  ArrayList<IntList> threeBars;
  byte[] numConnections;//number of link positions on each joint (three bar linkages share a space)
  ArrayList<IntList> allConnectingVertices;
  boolean[][] linkCrossbars;
  int[][] connectionPos;
  
  LegCalculator(){
    
    allConnectingVertices = new ArrayList<IntList>();
    calculateGeometry();
    
  }
  
  void calculateGeometry(){
    
    byte[] numConnectingLinks = new byte[numVertices];
    
    for (byte i=0;i<numVertices;i++){//get all connections and add them up
      IntList connectingVertices = new IntList();
      numConnectingLinks[i] = 0;//zero all elements of numConnectingVertices to start
      for (byte[] pair : vertexPairs){
        if (pair[0]==i){
          connectingVertices.append(pair[1]);
          numConnectingLinks[i]++;
        } else if (pair[1] == i){
          connectingVertices.append(pair[0]);
          numConnectingLinks[i]++;
        }
      }
      allConnectingVertices.add(connectingVertices);
    }
    
    ThreeBarCalculator threeBarCalculator = new ThreeBarCalculator(allConnectingVertices);
    threeBars = threeBarCalculator.threeBarList;
    
    numConnections = calculateNumConnections(numConnectingLinks, threeBars);//numConections = numConnectingLinks - 1 for each three bar linkage involved
    linkCrossbars = calculateCrossbars();
    
    ConnectionPositionCalculator positionCalculator = new ConnectionPositionCalculator(allConnectingVertices, numConnections, threeBars);
    connectionPos = positionCalculator.connectionPositions;
  }
  
  byte[] calculateNumConnections(byte[] numConnectingLinks, ArrayList<IntList>threeBars){
    
    byte[] numConnections = new byte[numConnectingLinks.length];
    arrayCopy(numConnectingLinks, numConnections);
    for (IntList threeBar : threeBars){
      for (int vertex : threeBar){
        numConnections[vertex]--;
      }
    }
    
    return numConnections;
  }
  
  PVector[] calculateVerticesForAngle(float angle){
    
    //position of vertices
    PVector[] vertices = {//x,y,z
      new PVector(0,0,0),
      new PVector(0,1,1.5),
      new PVector(0,2,-0.5),
      new PVector(0,-0.5,-1),
      new PVector(0,4,0),
      new PVector(0,3,-2.5),
      new PVector(0,0.5,-3.5),
    };
    
    return vertices;
  }
  
  boolean[][] calculateCrossbars(){//check full locomotive cycle for any small angles
  
    boolean[][] linkCrossbars = {
      {true, true},
      {true, true},
      {true, true},
      {true, true},
      {true, true},
      {true, true},
      {true, true},
      {true, true},
      {true, true},
      {true, true}
    };
    
    return linkCrossbars;
  }
  
  float[] calculateHingeWidths(){//fixed hinges are wide, rest are 0
  
    float[] hingeWidths = new float[numVertices];
    for (byte i=0;i<hingeWidths.length;i++){
      if (i==fixedHingeIndex){
        hingeWidths[i] = 2*legWidth;
      } else {
        hingeWidths[i] = 0;
      }
    }
    
    return hingeWidths;
  }
}
