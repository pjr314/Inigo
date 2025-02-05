#################
## Common libraries and functions
#################
#save(list = c("sine_tpm","sine_count","sine_row_meta","sine_col_meta","metaProxC", "tpmProxC", "countProxC"),file = "~/Documents/SalkProjects/ME/ShortLongSingature/raw/combineddata.rda",compress = TRUE)
#load("~/Documents/SalkProjects/ME/ShortLongSingature/raw/combineddata.rda")


metaProxC$Mouse_condition <- as.character(metaProxC$Mouse_condition)
metaProxC[metaProxC$Mouse_condition == "EE","Mouse_condition"] <- "1hr"
metaProxC[metaProxC$Mouse_condition == "5hpA","Mouse_condition"] <- "5hr"
metaProxC[metaProxC$Mouse_condition == "5hpAC","Mouse_condition"] <- "A>C"
metaProxC[metaProxC$Mouse_condition == "5hpAA","Mouse_condition"] <- "A>A"
metaProxC$Mouse_condition <- factor(metaProxC$Mouse_condition, c("HC","1hr","5hr","A>A","A>C"))

#names
Names <- function(x){
  if (!is.vector(x)){
    x <- colnames(x)
  }else{
    x <- as.character(x)
  }
  if(length(grep(".",x[1])) > 0){
    #colnames(x) <- as.vector(do.call("rbind",strsplit(colnames(x),fixed=TRUE,split="."))[,1])
    dotsplit <- strsplit(x,fixed=TRUE,split=".")
    #colnames(x) <- rbind.fill(lapply(x,function(y){as.data.frame(t(dotsplit),stringsAsFactors=FALSE)}))
    tmp <- vector()
    for (i in 1:length(dotsplit)){
      tmp <- c(tmp, dotsplit[[i]][1])
    }
    x <- tmp
  }else{
    scoresplit <- strsplit(x,fixed=TRUE,split="_")
    tmp <- vector()
    for (i in 1:length(scoresplit)){
      tmp <- c(tmp, scoresplit[[i]][1])
    }
  }
    x <- gsub(pattern="X",replacement="Sample_",x=x)
    a <- do.call("rbind",strsplit(x,split="Sample_"))[,2]
    l <- nchar(x) - nchar(gsub(pattern="_",replacement="",x=x))
    nam <- vector()
    for (i in 1:length(a)){
      if (l[i] == 7){
        nam <- c(nam, a[i])
      }else{
        if(add1 == TRUE){
        nam <- c(nam,paste(a[i],"_1",sep=""))
        }else{
          nam <- c(nam,paste(a[i],sep=""))
        }
      }
    }
    return(nam)
}
Meta <- function(x){
  metaProx <- as.data.frame(do.call("rbind",(strsplit(x=colnames(x),split="_"))))
  colnames(metaProx) <- c("date","well","prox","ctip","fos","cond","rep")
  rownames(metaProx) <- colnames(x)
  return(metaProx)
}

### Add QC to Meta (need to fix the code here)

propExp <- function(x,i=1){
  if(sum(is.na(x)) > i){
    sum(!is.na(x))/length(x)
  }else{
    sum(x > i)/length(x)
  }
}
rawExp <- function(x,i=2){
    sum(na.exclude(x) > i)
}
meanNoZero <- function(x,i=0){
  a <- mean(x[x>i])
  if(sum(is.na(x)) > i){
    a <- mean(x[!is.na(x)])
  }else if(sum(x>i) == 0){
    a <- 0
  }
  return(a)
}
varNoZero <- function(x){
  sd(x[x >0])
}
MedNoZero <- function(x){
  median(x[x >0])
}
countExp <- function(x){
  sum(x > 0)
}
scaleME <- function(x){
  return(scale(x)[,1])
}
elbow <- function(x){
  x <- as.vector(scale(x[order(x)]))
  x.1 <- c(0,diff(x))
  elbow <- max(x.1)
  cutoff <- mean(c(x[which(x.1 == elbow)], x[which(x.1 == elbow) -1]))
  return(cutoff)
}
#################
## Processed rdas
#################

