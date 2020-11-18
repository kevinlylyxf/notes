# 这是我c++的日常笔记

### 第3章 字符串、向量和数组
1. 头文件不应包含using声明：这是因为头文件的内容会



### 第9章 顺序容器
- 快速随机访问就是使用下标访问，string和vector可以使用下标访问 string[], 使用下标访问可以更改
    访问元素的值，但是不能使用下标访问给vector添加元素  

- 标准容器迭代器的运算符 *iter　 iter->mem　 ++iter　--iter　相等和不相等*

- 迭代器支持的运算 iter + n　iter - n　类的 迭代器加减

- forward_list 不支持--iter操作，链表不支持迭代器运算，只能顺序调整迭代器

- 容器适配器的理解：顺序容器提供了一些基本的接口，比如插入，删除等，但是栈、队列这种数据结构表现出来
    的形式跟普通的数据结构不一样，但是我们又不用重新定义数据结构，只需要根据他们的接口重新写一下栈队o
    列的数据结构就可以了，这就是容器适配器

### 容器的使用
- queue 队列 queu\<int\> que; que.push(5);入队 que.pop();出队 que.front(); 队首元素 que.size();元素个数 que.empty();是否为空
- stack stack\<int\> sta; sta.push(5); sta.pop(); sta.top();栈顶元素 sta.size(); sta.empty();
- vector vector\<int> v ;
- priority_queue 优先队列; 和stack函数一样,底层基于堆数据结构
- string ; string.find(s);返回查找的位置;if(str.find(s) == std::npos)
- map ;底层基于RBtree，要存储自定义数据结构要重载< 让红黑树知道怎么排序
   - multiple 可以重复出现，底层基于RBtree
   - unordered_map 底层基于hash表，无需排序
- set ; 底层基于RBtree，要存储自定义数据结构要重载，和map类似
- pair
