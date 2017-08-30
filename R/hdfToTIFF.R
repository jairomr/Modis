

# Charles Caioni

# Inserindo shapefile

# Amazonia
setwd("/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/PRODUTOS/shapefile")
am <- readOGR(".",layer="panamazonpoly")
proj4string(am) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 ")

# Mato Grosso
setwd("/mnt/data/dados_publicos/Documents/data_geo/shapes/mato_grosso/Limite_municipal_250_10")
mt <- readOGR(".",layer="MT_")
np="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 "
mt2= spTransform(mt,np)

# .............................Iniciando o processo de conversao..............................

# Converter de hdf para tiff
pasta.file<-function (pasta,file){
  return (paste(pasta,'/',file,sep = ''))
}

setwd("/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/DADOS_BRUTOS/et006/")
base_dir="/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/DADOS_BRUTOS/et006/"
pasta = dir(pattern = '20*')
library(gdalUtils)

files <- dir(pattern = ".hdf")

gdalinfo("MOD16A2.A2001001.h10v09.006.2017068135746.hdf")

filename<-function(fileName){
  return (paste0("ET.",substr(fileName,01,41), ".tif"))
}

i <- 1
j<-1
for(j in 1:length(pasta)){
  files <- dir(path = pasta[j], pattern = "*.hdf")
  for (i in 1:length(files)){
    sds <- get_subdatasets(pasta.file(pasta[j],files[i]))
    gdal_translate(sds[1], dst_dataset = pasta.file('TIFF',filename(files[i])))
  }
}

########################################################################


setwd("/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/DADOS_BRUTOS/et006/TIFF")

list.files()



# MOSAICAR AS IMAGENS: EVAPOTRANSPIRAÃAO 

mosaicGTiffs = function(proj.loc, gtiffs, mosaicName, overwrite){ 
  if("gdalUtils" %in% rownames(installed.packages()) == FALSE){ # checks if gdalutils is installed 
    install.packages("gdalUtils", repos="http://r-forge.r-project.org")
    require(gdalUtils)
  }
  suppressWarnings(dir.create(paste(proj.loc,"Mosaicked",sep="/"))) # creates a directory to store mosaicked file
  gdalwarp(gtiffs, paste(proj.loc,"/","Mosaicked","/",mosaicName,".tif",sep=""),overwrite = overwrite)
}


################################


setwd("/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/DADOS_BRUTOS/et006/TIFF")


ls.files = Sys.glob("*.tif");ls.files

ano = unique(substr(ls.files, 13, 16));ano
dia = unique(substr(ls.files, 17, 19));dia

for (a in 1:length(ano))
{
  ls.files_a = ls.files[substr(ls.files, 13, 16) == ano[a]]
  print(ano[a])
  for (m in 1:length(dia))
  {
    ls.files_m = ls.files_a[substr(ls.files_a, 17, 19) == dia[m]]
    print(dia[m])
    
    # try it out
    # load variables
    proj.loc = "/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/DADOS_BRUTOS/et006/TIFF"
    # gtiffs2 = list.files("/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/DADOS_BRUTOS/evapotranspiraÃÂ§ao_MOD16/MOD16A2",pattern = "*.tif", full.names = T) # list the files
    myMosaic = paste0("ET.",ano[a],'',dia[m]) # the name of the final Mosaicked_ET GeoTIFF
    
    #myMosaic = paste0("ET.AS.D",dia[m],'',ano[a]) # the name of the final Mosaicked_ET GeoTIFF
    
    
        # execute
    mosaicGTiffs(proj.loc = proj.loc, gtiffs = ls.files_m, mosaicName = myMosaic, overwrite = T)
    rm(proj.loc,gtiffs2,myMosaic) # remove variables to save memory
    list.files()
    
  }
}


# Stack ds imagens e excluindo valores diferentes de 0 a 65528 

setwd("/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/DADOS_BRUTOS/et006/TIFF/Mosaicked")
x01=list.files(,pattern="ET.20");x01
LE=stack(x01)
names(LE)


aday=substr(names(LE),04,10);aday
adata=as.Date(strptime(aday,format= "%Y%j"))
LE2 <- setZ(LE, adata, 'time')

month <- function(x)as.numeric(format(x, '%m'))
LEm <- zApply(LE2, by=as.yearmon, fun=sum,na.rm=TRUE, name='time')

#plot(LEm[[1]])



#ff<- function(x) { x[x>= 7000] <- NA; return(x) }

ff<- function(x) { x[x<= -32767  | x>= 32760] <- NA; return(x) }


mystack2=calc(LEm,fun=ff)

# Aplicando o fator de conversao

ET_real=mystack2*0.1

new_proj="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
ET_real_proj <- projectRaster(ET_real, crs=new_proj)

ET_real_mask=mask(crop(ET_real_proj,mt),mt)

plot(ET_real_mask)

#salvados os dados cortados e cornvertidos
setwd("/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/DADOS_BRUTOS/MOD_ET/ET_v006")
writeRaster(ET_real_crop, filename="ET_v006_MT", options="INTERLEAVE=BAND", overwrite=TRUE)



