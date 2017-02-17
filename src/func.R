

# 加载数据

data <- read.table("cache/position.csv", header = T, sep = " ")

colnames(data) <- c(  # 给col命名
  "positionId", "city",
  "industryField", "companyShortName", "companySize",
  "financeStage", "education",
  "positionName", "salary", "requirement"
)


