###Download Data Open Street Map (OSM) dan Intersect dengan Batas Administrasi

##Package
library(RCurl)
library(sf)
library(dplyr)
library(tidyverse)

##URL Link Download Data OSM
file_base = "http://download.geofabrik.de/asia/indonesia/java-latest-free.shp.zip"

##Set Tanggal Download Data
tanggal=format(Sys.Date()-1,format="%d%m%Y")

##Membuat Directory Penyimpanan Data OSM Hasil Download
dir=dir.create(paste0("D:/Data_OSM/OSM_Jawa/OSM_Jawa_",tanggal))

##Download Data OSM
#Data OSM yang di Download Merupakan Data Pulau Jawa
{
#Download Data
download.file(url = file_base, 
              destfile = paste0("D:/Data_OSM/OSM_Jawa/OSM_Jawa_",tanggal,"/",
                                substr(file_base, 45, nchar(file_base)-8),"_",tanggal,".zip"), 
              method = "curl")
#Unzip File Hasil Download
unzip(zipfile=paste0("D:/Data_OSM/OSM_Jawa/OSM_Jawa_",tanggal,"/",
                     substr(file_base, 45, nchar(file_base)-8),"_",tanggal,".zip"),
      exdir=paste0("D:/Data_OSM/OSM_Jawa/OSM_Jawa_",tanggal))
}

##Intersect Data untuk Format Data Point dan Clip Data untuk Format Data Polygon
#File Directory Hasil Unzip Data OSM yang Telah di Download
file_dir = list.files(path = paste0("D:/Data_OSM/OSM_Jawa/OSM_Jawa_",tanggal), full.names = TRUE, pattern = "shp")
#Apabila Data Memiliki Format Point, Maka Dilakukan Intersect dengan Batas Administrasi Kelurahan/Desa untuk Menambahkan Informasi Batas Administrasi Kelurahan/Desa
#APabila Data Memiliki Format Poligon, Maka Dilakukan Clip untuk Mengambil Data di WIlayah Jawa Barat
for(file in file_dir) {
  dataku=st_sf(st_read(file))
  class_dataku=class(dataku$geometry)[1]
  type="sfc_POINT"
  if (class_dataku == type){
    keldes_jabar=st_sf(st_read("F:/JDS - SATU PETA/ADMINISTRASI_KELDESA_AR_25K_BIG/ADMINISTRASI_KELDESA_AR_25K_BIG.shp"))
    sf::sf_use_s2(FALSE)
    out=st_join(dataku,keldes_jabar)%>%filter(!is.na(WADMKD))
    names<-substr(file, 40, nchar(file_dir)-4)
    tanggal=format(Sys.Date(),format="%d%m%Y")
    #dir=dir.create(paste0("D:/Data_OSM/OSM_Jabar/OSM_Jabar_",tanggal))
    st_write(out,dsn=paste0("D:/Data_OSM/OSM_Jabar/OSM_Jabar_",tanggal), layer=paste0(names), driver="ESRI Shapefile")
  } else {
    jabar=st_sf(st_read("F:/JDS - SATU PETA/SHP_Batas_Administrasi_Jabar/ADMINISTRASI_PROV_JAWA_BARAT_AR_25K_BIG/ADMINISTRASI_PROV_JAWA_BARAT_AR_25K_BIG.shp"))
    sf::sf_use_s2(FALSE)
    out=st_intersection(jabar,dataku)
    names<-substr(file, 40, nchar(file_dir)-4)
    tanggal=format(Sys.Date(),format="%d%m%Y")
    st_write(out,dsn=paste0("D:/Data_OSM/OSM_Jabar/OSM_Jabar_",tanggal), layer=paste0(names), driver="ESRI Shapefile")
  }
} 
