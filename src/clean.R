# 安装所需的包
install.packages("sqldf")

# 加载所需的包
library(sqldf)

# 加载数据
data <- read.table("cache/position.csv", header = T, sep = " ")

colnames(data) <- c(  # 给col命名
  "positionId", "city",
  "industryField", "companyShortName", "companySize",
  "financeStage", "education", "workYear",
  "positionName", "salary", "requirement"
)

# 简单查看一下每个 column 有多少类，确定哪几列需要预处理
attributes(data$industryField)
attributes(data$city)
attributes(data$financeStage)
attributes(data$positionName)
attributes(data$salary)
attributes(data$workYear)
attributes(data$companySize)
attributes(data$financeStage)

# 处理 Salary 字段
# salary 统一K为大写
data$salary <- toupper(data$salary)
data$salary <- as.factor(data$salary)
attributes(data$salary)

# 重新调整工资的阈值
# [1] "10K-15K" "10K-16K" "10K-18K" "10K-20K" "11K-20K" "11K-22K" "12K-14K" "12K-15K" "12K-16K" "12K-18K" "12K-20K" "12K-22K" "12K-24K"
# [14] "13K-16K" "13K-18K" "13K-20K" "13K-25K" "13K-26K" "14K-17K" "14K-20K" "14K-24K" "15K-20K" "15K-22K" "15K-25K" "15K-28K" "15K-30K"
# [27] "15K以上" "16K-25K" "16K-30K" "16K以上" "17K-34K" "18K-25K" "18K-28K" "18K-30K" "18K-32K" "18K-35K" "18K-36K" "19K-35K" "19K-38K"
# [40] "1K-2K"   "20K-25K" "20K-30K" "20K-35K" "20K-36K" "20K-38K" "20K-39K" "20K-40K" "21K-42K" "22K-40K" "22K-44K" "25K-30K" "25K-32K"
# [53] "25K-33K" "25K-35K" "25K-40K" "25K-45K" "25K-50K" "26K-40K" "26K-50K" "2K-3K"   "2K-4K"   "30K-39K" "30K-40K" "30K-45K" "30K-50K"
# [66] "30K-55K" "30K-60K" "35K-45K" "35K-50K" "35K-55K" "35K-70K" "3K-4K"   "3K-5K"   "3K-6K"   "40K-45K" "40K-50K" "40K-60K" "4K-5K"  
# [79] "4K-6K"   "4K-7K"   "4K-8K"   "5K-10K"  "5K-7K"   "6K-10K"  "6K-11K"  "6K-12K"  "6K-8K"   "6K-9K"   "7K-10K"  "7K-12K"  "7K-9K"  
# [92] "8K-10K"  "8K-12K"  "8K-14K"  "8K-15K"  "8K-16K"  "9K-10K"  "9K-12K"  "9K-13K"  "9K-15K"  "9K-16K"  "9K-18K" 

thresholds <- list(
  c("1K-2K","2K-3K","2K-4K","3K-4K","3K-5K","3K-6K",
    "4K-6K","4K-7K","4K-5K"),
  c("4K-8K","5K-10K","5K-7K","6K-10K","6K-11K","6K-12K",
    "6K-8K","6K-9K","7K-10K","7K-12K","7K-9K","8K-10K",
    "8K-12K","9K-10K","9K-12K"),
  c("8K-14K","8K-15K","8K-16K","9K-13K","9K-15K","9K-16K",
    "9K-18K","10K-15K","10K-16K","10K-18K","10K-20K",
    "12K-14K","12K-15K","12K-16K","12K-18K","13K-16K",
    "11K-20K"),
  c("11K-22K","12K-20K","12K-22K","12K-24K","13K-18K",
    "13K-20K","13K-25K","13K-26K","14K-17K","14K-20K",
    "14K-24K","15K-20K","15K-22K","15K-25K","15K以上"),
  c("15K-28K","15K-30K","16K-25K","16K-30K","16K以上",
    "18K-25K","18K-28K","18K-30K","20K-25K","20K-30K"),
  c("17K-34K","18K-32K","18K-35K","18K-36K","19K-35K",
    "19K-38K","20K-35K","20K-36K","20K-38K","20K-39K",
    "20K-40K","25K-30K","25K-32K","25K-33K","25K-35K"),
  c("21K-42K","22K-40K","22K-44K","25K-40K","25K-45K","25K-50K",
    "26K-40K","26K-50K","30K-39K","30K-40K","30K-45K","30K-50K",
    "30K-55K","30K-60K","35K-45K","35K-50K","35K-55K","35K-70K",
    "40K-45K","40K-50K","40K-60K")
)
# 工资分为下面这七个区间
salaries <- c("0-5K", "6-10K", "11-15K", "16-20K", "21-25K","26-30K", "31-100K")
GetSalaryMapping <- function(row){
  salary <- as.character(row[10]) 
  result <- c()
  for(i in 1:length(thresholds)){
    result <- grep(salary, thresholds[[i]])
    if(length(result) != 0){
      return(salaries[i]) 
      break
    }
  }
  return(salary)
}

# 替换掉原来的 salary 列
data$salary <- apply(data, 1, GetSalaryMapping)
data$salary <- as.factor(data$salary)

# 接下来处理职位描述这块，该字段包含很多 "\n" 和 空格，这里做一下替换处理就好了
data$requirement <- gsub("\n", "", data$requirement)
data$requirement <- gsub(" ", "", data$requirement)


# 保存最终预处理完成的数据
write.table(data,'cache/position_after_cleaning.csv', row.names=F, sep = " ")
