library(ggplot2)
library(RColorBrewer)
library(plotrix)
library(dplyr)
library(stringr)
library(sqldf)

# 学历的分布
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
  main = "数据挖掘对学历的要求"
)

# 城市的分布
count.city <- data$city
count.city <- data.frame(table(count.city))
names(count.city) <- c("City", "Freq")
count.city <- count.city[order(count.city$Freq, decreasing = T),]
# 第 7 位开始的城市都归为其他
tmp <- count.city[7:dim(count.city)[1],]
count.city <- count.city[1:6,]
count.city <- rbind(count.city, data.frame(
  City = "其他",
  Freq = sum(tmp$Freq)
))
label.percent <- paste(round(count.city$Freq / sum(count.city$Freq) * 100, 2), "%", sep = " ")
# R 做饼图不够美观，于是在 Mac 下使用 Number 做了
pie(
  x = count.city$Freq,
  labels = label.percent,
  col = brewer.pal(7, "Set3"),
  main = "「数据挖掘」- 城市分布"
  )
legend(x = , y = ,"topleft", as.character(count.city$City), cex=0.8, fill = brewer.pal(7, "Set3"))

# 公司财务状况的分布
company.finance <- data$financeStage
company.finance <- data.frame(table(company.finance))
names(company.finance) <- c("Finance", "Freq")
company.finance <- company.finance[order(company.finance$Freq, decreasing = T),]


# 行业的分布
fields <- paste(data$industryField, collapse = ",")
fields <- str_replace_all(fields, "、",",")
fields <- str_replace_all(fields, " ","")
fields <- strsplit(fields, ",")
fields <- fields[[1]]
fields <- as.factor(fields)
fields <- data.frame(table(fields))
fields <- fields[order(fields$Freq, decreasing = T),]

# 城市分布
popular.city <- data$city
popular.city <- data.frame(table(popular.city))
popular.city <- popular.city[order(popular.city$Freq, decreasing = T),]
rownames(popular.city) <- NULL  # 让行号重新从 1 开始
popular.city <- popular.city[1:6, 1]  # 取职位最多的前六个城市
popular.city <- as.character(popular.city)
filter.data <- filter(data, city %in% popular.city)
filter.data$city <- droplevels(filter.data$city)

# 重新排序 factor 的 levels 的顺序
filter.data$city <- factor(filter.data$city, levels = popular.city)

# 工作资历与薪酬的分布
ggplot(filter.data, aes(x = workYear, fill = salary)) +
  geom_bar(stat = "count", position = "dodge") + 
  theme_grey(base_family = "STKaiti") + 
  labs(x = "", y = "") +
  theme(legend.title = element_blank()) +
  ggtitle("「数据挖掘」- 工作资历与薪酬分布") +
  theme(plot.title = element_text(hjust = 0.5))


# 行业与薪酬的分布，好多职位都贴上了不止一个标签，在这里取第一个标签为准
fields <- data$industryField
fields <- str_replace_all(fields, "、",",")
fields <- str_replace_all(fields, " ","")
dim(fields) <- c(907, 1)

GetFirst <- function(item){
  item <- strsplit(item[1], ",")
  return(item[[1]][1])
}

fields.first <- lapply(fields, GetFirst)
dim(fields.first) <- c(907, 1)
fields.and.salary <- data.frame(salary = data$salary, industry = fields.first)
fields.and.salary$industry <- unlist(fields.and.salary$industry)
fields.and.salary$industry <- as.factor(fields.and.salary$industry)

popular.industry <-  data.frame(table(fields.and.salary$industry))
popular.industry <- popular.industry[order(popular.industry$Freq, decreasing = T),]
popular.industry <- popular.industry[1:8,1]
popular.industry <- as.character(popular.industry)

fields.and.salary <- filter(fields.and.salary, industry %in% popular.industry)
fields.and.salary$industry <- droplevels(fields.and.salary$industry)
fields.and.salary$industry <- factor(fields.and.salary$industry, levels = popular.industry)

ggplot(fields.and.salary, aes(x = industry, fill = salary)) +
  geom_bar(stat = "count", position = "dodge") + 
  theme_grey(base_family = "STKaiti") + 
  labs(x = "", y = "") +
  theme(legend.title = element_blank()) +
  ggtitle("「数据挖掘」- 行业与薪酬的分布") +
  theme(plot.title = element_text(hjust = 0.5))





