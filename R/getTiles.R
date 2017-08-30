getTile<-function(lat = -14,long = -52){
  tiles=genTile(tileSize = 10)
   return(tiles[tiles$ymin<=lat&tiles$ymax>=lat & tiles$xmin<=long&tiles$xmax>=long,])
}



getTiles<-function(latA,longA,latB,longB,latC,longC, query=T){
  return = NULL
  if(latA<latC|longA>longB){
    stop('Error: Informed coordinate does not form a valid geometry')
  }
  if(latA< -90|latA>90 | latB< -90|latB>90 | latC< -90|latC>90){
    stop('Error: Invalid latitude')
  }
  if(longA< -180|longA>180 | longB< -180|longB>180 | longC< -180|longC>180){
    stop('Error: Invalid longitude')
  }
  a=getTile(latA,longA)
  b=getTile(latB,longB)
  c=getTile(latC,longC)
  for(v in a$iv[1]:c$iv[length(c$iv)]){
    for(h in a$ih[1]:b$ih[length(b$ih)]){

      if(v<10){
        resv=paste('0',v,sep = '')
      }else{
        resv=v
      }
      if(h<10){
        resh=paste('0',h,sep = '')
      }else{
        resh=h
      }
      res=paste('h',resh,'v',resv,sep='')
      if(is.null(return)){
        return = res
      }else{
        return = paste(return,res,sep = '|')
      }

    }
  }
  return(return)
}