#################
## Raw Data
#################
# ####alignment
QCreadcount <- read.table("~/Documents/SalkProjects/ME/WCellActivation_Manuscript/EE_QC_alignment_stats.txt",header=TRUE)
QCreadcount <- QCreadcount[QCreadcount$group == "mouse",]
rownames(QCreadcount) <- do.call("rbind",strsplit(as.character(QCreadcount$sample),split="-",fixed=TRUE))[,1]
keepQC <- rownames(QCreadcount[QCreadcount$aligned > 50000,])

## Exclude a known experimental outlier, < 50000 aligned reads
Expoutlier <- c("nc_ux_ti_A12_141204","nm_ui_ti_G10_141204","nm_ux_ti_F7_141204")
#tmp <- read.table(as.matrix("~/Documents/SalkProjects/BenLacar/PC1_excludes.txt"))
#Expoutlier <- unique(c(Expoutlier,as.character(tmp$V1)))
## Count
#countQC1 <- read.table(as.matrix("~/Documents/gene_count.txt"),header=TRUE,row.names=1,fill=TRUE)
countQC1 <- read.table(as.matrix("~/Desktop/RECOVERED_RSEM_geneSymbol_tpm_141204_allsamples.txt"),header=TRUE,row.names=1)
countQC1 <- countQC1[,keepQC]
countQC2 <- countQC1[,-(match(Expoutlier,colnames(countQC1)))]
countQC <- round(countQC2)
#countQC <- countQC[,na.exclude(match(keptnames,colnames(countQC)))]
## TPM
#tpmQC1 <- read.table(as.matrix("~/Documents/SalkProjects/BenLacar/QC/QCtpm_genesymbol.txt"),header=TRUE,row.names=1)
tpmQC1 <- read.table(as.matrix("~/Documents/SalkProjects/BenLacar/RSEM_geneSymbol_tpm_141204_allsamples.txt"),header=TRUE,row.names=1)
tpmQC <- tpmQC1[,keepQC]
tpmQC <- tpmQC[,-(match(Expoutlier,colnames(tpmQC)))]
tpmQC <- log(tpmQC+1,2)
#tpmQC <- tpmQC[,na.exclude(match(keptnames,colnames(tpmQC)))]
## labels
labelsQC1 <- as.data.frame(do.call(rbind,strsplit(x=colnames(tpmQC1),split='_',fixed=TRUE)))
rownames(labelsQC1) <- do.call("rbind",strsplit(x=colnames(tpmQC1),split=".",fixed=TRUE))[,1]
labelsQC <- labelsQC1[keepQC,]
labelsQC <- labelsQC[-c(match(Expoutlier,rownames(labelsQC))),]

#### ERCCs

####### 07/2015 Homecage Prox1+ Fos Low/Neg, sorted by Baptiste and Jerika, processed by Jerika
#counts
excludes <- c("150629_H4_P_C_N_HC_1") # 150629_H4_P_C_N_HC_1 has almost no genes expressed
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_150629_gene_count.txt"),header=TRUE,row.names=1)
countProx <- round(count.1)
add1 <- FALSE
colnames(countProx) <- Names(countProx)
countProx <- countProx[,-c(which(colnames(countProx) == excludes))]

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_150629_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx <- log(tpm.1+1,2)
add1 <- FALSE
colnames(tpmProx) <- Names(tpmProx)
tpmProx <- tpmProx[,-c(which(colnames(tpmProx) == excludes))]

####### 08/03/2015 Homecage Prox1+ Fos Low/Neg, sorted by Baptiste and Jerika, processed by Jerika
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_150803_gene_count.txt"),header=TRUE,row.names=1)
countProx150803 <- round(count.1)
add1 <- FALSE
colnames(countProx150803) <- Names(countProx150803)
colnames(countProx150803) <- do.call("rbind",strsplit(colnames(countProx150803),".",fixed = TRUE))[,1]


