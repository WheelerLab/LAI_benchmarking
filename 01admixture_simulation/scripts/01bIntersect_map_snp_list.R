##take the intersection of a genetic map and a vcf
##output the list of snps as well as a truncated genetic map

suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(data.table)))
suppressWarnings(suppressMessages(library(argparse)))

parser <- ArgumentParser()
parser$add_argument("--snps", help="snp list from vcf file")
parser$add_argument("--map", help="genetic map file")
parser$add_argument("--out", help="As in plink - out path and output prefix")
args <- parser$parse_args()

"%&%" = function(a,b) paste(a,b,sep="")

map<-as.data.frame(fread(args$map, header = F))
snps<-as.data.frame(fread(args$snps, header = F))
#str(snps)
#str(map)
intersection<-inner_join(map,snps,by="V1")
#str(intersection)
fwrite(intersection, args$out %&% "_genetic_map_intersection.txt", col.names = F, row.names = F,quote = F,sep=' ')
#str(snps)
new_list<-select(intersection,V1) %>% as.data.frame()
fwrite(new_list, args$out %&% "_snp_list_intersection.txt", col.names = F, row.names = F,quote = F,sep=' ')
