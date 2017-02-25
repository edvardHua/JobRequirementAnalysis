# 拉勾网数据挖掘岗位分析代码

数据分析报告：http://www.jianshu.com/p/750c9b0996cc


使用到的 R 语言包：ggplot2, jiebaR, wordcloud2


代码结构：

      ├── data
      │   ├── position-\ 1:63 拉勾网的原始数据，为 json 格式
      ├── cache
      │   ├── position_after_cleaning.csv 预处理后的数据，直接读取既可使用
      │   ├── ...
      ├── corpus
      │   ├── collected.dict.utf8  数据挖掘领域相关的语料库
      │   ├── ...
      ├── graphs
      │   ├── ...
      ├── src
      │   ├── curl.R 爬虫
      │   ├── clean.R 数据清洗
      │   ├── func.R 公共函数
      │   └── statistics.R 统计结果可视化
      │   ├── mining.R 关键字提取和词频统计
      └── tests
          └── test.R
        