#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_150803_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx150803 <- log(tpm.1+1,2)
add1 <- FALSE
colnames(tpmProx150803) <- colnames(countProx150803)

####### 08/10/2015 Homecage Prox1+ Fos Low/Neg, sorted by Baptiste and Jerika, processed by Jerika
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_150810_gene_count.txt"),header=TRUE,row.names=1)
countProx150810 <- round(count.1)
add1 <- FALSE
colnames(countProx150810) <- Names(countProx150810)
colnames(countProx150810) <- do.call("rbind",strsplit(colnames(countProx150810),".",fixed = TRUE))[,1]

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_150810_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx150810 <- log(tpm.1+1,2)
add1 <- FALSE
colnames(tpmProx150810) <- colnames(countProx150810)


#151207 CA1 Samples
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_151207_gene_count_genename.txt"),header=TRUE,row.names=1)
colnames(count.1)[which(colnames(count.1) == "X151207_A8_N_C_N_EE_2.708.6.CAGAGAG.AGAGTAG_CAGAGAG.AGAGTAG_L006_R1_001_se")] <- "X151207_D8_N_C_N_EE_2.708.6.CAGAGAG.AGAGTAG_CAGAGAG.AGAGTAG_L006_R1_001_se"
countProx1512 <- round(count.1)
add1 <- TRUE
colnames(countProx1512) <- make.names(Names(countProx1512))
colnames(countProx1512) <- do.call("rbind",strsplit(colnames(countProx1512),".",fixed = TRUE))[,1]
#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_151207_gene_tpm_genename.txt"),header=TRUE,row.names=1)
colnames(tpm.1)[which(colnames(tpm.1) == "X151207_A8_N_C_N_EE_2.708.6.CAGAGAG.AGAGTAG_CAGAGAG.AGAGTAG_L006_R1_001_se")] <- "X151207_D8_N_C_N_EE_2.708.6.CAGAGAG.AGAGTAG_CAGAGAG.AGAGTAG_L006_R1_001_se"
tpmProx1512 <- log(tpm.1+1,2)
add1 <- TRUE
colnames(tpmProx1512) <- colnames(countProx1512)

#151214 
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_151214_gene_count_genename.txt"),header=TRUE,row.names=1)
countProx151214 <- round(count.1)
b <- do.call("rbind",strsplit(colnames(count.1)[87:134],"_",fixed=TRUE))
colnames(countProx151214)[87:134] <- paste(b[,1],b[,2],sep="_")
a <- do.call("rbind",strsplit(colnames(countProx151214)[1:86],"_",fixed=TRUE))
colnames(countProx151214)[1:86] <-paste(a[,1],a[,2],a[,3],a[,4],a[,5],a[,6],a[,7],sep="_")

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_151214_gene_tpm_genename.txt"),header=TRUE,row.names=1)
tpmProx151214 <- log(tpm.1+1,2)
colnames(tpmProx151214) <- colnames(countProx151214)#make.names(Names(tpmProx151214))


#160107 
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160107_gene_count.txt"),header=TRUE,row.names=1)
b <- do.call("rbind",strsplit(colnames(count.1),"_",fixed=TRUE))
colnames(count.1) <- paste(b[,1],b[,2],sep="_")
countProx160107 <- round(count.1)

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160107_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx160107 <- log(tpm.1+1,2)
colnames(tpmProx160107) <- colnames(countProx160107)

#160324 
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160324_gene_count.txt"),header=TRUE,row.names=1)
b <- do.call("rbind",strsplit(colnames(count.1),"_",fixed=TRUE))
colnames(count.1) <- paste(b[,1],b[,2],sep="_")
countProx160324 <- round(count.1)

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160324_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx160324 <- log(tpm.1+1,2)
colnames(tpmProx160324) <- colnames(countProx160324)
#######
#160523 
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160523_gene_count.txt"),header=TRUE,row.names=1)
b <- do.call("rbind",strsplit(colnames(count.1),"_",fixed=TRUE))
colnames(count.1) <- paste(b[,1],b[,2],sep="_")
countProx160523 <- round(count.1)

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160523_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx160523 <- log(tpm.1+1,2)
colnames(tpmProx160523) <- colnames(countProx160523)


