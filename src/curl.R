# 定义请求头
my.header <- c(
  "Host" = "www.lagou.com",
  "Origin" = "https://www.lagou.com",
  "X-Anit-Forge-Code" = "0",
  "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
  "Content-Type" = "application/x-www-form-urlencoded; charset=UTF-8",
  "Accept" = "application/json, text/javascript, */*; q=0.01",
  "X-Requested-With" = "XMLHttpRequest",
  "X-Anit-Forge-Token" = "None",
  "Referer" = "https://www.lagou.com/jobs/list_%E6%95%B0%E6%8D%AE%E6%8C%96%E6%8E%98?labelWords=&fromSearch=true&suginput=",
  "Accept-Encoding" = "gzip, deflate, br",
  "Accept-Language" = "zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4",
  "Cookie" = "LGUID=20170212222937-ae7f6943-f12f-11e6-a685-525400f775ce; user_trace_token=20170212222936-7b4486912f87460dbe822d2c7014e7bb; showExpriedIndex=1; showExpriedCompanyHome=1; showExpriedMyPublish=1; hasDeliver=8; index_location_city=%E6%B7%B1%E5%9C%B3; JSESSIONID=522C5ED68CC7FCFBE09ACB43565ECAD1; Hm_lvt_4233e74dff0ae5bd0a3d81c6ccf756e6=1486909777,1486979194,1487125393; Hm_lpvt_4233e74dff0ae5bd0a3d81c6ccf756e6=1487299799; _gat=1; _ga=GA1.2.9339698.1486909777; LGSID=20170217104958-c562c41b-f4bb-11e6-8fc3-5254005c3644; PRE_UTM=; PRE_HOST=; PRE_SITE=; PRE_LAND=https%3A%2F%2Fwww.lagou.com%2F; LGRID=20170217104958-c562c67c-f4bb-11e6-8fc3-5254005c3644; TG-TRACK-CODE=index_search; SEARCH_ID=482ccd4314dd4b46a4cdd31db61f3cdf"
)

# 获取搜索结果的总页数
CalTotalPages <- function(str.json){
  json <- fromJSON(str.json)
  result.info <- json$content$positionResult
  result.total.pages <- json$content$positionResult$totalCount/json$content$positionResult$resultSize
  return(result.total.pages <- ceiling(result.total.pages))
}

# 如果自己有代理的话
# Sys.setenv(http_proxy="https://127.0.0.1:1080")
i <- 1 
total.pages <- 3  #  具体的页数，要第一次请求后才能知道
while(i <= total.pages){
  # 用 POST 去获取数据
  # 使用了网上的免费代理
  #
  # 这里请求的url获取的是全部的数据挖掘岗位，如果需要按城市的条件筛选，
  # 可以在请求链接上加上 city 参数
  r <- POST(
    "https://www.lagou.com/jobs/positionAjax.json?needAddtionalResult=false", 
    encode = "form", 
    body = list(first = "true", pn = i, kd = "数据挖掘"),
    add_headers(.headers = my.header),
    use_proxy("183.19.12.40", 3128),  # 根据需求看是否要代理
    verbose()
  )
  if(200 == status_code(r)){
    positions <- content(r, "text", encoding = "UTF-8") #  获取返回内容
    
    if(1 == i){  # 表明第一次请求，计算取得总的页数的值
      total.pages <- CalTotalPages(positions)
    }
    
    file.name <- paste("data/position-", i)  # 按页数保存获取的数据，并储存在指定目录下，可按需求更改
    writeBin(positions, file.name)
  }else{
    break
  }
  
  Sys.sleep(5)  # 系统暂停 5 秒后再执行,避免封锁IP
  
  i <- i + 1
}


# 从json数据中得到职位的基本信息
required.fields <- c(  # 获取需要的字段
  "positionId", "city",
  "industryField", "companyShortName", "companySize",
  "financeStage", "education", "workYear",
  "positionName", "salary"
)
FuncFilter <- function(item){
  item <- item[required.fields]
  item <- unlist(item)
  item <- unname(item)
  return(item) 
}

# 从 json 数据获取职位基础的信息
GetBasicPositionInfo <- function(path){
  json <- fromJSON(file = path)
  result.info <- json$content$positionResult
  position.result <- json$content$positionResult$result  # 取得返回的列表
  tmp <- lapply(position.result, FuncFilter)
  return(tmp)
}

files.names <- dir(path="data/")
files.names <- paste('data/', files.names, sep = "")  # 路径加上前缀
all.positions <- lapply(files.names, GetBasicPositionInfo)

# 根据职业的ID，再从拉勾网上获取对应职业的专业技能要求
position.data.frame <- data.frame()
for(i in 1:length(all.positions)){  # 这步时间可能会有点长,需要等半个小时左右
  for(j in 1:15){
    tmp <- all.positions[[i]][j]
    tmp <- unlist(tmp)
    tmp <- unname(tmp)
    if(length(tmp) != 10)  # 对没有填充完整数据的职位，则跳过不处理
      next
    url <- paste("https://www.lagou.com/jobs/", tmp[1], ".html", sep = "")
    web <- GET(url)
    web <- read_html(content(web, "text", encoding = "UTF-8"))
    requirement <- web %>% html_nodes(".job_bt") %>% html_text() #  根据class获取需求内容
    tmp[11] <- requirement
    dim(tmp) <- c(1,11)
    position.data.frame <- rbind(position.data.frame, tmp)
    Sys.sleep(2)  # 系统暂停 2 秒后再执行,避免封锁IP
  }
}

# 保存至 data 文件夹中，数据爬取完成
write.table(position.data.frame,'cache/position.csv', row.names=F, sep = " ")



