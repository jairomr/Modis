library(rvest) 
library(curl) 
library(dplyr) 
library(xml2) 
library(httr) 
library(stringr) 
library(methods) 
setwd("/mnt/data/dados_publicos/Documents/MODIS_local/AMAZONIA/DADOS_BRUTOS/et006")
if (!require("pacman")) #install.packages("pacman")
  pacman::p_load(dplyr, xml2, rvest, httr, stringr, methods)

# url do ftp que contÃ©m as cenas
path_root <- "http://e4ftl01.cr.usgs.gov/MOLT/MOD16A2.006"

# carrega a raiz do ftp
page_root <- read_html(path_root)

# extrai os dias das cenas
scene_days_ <- page_root %>% 
  html_nodes("a") %>% 
  html_text(trim = T) %>%
  '['(-c(1:7)) %>%
  str_replace_all("\\/", "")

glimpse(scene_days_)


scene_days_
scene_days=scene_days_[411:751]


# inicio do 1Ã‚Âº loop - dias
for (i in seq_along(scene_days)) {
  # cria a pasta para receber os tiles
  if(!dir.exists(scene_days[i])) {
    dir.create(scene_days[i])

  }
  

  day <- scene_days[i]
  
  # carrega a pagina do dia da cena
  if(!file.exists(paste(day,'/',day,'.html',sep = ''))){
    page_tiles <- read_html(paste(path_root, day, sep = "/"))
    write_html(page_tiles,paste(day,'/',day,'.html',sep = ''))
  }else{
    page_tiles<-read_html(paste(day,'/',day,'.html',sep = ''))
  }

  path_tiles <- page_tiles %>% 
    html_nodes("a") %>% 
    html_text(trim = T) %>%
    '['(str_detect(., "[hdf]$")) %>% 
    '['(str_detect(., "h10v08|h11v10|h12v10|h13v10|h10v09|h11v09|h12v09|h13v09|h11v08|h12v08|h13v08|h10v10"))
  
  # inicio do 2Ã‚Âº loop - tiles
  for (j in seq_along(path_tiles)) {
    # url do tile
    path_tile <- paste(path_root, day, path_tiles[j], sep = "/")
    
    # id do tile
    tile <- paste(day, path_tiles[j], sep = "/")
    
    # download do arquivo
    if (!file.exists(tile)) {

      cat(tile,'\n')
      temp <- GET(path_tile, authenticate("Caioni1", "Caioni1/02/12/1991"))
      writeBin(content(temp, "raw"), tile)
      rm(temp)

    }
  }
}



## End(Not run)