##########
#160617
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160617_gene_count.txt"),header=TRUE,row.names=1)
b <- do.call("rbind",strsplit(colnames(count.1),"_",fixed=TRUE))
colnames(count.1) <- paste(b[,1],b[,2],sep="_")
countProx160617 <- round(count.1)

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160617_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx160617 <- log(tpm.1+1,2)
colnames(tpmProx160617) <- colnames(countProx160617)

##########
#160707
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160707_gene_count.txt"),header=TRUE,row.names=1)
b <- do.call("rbind",strsplit(colnames(count.1),"_",fixed=TRUE))
colnames(count.1) <- paste(b[,1],b[,2],sep="_")
countProx160707 <- round(count.1)

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_160707_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx160707 <- log(tpm.1+1,2)
colnames(tpmProx160707) <- colnames(countProx160707)

##########
#161121
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_161121_gene_count.txt"),header=TRUE,row.names=1)
b <- do.call("rbind",strsplit(colnames(count.1),"_",fixed=TRUE))
colnames(count.1) <- paste(b[,1],b[,2],sep="_")
countProx161121 <- round(count.1)

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_161121_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx161121 <- log(tpm.1+1,2)
colnames(tpmProx161121) <- colnames(countProx161121)

##########
#161209
#counts
count.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_161209_gene_count.txt"),header=TRUE,row.names=1)
b <- do.call("rbind",strsplit(colnames(count.1),"_",fixed=TRUE))
colnames(count.1) <- paste(b[,1],b[,2],sep="_")
countProx161209 <- round(count.1)

#tpm
tpm.1 <- read.table(as.matrix("~/Documents/SalkProjects/ME/ShortLongSingature/raw/Prox1_161209_gene_tpm.txt"),header=TRUE,row.names=1)
tpmProx161209 <- log(tpm.1+1,2)
colnames(tpmProx161209) <- colnames(countProx161209)


################################

#combine
runs <- 13
a <- table(c(rownames(tpmProx),rownames(tpmQC),rownames(tpmProx150803),rownames(tpmProx150810),rownames(tpmProx1512), rownames(tpmProx151214),rownames(tpmProx160107),rownames(tpmProx160324),rownames(tpmProx160523),rownames(tpmProx160617),rownames(tpmProx160707),rownames(tpmProx161121),rownames(tpmProx161209)))
tpmProxC <- cbind(tpmProx[names(a[a==runs]),],tpmQC[names(a[a==runs]),],tpmProx150803[names(a[a==runs]),],tpmProx150810[names(a[a==runs]),],tpmProx1512[names(a[a==runs]),], tpmProx151214[names(a[a==runs]),],tpmProx160107[names(a[a==runs]),],tpmProx160523[names(a[a==runs]),],tpmProx160324[names(a[a==runs]),],tpmProx160617[names(a[a==runs]),],tpmProx160707[names(a[a==runs]),],tpmProx161121[names(a[a==runs]),],tpmProx161209[names(a[a==runs]),])
colnames(tpmProxC) <- make.names(colnames(tpmProxC))
a <- table(c(rownames(countProx),rownames(countQC),rownames(countProx150803),rownames(countProx150810),rownames(countProx1512), rownames(countProx151214),rownames(countProx160107), rownames(countProx160324),rownames(countProx160523),rownames(countProx160617),rownames(countProx160707),rownames(countProx161121),rownames(countProx161209)))
countProxC <- cbind(countProx[names(a[a==runs]),],countQC[names(a[a==runs]),],countProx150803[names(a[a==runs]),],countProx150810[names(a[a==runs]),],countProx1512[names(a[a==runs]),],countProx151214[names(a[a==runs]),],countProx160107[names(a[a==runs]),], countProx160324[names(a[a==runs]),], countProx160523[names(a[a==runs]),], countProx160617[names(a[a==runs]),], countProx160707[names(a[a==runs]),],countProx161121[names(a[a==runs]),],countProx161209[names(a[a==runs]),])
colnames(countProxC) <- make.names(colnames(countProxC))


