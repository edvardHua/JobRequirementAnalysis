# 安装所需的包
install.packages("plotrix")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("sqldf")
install.packages("jiebaR")
install.packages("wordcloud2")

# 读取数据
data <- read.table("cache/position_after_cleaning.csv", header = T, sep = " ")
# 重新排序 factor 的 levels 的顺序
data$salary <- factor(data$salary, levels = c("0-5K", "6-10K", "11-15K", "16-20K", "21-25K", "26-30K", "31-100K"))
data$workYear <- factor(data$workYear, levels = c("不限", "应届毕业生", "1年以下", "1-3年", "3-5年", "5-10年", "10年以上"))

