kanal=read.csv("kanal.csv", sep=";")
kanal2=read.csv("kanal2.csv", sep=";")
kanal$ident=paste0(kanal$id, kanal$kanal)
#kanal ajakulu
ajakulu=kanal2[,c("id","kanal", "ajakulu")]
ajakulu=ajakulu[!duplicated(ajakulu),]
ajakulu$ident=paste0(ajakulu$id, ajakulu$kanal)
#hind
hind=kanal2[,c("id","kanal", "hind")]
hind=hind[!duplicated(hind),]
hind$ident=paste0(hind$id, hind$kanal)

#osut arv
osutarv=kanal2[,c("id","kanal", "osutamistearv")]
osutarv=osutarv[!duplicated(osutarv),]
osutarv$ident=paste0(osutarv$id, osutarv$kanal)

#rahulolu
rahulolu=kanal2[,c("id","kanal", "rahulolu")]
rahulolu=rahulolu[!duplicated(rahulolu),]
rahulolu$ident=paste0(rahulolu$id, rahulolu$kanal)

#keevitame algsesse tabelisse
proov=merge(kanal, ajakulu, by="ident", all.x = T, all.y = F)
proov$ajakulu.x=NULL
proov$id.y=NULL
proov$kanal.y=NULL

proov=merge(proov, hind, by="ident", all.x = T, all.y = F)
proov$hind.x=NULL
proov$id.y=NULL
proov$kanal.y=NULL
proov=merge(proov, osutarv, by="ident", all.x = T, all.y = F)
proov$hind.x=NULL
proov$id.y=NULL
proov$kanal.y=NULL
proov=merge(proov, rahulolu, by="ident", all.x = T, all.y = F)

#jätame vajaliku alles
kanalPuhas=proov[,c("id.x", "link", "kanal.x", "ajakulu.y", "hind.y","osutamistearv.y","rahulolu.y")]

#eemaldame duplikaadid
proov=kanalPuhas[!duplicated(kanalPuhas[,c("id.x","link","kanal.x")]),]
#write
write.table(proov, "kanal.csv",sep=";", row.names = F)

#checkime kas kõik on ka teenuste tabelis olemas
kanaliID=unique(proov$id.x)

#teenus
teenus=read.csv("teenus.csv", sep=";")
teenusID=unique(teenus$id)
#mida kanalis pole
(new <- kanaliID[which(!kanaliID %in% teenusID)])
#mida teenuses pole
(new <- teenusID[which(!teenusID %in% kanaliID)])
#õigusaktide puhul ka kontroll
regualtsioon=read.csv("teenus_has_regulatsioon.csv",sep=";")
regulID=unique(regualtsioon$id)
(new <- regulID[which(!regulID %in% teenusID)])
