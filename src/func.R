# 安装所需的包

install.packages("plotrix")
install.packages("ggplot2")

# 加载所需的包

library(ggplot2)
library(RColorBrewer)
library(plotrix)

# 加载数据

data <- read.table("cache/position.csv", header = T, sep = " ")

colnames(data) <- c(  # 给col命名
  "positionId", "city",
  "industryField", "companyShortName", "companySize",
  "financeStage", "education",
  "positionName", "salary", "requirement"
)

education <- data$education
education <- data.frame(table(education))

education.qualifications <- as.factor(education$education)
myLabel <- paste(education.qualifications, " (", round(education$Freq / sum(education$Freq) * 100, 2), "%)", sep = "") 

par(family='STXihei')  # 防止 Mac 下中文显示乱码 
# 由于占比过小，使用 pie 会挤在一起，所以使用 pie3D
pie3D(
  x = education$Freq, labels = myLabel,
  radius = 0.8,
  height = 0.1,
  border = "white", col = brewer.pal(5, "Set1"),
  labelcex = 0.85,
  main = "企业对学历的要求"
)










