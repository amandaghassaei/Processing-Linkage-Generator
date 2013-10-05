//ThreeBarCalculator - calculates the locations of the three bar linkages in the mechanism

class ThreeBarCalculator{
  
  ArrayList<IntList> threeBarList;
  
  ThreeBarCalculator(ArrayList<IntList> allConnectingVertices){
    
    threeBarList = new ArrayList<IntList>();
    for (byte i=0;i<numVertices;i++){
      IntList list1 = allConnectingVertices.get(i);
      for (int j : list1){
        IntList list2 = allConnectingVertices.get(j);
        IntList matches = findMatchesBetweenLists(list1,list2);
        if (matches.size()>0){
          threeBarList = addMatchToList(i, j, matches, threeBarList);
        }
      }
    }
  }
  
  ArrayList addMatchToList(int vert1, int vert2, IntList matches, ArrayList<IntList> threeBarList){

    if (threeBarList.size()==0){
      threeBarList.add(newThreeBarLink(vert1, vert2, matches.get(0)));
    }
    for (int match : matches){//check if this 3 bar link is already contained in the list
      if (!matchAlreadyInList(vert1, vert2, match, threeBarList)){
        threeBarList.add(newThreeBarLink(vert1, vert2, match));
      }
    }
    
    return threeBarList;
  }
  
  boolean matchAlreadyInList(int vert1, int vert2, int vert3, ArrayList<IntList> threeBarList){
    
    for (IntList threeBarLink : threeBarList){
      if (threeBarLink.hasValue(vert1) && threeBarLink.hasValue(vert2) && threeBarLink.hasValue(vert3)){//not already in list
        return true;
      }
    }
    
    return false;
  }
  
  IntList newThreeBarLink(int vert1, int vert2, int vert3){
    
    IntList threeBarLinkToAdd = new IntList();
    threeBarLinkToAdd.append(vert1);
    threeBarLinkToAdd.append(vert2);
    threeBarLinkToAdd.append(vert3);
    
    return threeBarLinkToAdd;
  }

  IntList findMatchesBetweenLists(IntList list1, IntList list2){
    
    IntList matches = new IntList();
    for (int list1Item : list1){
      for (int list2Item : list2){
        if (list1Item == list2Item){
          matches.append(list1Item);
        }
      }
    }
    
    return matches;
  }
}