#Hold off on this until metaProxC is updated on the original file
metaProxC <- read.table("~/Documents/SalkProjects/ME/ShortLongSingature/raw/snRNAseqSampleIDFile3.txt",header=TRUE)
#metaProxC$Sample_ID <- make.names(metaProxC$Sample_ID)
#rownames(metaProxC) <- metaProxC$Sample_ID
metaProxC$outliers <- ifelse(test = metaProxC$alignable > 100000 & metaProxC$Smartseq2_RT_enzyme_used == "ProtoscriptII",yes = "in",no = "out")
#########
# outliers
samples <- rownames(metaProxC[ metaProxC$alignable <  100000 ,])
samples <- samples[-grep("NA",samples)]
g <- apply(tpmProxC,2,rawExp,1)
samples <- unique(c(samples,names(g[g < 4000])))
samples <- unique(c(samples,rownames(metaProxC[ metaProxC$Smartseq2_RT_enzyme_used != "ProtoscriptII" ,])))
samples <- samples[!is.na(samples)]
metaProxC$outliers <- "in"
metaProxC[samples,"outliers"] <- "out"

table(metaProxC$outliers, metaProxC$Mouse_condition)
#########
# Load SINE data
#########
sine_count <- read.table(as.matrix("~/Documents/SalkProjects/ME/SINE/sine_raw/Prox1_rodrep_count2.txt"))
sine_col_meta <- read.table(as.matrix("~/Documents/SalkProjects/ME/SINE/sine_raw/Prox1_meta2.txt"))
sine_col_meta <- data.frame(sample = rep(as.character(sine_col_meta[,1]),each=3), value = c("all_elements","avg_start_pos","tso_elements"))
sine_row_meta <- read.table(as.matrix("~/Documents/SalkProjects/ME/SINE/sine_raw/Prox1_rowmeta.txt"))

a <- make.names(do.call("rbind",strsplit(as.character(sine_col_meta$sample),"-"))[,1])
b <- match(a, rownames(metaProxC))
a2 <- a[is.na(b)]
x150629 <- do.call("rbind",strsplit(a2[grep("150629",a2)],"_1"))[,1]
a2[grep("150629",a2)] <- x150629
x151214 <- do.call("rbind",strsplit(a2[grep("151214",a2)],"_3_"))[,1]
a2[grep("151214",a2)] <- x151214
x160107 <- do.call("rbind",strsplit(a2[grep("160107",a2)],"_S"))[,1]
a2[grep("160107",a2)] <- x160107
x160118 <- do.call("rbind",strsplit(a2[grep("160118",a2)],"_S"))[,1]
a2[grep("160118",a2)] <- x160118
x160324 <- do.call("rbind",strsplit(a2[grep("160324",a2)],"_S"))[,1]
a2[grep("160324",a2)] <- x160324
x151221 <- do.call("rbind",strsplit(a2[grep("151221",a2)],"_S"))[,1]
a2[grep("151221",a2)] <- x151221

a[is.na(b)] <- a2

sine_col_meta <- cbind(sine_col_meta,metaProxC[a,])

sine_tpm <- matrix(0,nrow = nrow(sine_count),ncol = ncol(sine_count))
for(i in 1:ncol(sine_count)){
  num <- sine_count[,i] / sine_row_meta$V2
  den <- sum(sine_count[,i] / sine_row_meta$V2)
  sine_tpm[,i] <- 1e06 * num / den
}

sine_tpm <- log(sine_tpm+1,2)
