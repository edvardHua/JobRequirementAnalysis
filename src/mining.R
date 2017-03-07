# 词库是从搜狗输入法官网下载的
decode_scel(scel = "corpus/计算机词汇大全.scel",output = "corpus/cs.dict.utf8",cpp = TRUE)
decode_scel(scel = "corpus/linux少量术语.scel",output = "corpus/cs1.dict.utf8",cpp = TRUE)
decode_scel(scel = "corpus/机器学习.scel",output = "corpus/cs2.dict.utf8",cpp = TRUE)
decode_scel(scel = "corpus/自然语言处理及计算语言学相关术语.scel",output = "corpus/cs3.dict.utf8",cpp = TRUE)
decode_scel(scel = "corpus/计算机应用技术.scel",output = "corpus/cs4.dict.utf8",cpp = TRUE)
decode_scel(scel = "corpus/计算机词汇.scel",output = "corpus/cs5.dict.utf8",cpp = TRUE)
decode_scel(scel = "corpus/计算机词汇大全.scel",output = "corpus/cs6.dict.utf8",cpp = TRUE)
decode_scel(scel = "corpus/软件专业.scel",output = "corpus/cs7.dict.utf8",cpp = TRUE)

# 最后，将几个 *.utf8 文件都合并为一个，也即 cs.dict.utf8 文件
# 但我发现里面词还是比较陈旧，所以，自己也搜集了一些词汇 存放在 collected.dict.utf8 文件中
# 最后，只需要将 cs.dict.utf8 和 collected.dict.utf8 里面的内容复制到 jiebaR 的 dict 目录下的 user.dict.utf8 即可
# 分词，词频统计

mixseg <- worker()
requirements.document <- paste(as.character(data$requirement), collapse = "")
writeBin(requirements.document, "cache/requirement_document.txt")
requirements.document <- tolower(requirements.document)

requirement.segmentation <- mixseg[requirements.document]

# 使用 tf-idf 算法得出主要职业描述的 5 个关键字
keys <- worker("keywords", topn = 7)
# 输出的 5 个 keyword 为如下
# 使用自己收集词库后得出的结果
# 22400    11906.9    11570.9    11359.4    10911.8    10764.9    9853.12 
# "数据挖掘"     "算法"     "数据"     "经验"     "熟悉" "机器学习"     "优先"  
# 未使用词库后得出的结果
# 24803.7    15244.3    13136.2    11881.7    11359.4    10911.8    9853.12 
# "数据挖掘"     "算法" "机器学习"     "数据"     "经验"     "熟悉"     "优先" 

# 是否可以理解为"我们要招聘的数据挖掘工程师,最好要熟悉相关的机器学习算法并且还需要有一定的经验"
requirements.keywords <- vector_keywords(requirement.segmentation, keys)

# 下面通过词频统计获得流行的开发工具和语言
word.freq <- freq(requirement.segmentation)
word.freq <- word.freq[order(word.freq$freq, decreasing = T),]
write.table(word.freq,'cache/word_freq.csv', row.names = F, sep = " ")


# 根据自己的词典，取出我认为关键的词和其词频，然后构建词云
corpus <- read.csv("corpus/collected.dict.utf8", sep = " ", header = F)
# 我只要第一列
corpus <- tolower(corpus[,1])
corpus.freq <- filter(word.freq, char %in% corpus)
corpus.freq <- corpus.freq[-86,]
corpus.freq[67, 2] <- 86
corpus.freq <- corpus.freq[-38,]
corpus.freq <- corpus.freq[order(corpus.freq$freq, decreasing = T),]
names(corpus.freq) <- c("word", "freq")
corpus.freq$word <- toupper(corpus.freq$word)

# 生成词云
wordcloud2(corpus.freq)


# 生成高频词的条形图

labels <- as.character(corpus.freq$word)
corpus.high.freq <- corpus.freq[1:15,]
corpus.high.freq$word <- factor(corpus.high.freq$word, levels = labels[1:15])

ggplot(corpus.high.freq, aes(x = word, y = freq, fill = word, label = freq)) +
  geom_bar(stat = "identity", position = "stack") + 
  theme_grey(base_family = "STKaiti") + 
  labs(x = "", y = "") +
  theme(
    legend.title = element_blank(),  # 设置 legend 的标题为空
    axis.text.x = element_text(angle = 75, hjust = 1),  # 设置x轴字体的旋转角度
    plot.title = element_text(hjust = 0)
        ) +
  geom_text(vjust = 1.5, size = 3) +  # 设置柱状条显示的字体和大小
  ggtitle("「数据挖掘」- 热门术语出现次数") +
  theme(plot.title = element_text(hjust = 0.5))


# 进行关联的分析
# 企业对不同工作资历的应聘者的要求是什么 ？
workyear.empty <- dplyr::filter(data, workYear == "不限")
workyear.freshman <- dplyr::filter(data, workYear == "应届毕业生")
workyear.oneyear <- dplyr::filter(data, workYear == "1年以下")
workyear.threeyear <- dplyr::filter(data, workYear == "1-3年")
workyear.fiveyear <- dplyr::filter(data, workYear == "3-5年")
workyear.tenyear <- dplyr::filter(data, workYear == "5-10年")
workyear.overtenyear <- dplyr::filter(data, workYear == "10年以上")






