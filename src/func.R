# 安装爬取代码的包
install.packages("rjson")
install.packages("rvest")

# 安装画图的包
install.packages("plotrix")
install.packages("ggplot2")

# 安装处理数据的包
install.packages("dplyr")
install.packages("sqldf")

# 安装分词和词云的包
install.packages("jiebaR")
install.packages("wordcloud2")

# 安装关联分析的包
install.packages("arules")

# 安装转换搜狗词库的内容
# https://github.com/qinwf/cidian/
install.packages("devtools")
install.packages("stringi")
install.packages("pbapply")
install.packages("Rcpp")
install.packages("RcppProgress")
install_github("qinwf/cidian")

# 加载相关的包，在这里一次性全部加载
library(rjson)  
library(httr)
library(rvest)

library(sqldf)

library(jiebaR)
library(wordcloud2)
library(dplyr)

# 将搜狗的计算机类别的细胞词库转换成 jieba 词典格式
# Sys.setenv(http_proxy="https://127.0.0.1:1080")  # 设置代理，下面的内容好像需要翻墙安装
library(devtools)
library(cidian)

library(ggplot2)
library(RColorBrewer)
library(plotrix)
library(dplyr)
library(stringr)
library(sqldf)


# 读取数据
data <- read.table("cache/position_after_cleaning.csv", header = T, sep = " ")
# 重新排序 factor 的 levels 的顺序
data$salary <- factor(data$salary, levels = c("0-5K", "6-10K", "11-15K", "16-20K", "21-25K", "26-30K", "31-100K"))
data$workYear <- factor(data$workYear, levels = c("不限", "应届毕业生", "1年以下", "1-3年", "3-5年", "5-10年", "10年以上"))

