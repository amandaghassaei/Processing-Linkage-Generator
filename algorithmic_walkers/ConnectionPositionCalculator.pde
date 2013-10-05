//connectionPositionCalculator - calculates the 3d geometry of linkage

class ConnectionPositionCalculator{
  
  int[][] connectionPositions = {//{index of vertex1, index of vertex2, 
      {0,0},
      {1,1},
      {1,1},
      {1,0},
      {1,0},
      {1,0},
      {0,0},
      {1,1},
      {0,0},
      {2,0}
  };
    
  ArrayList<IntList> allConnectingVertices;
  byte[] numConnections;
  ArrayList<IntList> threeBarList;
  
  ConnectionPositionCalculator(ArrayList<IntList> _allConnectingVertices, byte[] _numConnections, ArrayList<IntList> _threeBarList){
    
    allConnectingVertices = _allConnectingVertices;
    numConnections = _numConnections;
    threeBarList = _threeBarList;
    
    ArrayList<boolean[]> availablePositions = initAvailablePositions();
    IntList narrowestPath = findShortestPathFromFootToCrank();//the shortest path from the foot to the crank will be the narrowest
    int[][] allPositions = new int[vertexPairs.length][2];
    
    for (int i=0;i<allPositions.length;i++){
      for (int j=0;j<2;j++){
        allPositions[i][j] = -1;//initialize all values of allPositions as something non-sensical
      }
    }
    
    setPositionOfNarrowPath(narrowestPath, allPositions, availablePositions);
    assignPositionsAroundVertex(crankVertIndex, allPositions, availablePositions);
    
    
    for (int[] pair : allPositions){
      for (int vert : pair){
        print(vert);
        print("  ");
      }
      println("");
    }
  }
  
  void assignPositionsAroundVertex(byte centerVertex, int[][] allPositions, ArrayList<boolean[]> availablePositions){
    
    IntList availableCenterPositions = getAvailablePositions(availablePositions.get(centerVertex));
    ArrayList<IntList> availableConnectingPositions = new ArrayList<IntList>();
    IntList connectingVertices = new IntList();
    
    for (int vertex : allConnectingVertices.get(centerVertex)){//for all vertices around centerVertex
      if (!pairHasBeenSet(centerVertex, vertex, allPositions)){//if the positions haven't already been set
        connectingVertices.append(vertex);
        availableConnectingPositions.add(getAvailablePositions(availablePositions.get(vertex)));        
      }
    }
    
    int[][] connectingPositions = findBestPositionMatches(availableCenterPositions, centerVertex, availableConnectingPositions, connectingVertices);
    assignConnectingPositions(connectingPositions, centerVertex, connectingVertices, allPositions, availablePositions);
    
  }
  
  void assignConnectingPositions(int[][] finalConnectingPositions, int centerVertex, IntList connectingVertices, int[][] allPositions, ArrayList<boolean[]> availablePositions){
    
    for (int i=0;i<finalConnectingPositions.length;i++){
      int[] linkPositions = finalConnectingPositions[i];
      addLinkEndAtPosition(centerVertex, connectingVertices.get(i), linkPositions[0], allPositions, availablePositions);
      addLinkEndAtPosition(connectingVertices.get(i), centerVertex, linkPositions[1], allPositions, availablePositions);
    }
  }
  
  int[][] findBestPositionMatches(IntList availableCenterPositions, int centerVertex, ArrayList<IntList> availableConnectingPositions, IntList connectingVertices){
    
    int[][] finalConnectingPositions = new int[connectingVertices.size()][2];//[position of centerVertex, position of vertex]
    
    if (involvesThreeBarLinkage(centerVertex)){
      println("warning - need to deal with three bar linkage");
      exit();
    } else {
      if (availableCenterPositions.size() == 1){
        for (int i=0;i<availableConnectingPositions.size();i++){
          
          IntList vertexConnectingPositions = availableConnectingPositions.get(i);
          int centerVertPosition = availableCenterPositions.get(0);
          
          finalConnectingPositions[i][0] = centerVertPosition;
          if (vertexConnectingPositions.hasValue(centerVertPosition)){
            finalConnectingPositions[i][1] = centerVertPosition;
          } else {
            finalConnectingPositions[i][1] = findBestConnectionSolution(vertexConnectingPositions, centerVertPosition);
          }
        }
      } else {
        println("need to finish this");
        for (int centerPosition : availableCenterPositions){
          
          
          
          
        }
      }
    }
    return finalConnectingPositions;
  }
  
  int findBestConnectionSolution(IntList availableConnections, int centerPos){
    
    int i=0;
    while(i>=0){
      for (int position : availableConnections){
        if ((position-centerPos) == i){
          return position;
        }
        if ((position-centerPos) == -i){
          return position;
        }
      }
      i++;
    }
    println("warning - no best connection");
    exit();
    return i;
  }
  
  IntList removeFromList(int numberToRemove, IntList list){
    
    IntList newList = new IntList();
    for (int number : list){
      if (number == numberToRemove){
        newList.append(number);
      }
    }
    return newList;
  }
  
