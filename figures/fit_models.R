library(data.table)
library(ggplot2)
library(lubridate)
library(viridis)

benchmarks<-fread("~/data/Local_ancestry_project/ASW_simulations/bench/benches.txt", header = T)
benchmarks<-benchmarks[complete.cases(benchmarks),]

time<-benchmarks[metric=="time"]
time$new_time <- as.numeric(ms(time$value, roll = T))
for(run in 1:nrow(time)){
  if(is.na(time[run, 5])){
    time[run, 5] <- as.numeric(hms(as.character(time[run, 4]))) #if in HMS format
  }
}
time$hours<-time$new_time / 3600

mem<-benchmarks[metric=="mem"]
mem$Gb <- as.numeric(mem$value) / 1000000 #to MB

mem$title<-"Memory Usage with Respect to Sample Size"
mem_plot<-ggplot(data=mem,aes(x=n, y = Gb))
setEPS()
postscript("~/data/Local_ancestry_project/ASW_simulations/bench/mem_Gb.eps")
mem_plot + geom_point(aes(color = software),size=3) + 
  geom_line(aes(color = software),size=1.2) + 
  labs(x = "n individuals", y = "run mememory (Gb)") +
  theme_bw(20) +
  facet_wrap(~title) +
  theme(text = element_text(size = 15)) + 
  scale_color_viridis(option = "inferno",discrete=T,begin = 0.1, end = 0.9)
dev.off()

time$title<-"Runtime with Respect to Sample Size"
time_plot<-ggplot(data=time,aes(x=n, y = hours))
setEPS()
postscript("~/data/Local_ancestry_project/ASW_simulations/bench/time.eps")
time_plot + geom_point(aes(color = software),size=3) + 
  geom_line(aes(color = software),size=1.2) + 
  labs(x = "n individuals", y = "runtime (hr)") +
  facet_wrap(~title) +
  theme_bw(20) +
  theme(text = element_text(size = 15)) + 
  scale_color_viridis(option = "inferno", begin = 0.1, end = 0.9,discrete = T)
dev.off()
#plot(rf_quadratic_model)

rf_time<-time[software =="rfmix",]
lamp_time<-time[software =="lampld",]
elai_time<-time[software =="elai",]
mosaic_time<-time[software =="mosaic",]
loter_time<-time[software =="loter",]

rf_linear_model<-lm(new_time~n,rf_time)
rf_quadratic_model<-lm(new_time~I(n^2),rf_time)
summary(rf_linear_model)$r.squared
summary(rf_quadratic_model)$r.squared

lampld_linear_model<-lm(new_time~n,lamp_time)
lampld_quadratic_model<-lm(new_time~I(n^2),lamp_time)
summary(lampld_linear_model)$r.squared
summary(lampld_quadratic_model)

elai_linear_model<-lm(new_time~n,elai_time)
elai_quadratic_model<-lm(new_time~I(n^2),elai_time)
summary(elai_linear_model)
summary(elai_quadratic_model)

mosaic_linear_model<-lm(new_time~n,mosaic_time)
mosaic_quadratic_model<-lm(new_time~I(n^2),mosaic_time)
summary(mosaic_linear_model)
summary(mosaic_quadratic_model)

loter_linear_model<-lm(new_time~n,loter_time)
loter_quadratic_model<-lm(new_time~I(n^2),loter_time)
summary(loter_linear_model)
summary(loter_quadratic_model)

rf_mem<-mem[software =="rfmix",]
lamp_mem<-mem[software =="lampld",]
elai_mem<-mem[software =="elai",]
mosaic_mem<-mem[software =="mosaic",]
loter_mem<-mem[software =="loter",]

rf_linear_model<-lm(Gb~n,rf_mem)
rf_quadratic_model<-lm(Gb~I(n^2),rf_mem)
summary(rf_linear_model)
summary(rf_quadratic_model)

lampld_linear_model<-lm(Gb~n,lamp_mem)
lampld_quadratic_model<-lm(Gb~I(n^2),lamp_mem)
summary(lampld_linear_model)
summary(lampld_quadratic_model)

elai_linear_model<-lm(Gb~n,elai_mem)
elai_quadratic_model<-lm(Gb~I(n^2),elai_mem)
summary(elai_linear_model)
summary(elai_quadratic_model)

mosaic_linear_model<-lm(Gb~n,mosaic_mem)
mosaic_quadratic_model<-lm(Gb~I(n^2),mosaic_mem)
summary(mosaic_linear_model)
summary(mosaic_quadratic_model)

loter_linear_model<-lm(Gb~n,loter_mem)
loter_quadratic_model<-lm(Gb~I(n^2),loter_mem)
summary(loter_linear_model)
summary(loter_quadratic_model)