  boolean involvesThreeBarLinkage(int vertex){
    
    for (IntList threeBarLinkage : threeBarList){
      if (threeBarLinkage.hasValue(vertex)){
        return true;
      }
    }
    return false;
  }
  
  IntList getAvailablePositions(boolean[] positions){
    
    IntList availablePositions = new IntList();
    for (int i=0;i<positions.length;i++){
      if (positions[i]){
        availablePositions.append(i);
      }
    }
    
    return availablePositions;
  }
  
  int getLowestAvailablePosition(boolean[] positions){
    
    for (int i=0;i<positions.length;i++){
      if (positions[i]){
        return i;
      }
    }
    
    println("warning - no positions available");
    return -1;//something has gone wrong, return something non-sensical
  }
  
  boolean pairHasBeenSet(int end1, int end2, int[][] allPositions){
    
    int[] indices1 = findIndicesOfVertexInPair(end1, end2);
    int[] indices2 = findIndicesOfVertexInPair(end2, end1);
    
    if (allPositions[indices1[0]][indices1[1]] >= 0 && allPositions[indices2[0]][indices2[1]] >= 0){
      return true;
    } else if (allPositions[indices1[0]][indices1[1]] < 0 && allPositions[indices2[0]][indices2[1]] < 0){
      return false;
    }
    
    //else - one is assigned and the other isnt
    return false;
  }
  
  void setPositionOfNarrowPath(IntList narrowestPath, int[][] allPositions, ArrayList<boolean[]> availablePositions){
    
    int alternatingPosition = 0;
    for (int i=0;i<narrowestPath.size()-1;i++){
      addLinkEndAtPosition(narrowestPath.get(i), narrowestPath.get(i+1), alternatingPosition, allPositions, availablePositions);
      addLinkEndAtPosition(narrowestPath.get(i+1), narrowestPath.get(i), alternatingPosition, allPositions, availablePositions);
      alternatingPosition = abs(alternatingPosition-1);//toggle position between 0 and 1
    }
    
  }
  
  void addLinkEndAtPosition(int end, int pairEnd, int position, int[][] allPositions, ArrayList<boolean[]> availablePositions){
    
    int[] indices = findIndicesOfVertexInPair(end, pairEnd);
    allPositions[indices[0]][indices[1]] = position;
    availablePositions.get(end)[position] = false;//position is no longer available
  }
  
  int[] findIndicesOfVertexInPair(int end, int pairEnd){//returns index of end one in pair (end1, end2)
    
    int[] indices = {-1,-1};//start with something nonsensical, in case this test fails
    for (byte i=0;i<vertexPairs.length;i++){
      byte[] pair = vertexPairs[i];
      for (byte j=0;j<pair.length;j++){
        if (pair[j] == end && pair[abs(j-1)] == pairEnd){//if there is a match
          indices[0] = i;
          indices[1] = j;
          return indices;
        }
      }
    }
    
    println("warning: there has been a problem locating a vertexPair");
    return indices;//return something non-sensical
  }
  
  ArrayList initAvailablePositions(){//initialize an array of booleans for each vertex with size numConnections, initialize all as true
    
    ArrayList<boolean[]> availablePositions = new ArrayList<boolean[]>();
    for (byte numConnectionsAtVertex : numConnections){
      boolean[] positionsAtVertex = new boolean[numConnectionsAtVertex];
      for (int i=0;i<positionsAtVertex.length;i++){
        positionsAtVertex[i] = true;//initialize all positions as true - none have been claimed yet
      }
      availablePositions.add(positionsAtVertex);
    }
    
    return availablePositions;
  }
  
  IntList findShortestPathFromFootToCrank(){
        
    ArrayList<IntList> shortestPaths = new ArrayList<IntList>();
    ArrayList<IntList> allPaths = findAllUniquePaths();
    int shortestPathSize = 500;//nonsense placeholder to start
    
    for (IntList path : allPaths){//find size of shortest path(s)
      if (path.size()<shortestPathSize){
        shortestPathSize = path.size();
      }
    }
    for (IntList path : allPaths){//add shortest paths to shortestPaths
      if (path.size()==shortestPathSize){
        shortestPaths.add(path);
      }
    }
    if (shortestPaths.size()>1){
      println("warning: there are multiple short paths");
    }
    
    return shortestPaths.get(0);
  }
  
  ArrayList<IntList> findAllUniquePaths(){
    
    ArrayList<IntList> allPaths = new ArrayList<IntList>();
    
    IntList path = new IntList();
    path.append(footVertIndex);//start at foot
    calculatePath(footVertIndex, path, allPaths);
    
    return allPaths;
  }
  
  void calculatePath(int lastVert, IntList path, ArrayList<IntList> allPaths){
    
    for (int vertex : allConnectingVertices.get(lastVert)){
      if (!path.hasValue(vertex)){//we don't want to loop back tot he same vertex multiple times
        path.append(vertex);
        if (vertex == crankVertIndex){//end at crank
          allPaths.add(path.copy());
        } else {
          calculatePath(vertex, path, allPaths);
        }
      } else{
        path.append(vertex);//this will be removed immediately - need this line to keep path.size() consistent
      }
      path.remove(path.size()-1);
    }
    return;
  }
}
