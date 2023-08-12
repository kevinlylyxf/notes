#### ada编译gnat

- [ada编译理解](https://www.wenmi.com/article/ptlf7v04iygi.html)

- 编译步骤

  ```
  Three steps are needed to create an executable file from an Ada source file:
  	The source file(s) must be compiled.    gcc编译，对于每一个只要gcc -c *.adb，不用管ads
  	The file(s) must be bound using the GNAT binder.  gnatbind
  	All appropriate object files must be linked to produce an executable. gnatlink
  ```

- 只有一个文件main.adb

  ```
  $ gnatmake main.adb
  gcc -c main.adb
  gnatbind -x main.ali
  gnatlink main.ali
  ```

- 对于多个文件

  ```
  $ gnatmake main.adb
  gcc -c main.adb
  gcc -c overload.adb
  gnatbind -x main.ali
  gnatlink main.ali
  ```

  - 对于多个文件也是执行gnatmake + 主文件，其中的过程会自己执行。

#### 数据类型

##### 基型数字

- 在大部分语言中，都使用 10 进制数字表示；Ada 里整数可以不用 10 进制的表示方法书写，而是直接使用 2 至 16 进制的表示法，格式为:Base#Number#，Base 表示所采用的进制，Number 为该进制下所表示的数字。如：

  ```
  16#90#,表示 16 进制数 90，其 10 进值为 144；
  
  代码实例
  subtype SSR_CODES is INTEGER_16 range 0 .. 8#7_777#;
  如果用4096表示不太好看，因为SSR是8进制的，最大到7777，所以我们用这个8#7777#来表示最大值，和4096一样。
  只是表示的方法好看与否，和其他的没关系。
  ```

- 实型数、整型数，都可以在其间加上下划线，使长数字更加易读或者使数字串具有某种含义。如 56886515645125615,可写为 56_886_515_645_125_615 或 5_6886_5156_4512_5615,下划线并不改变数字的 值。但两个下划线不能是连续的，下划线也不可以在数字首部和尾部,如 676__66 和 67_E4 都是非法的。

##### 创建新的数据类型

- 创建一个新类型，需要使用保留字 type，is,range。格式如下： 

  ```
  type type_name is range range_specifcation; 
  ```

  - type_name 为新类型的名称，是一个合法标识符；range_specifcation 表示该类型的取值范围，表示方式为 First .. Last,如 1..100 , -9 ..10 。 

- 例如创建上面提及的一个新类型 Age ：

  ```
   type Age is range 1 .. 100; 
  ```

  - 这样就有了一个数据类型 Age, 取值范围 1 .. 100。

-  有一点要注意：range_specfication 中 First 要大于 Last。 如 type months is range12 .. 0, 实际上 months 是一个空集(null)，而不是所期望的 0..12。

##### 派生类型

- 大家可能会发现，如果像上面一样创建一个截然不同的新类型，还需要定义它的运算符，使用很不方便。因此，往往是派生现有的类型，其格式为: 

  ```
  type type_name is new old_type {range range_specification};
  ```

  -  type_name 为新类型的名称，是一个合法标识符；range range_specification 表示该类型的取值范围，是可选的，没有的话表示新类型 type_name 的取值范围和 old_type 一样。如将上例改为： 

  ```
  000 — filename:putwage.adb
  001 with Ada.Text_IO; use Ada.Text_IO; 
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO; 
  003 procedure putwage is 
  004 type Age is new Integer range 1 .. 100; 
  005 type wage is new Integer; 
  006 Bill_Age : Age := 56; 
  007 Bill_Wage: Wage := 56; 
  008 begin 
  009 Put (―Total wage is‖); 
  010 Put (Bill_Wage * Bill_Age); 
  011 New_Line; 
  012 end putwage; 
  ```

  - 上例还是不能编译通过，因为派生类型只继承母类型的属性，如运算符，不同的派生类型即使母类型相同也还是属于不相同的类型。但将[10]改为Put (Integer(Bill_wage * 56))则能输出正确的结果。但是派生类型使用还是麻烦了一点，不同类型之间即使都是数字类型也无法混合使用,只是自己不用创建运算符省力了点。

##### 创建子类型

- 创建新类型和派生类型的麻烦从上文就可以感受的到，特别是在科学计算这些有很多种小类型的软件当中，上述两种方法实在过于繁杂。这时子类型(subtype)就相当有用，子类型的定义格式为:

  ```
   subtype type_name is old_type {range range_specification};
  ```

  -  type_name 为新类型的名称，是一个合法标识符；range range_specification 表示该类型的取值范围，是可选的，没有的话表示新类型 type_name 的取值范围和 old_type 一样。

- 再将先前的例子改一下： 

  ```
  000 — putwage.adb
  001 with Ada.Text_IO; use Ada.Text_IO; 
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO; 
  003 procedure putwage is 
  004 subtype Age is Integer range 1 .. 100; 
  005 subtype Wage is Integer; 
  006 Bill_Age : Age := 56; 
  007 Bill_Wage: Wage := 56; 
  008 begin 009 Put (―Total wage is‖); 
  009 Put (Bill_Wage * Bill_Age); 
  010 New_Line; 
  011 end putwage; 
  ```

  - 编译通过，输出值为3136。子类型不仅继承母类型的属性，而且和母类型、其它同母类型的子类型可混合使用。 

- 在前面的例子中的，我们都提到了取值范围，这也是 Ada 的一项―特色‖：Ada 不同于 C 和 Pascal— 赋给一个变量超过其取值范围的值或进行不合法运算，会输出错误的值而不报错，与此相反，Ada 程序在编译时会提示错误，或在运行 Ada 程序时产生Constraint_Error异常（异常和 C 中的信号Signal差不多。

![](https://atts.w3cschool.cn/attachments/image/20161025/1477361247520533.png)

##### 标量类型

- 大部份语言，基本的数据类型如果按照该类型所表示的数据类型来分，一般来说可分为整型(integer)，实型(real)，布尔型(boolean)，字符型(character)这四类，并以它们为基础构成了数组，记录等其它更复杂的数据类型。在程序包 Standard 中预定义了一些简单数据类型，例如Integer，Long_Integer，Float，Long_Float，Boolean，Character，Wide_Character，以及这些数据类型的运算符。下面我们除了学习上述的4种标量类型(Scalar Type)外，还要学习一下枚举类型(Enumration)。由于 Ada 中布尔型和字符型都是由枚举类型实现的，因此也可将这两种类型认为是枚举类型。

###### 整形

- 一个整型数据能存放一个整数。预定义的整型有Integer，Short_Integer，Short_Short_Integer，Long_Integer，Long_Long_Integer还有Integer的子类型 Positive ，Natural。RM95 没有规定 Integer及其它整型的具体取值范围及其位数，由编译器决定。只规定了没多大意思的最小取值范围，如要求一个Integer 至少要为16位数，最小取值范围为-32767..32767(-2 ** 15+1 .. 2**15-1)。因此还有Integer_8,Integer_16,Integer_32,Integer_64这些指定了位数的整型,以方便用户。在RM95里，也就是编译器实现里，以上类型声明格式为:

  ```
  type Integer is range implementation_defined(Long_Integer它们也一样)
  subtype Positive is Integer range 1..Integer'Last;
  subtype Natural is Integer range 0..Integer'Last; (Integer'Last 表示Integer的最后一个值，即上限，见2.5 数据类型属性)
  ```

- 程序 System 里定义了整数的取值范围:

  ```
  type Integer is range implementation_defined(Long_Integer它们也一样)
  subtype Positive is Integer range 1..Integer'Last;
  ```

###### Modular 整型

- 还有一类整型是 Modular,异于上面的整型。如果将 Integer 整型与 C 中的 signed int 相类比，它们的取值范围可包括负数;那么 Modular 类型就是unsigned int，不能包含负数。其声明格式为:

  ```
  type tyep_name is mod range_specification;
  ```

  - 其中的 range_specification 应为一个正数; type_name 的取值范围为(0..range_specification - 1)。

- 如下面类型 Byte:

  ```
  type Byte is mod 256;
  ```

  - 这里 Byte 的取值范围为 0 .. 255。

- Modular 类型在程序包 System 也有常量限制，range_specification 如是2的幂则不能大于 Max_Binary_Modulus ，如不是幂的形式则不能大于Max_Nonbinary_Modulus。 这两个常量的声明一般如下：

  ```
  Max_Binary_Modulus : constant := 2 ** Long_Long_Integer'Size;
  Max_Nonbinary_Modulus : constant := Integer'Last;
  ```

  - 诸位可能会发现上面两个常量的值实际上是不一样的，也就是说 Modular 类型实际上有两个不同的限制。RM95 关于这点的解释是,2进制兼容机上，Max_Nonbinary_Modulus 的值大于 Max_int 很难实现。

##### 实型

- 相对于整型表示整数，实型则表示浮点数。实型分为两大类: 浮点类型(floating point) 和定点类型 (fixed point)。它们之间的区别在于浮点类型有一个相对误差;定点类型则有一个界定误差，该误差的绝对值称为 delta。下面就分类介绍这两类数据类型。

###### 浮点类型

- 浮点类型预定义的有Float，Short_Float，Short_Short_Float，Long_Float，Long_Long_Float等,它们的声明格式入下:

  ```
  type type_name is digits number [range range_specification] ;
  ```

  - digits number 表示这个浮点类型精度，即取 number 位有效数字，因此 number 要大于0;range range_specification 是可选的，表示该类型的取值范围。下面是几个例子：

  ```
  type Real is digits 8;
  type Mass is digits 7 range 0.0 .. 1.0E35;
  subtype Probability is Real range 0.0 .. 1.0;
  ```

  - Real 表示精度为8位的符点数类型，它的取值范围由于没给定，实际上由编译器来决定;RM 95里关于这种情况是给出了安全范围(safe range), 取值范围是-10.0**(4*D) .. +10.0**(4*D), D 表示精度，此例中为8,所以 Real 的安全取值范围一般来说应为 -10.0E32 .. +10.0E32。

  - Mass 是表示精度为7位的符点型，取值范围为 00.. 1.0E35;

  - Probability 是Real的子类型，精度也是8位，取值范围 0.0..1.0;

- 程序包 System 定义了精度的两个上限：Max_Base_Digits 和 Max_Digits ,一般来说应为

  ```
  Max_Base_Digits : constant := Long_Long_Float'digits;(即Long_Long_Float的精度)
  
  Max_Digits : constant := Long_Long_Float'digits;
  ```

  - 当range_specification指定时，所定义类型的精度不能大于 Max_Base_Digits;当range_specification没有指定时，所定义类型的精度不能大于 Max_Digits。

###### 定点类型

- 定点类型主要是多了一个delta，它表示该浮点类型的绝对误差。比方说美元精确到 0.01 元(美分)，则表示美元的数据类型 Dollar 的 delta 为 0.01，不像浮点型是近似到 0.01。

- 定点型的声明格式有两种：

  ```
  普通定点型：type type_name is delta delta_number_range range_specification;
  
  十进制定点型：type type_name is delta delta_number digits digit_number [rangerange_specification];
  ```

  - 除 delta delta_number 外，各部份意义与浮点型相同。

- 定点型中有一个 small 的概念。定点数由一个数字的整数倍组成，这个数字就称为该定点数类型的 small。如果是普通定点型，则 small 的值可以被用户指定(见下节 数据类型属性)，但不能大于该类型的 delat;如果没有指定，small 值由具体实现决定，但不能大于 delta。如果是十进制定点型，则 small 值为 delta，delta 应为 10 的幂,如果指定了该定点型的取值范围，则范围应在 -(10**digits-1)*delta..+(10**digits-1)*delta 之间。看一下下例：

  ```
  type Volt is delta 0.125 range 0.0..255.0;
  type Fraction is delta System.Fine_Delta range -1.0..1.0;
  type Money is delta 0.01 digits 15;
  subtype Salary is Money digits 10;
  ```

##### 布尔型

- 逻辑运算通常需要表示"是"和"非"这两个值，这时就需要使用布尔型。Ada 中的布尔型与 Pascal 中的类似，是 True 和 False 两个值。布尔型属于枚举数据类型，它在程序包 Standard 中定义如下：

  ```
  type Boolean is (True, False);
  ```

  - 习惯于 C 语言的朋友在这里需要注意一下，Boolean 的两个值 True,False 和整型没有什么关系，而不是 C 语言中往往将True 定义为值1，False 为2。

##### 字符型

- Ada83 最初只支持 7 位字符. 这条限制在 Ada95 制订前已经放松了，但一些老编译器如 Meridian Ada 还是强制执行. 这导致在一台PC上显示图形字符时出现问题;因此，在一般情况下，是使用整型来显示 Ascii 127以后的字符,并使用编译器厂商提供的特殊函数。

- 在 Ada95 里，基本字符集已由原来的ISO 646 标准的7位字符变为ISO 8859标准的8位字符，基于 Latin-1并且提供了 256 个字符位置。 Ada95 同样也支持宽字符 ISO 10646，有2**16个的字符位置。因此现代编译器能很好地处理 8 位字符和 16 位字符。

- 7 位字符在已经废弃的程序包 Standard.Ascii 内定义。在程序包 Standard 内预定义的字符型 Character 和 Wide_Character 分别表示Latin-1 字符集和宽字符集，类型 Wide_Character 已经包含了类型 Character 并以它作为前 256 个字符。程序包 Ada.Characters.Latin_1和Ada.Characters.Wide_Latin_1 提供了 Latin-1 字符集的可用名称，Ada.Characters.Handling 则提供一些基本的字符处理函数。

-  从下例可以了解一下字符型：

  ```
  000 -- filename: puta.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 procedure puta is
  003 subtype Small_Character is {'a' ,'b','c', 'd'};
  004 Level : Small_Character := 'a';
  005 begin
  006 Put ("You level is");
  007 Put (Level);
  008 New_Line;
  009 end puta;
  ```

  - [003] 创建了一个字符类型 Small_Character,包含 a,b,c,d四个字母；如 C 语言一样，使用字符时需加' '。

  - [004]声明变量 Level,类型为Small_Character,值为字母 a 。

  - 上面这个例子主要还是说明一下字符类是怎样定义的，但 Character和Wide_Chracter 实际实现却不是这么简单。

##### 枚举类型

- 有时候我们需要一个变量能表示一组特定值中的一个。如 today 这个变量，我们希望它的值是Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday其中的一个，这时枚举类型就相当有用，上述情况中就可以创建新类型 Day,如下：

  ```
  type Day is ( Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday);
  ```

- 然后声明变量 today 的数据类型为 Day:

  ```
  today : Day ;
  ```

  - 这样today 就能接受Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday这几个值中的任意一个。

- 前面提及的类型 Character ,Wide_Character,Boolean 都是枚举类型，也按照下面给出的格式声明:

  ```
  type type_name is (elememt_list);
  ```

  - element_list 需列举出该类型所有的可能值。

- Ada 能自动检测上下文，因此大部份情况下能分辨不同枚举数据类型下的枚举元素，如再声明一个类型 Weekend:

  ```
  type Weekend is ( Saturday, Sunday);或subtype Weekend is range Saturday .. Sunday;
  ```

- 赋给上例中的变量 Today 值为 Sunday时，不会产生歧义;但在有些情况下，Ada 无法分辨枚举元素时则会产生问题，这时就要使用类型限制。

- Ada 中的基本数据类型就讲到这里，实际上本节是基于上一节内容的扩展，说穿了还是创建数据类型。Ada 在数据类型处理上提供的强大功能在接下的章节里我们将会接触的更多，在这方面 Ada 的确比其它大部份语言做的好多了，熟悉 C ,Pascal的朋友大概会感到相当有意思。

- 对于ada中离线配置的是字符串，而内部数据存储是枚举类型，按如下方式解决

  ```
  begin
    PRINT_TARGET := FPL_PARAMETERS.STRIP_PRINT_TARGETS'VALUE(ELEMENT.TEXT(ELEMENT.FIRST .. ELEMENT.LAST));
  exception
    when others =>
      ERROR.ID := ADAPT_ERROR_MNG.INVALID_PRINT_STRIP_TARGET;
  end;
  ```

  - 用VALUE数据类型属性将字符串转换为枚举类型，如果字符串跟枚举类型中的一样就能转过去，否则就会出现异常，此时我们捕获异常，设置ID属性，就能根据ID属性进行后续的判断了。

##### 数据类型属性

- 数据类型属性，表示某个数据类型的具体特征---取值范围，最小值，最大值，某数在该类型中的位置 …… 应该说是相当有用的-----起码不像 C 语言，还要翻翻系统手册才能知道某个数据类型的具体定义。这些属性的用法和调用函数一样，也可以认为它们就是预定义的函数----虽然不怎么准确，有些返回值为通用类型(universal type)和字符串型。

- 数据类型的属性既可以使用预先定义的操作，也可以自己定义数据类型的属性，如S'First　是返回 S　类型的下限，如果用户不满意默认的属性，也可自己指定S'First(虽然没必要)，如:

  ```
  for S'First use　My_Version_First;
  ```

  - My_Version_First　是用户自己的函数，以后当使用 S'First　时，实际上调用 My_Version_First;有些数据属性也可以直接用数字标示，如：

  ```
  for S'First use　0;
  ```

  - 这样，S'First　的值就成了0。在很多地方，如内存管理中，这种用法还是比较普遍的。下面简单地列出标量类型的属性，S 表示某个标量类型：

###### 通用标量类型属性

- 一个标量就是一个单独的数(整数或实数)，标量就是一个数，只有大小没有方向。

```
S'First 返回 S 类型的下限，返回值为 S 型。
S'Last 返回 S 类型的上限，返回值为 S 型。
S'Range 返回 S 类型的取值范围，即 S'First .. S'Last。
S'Base 表示 S 类型的一个子类型，但没有范围限制(单纯从取值范围角度讲，“儿子”反而比“父母”大)，称之为基类型(base type)。
S'Min 函数定义为: function (Left,Right:S'Base) return S'Base 。比较 Left和 Right 的大小，返回较小值。如：Integer'Min (1 , 2) = 1 。
S'Max 函数定义为: function (Left,Right:S'Base) return S'Base 。比较 Left和 Right 的大小，返回较大值。如：Integer'Max (1 , 2) =2 。
S'Succ 函数定义为：function S'Succ (Arg :S'Base) return S'Base 。返回 Arg 的后趋。
S'Pred 函数定义为: function S'Pred (Arg :S'Base) return S'Base 。返回 Arg的前趋。
S'Wide_Image 函数定义为：function S'Wide_Image (Arg : S'Base) return Wide_String 。返回 Arg 的“像”，即可显示的字符串，这里返回宽字符串型 Wide_String。如：Float'Wide_Image (9.00) = “9.00" 。详见 第三章 数组。
S'Image 与 S'Wide_Image 一样，但返回字符串型 String 。
S'Wide_Width 表示 S'Wide_Image 返回的字符串的最大长度，返回值为 universal_integer。
S'Width 表示 S'Image 返回的字符串的最大长度,返回值为 universal_integer。
S'Wide_Value 函数定义为: function S'Wide_Value ( Arg : Wide_String) return S'Base。是 S'Wide_Image 的逆过程，返回与“像”Arg 相对应的 S 类型的值。如: Float'Wide_Value ("9.00") = 9.00 。
S'Value 与 S'Wide_Value 一样，但参数 Arg 是 String 类型。
```

```
S'img和S'Image是一个意思，都是将其他类型的数据转换为string，然后输出，只是img不需要括号的参数，image需要参数。
INTEGER'image(INTEGER(TEMP_DATE.HOURS))  这个是拼接字符串的一部分
DEBUG.DISPLAY("M4029_3 : Unknown field " & FIELD'img & ", ignore it!" );
```

###### 通用离散类型属性

- 离散类型包括整型和枚举型，除了上述的属性外，还有：

  ```
  S'Pos 函数定义为: function S'Pos (Arg : S'Base) return universal_integer。返回 Arg 在 S 类型中的位置。
  
  S'Val 函数定义为: function S'Pos (Arg : S'Base) return S'Base。返回 在 S 类型中位置为 Arg 的值。
  ```

  例如：

  ```
  type Color is (red, white, blue);
  Color'Pos (White) = 1
  Color'Val (0) = red 
  ```

###### 浮点类型属性

- S'Digits 　返回 S　类型的精度，为 universal_integer　类型。

###### 定点类型属性

```
S'Small 返回 S 类型的 small　值，返回值为实型。

S'Delta　返回 S　类型的 delata，返回值为实型。

S'Fore　 返回 S 类型所表示数的小数点前面的最小字符数量，返回值类型 universal_integer。

S'Alt 返回 S 类型所表示数的小数点后面的最小字符数量，返回值类型 universal_integer。
```

###### 十进制定点型属性

```
S'Digits 返回 S 类型的精度。

S'Scale 返回 S 类型的标度 N，使 S'Delta=10.0**(-N)。

S'Round 函数定义为 function S'Round(X:universal_real) return S'Base;返回 X 的舍入值。
```

##### 类型限制和类型转换

- 先让我们看一下下面的例子：

  ```
  type primary is (red, green, blue);
  type rainbow is (red, yellow, green, blue, violet);
  ...
  for i in red..blue loop
  ...
  ```

- 这里明显有歧义，编译器也就无法自动判定 red，blue 到底是 primary 还是 rainbow 中的元素。因此我们就需要使用类型限制，精确指明元素：

  ```
  for i in rainbow'(red)..rainbow'(blue) loop
  for i in rainbow'(red)..blue loop -- 只需要一个限制
  for i in primary'(red)..blue loop
  ```

- 类型限制并不改变一个值的类型，只是告诉编译器程序员所期望的数据类型。由于 Ada 中提供了重载等特性，变量、子程序等重名的现象相当普遍，以后我们会碰到，解决方法和现在所讲的类型限制差不多，都是指明资源的准确位置。

- 类型转换我们也常常在使用，比方说 modular 类型的数的输入输出需要特定的程序包，初学者便可以将 modular 数转换成 Integer 数来处理(虽然不怎么好)。下面是一个 Integer 和 Float 类型数互相转换的例子：

  ```
  X : Integer:= 4;
  Y : Float;
  Y := float(X);
  . . .
  X := Integer(Y);
  ```

  - 这导致编译器插入合适的代码来做类型转换，实际效果就取决于编译器，而且一些类型之间的转换是禁止的;像上述的强行转换一般也不推荐，除非意义很明确，建议是使用上节所讲的数据类型属性、以及以后会碰到的相关子程序等来进行类型转换。
  - 还有一种不进行检查的类型转换，我们会在以后遇到。

##### 运算符

- in 、not in范围测试

  ```
  N not in 1..10 --范围测试，如果 N 在 1..10 中，为 True
  Today in Mon..Fri
  Today in Weekday
  ```

  - 后面可以是各种类型，枚举什么的。

#### 数组array

- 数组是一种复合数据类型(composite type)，包含多个同一种类型的数据元素。数组元素的名称用指定的 下标表示，这些下标是离散数。数组的值则是一个由这些元素的值构成的合成值(composite value)。Ada 下 的数组和其它语言很相似，只是多了一些“宽松”的规定，如无约束数组、动态数组，更加方便了用户。字符串类型 String，Wide_String 等则是数组元素为字符型的数组类型

##### 简单数组simple array

```
type array_name is array (index specification) of type;
```

- 字段说明

  - array_name是该数组类型的名称
  - index specification指明该数组类型的元素下标，这个小括号是一定要加的
  - type是一个已经定义了的数据类型，表示每个元素的数据类型。

- 通常情况下，数组类型的使用方式和下例相同

  ```
  type Total is range 1 .. 100; -- 声明一个整型 Total,取值范围 1..100。
  type Wages is array (Total) of Integer;-- 声明一个数组类型Wages,该类型有100个Integer元素。
  Unit1 : Wages; -- 声明一个Wages类型的变量 Unit1，具有100个 Integer 元素，下标取值 1 .. 100。
  
  Wages 的声明也可改为
  type Wages is array (1 .. 100) of Integer;
  效果是一样的，只是从维护性的角度来讲还是由 Total 来决定 Wages 的下标比较好。
  ```

- Ada 数组的 index specification 是离散数，可以是一个范围，也可以是枚举类型，而不是单纯的一个表示数组大小的数值，这点和 C 、Pascal 有所区别 。数组元素的下标也不需要一定从 0 或从 1 开始，例如：

  ```
  type First_Name is( Bill, Jack, Tom );
  type Enrollment is array ( First_Name ) of Integer;
  Var : Enrollment; -- 数组 Var 有 3 个 Integer 元素，Var (Bill)、Var (Jack)、Var (Tom)。
  type NO is array (-5 .. 100) of Integer;
  X : NO; -- 数组 X 有 105 个 Integer 元素，第一个元素是 X (-5)，最后一个是 X (100)。
  ```

##### 匿名数组

- 如果嫌上一节中的 Unit1 的声明过程麻烦，也可以直接声明：

  ```
  Unit1 : array (1 .. 100) of Integer;
  ```

  - 虽然更为精简了，但不推荐这样使用数组。这种数组没有明确的类型，被称为匿名数组(anonymous array),既不能作为子程序的参数，也无法同其它数组混用----即使声明一样。通常情况下应避免出现这种情况

##### 无约束数组

- 像上面的例子，数组有几个元素在声明数组类型时已经决定，而不是在声明该类型的数组变量时决定，当然这样的好处是明确的知道每个数组会占用多少空间，控制起来也方便。但如同我们先前提及的一样，字符串类型 String，Wide_String 是数组类型，而用户输入的字符串却是不定的，如果它们的长度也预先定好了，使用字符串时无疑会造成内存空间浪费或不够用，这时一般是使用无约束数组---其声明和一般数组类型相同，只是没有规定它的长度---其长度在声明该类型的数组变量时决定。

- 如 String 类型的声明:

  ```
  subtype Positive is Integer range 1..Integer'Last;
  type String is array (Positive range <>) of Character;
  type Wide_String is array (Positive range <>) of Wide_Character;
  ```

  - < > 表示当声明该无约束数组类型的变量时，需要在( )中指定一个范围。如创建一个变量 Path_Name, 长度为1024:

  ```
  Path_Name: String (1 .. 1024);
  ```

  - 如果没有指定该数组的大小，如:

  ```
  Path_Name: String;
  ```

  - 是不合法的。

  - 当然范围也无须从 1 开始，Path_Name:String (7..1030) 和上例表示的字符串长度一样,只是下标不同而已。如果有一个函数 Get_Path (Path_Name :in out String),将当前路径名赋给参数 Path_Name，只要是 String 类型的参数就可以通用，长度也无须计较---函数出错或不处理不符合长度要求的字符串则是另一回事。

- 这里强调一下字符串类型的赋值问题，假如将 Path_Name 赋予"/root/",可以在一开始就赋值：

  ```
  Path_Name :String := "/root/";
  ```

  - 这样 Path_Name 的长度就自动成为6，数组的下标是从1开始的。但如果

  ```
  Path_Name :String(1..10) := "/root/";
  ```

  - 则会引起错误(看上去很正确)，因为还缺4个字符，应为

  ```
  Path_Name :String(1..10) := "/root/ ";
  ```

  - 或采用从理论上讲麻烦点实际上根本不会这么做的方案：

  ```
  Path_Name:String (1..10);
  Path_Name(1) := '/';
  Path_Name(2) := 'r';
  ...
  Path_Name(6) :='/';
  ```

  - 这点是和其它语言有所不同，也是很不方便的一点

##### 动态数组

- 数组大小也可以在运行时动态决定，而不是在程序的源代码中就决定。如：

  ```
  X : Positive := Y;
  Var : array (1 .. X) of Integer;
  ```

  - 这样 Var 的大小就由 X 来决定了，X 多大它也多大。只是这样做相当不妙，假设 Y 值是用户输入的，它的大小，甚止于输入的到底是什么，就根本无法确定，如果过大或负数或非Positive 类型都会产生麻烦。一般情况下还是用在子程序中:

  ```
  procedure Demo (Item :string) is
  copy : String(Item'First..Item'Last) := Item;
  double: String(1..2*Item'Length) := Item & Item; --Item'First,Item'Last等都是数组属性，& 是将两个字符串相连，参见下文。
  begin
  ...
  end Demo;
  ```

  - 这样的话，对于动态数组的操作与用户没有多大关系，保证了安全性

##### 多维数组

- 前面提及的数组用法对多维数组也适用，只是多维数组的声明和元素的表示略有不同。如定义一个矩阵:

  ```
  type Marix is array (1 .. 100,1..100) of Integer;
  ```

  - Var :Marix;---Var有 100x100个元素，分别为 Var(1,1),Var(1,2)....Var(100,99),Var(100,100)。

  - 上例的Matrix是二维数组，多维数组的 index_specification 由多个范围组成，每个范围由,隔开。
  
  - 二维数组的初始化，用两个other
  
    ```
    FSN_UID_ARRAY : FSN_UID_T(FPL_PARAMETERS.ALPHABETIC'FIRST .. FPL_PARAMETERS.ALPHABETIC'LAST, SN_RANGE_T'FIRST .. SN_RANGE_T'LAST)              := ( others => (others => FPL_BRICK.NUMBER_DEF) );
    ```
  

##### 访问和设置数组

- 访问数组时，只需在添加在 index specification 范围内的下标，如 3.2 中的数组Unit1:

  ```
  Unit1 (1) := 190; -- 赋予Unit(1)值 190;
  Unit1 (7) := 210;
  Unit1 (7) > Unit (1) -- 返回 True;
  ```

- 数组的值虽然可以单个元素分别赋予，但这样做明显是开玩笑的麻烦。以上例中的Var:Enrollment 为例,一般情况下可以如下赋值:

  ```
  Var := (15,14,13);
  ```

- 结果为 Var (Bill) = 15, Var (Jack) = 14, Var (Tom) =13，( )中的值，按顺序赋给数组里的元素，因此数量也不能少：

  ```
  Var := (15,14) -- 不合法
  ```

- 当数组元素有名称时,例如元素下标是用枚举类型表示，也可以这样赋值：

  ```
  Var := (Bill => 15, Jack => 14, Tom => 13);
  ```

- 结果与上等同。但如果同时用以上两种表示法是不合法的，如：

  ```
  Var := (Bill => 15, Jack => 14, 13); -- 不合法
  ```

- 如希望相邻的一些元素都是相同值，如 Var (Bill)、 Var(Jack)、Var(Tom)都等于 15，则可以如下：

  ```
  Var := (Bill .. Tom => 15);
  ```

  - 注意是 Bill 和 Tom (包括它们本身)之间的所有元素值为 15。

- 而希望 Var (Bill) 等于 15，其余都等于14时，也可以如下：

  ```
  Var := (Bill => 15, others => 14);
  ```

- 这样 Var (Jack) = Var(Tom) =14。others 在有很多元素都要赋予相同值时是相当有用。

- 如果将 Var 作为常量数组，则在声明该数组时就赋予初使值：

  ```
  Var ：constant Enrollment := (Bill => 15, others => 14);
  ```

- 最后看一下以下三种情况：

  ```
  type Vector is array (Integer range <>) of Float;
  V: Vector(1 .. 5) := (3 .. 5 => 1.0, 6 | 7 => 2.0);-- [1]
  V := (3 .. 5 => 1.0, others => 2.0); -- [2]
  V := (1.0, 1.0, 1.0, others => 2.0); -- [3]
  ```

  - 对于 [3]，我们已经学过：V(1)=V(2)=V(3)=1.0，V(4)=V(5)=2.0。 但 [1] 和 [2] 却很特殊，在 [1] 中：V(1)=V(2)=V(3)=1.0，V(4)=V(5)=2.0;在[2]中V(3)=V(4)=V(5)=1.0，V(1)=V(2)=2.0。[1]和[2] 的情况是 Ada95 新增的。像 [1] 的话，Ada83 会认为它是超过了数组的下标，产生异常 Constraint_Error，而在 Ada95 则是合法的，并且( )里面的值按顺序赋给数组的元素;[2] 在 Ada83 里也是不允许的，Ada95 允许先赋值给V(3),V(4),V(5)，others 就默认是指 V(1) 和 V(2)。这3种情况很容易引起混淆，请读者注意一下。

##### 数组运算符

###### 赋值

- 整个数组的值可以赋给另一个数组，但这两个数组需要是同1种数组类型，如果是无约束数组，数组的元素的个数要相等。如：

  ```
  My_Name : String (1..10) := "Dale ";
  Your_Name : String (1..10) := "Russell ";
  Her_Name : String (21..30) := "Liz ";
  His_Name : String (1..5) := "Tim ";
  Your_Name := My_Name;
  Your_Name := Her_Name; -- 合法的,它们的元素个数和类型相同
  His_name := Your_name; -- 会产生错误,类型虽然相同，但长度不同
  ```

###### 等式与不等式

- 数组也可以使用运算符 = ，/=,<=,>=,<,> ，但意义与单个元素使用这些运算符不一样。如：

  ```
  Your_Name = His_Name --返回值为 False
  ```

- =,/= 比较两个数组中每个元素的值。如果两个数组相对应的元素值---包括数组长度都相等，则这两个数组相等，否则不相等。

  ```
  Your_Name < His_Name --返回值为 True
  ```

- <=,>=,>,< 实际上比较数组中第一个值的大小，再返回True或Fasle，数组长度不一样也可比较。

###### 连接符

- 连接符为 & ,表示将两个数组类型相“串联”。如：

  ```
  His_Name & Your_Name --返回字符串 "Tim Russell"
  type vector is array(positive range <>) of integer;
  a : vector (1..10);
  b : vector (1..5) := (1,2,3,4,5);
  c : vector (1..5) := (6,7,8,9,10);
  a := b & c;
  则 a =( 1,2,3,4,5,6,7,8,9,10);
  如果再添一句：
  a := a (6..10) & a(1..5);
  ```

  - 则 a =(6,7,8,9,10,1,2,3,4,5)。这种情况也有点特殊，虽然 a(1..5) 看上去接在 a(10) 后面，实际上 a(6..10)和a(1..5)连接重新组合成一个10个元素的数组，再赋该值给 a。这种用法在 Ada83 里是认为不合法的，因为它认为 a(1..5) 是接在 a(10) 之后，而 a 只有10 个元素，不是 15 个。

##### 数组属性

- 数组属性有以下一些，A 表示该数组：

  ```
  A'First 返回 A 的下标范围的下限。
  A'Last 返回 A 的下标范围的上限。
  A'Range 返回 A 的下标范围，等价于 A'First .. A'Last。
  A'Length 返回 A 中元素的数目。
  
  下面的是为多维数组准备的：
  A'First(N) 返回 A 中第 N 个下标范围的下限。
  A'Last(N) 返回 A 中第 N 个下标范围的上限。
  A'Range(N) 返回 A 中第 N 个下标范围，等价于 A'First(N) .. A'Last(N)。
  A'Length(N) 返回 A 中第 N 个下标范围所包含元素的数目。
  ```

  如：

  ```
  Rectange : Matrix (1..20,1..30);
  Length : array (1..10) of Integer;
  ```

  因此：

  ```
  Rectange'First (1) = 1; Rectange'Last (1) = 20;
  Rectange'First (2) = 1; Rectange'Last (1) = 30;
  Rectange'Length (1) = 20; Rectange'Length (2) = 30;
  Rectange'Range(1) =1.. 20; Rectange'Range (2) = 1..30;
  Length'First = 1; Length'Last = 10;
  Length'Range = 1..10; Length'Length = 10;
  ```

##### 数组使用注意事项

###### 数组初始化

- 数组在使用时，可以定义一个很大的，但不初始化，只将前面一些初始化，后面没初始化的可能就是一些垃圾值，这样在循环中判断到后面一些值时，可能就会产生CONSTRAINT_ERROR异常，这个异常不只指数组越界异常，当某变量值超过其类型的取值范围时也可以引发。所以在后面的一些使用时，不是数组越界，而是一堆垃圾值导致超过类型的取值范围引发。
  - 上面这种情况，一般在定义数组时，定义一个表示数组最后一个有效值的索引LAST_INDEX，这样在循环中我们只需要循环到这个值就可以了。
  - 或者可以数组全部初始化，然后判断是否等于默认值就可以判断是否有效了。

###### 关于数组的下标

- 在不指定STRING数组下标时

  ```
  procedure MAIN is                                                                                             
  	STR1 : STRING := "abcdedf";                                                                                               
  	STR2 : STRING := STR1(3 .. 5);                                                                                  
  begin                                                                                                                       
  	for INT in STR2'range  loop                                                                                         
  		Put_Line(INT'img);
  	end loop;
  	Put(STR2(3 .. 5));
  end MAIN;
  
  打印值
  3
  4
  5
  cde
  ```

  - 说明如果数组没有指明下标，被赋值的STRING就是给定值的数组下标，例如上面STR2的数组下标为3 .. 5

- 指定STRING的数组下标时

  ```
  procedure MAIN is                                                                                             
  	STR1 : STRING := "abcdedf";                                                                                               
  	STR2 : STRING(1 .. 3) := STR1(3 .. 5);                                                                                  
  begin                                                                                                                       
  	for INT in STR2'range  loop                                                                                         
  		Put_Line(INT'img);
  	end loop;
  	Put(STR2(1 .. 3));
  end MAIN;
  
  打印值
  1
  2
  3
  cde
  ```

  - 在指定数组下标后，数组下标就按照指定的数组下标来，例如上面STR2在声明时指定1 .. 3，所以STR2的数组下标就是1 .. 3

- 赋值时数组下标倒置

  ```
  STR1 : STRING := "abcdedf";                                                                                                   
  STR2 : STRING := STR1(3 .. 0);
  ```

  - 这样倒置的话STR2为空，没有任何值。且数组没有大小，数组无任何值。

#### 记录

- 记录则是由命名分量(named component)组成的复合类型，即具有不同属性的数据对象的集合，和C 下的结构(structure)、Pascal 下的记录(record) 类似。Ada 的记录比它们提供的功能更强，也就是限制更少。同时记录扩展(record extension)是 Ada95 中类型扩展(继承)机制的基础，使记录的地位更加突出，关于记录扩展详见 第6章 面向对象特性，为了避免重复，本章对此不作介绍。

##### 简单记录

- 记录类型的一般声明如下：

  ```
  type record_name is
  record
  field name 1: type 1;
  field name 2: type 2;
  ...
  field name n: type N;
  end record;
  ```

  - record_name 是记录类型的名称，一大堆 filed name 是记录的成员名称，紧跟其后的是该成员的数据类型。

- 如下面的例子：

  ```
  type Id_Card is
  record
  Full_Name : String (1..15);
  ID_Number : Positive;
  Age : Positive;
  Birthday : String (1..15);
  Familiy_Address : String (1..15);
  Family_telephone : Positive;
  Job : String(1..10);
  end record;
  My_Card :Id_Card;
  ```

  - 一个简单ID卡的记录，包含Full_Name,ID_Number,Age,Birthday，Familiy_Address，Family_telephone，Job 这些成员。

##### 访问和设置记录

- 使用记录的成员时，只需在记录和其成员之间用 “.” 隔开即可。如赋予My_Card中的变量 Full_Name 值 Jack Werlch:

  ```
  My_Card.Full_Name := "Jack Welch ";
  ```

- 设置记录成员的值和设置数组给人感觉上有点类似,如：

  ```
  My_Card := ("Jack Welch ", 19830519，45， "Jan 1st 1976 ",
  "China "，8127271，"CEO ");
  ```

  - 将 ( )中的值依次赋给My_Card 的成员。

- 相同的数据类型的成员一多，无疑会使人不大明了，因此也可以：

  ```
  My_Card := ( Full_Name => "Jack Welch ",
  ID_Number => 19830519,
  Age => 45,
  Birthday => "Jan 1st 1976 ",
  Familiy_Address => "China ",
  Family_telephone => 8127271;
  Job => "CEO ") ;
  ```

- 上面两种表示法可以混用，但按位值在有名的值前面：

  ```
  My_Card := ( "Jack Welch ",
  19830519,
  Age => 45,
  Birthday => "Jan 1st 1976 ",
  Familiy_Address => "China ",
  Family_telephone => 8127271;
  Job => "CEO ");
  ```

- 但如果为:

  ```
  My_Card := ( Full_Name => "Jack Welch ",
  ID_Number => 19830519,
  Age => 45,
  Birthday => "Jan 1st 1976 ",
  Familiy_Address => "China ",
  8127271;
  "CEO ");
  ```

  - 则是非法的。

- 如果几个相同类型的成员，赋予同一数值，也可以：

  ```
  My_Card := ( Full_Name => "Jack Welch ",
  ID_Number | Family_telephone => 19830519,
  Age => 45,
  Birthday => "Jan 1st 1976 ",
  Familiy_Address => "China ",
  Job => "CEO ");
  ```

  - 上例我们假设 ID_Number 和 Family_telephone 值是一样的，为19830519，不同成员间用 | 隔开。

- 记录类型有时在声明也需要默认值：

  ```
  type Id_Card is
  record
  Full_Name : String (1..100) := "Jack Welch ",
  ID_Number : Positive := 19830519,
  Age : Positive := 45,
  Birthday: String (1..20) := "Jan 1st 1976 ",
  Familiy_Address :String (1..100):= "China ",
  Family_telephone :Positive := 8127271;
  Job : String(1..10) := "CEO ");
  end record;
  My_Card :Id_Card;
  ```

  - 将 Jack Welch 的资料当作了 Id_Card 类型的默认值，My_Card 无须赋值，在声明时已经有了前几个例子中所赋的值。

- 声明常量记录如下：

  ```
  My_Card ：constant Id_Card := ( Full_Name => "Jack Welch ",
  ID_Number => 19830519,
  Age => 45,
  Birthday => "Jan 1st 1976 ",
  Familiy_Address => "China ",
  Family_telephone => 8127271;
  Job => "CEO ";)
  ```

  - 和创建其它类型的常量类似，只需在该记录类型前添个 constant。

##### 变体记录

- 在讲变体记录前，先介绍一下记录判别式(record discriminant)的概念。判别式(discriminant)以前没接触过，这里先简单提一下它的定义：一个复合类型(除了数组)可以拥有判别式，它用来确定该类型的参数(具体参见 RM95 3.7 Discriminant)。也就是说，一个复合类型创建时可以有一些参数，在接下去声明该类型的变量时，可以通过那些参数的值来改变变量初始化时所占用内存大小、成员数量、取值等等。这一节以及下一节的无约束记录(unconstrained record)的内容都在记录判别式的范围内，至于其它复合类型将在以后讲述。

- 变体记录，即它的一些成员存在与否取决于该记录的参数。如我们将 Id_Card 这个记录类型扩充一下：

  ```
  type Id_Card (Age : Positive := 1) is
  	record
  		Full_Name : String(1..15);
  		ID_Number : Positive;
  		Birthday : String(1..15);
  		Familiy_Address : String(1..15);
  		Family_telephone : Positive;
  		Job : String(1..10);
  	case Age is
  		when 1 .. 18 => School_Address : String(1..15);
  		when 19 .. 60 => Monthly_Income : Integer;
  			Working_Address: String(1..15);
  		when others => null; -- 如果 Age 的值不属于 1..60,成员不改变
  	end case;
  end record;
  My_Card : Id_Card ;
  Your_Card: Id_Card (Age => 20);
  ```

  - 上例中，case Age ... end case 是变体部份，当 Age 值在 1..18 时，动态创建成员 School_Address;当 Age 值在 19..60 时，动态创建成员 Monthly_Income，Working_Address;当 Age 不在 1..60 时，数据成员不改动。在声明判别式时一般应赋予一个默认值，如上例 Age 的默认值为 1 ，这样声明变量 My_Card 时不带参数也可以，默认参数为 1。但如果 Age 没默认值，上例中的 My_Card 声明是非法的。

  - 因此，记录 My_Card 有 Full_Name，ID_Number，Birthday，Familiy_Address，Family_telephone, Job，School_Address这些成员，因为 Age 默认为 1; 记录 Your_Card 中 Age 值为 20，因此有 Full_Name，ID_Number，Birthday，Familiy_Address，Family_telephone, Job， Monthly_Income，Working_Address 这些成员。

- 最后注意一下，变体部份要在记录类型声明的底部，不能在 Job 或其他成员前面---变体记录的变量大小是不定的

- 注意Age变量也是record的一部分，也是占内存的，我们在打印的时候也能打印这个变量值。

##### 无约束记录

- 上面的记录都是受限定的，如 创建 My_Card 后，它的判别式无法再被改动，Monthly_Income，Working_Address这些成员也无法拥有。但如果 ID_Card 的判别式有了初使值，则还有办法使记录动态改变。

  如：

  ```
  type Id_Card (Age : Positive := 1) is
  record
  Full_Name : String(1..15);
  ID_Number : Positive;
  Birthday : String(1..15);
  Familiy_Address : String(1..15);
  Family_telephone : Positive;
  Job : String(1..10);
  case Age is
  when 1 .. 18 => School_Address : String(1..15);
  when 19 .. 60 => Monthly_Income : Integer;
  Working_Address: String(1..15);
  when others => null;
  end case;
  end record;
  ```

  ```
  My_Card : Id_Card ;-- 以上和上一节的例子一样
  
  ....
  
  begin
  
  ...
  
  My_Card := (17, "Jack Welch ", 19830519, "Jan 1st 1976 ", "China ",8127271,
  "CEO ","Shanghai ");
  end;
  赋值的时候就有了点特殊。My_Card 在程序内部赋值，但与常规赋值不同，它的第一个值是判别式的值，后面才是成员的值---成员数量按照判别式的值动态改变，上例就多了一个 School_Address 成员。这种情况下，编译器会分配给 My_Card 可能使用的最大内存空间。因此将下句接在上句后面：
  My_Card := (17, "Jack Welch ", 19830519, "Jan 1st 1976 ", "China ",8127271,
  "CEO ", 78112 ，"Shanghai ");
  也是可行的。
  上面一些记录的例子并不好，成员的数据类型太简单(像生日的数据类型，一般是年月日做成员的一个记录)，字符串类型太多，手工赋值的话还要数一下有几个字符，实际中也很少这样的用法，一般还是用函数来赋值。这点请注意一下。
  ```

##### 判别式的其他用途

- 判别式的另一个用途是动态决定其成员长度，如：

  ```
  type Buffer (Size:Integer) is
  record
  High_Buffer(1..Size);
  Low_Buffer(1..Size);
  end record;
  ```

  - 这样 Buffer 两个成员的大小就取决于 Size 值，在文本处理中这种用法还是挺好的。

##### record和c语言的接口

- ada在创建了一个record类型之后，如果要和c语言接口进行使用，此时就需要决定各个类型占用多少字节，因为c语言每一个数据类型的字节数是固定的，所以我们要规定ada中每一个类型的数据占用的字节数。

  - 例子

  ```
  for myRecord use
      record
          eta    at    8    range    0 .. 31;
          ttg    at    16   range    0 .. 63;
      end record;
  ```

  - eta 从记录开始的字节偏移量 8 的第 0 位开始，一直到第 31 位；即它占用从字节 8 开始的 32 位。

- 变体记录和c的接口

  ```
  type MESSAGE_T(KIND : MESSAGE_KIND_T := ACK) is
      record
        HEADER         : IAC_MESSAGE_HEADER.HEADER_FOR_MMI_MESSAGE_T;
        IPCS           : ARTTS.ARTTS_QUEUEING.TC_IPCS_HEADER;
        NUMBER         : IAC_FLIGHT_PLAN_TYPES.FLIGHT_PLAN_NUMBER_T;
        MODIF_TIME     : ARTTS.ARTTS_TIME.TC_TIME_UNIVERSAL_TIME;
        ETO_MODIF_TIME : ARTTS.ARTTS_TIME.TC_TIME_UNIVERSAL_TIME;
  
        case KIND is
          when ACK              =>
            DATA                  : DATA_T;
          when FLIGHT_DATA      =>
            FP_DATA               : DATA_T;
            CDC_INFOS             : IAC_FDP_TO_MMI_PROP_TYPES.FIELDS_FOR_MMI_T;
          when FORECAST         =>
            FORECAST_INFO         : FORECAST_INFO_T;
          when SUMMARY          =>
            SUMMARY_INFO          : SUMMARY_INFO_T;
          when FLIGHT_PLAN_LIST =>
            FLIGHT_PLAN_LIST_INFO : FLIGHT_PLAN_LIST_INFO_T;
          when MSG_SEARCH_KIND  =>
            MSG_SEARCH_LIST_INFO  : MSG_SEARCH_LIST_INFO_T;
        end case;
      end record;
      
  for MESSAGE_T use
      record at mod 4;
        KIND                  at 0                           range 0 .. 7;
        HEADER                at 4                           range 0 .. 191;
        IPCS                  at 28                          range 0 .. 1_663;
        MODIF_TIME            at 236                         range 0 .. 95;
        ETO_MODIF_TIME        at 248                         range 0 .. 95;
        NUMBER                at 260                         range 0 .. 15;
        DATA                  at START_OF_DATA               range 0 .. DATA_T_SIZE                * STANDARD_TYPES.OCTET - 1;
        FP_DATA               at START_OF_DATA               range 0 .. DATA_T_SIZE                * STANDARD_TYPES.OCTET - 1; 
        CDC_INFOS             at START_OF_DATA + DATA_T_SIZE range 0 .. CDC_INFOS_SIZE             * STANDARD_TYPES.OCTET - 1; 
        FORECAST_INFO         at START_OF_DATA               range 0 .. FORECAST_INFO_SIZE         * STANDARD_TYPES.OCTET - 1; 
        SUMMARY_INFO          at START_OF_DATA               range 0 .. SUMMARY_INFO_SIZE          * STANDARD_TYPES.OCTET - 1; 
        FLIGHT_PLAN_LIST_INFO at START_OF_DATA               range 0 .. FLIGHT_PLAN_LIST_INFO_SIZE * STANDARD_TYPES.OCTET - 1; 
        MSG_SEARCH_LIST_INFO  at START_OF_DATA               range 0 .. MSG_SEARCH_LIST_INFO_SIZE  * STANDARD_TYPES.OCTET - 1; 
    end record;
  
  因为记录是变体的，即里面的东西是可变的，所以在设置时，case后面的一些字段都是从同一个字节开始的。
  ```

- 也可以不是record，也可以是枚举类型，例如

  ```ada
  type TITLES is
        (NONE,
         SYSTEM_MAPS,
         SET_MAPS,
         DAIW_MAPS,
         DTZ_MAPS,
         NTZ_MAPS,
         RESTRICTED_MAPS,
         SYSTEM_MAPS_LIST,
         SYSTEM_MAPS_COLOURS);
  
    for TITLES use (NONE                => 0,
                    SYSTEM_MAPS         => 1,
                    SET_MAPS            => 2,
                    DAIW_MAPS           => 3,
                    DTZ_MAPS            => 4,
                    NTZ_MAPS            => 5,
                    RESTRICTED_MAPS     => 6,
                    SYSTEM_MAPS_LIST    => 7,
                    SYSTEM_MAPS_COLOURS => 8);
  
    for TITLES'SIZE use 32;
  ```

  - 因为我们的枚举和c语言的枚举不一样，c语言的枚举是一个整形，所以上面这是让我们的枚举变成整形，最后在cdc中占用4个字节。可以看一下iac_ssr_code_cdc_types.a文件ECR_SKYNETX_36
  - 这个枚举这样写就是确定在内存中占用的字节数和具体每一个元素代表的值，和c语言的枚举类型对应起来。如果c语言不需要，只是我们内部ada使用，也就不用写后面的for use了。
  - 枚举类型的for use使用是确定占用内存数，和每一个元素代表的整形值，record也是确定占用多少字节，和结构中每一个元素占用的大小。这两个要区分开，两个的写法也不一样，record可以包含枚举。但是枚举也需要像这样写好，然后在record中在确定字节数。

- 在我们ada和c的通信中，有两种类型，一种就是我们直接通过ada写进文件或者内存中，然后c在直接按照c的读出来即可，只要按照for use这种数据大小对应好就行。上面这种主要就是fifo和cdc中，ada和c是各干各的，不会说ada调用c的接口写进去。

  - 第二种就是写进ACF文件中，c定义了一个结构，和ada的不一样，然后我们ada调用c的接口写进去，这时候也是需要内存对应好的，例如c里面bool类型是4个字节，ada中boolean是1个字节，这时候就需要转换一下，将ada中的转换为c的bool，然后写进去。因为结构是c定好的，我们只能按照c的结构来。ada调用c的接口，形参类型都是指针。

- 我们的代码的例子

  ```ada
  type CONFIGURATION_POSITION_ITEM_T(POSITION_CATEGORY : POSITION_CATEGORY_T := POSITION_CATEGORY_DEF)
              is
      record
        LOGICAL_POSITION_NAME  : LOGICAL_POSITION_NAME_T;
        PHYSICAL_POSITION_NAME : PHYSICAL_POSITION_NAME_T;
        PADDING_1              : PAD_BYTE_T;
        POSITION_ROLE          : POSITION_ROLE_T;
        PADDING_2              : PAD_BYTE_T;
        case POSITION_CATEGORY is
          when POSITION_IS_EC =>
            PLC_LOGICAL_POS_NAME : LOGICAL_POSITION_NAME_T;
          when POSITION_IS_PLC =>
            DEFAULT_EC_LOGICAL_POS : LOGICAL_POSITION_NAME_T;
          when others =>
            DUMMY : LOGICAL_POSITION_NAME_T;
        end case;
      end record;
  
    for CONFIGURATION_POSITION_ITEM_T use
      record
        LOGICAL_POSITION_NAME  at 0  range 0 .. 39;
        POSITION_CATEGORY      at 8  range 0 .. 7;
        PHYSICAL_POSITION_NAME at 12 range 0 .. 39;
        PLC_LOGICAL_POS_NAME   at 20 range 0 .. 39;
        DEFAULT_EC_LOGICAL_POS at 20 range 0 .. 39;
        DUMMY                  at 20 range 0 .. 39;
        PADDING_1              at 25 range 0 .. 23;
        POSITION_ROLE          at 28 range 0 .. 7;
        PADDING_2              at 29 range 0 .. 23;
      end record;
    for CONFIGURATION_POSITION_ITEM_T'SIZE use 32 * STANDARD_TYPES.OCTET;
    
    
    LOGICAL_POSITION_NAME_LENGTH : constant := 5;
    subtype LOGICAL_POSITION_NAME_T is STRING (1 .. LOGICAL_POSITION_NAME_LENGTH);
  
  ```

  - 例如上面LOGICAL_POSITION_NAME占用了5个字节，每一个字节8bits，所以从0到39正好40个bits，其他的多余的是补充字节，和c对应。
  - 一般在用这种结构的时候定义一个S'Size这个确定字节数。

#### 控制结构

- 在 Ada 子程序的 “**is**”和“**end**”之间，是一组有序语句，每句用双引号；结束。这些语句大致可分成三种控制结构：顺序结构，选择结构，循环结构----如果按照前辈们辛辛苦苦的证明：任何程序都可以只由这三种结构完成。以前我们见过的简单程序都是顺序结构，本章里会介绍一下 Ada 里选择结构的if、case 语句和循环结构的 loop 语句及其变种，并介绍顺序结构中以前没讲过的 null 和块语句(block statement)，最后是比较有争议的 goto 语句---好像每本教科书上都骂它，说它打破了程序的良好结构。控制结构是一门老话题，Ada95 对它也没作多大改动，语法上和其它语言还是很接近的，但可读性好一点，所有控制结构后都以"**end** something"结束。

##### if语句

-  if 语句判断一个条件是否成立，如果成立，则执行特定的语句，否则跳过这些语句。一般格式如下：

  ```
  if condition then
        statements
  end if;
  ```

  -   当 *condition* 的值为 True 时,则执行 *statements*,否则跳过 *statements*，执行“end if”后面的语句。

-   如果当 *condition* 为 False 也要执行特定语句，则用下面的格式：

  ```
  if condition then
       statements
  else
         other statements
  end if;
  ```

  -   这样当条件不成立时，执行*other statement*,而不是跳过 if 结构。

-   下面一种格式是为了多个条件判断而用，防止 if 语句过多:

  ```
  if condition then
     statements
  elsif condition then
    other statements
  elsif condition then
     more other statements
  else
    even more other statements
  end if;
  ```

  -   使用 elsif 的次数没有限制，注意 elsif 的拼写----不是elseif。在这里需要注意一下*condition* 的值，一定要为布尔型，不像 C 里面，随便填个整数也没事。

-   下面以简单的一个例子来解释一下 if 语句：

  ```
  000 -- filename: ifInteger.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure testrange is
  004       Var : Integer;
  
  005 begin
  006       Put ("Enter an Integer number to confirm its range:");
  007       Get (Var);
  
  008      if Var in Integer'First .. -1 then
  009             Put_Line ("It is a negative number");
  010      elsif Var in 1 .. Integer'Last then
  011            Put_Line ("It is a positive number");
  012      else
  013             Put_Line ("It is 0");
  014      end if;
  015 end testrange; 
  ```

  - [007] 输入值 Var;[008]-[014]的语句都是测试 Var 的范围，如是负数则输出"It is a negative number",正数输出"It is a positive number",为0则输出"It is 0"，以上3种情况如果都没产生，则是因为输入值非 Integer 类型或输入值过大，从而产生异常。

##### case语句

- 如果所要判断的变量有多种可能，并且每种情况都要执行不同的操作，if 语句很显然繁了一点，这时就使用 case 语句，格式为：

  ```
  case expression is
     when choice1 => statements
     when choice2 => statements
       . . .
     when others => statements
  end case;
  ```

  -   判断 expression 的值，如符合某项choice，则执行后面的statement,如果全都不符合时，就执行 **others** 后的语句。choice 的值不能相同。**when others** 也可以没有，但不推荐这样做，以免有没估计到的情况产生。因此上例也可改成：

  ```
  000 -- filename: ifInteger.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure testrange is
  004     Var : Integer;
  005 begin
  006        Put ("Enter an Integer number to confirm its range:");
  007        Get(Var);
  008     case Var is
  009          when Integer'First .. -1 =>
  010                                        Put_Line ("It is a negative number");
  011       when 1 .. Integer'Last =>
  012                     Put_Line ("It is a positive number");
  013       when others =>
  014                     Put_Line ("It is 0");
  015    end case; 
  016 end testrange;
  ```

  - 与前面的例子完全等效。
  - ada中的case和c语言中的switch不一样，ada中的when条件可以是一个值，也可以是一个范围，从上面就可以看到。相当于in运算符也可以，所以我们可以用数字，然后用范围作为when的条件，也可以用枚举，然后用枚举的范围做一个when的条件，也可以直接用一个值，不用范围。两者可以交叉使用。

##### loop语句

- 很多情况下，我们要反复执行同一操作，无疑这时要使用循环结构。循环结构除了最简单的loop语句，还有其变种for 和while语句。

-   最简单的loop语句格式为：

  ```
  loop 
     statements
  end loop; 
  ```

-   当要退出该循环时，使用 exit 或 exit when 语句。exit表示直接退出该循环，exit when则在符合 when 后面的条件时再退出。再将testrange 改动一下，来了解loop和exit语句。

  ```
  000 -- filename: ifInteger.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure testrange is
  004     Var : Integer; 
  005 begin
  006    loop
  007        Put ("Enter an Integer number to confirm its range:"); 
  008        Get(Var);
  009       case Var is
  010          when Integer'First .. -1 =>
  011                         Put_Line ("It is a negative number"); 
  012          when 1 .. Integer'Last =>
  013                         Put_Line ("It is a positive number");
  014          when others =>
  015                         Put_Line ("It is 0");
  016       end case; 
  017       exit when Var = 0;
  018    end loop;
  019 end testrange;
  ```

  - 上例循环输出"Enter an Integer number to confirm its range:"，要求输入一个整数；当输入值为0时，输出"it is 0",再退出。

##### for循环

- for 循环只是loop的变种，格式如下：

  ```
  for index in [reverse] range loop
      statements;
  end loop;
  ```

  - reverse 是可选的.
  - for循环后面跟随的range也可以用一个subtype写一个类型，此时直接写这个类型，就不用手写范围了  1 .. ---

-   注意一下，*index* 是for循环中的局部变量，无需额外声明，只需填入一个合法的标识符即可，在for循环内，不能修改*index*的值。*index*的值一般情况下是递增加1，如 **for** i **in** 1..100,i的初值为1，每循环一次加1，直至加到100，循环100次结束；有时也需要倒过来，如i初值为100,减到1，则为 **for** i **in reverse** 1..100。但*range*中较大值在前则该循环不进行，如 **for** i **in [reverse]**100..1,循环内语句会略过---即变成了空语句。

  -   仍旧是通过修改testrange来了解for:

  ```
  000 -- filename: ifInteger.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure testrange is
  004     Var : Integer; 
  005 begin
  006    for i in 1..10 loop
  007        Put ("Enter an Integer number to confirm its range:"); 
  008        Get(Var);
  009       case Var is
  010          when Integer'First .. -1 =>
  011                      Put_Line ("It is a negative number"); 
  012          when 1 .. Integer'Last =>
  013                      Put_Line ("It is a positive number");
  014          when others =>
  015                      Put_Line ("It is 0");
  016       end case; 
  017       exit when Var = 0;
  018    end loop;
  019 end testrange;
  ```

  - 如果不输入0，在输入10次整数后，该程序会自动结束。

##### while循环

-  while 循环则在某条件不成立时结束循环，其格式为：

  ```
  while condition loop
      statements
  end loop;
  ```

  -   *condiotion* 和 if 语句中的 *condition* 一样，都要求为布尔值，在其值为 False 时，循环结束。
  -   还是老套的testrange:

  ```
  000 -- filename: ifInteger.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure testrange is
  004     Var : Integer; 
  005 begin
  006    while Var /= 0 loop
  007        Put ("Enter an Integer number to confirm its range:"); 
  008        Get(Var);
  009       case Var is
  010          when Integer'First .. -1 =>
  011                      Put_Line ("It is a negative number"); 
  012           when 1 .. Integer'Last =>
  013                      Put_Line ("It is a positive number");
  014          when others =>
  015                      Put_Line ("It is 0");
  016       end case; 
  017    end loop;
  018 end testrange;
  ```

  - 这里取消了**exit when**语句，由while语句来检测Var的值。当Var值为0时，循环结束。

##### null语句

-  **null** 语句所做的事就是不做事，大部份情况下就等于没写；但在一些情况下，还是有其作用,如**if** var > 0 **then null end if**,如果没有 **null**，则属于语法错误，缺少了语句。因此 **null** 用在语法上要求必须有语句，但又不想让程序干什么事的时候。

##### 块语句

- 块语句(block statement),就是以一组语句为单位，当作一个独立的块,也常用在循环中，格式为;

  ```
  identifier:
      [declare]
     begin
          statements
      end indentifier;
  declare是可选的，如：
  Swap:
    declare
        Temp :Integer;
    begin
        Temp := V; V:=U; U:=Temp;
    end Swap;
  ```

  -   块语句可以写identifier也可以不写，declare下面跟变量的定义什么的
  -   快语句的主要作用为可以在declare下面定义一些局部变量，这样就可以在用的时候在定义，不用直接写到大函数的begin前面了。
  -   其中的Temp为局部变量，Swap 外的语句无法访问它，Temp也可写成Swap.Temp,以此从形式上区分局部变量和全局变量。块语句的用法，还是通过实例来讲解方便：

  ```
  000 -- filename: swap.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure Swap is
  004     V:Integer := 1;
  005     U:Integer := 2;
  006 begin
  007     PutVU1:
  008       begin 
  009             Put("V is:"); Put(V); New_Line;
  010             Put("U is:"); Put(U); New_Line;
  011       end PutVU1; 
  012     Swap:
  013       declare 
  014           Temp :Integer;
  015       begin
  016           Temp := V; V:=U; U:=Temp;
  017       end Swap; 
  018     Put_Line ("After swap");
  019     PutVU2:
  020       begin 
  021             Put("V is:"); Put(V); New_Line;
  022             Put("U is:"); Put(U); New_Line;
  023    end PutVU3; 
  024 end Swap;
  ```

- 通过上面的例子，大家可能感觉没什么意思，块结构可有可无---反正还是按语句的先后顺序执行。但如果它用在循环结构中，则还有点用处：

  ```
  Main_Circle:
     begin
     loop
         statements;
        loop 
            statements;
           exit Main_Circle when Found;--* 如果 Found 为 True，则跳出 Main_Circle，而不是该句所在的小循环
            statements;
        end loop;
         statements;
     end loop;
  end Main_Circlel;
  ```

  - 这样就能跳出一堆嵌套循环,接下去执行的语句都在跳出的循环后面。

##### goto语句

- goto 语句能直接跳到程序的某一处开始执行，使程序结构松散很多，有关编程的教材基本上将它作为碰都不能碰的东西。但在处理异常情况中，goto 还是很方便的---并被有些权威人士推荐；只要别滥用就可以了。Ada 里goto语句格式为：

  ```
  <<Label>>
     statements;
  goto Label;
  ```

- 如将上例改为：

  ```
  000 -- filename: swap.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure Swap is
  004     V:Integer := 1;
  005     U:Integer := 2;
  006 begin
  007    <<restart>>
  008       PutVU1:
  009         begin 
  010               Put("V is:"); Put(V); New_Line;
  011               Put("U is:"); Put(U); New_Line;
  012         end PutVU1; 
  013       Swap:
  014         declare 
  015               Temp :Integer;
  016         begin
  017               Temp := V; V:=U; U:=Temp;
  018          end Swap; 
  019       Put_Line ("After swap");
  020       PutVU2:
  021         begin 
  022               Put("V is:"); Put(V); New_Line;
  023               Put("U is:"); Put(U); New_Line;
  024         end PutVU2;
  025    goto restart; 
  026 end swap;
  ```

  - 快到程序结尾时，又返回到开头<<restart>>处，因此成了无限循环。goto语句在 Ada 里的限制还是挺多的，如不能跳到if,case,for,while里面和其所在子程序外。

#### 子程序

- 一个程序是由一个或更多的子程序组成，以一个主过程(main procedure)为根本，主过程类似与 C 下的 main 函数。子程序包括过程(proceudre)和函数(function)两类,两者区别在于，过程没有返回值，而函数有返回值。
- 子程序，包括函数和过程，以及下一章所讲述的程序包，是构成 Ada 程序的基础。Ada 提供了一些和 C、Pascal 不同的新特性，如重载、参数模式、分离程序等。

##### 过程

- 过程我们以前已经见过了，但那些都是主过程(main procedure)，即程序的主体部体，作用和C下的 main 函数相似。一般情况下，Ada 程序的主程序名应当和该主程序所在的文件名相同。过程的声明格式如下：

  ```
  procedure procedure_name (parameter_specification);
  ```

  -   它的执行部份则为：

  ```
  procedure procedure_name (parameter_specification) is
      declarations;
  begin
      statements;
  end procedure_name ;
  ```

  -   *procedure_name* 为该过程的名称；*parameter_specification* 是这个过程所要使用的参数，是可选的；*declarations* 是声明一些局部的新类型、变量、函数、过程；*statements* 则是该过程要执行的语句。
  -   没有参数的话括号就不用写了，和c语言不一样

-   下例创建一个比较两数大小，并输出较大值的过程**：**

  ```
  procedure compare (A:Integer; B :Integer) is 
  begin 
     if A > B then 
        Put_Line ("A > B");
     elsif A = B then 
        Put_Line ("A = B");
     else 
         Put_ine ("A <B"); 
     end if;
  end compare;
  ```

-   下例则是完整的程序：

  ```
  000 -- filename:comp.adb;
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure comp is 
  004     procedure compare (A:Integer; B :Integer) is 
  005     begin 
  006        if A > B then 
  007            Put_Line ("A > B.");
  008        elsif A = B then 
  009            Put_Line ("A = B.");
  010        else
  011            Put_ine ("A < B.");
  012        end if;
  013     end compare;
  014 X,Y:Integer;
  015 begin
  016     Put ("Enter A:"); Get (X);
  017     Put ("Enter B:"); Get (Y);
  018    compare (X,Y);
  019 end comp;
  ```

  -   通过上例，对过程的用法应该会有基本的了解了。因为 compare 的执行部分是在 comp 内部，所以我们无须给出单独的 compare 声明，如果要加一句**"procedure** compare (A:Integer; B :Integer)；"，程序还是老样子。声明部份和执行部份一般在使用程序包时分离。其中Put_Line，Get也都是预定义的过程。

##### 函数

- 函数和过程也很像，只是它还要有返回值，和 C 很相似，也用 return 来返回函数值。声明格式为：

  ```
  function function_name (parameter_specification) return return_type;
  ```

  - 执行部份为：

  ```
  function function_name (parameter_specification) return return_type is
    declarations;
  begin
    statements;
    return return_value;
  end function_name;
  ```

  -   *function_name* 为该函数的名称；*parameter_specification* 是这个函数所要使用的参数，是可选的；*declarations* 是声明一些局部的新类型、变量、函数、过程；*statements*则是该函数要执行的语句。**return** 返回一个数据类型为*return_type*的return_value

-   将上一节的 comp 程序改动一下：

  ```
  000 -- filename:comp.adb;
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure comp is 
  004    function compare (A:Integer; B :Integer) return Integer is 
  005    begin 
  006       return (A - B);
  007    end compare;
  008 X,Y,Result:Integer;
  009 begin
  010     Put ("Enter A:"); Get (X);
  011     Put ("Enter B:"); Get (Y);
  012     Result := compare (X,Y);
  013    case Result is
  014       when Integer'First..-1 => Put_Line (" A < B.");
  015        when 0 => Put_Line (" A = B.");
  016       when 1..Integer'Last => Put_Line (" A > B.");
  017       when others => null;
  018    end case;
  019 end comp;
  ```

  -   上例应该还能说明函数的特点。因为函数是返回一个值，所以在变量声明中赋予初始值时，也可用函数作为所要赋的值，如返回当前时间的 Clock 函数，可以直接在初始化某变量时作为要赋的值：Time_Now :Time:= Clock。与过程一样，在上述情况下，单独的函数声明可有可无。还有一点就是函数、过程的嵌套，上面两个例子就是过程包含过程，过程包含函数，可以无限制的嵌套下去---只要编译器别出错。

##### 参数模式

- 在上面的例子中，我们对函数或过程的参数并没做什么修饰，只是很简单的说明该参数的数据类型，但有时候，我们要设置参数的属性---函数和过程是否能修改该参数的值。一共有三种模式：**in**,**out**,**in out**。

###### **in** 模式

-   默认情况下，函数和过程的参数是 **in** 模式，它表示这个参数可能在子程序中被使用，但值不能被子程序改变。如我们写一个略微像样点的swap函数：

```
000 filename:swap.adb
001 with Ada.Text_IO; use Ada.Text_IO;
002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

003 procedure Swap is 
004    procedure Swap ( A: in Integer;B: in Integer) is
005        Temp :Integer;
006    begin
007        Temp := A; A:= B; B :=Temp;
008    end Swap; 
009 X,Y:Integer; 
010 begin
011    Put ("Enter A:"); Get (X); 
012    Put ("Enter B:"); Get (Y);
013    Put ("After swap:"); New_Line;
014    swap(X,Y);
015    Put ("A is "); Put (X); New_Line;
016    Put ("B is "); Put (Y); New_Line;
017 end Swap;
```

-   上例的程序是无法编译通过的，因为Swap的两个参数 A 和 B 都是 **in** 模式，在这个子过程中无法修改X,Y的值，也就无法互换这两个值。这时就要使用 **in out** 模式的参数。

###### in out 模式

-   **in out** 模式表示该参数在这个子程序中既可修改又可使用。如只要将上例的[004]改为：**procedure** Swap ( A: **in out** Integer,B: **in out** Integer) **is;**该程序便能编译通过，运行正常。

###### out 模式

-   单纯的 **out** 模式表示该参数在这个子程序中可以修改，但不能使用。如求和的 add 过程：

```
procedure Add (Left ,Right : Integer; Result : out Integer) is
begin
Result := Left + Right;
end Add；

这个过程没问题，但假如还有个输出过程为：
procedure PutResult ( Result : out Integer) is

Temp : Integer := Result;
begin
Put (Temp);
end PutResult;
```

- 则会产生问题，虽然编译可能通过，但结果是不定的，最起码不是所指望的结果，因此 **out** 模式的参数不能赋值给其它变量。单独的 out 模式一般也不会出现。

- 上面也指出out模式的参数不能赋值给其他变量，相当于out类型的变量在函数里面是一个垃圾值，并不是传进来的那个值，所以out类型的参数要在函数里面先初始化。如果函数里面没有初始化，也没有进行其他操作，出来的就是一个垃圾值，例如

  ```
      1 with Ada.Text_IO; use Ada.Text_IO;                                                                                     
  --  2 with Interfaces; use Interfaces;                                                                                       
      3                                                                                                                         
      4 procedure MAIN is                                                                                                       
      5     procedure TEST (NBR : out INTEGER) is                                                                             
      6     begin                                                                                                               
      7         null;                                                                                                           
      8     end TEST;                                                                                                           
      9     A : INTEGER := 1;                                                                                                   
     10 begin                                                                                                                   
     11     TEST(A);                                                                                                           
     12     Put(A'img);                                                                                                         
     13 end MAIN; 
  ```

  - 上面这个测试程序执行结果`-1308531608`，是一个垃圾值，所以out类型的表示传出去，并不保证传进来的值，所以要保证是传进来的值，类型要设置为in out，这样传进去的是1，没有进行任何操作，传出来的也是1

##### 调用子程序

- 调用子程序最简单的方式就是按照子程序声明的格式调用，如前例的procedure swap(A:Integer;B:Integer),只要填入的参数是Integer类型，便能直接使用 swap (A,B)。注意调用子程序时参数之间用“,”隔开;同类型的参数在声明时也可简化，如procedure swap(A,B:Integer)。但使用参数时还有下列几种特殊情况.

###### 有名参数

-  我们也可以不按照参数顺序调用子程序。如调用 swap 也可以这样: swap(B => Y, A => X),这时是使用有名参数，明确声明每个变量的值，可以不按照子程序声明中的参数顺序赋值。这样的做的话可读性是好了一点,比较适合参数较多的情况。

-   如果将有名参数和位置参数一起混用，只需遵守一条规则：位置参数在有名参数前面。因此 swap 的调用有以下几种情况：

  ```
  swap(x , y);
  swap(A => x , B => y);
  swap(B => y , A => x);
  swap(x, B => Y);
  ```

  -   上述四种情况是一样的。下列两种情况是非法的：

  ```
  swap(y, A => x);---不合法
  swap(A => x , y); ---不合法
  ```

###### 默认参数值

-  在声明某个子程序时，我们也可以使参数具有默认值，如下例：

  ```
  000 -- filename:putlines.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure putlines is 
  004    procedure putline(lines: integer:=1) is
  005 	begin
  006        for count in 1..lines loop
  007           New_Line;
  008        end loop;
  009    end putline;
  010    Line :Integer;
  011 begin
  012    Put ("Print Lines :"); Get (Line);
  013    putline;
  014 end putlines;
  ```

  -   实际上[012]可有可无，因为调用输出行函数 putline 时，没用参数。而 putline 在声明时赋予了参数 lines 一个默认值 1，这样的话如果调用 putline 没用参数，就以 1 作为参数值。上例也就只输出一个空行。如果putline有参数，如putline(Line),则输出的行数取决于 Line 的数值。

##### 重载

- 子程序重载

  -  实际上通过先前的一些例子，细心的朋友可能发现，过程 Put 能处理不能类型的参数，不像 C 下的 printf 要选择输出类型，这就涉及到子程序重载：只要参数不一样，子程序可以有相同的名称。如在程序包Ada.Text_IO里的两个过程:

    ```
    procedure Put (Item : in Character);
    
    procedure Put (Item : in String);
    ```

  - 编译器会自动选择合适的子程序，如果Put后面的参数为 Character类型，则调用**procedure** Put (Item : **in** Character);为 String 类型，则调用**procedure** Put (Item : **in** String)。这样在用户层上使用子程序简便了许多，很多常见的子程序:Get,Put_Line,Line, Page都是这样实现的----虽然在预定义程序包内针对不同参数都有一个子程序与之相对应,用户却只要记住一个名称就可以了。

- 如果重载的子程序参数类型是同一个类型的subtype，这样重载也不会成功，相当于重复定义

  ```
  subtype A is INTEGER_32;
  subtype B is INTEGER_32;
  
  procedure SET(VAL1 : A) is
  begin
     null;
  end SET;
  
  procedure SET(VAL1 : B) is
  begin
     null;
  end SET;
  ```

  - 上面这种定义不成功，因为A和B都是从INTEGER_32 subtype，相当于重复定义了。

    ```
    error: duplicate body for "SET" declared
    ```

- 运算符重载

  - 运算符重载应该说时时刻刻都在----不同的数据类型都拥有相同的运算符:+,-,*,/等。它的原理和子程序重载是一样的，在 Ada 里，运算符也是通过子程序形式来实现。下面就给出一个“+”和 put 重载的例子：

    ```
    000 -- filename: overload.adb
    001 with Ada.Text_IO; use Ada.Text_IO;
    002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
    
    003 procedure overload is
    004    type Vector is array (1 .. 5 ) of Integer;
    005     a, b, c :Vector;
    
    006    function "+"(left,right:Vector) return Vector is
    007        result : Vector ;
    008    begin
    009       for i in left'range loop
    010           result(i) := left(i) + right(i);
    011       end loop;
    012       return result;
    013    end "+";
    
    014    procedure Put (Item : Vector) is
    015    begin
    016       for i in Item'range loop
    017           Put (Item(i));
    018       end loop;
    019    end Put;
    020 begin
    021    a := (1,2,3,4,5);
    022    b := (1,2,3,4,5);
    023    c := a + b;
    024    Put (c);
    025 end overload;
    ```

  -   上例为了简化问题，有些实际中应该有的代码去除了----如检测所操作数的类型。但其它类型的运算符和重载子程序实现原理也和上例一样。

##### 分离子程序

- Ada 还允许子程序分成多个部份，而不是像以前的例子一样都塞在同一文件里，如将上例分成两个文件：

  - 第一个文件：

  ```
  000 -- filename: overload.adb
  001 with Ada.Text_IO; use Ada.Text_IO;
  002 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  
  003 procedure overload is
  004    type Vector is array (1 .. 5 ) of Integer;
  005     a, b, c :Vector;
  006    function "+"(left,right:Vector) return Vector is
  007        result : Vector ;
  008    begin
  009       for i in left'range loop
  010           result(i) := left(i) + right(i);
  011       end loop;
  012       return result;
  013    end "+";
  014    procedure Put (Item : Vector) is separate;
  015 begin
  016    a := (1,2,3,4,5);
  017    b := (1,2,3,4,5);
  018    c := a + b;
  019    Put (c);
  020 end overload;
  第二个文件：
  000 --filename:overload-put.adb
  001 separate (overload)     -- *注意结尾没有分号；
  002 procedure Put (Item : Vector) is 
  003 begin
  004    for i in Item'range loop
  005       Put (Item(i));
  006    end loop;
  007 end Put;
  ```

  - 这个程序和先前那个完全一样，只是"分了家"而已。这样分离程序有时能更好的分解程序的任务，使程序结构更为清楚。注意一下overload.adb的[014] 和 overload-put.adb的 [001]，这两句就是分离子程序的主要语句。

##### 子程序的内嵌扩展

- 子程序可以在调用地点被内嵌扩展，以提高程序效率，它的格式为：

  ```
  pragma Inline(name);
  ```

  - 如果name是一个可调用的实体，子程序或类属子程序（见第１１章），那么 pragma Inline　指示在所有调用该实体的地方要求对该实体进行内嵌扩展。这在封装其它语言的接口时，使用的比较多，以提高效率。

#### 程序包

- 多子程序封装在一个文件里过于庞大，且分类不清，这时就使用了程序包（package),作为一种分组机制，将子程序归类封装成独立的单元。Ada 的程序包机制主要受 Pascal 及 70 年代时的软件工程技术影响。当时很主要的一项革新就是软件包的概念。软件包使一个大程序分离成了多个单元，使软件维护更加方便，可重用性也更高，是结构化编程思想中必不可少的一部份。
-   软件包并不关心程序是如何运行的，而是在于理解程序是如何构成的以及维护性。Ada 的程序包是定义一堆相关实体（如数据类型、运算符、子程序）的最基本单元，也是使用最常用的编译单元之一。本章里我们介绍程序包的常见用法，更多的内容，如类属程序包，请参见后面的章节。

##### 程序包的声明

- 程序包一般分为两部份，声明部分和执行部份。声明部份声明子程序、变量等实体，他们通常被称为资源；而执行部份则是声明部分中实体的实现。它们的扩展名一般情况下分别为 ads 和 adb。为了省力点，我们就直接将上一章的overload 做个处理，将"+"和Put封装在程序包内,这样程序包说明如下：

  ```
  000 --filename:overload.ads
  001 package Overload is
  002    type Vector is array (1 .. 5 ) of Integer;
  003    function "+"(left,right:Vector) return Vector;
  004    procedure Put (Item : Vector) ;
  005 end Overload;
  ```

-   从这个例子，我们应该知道了程序包说明的格式：

  ```
  package packgae_name is
    statements;
  end package_name;
  ```

  -   *statemets*就是数据类型、变量、常量、子程序的声明。

##### 程序包的主体部分

- 仅仅有说明部份，程序包还没什么用处，还要有它的主体部份，即说明部份的具体实现。主体部份可以包含创建数据类型、子程序、变量、常量。它的格式为:

  ```
  package body packgae_name is
      statements1;
  [begin]
      statements2;
  end package_name;
  ```

  -   *statements1* 是创建子程序、数据类型、变量、常量的语句，一般情况下是说明部份的具体实现；**[begin]**是可选的，它后面的*statement2* 是程序包的初始化语句，在主程序执行前开始执行。

-   所以上例 overload 的主体部分为：

  ```
  000 -- filename:overload.adb
  001 with Ada.Integer_Text_IO; use Ada.Integer_text_IO;
  
  002 package body Overload is
  003    function "+"(left,right:Vector) return Vector is
  004        result : Vector ;
  005    begin
  006       for i in left'range loop
  007           result(i) := left(i) + right(i);
  008       end loop;
  009       return result;
  010    end "+";
  011    procedure Put (Item : Vector) is
  012    begin
  013       for i in Item'range loop
  014           Put (Item(i));
  015       end loop;
  016    end Put;
  017 end Overload;
  ```

- 这里我们没有使用可选的 [**begin**] *statement2*，因为没有必要做一些初始化操作。下面是一些注意点：

  1.主体部分内的资源不能被其它程序包所引用，会引起编译错误。

  2.假如好几个程序包都有初始化语句，执行顺序是不确定的。

  3.所有说明部份内的资源可以被其主体部份直接使用，无须 **with** 和 **use** 语句。

##### 程序包的使用

- 如同我们先前使用 Ada.Text_IO 一样，使用程序包要使用 **with** 和 **use**。**use** 可以不用，但这样的话使用程序包麻烦很多，如 Put ，就要使用 Ada.Text_IO.Put这种详细写法；**use** 使编译器自动在软件包中寻找相匹配的子程序和其它资源。现在将 overload 的主程序给出：

  ```
  000 -- filename: main.adb
  001 with Overload; use Overload;
  
  002 procedure Main is 
  003    a,b,c:Vector;
  004 begin
  005    a := (1,2,3,4,5);
  006    b := (1,2,3,4,5);
  007    c := a + b;
  008    Put (c);
  009 end Main;
  ```

-   编译 main.adb,overload.adb,overload.ads 所得的程序和以前的效果也一样。

-    一般情况下，with 和 use 语句在程序的首部，但 use 语句也可以在程序内部（with 语句则不能），如：

  ```
  000 -- filename: main.adb
  001 with Overload;
  
  002 procedure Main is 
  003    use Overload;
  004    a,b,c:Vector;
  005 begin
  006    a := (1,2,3,4,5);
  007    b := (1,2,3,4,5);
  008    c := a + b;
  009    Put (c);
  010 end Main;
  ```

  -    这种用法很常见，特别是使用类属程序包时。以后我们会见到这方面的其它实例。

- 使用软件包时要注意一下变量、常量等名称的问题，如果有相同的名称，就需要详细写出所期望的资源名称，如程序包 Ada.Text_IO 的 Put 要写为 Ada.Text_IO.Put。如果在 Overload 的声明部份也加一个变量a(2,3,5,6,8)，则声明部份为：

  ```
  000 --filename:overload.ads
  001 package Overload is
  002    type Vector is array (1 .. 5 ) of Integer;
  003     a: Vector := (2,3,5,6,8); 
  004    function "+"(left,right:Vector) return Vector;
  005    procedure Put (Item : Vector) ;
  006 end Overload;
  ```

  -   同时我们希望主程序将两个不同的a分别与b相加，则 Overload 中的 a 要表示为 Overload.a,主程序变为：

  ```
  00 -- filename: main.adb
  001 with Overload; use Overload;
  002 with Ada.Text_IO; use Ada.Text_IO;
  
  003 procedure Main is 
  004    a,b,c:Vector;
  005 begin
  006    a := (1,2,3,4,5);
  007    b := (1,2,3,4,5);
  008    c := a + b;
  009    Put (c); 
  010    New_Line;
  011    c := Overload.a + b; -- Overload.a 表示程序包 Overload中的变量 a 
  012    Put (c);
  013    New_Line; 
  014 end Main;
  ```

  -  明确资源的位置在很多地方都是需要的，都是为了防止相同名称引起混淆。

##### 私有类型和有限专用类型

###### 私有类型

- 到目前为止，我们见过的在程序包内定义的数据类型，只要使用with语句，我们都能对它进行任意的处理，没有什么限制。这在有些情况下，会引起麻烦。比方说创建了一套函数库，如果在该函数库里的数据类型能被用户自由处理----创建新类型，加减乘除运算.....用户又频繁使用的话，会使用户程序相当依赖于这些数据类型，而函数库的创建者为了提高效率或其它什么原因，需要改变这些数据类型---取消，重写或合并，这时用户所写的程序将会遇到很大的麻烦，要么就用旧版的函数库，要么就改写自己的程序-----都是不怎么好的做法。在 Unix 下有 C 语言经验的朋友应该对这所谓的“兼容性”深有体会----系统很无聊的包含了很多只为了兼容性考虑的数据类型、函数，为了移植性，开发稍大一点的软件就多了一些很无谓的“痛苦”。私有类型就是为这种情况产生的：在程序包外，对私有类型数据只能执行 := 和 = 操作，如有其它操作也是程序包内定义的。这样的好处是私有类型不会被滥用，相关的子程序都是程序包创建者定义的，而不是用户。考虑一下下面的账号管理的例子，具体函数实现略，只是象征性的说明一下问题：

  ```
  000 -- filename:account.ads
  001 package Accounts is
  002    type account is private; -- 具体声明在后面
  003     My_Account : constant account;
  004    procedure withdraw(account:in out account; amount :in Positive);
  005    procedure deposit (account:in out account; amount :in Positive);
  006    function create(account:in out account;account_id :Positive) return Boolean; 
  007    function cancel(account:in out account;account_id :Positive) return Boolean;
  008    function balance(account: in out account) return Integer;
  009 private 
  010    type account is 
  011    record
  012        account_id : positive;
  013        balance : integer;
  014    end record;
  015 My_Account:constant account := (78781, 122); 
  016 end accounts;
  ```

  -   过程 withdraw 和 deposit 对帐号进行取款和存款操作，create 和 cancle 对帐号进行创建和注销，balance 返回当前账号的存款额。实际应用中为了提高效率，这种类型的函数库很有可能需要随时升级，使用了私有类型，用户层的麻烦少了不少。

  -   私有类型 account 先简略地声明为类型 private，它的具体声明跟在保留字 private 后，接下去就跟普通数据类型声明一样。account 类型的数据可以在该程序包外包括在主程序中创建，但对它的操作只能是赋值、相等比较及该函数包定义的操作；在该程序包内，则能对私有类型进行任意操作，就好像它不是私有类型一样。在这个例子里，我们还创建了一个 account 类型的常量 My_Account，注意它的声明方式：先是不完全的声明,再在private 部份给出完整声明。不管怎样，用户只能通过函数说明知道有这么个私有类型，却不能过多的使用它。

###### 有限专用类型

- 如果嫌私有类型的 := 和 = 这两个默认操作也多余，则使用有限专用类型。如声明上例的account为有限专有类型：

  ```
  type account is limited private;
  ```

-   其它方面与私有类型一样，只是声明略有不同。对这种数据类型的操作只能由该程序包完全定义，没有了其它默认操作。

-   有时类型定义中还会出现单独的 limited，没有 private，这表示该类型是限制类型，赋值等操作不能作用于该类型变量，但不是“私有”的。

##### 子单元和私有子单元

###### 子单元

- 在一个比较大的软件系统开发中，往往会出现某个程序包变得很大这种情况。对于需要这些新添功能的用户来说，这是好事；而对于其它用户来说，却要花费更多的时间编译更大的程序包，无疑很让人不舒服。在这种情况下，就有了子单元这种处理方法：将逻辑上单一的程序包分割成几个实际上独立的程序包，子单元从逻辑上讲是源程序包的扩展，但却以独立的文件形式存在,如将上例分割：

  ```
  000 -- filename:account.ads
  001 package Accounts is
  002    type account is private; 
  003    My_Account : constant account;
  004    procedure withdraw(account:in out account; amount :in Positive);
  005    procedure deposit (account:in out account; amount :in Positive);
  006    function balance(account: in out account) return Integer;
  007 private 
  008    type account is 
  009    record
  010       account_id : positive;
  011       balance : integer;
  012    end record;
  013    My_Account:constant account := (78781, 122); 
  014 end accounts;
  
  000 --filename:accounts_more_stuff.ads
  001 package accounts.more_stuff is
  002    function create(account:in out account;account_id :Positive) return Boolean; 
  003    function cancel(account:in out account;account_id :Positive) return Boolean;
  004 end accounts.more_stuff;
  ```

  -   程序包 accounts.more_stuff 是accounts的子程序包。这个例子的实际效果与上例一样，包括作用域等等，只是从形式上来说分成了两个不同程序包,编译时也是分别编译。对于用户来讲，使用上的区别还是有一点：

  ```
  with accounts.more_stuff;
  procedure test is
     ...
  begin
     ...
     accounts.more_stuff.create (his_account,7827);
     accounts.deposit(his_account,7000);
     ...
  end test;
  ```

  -   上面虽然只 with 了accounts.more_stuff，但能使用accounts里的资源，默认情况下已作了 with accounts 的工作，如果 accounts 还有其它子单元，则不会自动 with 那些子单元。 use 和 with 不一样，它不会在 use accounts.more_stuff 时默认也 use accounts：

  ```
  with accounts.more_stuff; use accounts; use more_stuff;
  
  procedure test is
     ...
  begin
     create (his_account,7827);
     deposit(his_account,7000);
     ...
  end test;
  ```

  -   子单元的使用应该说还是和原来差不多。另外注意一下，程序使用程序包时会将程序包内的所有子程序都载入内存，因此有内存浪费现象；如果一个程序包内一部份资源使用频率较高，另一部份资源较少使用，则可以将这两部份资源分成两个子单元，以提高效率，这方面的典型情况就是程序包 Characters.Latin_1，Characters.Handling，具体见 第13章。

###### 私有子单元

-   私有子单元允许创建的子单元只能被源程序包所使用，如：

  ```
  000 --filename:accounts_more_stuff.ads
  001 private package accounts.more_stuff is
  002    function create(account:in out account;account_id :Positive) return Boolean;
  003    function cancel(account:in out account;account_id :Positive) return Boolean;
  004 end accounts.more_stuff;
  ```

  -   这样的话 create 和 cancle 对于用户来说是不可见的，只能被程序包 accounts 所使用。

-   子单元除了上述的使用方法外，也可直接在其它程序包内部：

  ```
  package parent_name is
  
  ...
  
  package child_name is
  
  ...
  
  end child_name;
  
  ...
  
  end parent_name;
  ```

#### 访问类型(指针)

##### 创建和使用访问类型

- 如同声明其它数据类型一样，声明访问类型按照下面的格式：

  ```
  type new_type_name is access [all] type_name
  ```

  - new_type_name 是该访问类型名称，type_name 是其它数据类型。all为可选项

    ```
    type List_Node is
    record
    	Data : Integer;
    end record;
    
    type List_Node_Access is access List_Node;
    Current :List_Node_Access;
    ```

  - 创建了访问类型 List_Node_Access，及其变量 Current。变量 Current 的初始值为 null，也就是 Current不指向任何对象，访问值为 null。

- 有关访问类型最常见的一个操作是创建一个对象，返回一个访问值指向这个对象，如同 C 下的malloc,Pascal 和 C++ 的 new，Ada 也有一个操作 new,如：

  ```
  Current := new List_Node;
  Root := new List_Node;
  ```

  - 表示 Current 访问一个 List_Node，Root 访问另一个 List_Node，它们都指向 List_Node 类型的数据在内存中的地址。这些新创建的对象在内存中所占用的空间，不会像整型这些变量一样随着子程序的退出自动消失

- 如果要访问真实的对象，而不是上述的引用，可以用“ .” 访问所指向对象的实际值

  ```
  Current.Data := 1;
  Root.Data := 2;
  ```

  - 表示赋 1 给 Current 所指向的对象的成员 Data ，赋 2 给 Root 所指向的对象的成员 Data。

- 访问类型的变量也可以不指向任何对象，而是 null，只需赋值为 null即可：

  ```
  Current := null;
  ```

- 因此也可以用 = 、 /= 来比较变量值是否为 null，以此来得知某访问类型的变量是否指向一个对象。如果没有指定其它初始值，访问类型的变量被创建时的默认值也为 null。

- 访问类型变量的成员值也可以初始化,如：

  ```
  Current := new List_Node'(1);
  Root := new List_Node'(Data =>2);
  ```

  - 这样的话 Current.Data 的值为 1，Root.Data 的值为 2。假如所指向对像有多个成员，初始化它的值时每个成员都要初始化。

- ada释放指针

  - Ada 提供了一个类属过程来释放一个对象所占用的内存空间，该过程在类属程序包Ada.Unchecked_Deallocation 内定义：

    ```
    generic
    type Object (<>) is limited private;
    type Name is access Object;
    procedure Ada.Unchecked_Deallocation (X : in out Name);
    需要传递参数有两个：一个数据类型 object,以及它的访问类型 Name。出于习惯，我们将回收内存的函数命名为 Free：
    procedure Free is new Ada.Unchecked_Deallocation (List_Node, List_Node_Access);
    或者
    procedure Free is new Ada.Unchecked_Deallocation (Object=>List_Node,Name=>List_Node_Access );
    ```

    - 这样的话，我们就有了处理无用内存的过程 Free,将上一节中的节点释放，只需：

      ```
      Free (Current);
      ```

#### 类属单元

- 代码重用是多年来软件开发一直强调的重点，也是程序员们的一个希望。Ada 里提供了类属单元(Generic unit)的功能,使我们有可能创建更为通用的子程序或程序包。
- 一个类属单元可以是程序包或子程序，允许执行的运算不依赖特定数据类型。比方说一个是类属单元的 Swap 函数，它可以接受 Integer，Float 等各种数据类型的参数，而无需为不同数据类型的参数各写一个 Swap。使用一个类属单元需要设置它的特定数据类型，这个过程称之为实例化(instantiation)，如使用上面所说的 Swap 函数时，要配置它将要处理的数据类型。

##### 类属子程序

- 类属子程序即子程序为类属单元。下面通过一个 Swap 的例子来讲解：

  ```
  000 -- filename:Swap.adb
  001 with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
  002 procedure Swap is
  003 generic
  004 	type Element_Type is private;
  005		procedure Generic_Swap(Left, Right : in out Element_Type);
  006		procedure Generic_Swap(Left,Right:in out Element_Type) is
  007			Temporary : Element_Type;
  008		begin
  009			Temporary := Left;
  010			Left := Right;
  012			Right := Temporary;
  013 	end Generic_Swap;
  014 procedure Swap is new Generic_Swap(Integer);
  015		A, B : Integer;
  016 begin
  017     A := 5;
  018     B := 7;
  019		Swap(A, B);
  020 end Swap;
  ```

- 14行实例化之后，就可以直接使用了，19行直接使用。

- 实例化的参数是里面generic的类型，最后实际使用的时候还要使用函数定义时的类型和数量。

- [003]-[004] 声明一个类属数据类型 Element_Type,[005]声明一个类属子程序 Generic_Swap，它的参数是类属类型(generic type)，[006]-[013] 是 Generic_Swap 函数的具体实现。但这些还不够，Element_Type 并不是什么整型、浮点型等具体数据类型，只是抽象意义上的类属类型，为形式参数。因此还需要[014] 创建实际的子程序 Swap，这里的 Integer 就是一个实际参数,表示 Swap 能接受 Integer 类型的参数，这个步骤称之为实例化。当然为了可以交换浮点等其它数据类型，也可以再添加：

  ```
  procedure Swap is new Generic_Swap(Float);
  ```

- 15行定义整形的A和B是第二行的Swap函数的定义，这个函数如果调用的话只能执行固定的参数，如果我们想在任何地方实例化这个，需要将类属子程序拆分出来，意思为将generic和end generic_swap这部分拆成一个单独的文件，这样我们就可以任意实例化这个类属子程序。

- 拆出来也需要将5行声明写上，声明和定义可以写在一个文件里面。

- 自己的实例

  ```
  with FDP_RETRY;
  use  FDP_RETRY;
  with FPL_OUTPUT;
  
  generic
  
    type MESSAGE_TYPE is private;
    with procedure RECEIVE
        (MESSAGE    :    out MESSAGE_TYPE;
         FIFO_EMPTY :    out BOOLEAN;
         PROCESSING :    out FDP_RETRY.PROCESSING_STATE_T);
    type REPLY_DATA_T is private;
    with function EXTRACT_ISSUER
        (MESSAGE : in     MESSAGE_TYPE)
        return STRING;
    with procedure GET_LAST_SENT_ANSWER
        (GROUP         : in     STRING;
         ANSWER_FIFO   :    out FPL_OUTPUT.TC_FIFO_NAME_TYPE;
         ANSWERED_DATA :    out REPLY_DATA_T);
    with procedure SEND_AGAIN_ACK
        (MESSAGE : in     REPLY_DATA_T;
         GROUP   : in     STRING);
  
  procedure GENERIC_SECURED_RECEPTION
      (MESSAGE :    out MESSAGE_TYPE;
       VALID   :    out BOOLEAN);
  
  with BS_DEFINITIONS;
  with DEBUG;
  with STRING_UTIL;
  procedure GENERIC_SECURED_RECEPTION
      (MESSAGE :    out MESSAGE_TYPE;
       VALID   :    out BOOLEAN) is
  
    FIFO_IS_EMPTY : BOOLEAN := FALSE;
    GENERIC_SECURED_RECEPTION_A_IDENT :
      constant STRING := "@(#) TAAATS PROGRAM FILE generic_secured_reception.a Release 1.1 2/13/98 00:07:27 ~";
    STATE_OF_PROCESSING : FDP_RETRY.PROCESSING_STATE_T;
    MY_MESSAGE          : MESSAGE_TYPE;
  
  begin  -- GENERIC_SECURED_RECEPTION
    RECEIVE(MESSAGE    => MY_MESSAGE,
            FIFO_EMPTY => FIFO_IS_EMPTY,
            PROCESSING => STATE_OF_PROCESSING);
  
    VALID := not FIFO_IS_EMPTY and then STATE_OF_PROCESSING = FDP_RETRY.NEW_MESSAGE;
    if not FIFO_IS_EMPTY
    then
      case STATE_OF_PROCESSING is
        when FDP_RETRY.NEW_MESSAGE =>
          MESSAGE := MY_MESSAGE;
        when FDP_RETRY.MESSAGE_RECEIVED_UNDER_PROCESSING =>
          null;
        when FDP_RETRY.MESSAGE_RECEIVED_ANSWERED =>
          declare
  
            ISSUER_GROUP : STRING (1 .. BS_DEFINITIONS.MAX_GROUP_LG);
            REPLY_FIFO   : FPL_OUTPUT.TC_FIFO_NAME_TYPE;
            REPLY_DATA   : REPLY_DATA_T;
  
          begin
            STRING_UTIL.FILL_STRING
                  (SOURCE => EXTRACT_ISSUER(MY_MESSAGE),
                   TARGET => ISSUER_GROUP);
            GET_LAST_SENT_ANSWER(GROUP         => ISSUER_GROUP,
                                 ANSWER_FIFO   => REPLY_FIFO,
                                 ANSWERED_DATA => REPLY_DATA);
            SEND_AGAIN_ACK(MESSAGE => REPLY_DATA,
                           GROUP   => ISSUER_GROUP);
            DEBUG.DISPLAY("FPL: Auto-repeat of proc result after UBSS secured message repeat");
          exception
            when others =>
              MESSAGE := MY_MESSAGE;
              VALID := TRUE;
          end;
  
      end case;
    end if;
  end GENERIC_SECURED_RECEPTION;
  ```

  ```
  实例化
  procedure RECEIVE_MMI_FLIGHT_PLAN_COMMAND_MSG is new GENERIC_SECURED_RECEPTION
          (MESSAGE_TYPE         => IAC_MMI_TO_FDP_TYPES.MESSAGE_T,
           RECEIVE              => MMI_TO_FDP_FLIGHT_PLAN_COMMAND_FIFO.RECEIVE,
           REPLY_DATA_T         => IAC_FDP_TO_MMI_TYPES.MESSAGE_T,
           EXTRACT_ISSUER       => RX_FIFO.EXTRACT_ISSUER,
           GET_LAST_SENT_ANSWER => MMI_TO_FDP_FLIGHT_PLAN_COMMAND_FIFO.GET_LAST_SENT_ANSWER,
           SEND_AGAIN_ACK       => SEND_AGAIN_MMI_ACK);
  ```

  - 从上面可以看出generic和函数声明的地方之间都是可以传进来的参数，所以with 的那些函数也是可以传进来的，例如上面的实例化。传进来的函数参数类型要和generic定义的一样。

##### 类属程序包

- 如果一个程序包内的子程序都需要成为类属子程序，并且实例化时一次性使整个程序包的子程序能处理所指定的数据类型，使用类属程序包就比较适合。将上例 swap 改动一下：

  ```
  000 -- filename:generic_swap.ads
  001 generic
  002 	type Element_Type is private;
  003 package Generic_Swap is
  004     procedure Generic_Swap(Left, Right : in out Element_Type);
  005 end Generic_swap;
  
  000 -- filename:generic_swap.adb
  001 package body Generic_Swap is
  002 	procedure Generic_Swap(Left, Right : in out Element_Type) is
  003 		Temporary : Element_Type;
  004 	begin
  005 		Temporary := Left;
  006 		Left := Right;
  007 		Right := Temporary;
  008 	end Generic_Swap;
  009 end Generic_Swap;
  
  000 -- filename:integer_swap.ads
  001 with generic_swap;
  002 package Integer_Swap is new Generic_Swap(Integer);
  
  000 -- filename:swap.adb
  001 with Integer_Swap;use Integer_Swap;
  002 procedure swap is
  003 	A, B : Integer;
  004 begin
  005 	A := 5;
  006 	B := 7;
  007 	Integer_Swap(A, B);
  008 end swap;
  
  Integer_Swap是直接用的模板里面的函数，因为模板在integer_swap.ads里面实例化完了，而且Integer_Swap自己是一个package，直接实例化的package，并不是包含在另一个package里面的，所以我们with然后在use可以直接使用里面的函数。
  ```

- 类属程序包实例化是将package实例化，然后我们就可以直接用里面的函数了，里面的函数不用单独实例化。

- 上例的确是有点小题大做了，但说明问题还可以。注意一下 generic_swap.ads 的[001]-[002],在程序包 声明前面的位置声明类属类型，其后的子程序使用这个类属类型，其它方面和普通程序包一样。 integer_swap.ads 是新接触的，[002] 创建程序包 Integer_Swap,是 Generic_Swap 的 Integer 版，即 Integer_Swap 是 Generic_Swap 的一份拷贝，但类型 Element_Type 由 Integer 替换。Element_Type 也可以 由其它数据类型替换，只需按照上面的格式创建程序包即可。需要注意一下 integer_swap.ads 的第一句 with generic_swap,不能再加上 use generic_swap，因为类属程序包是不可用的。

- 上例中还无法见出类属程序包的好处，因为只有一个 generic_swap 过程，但假如程序包内有很多子程 序的代码需要共用，则相当方便。预定义的很多程序包就是这样实现的，例如我们先前遇到的 Ada.Integer_Text_IO 之类的程序包，如果也是每个子程序重写一遍，工作量简直不敢想象，而它们的实现 仅是：

  ```
  with Ada.Text_IO;
  package Ada.Integer_Text_IO is new Ada.Text_IO.Integer_IO (Integer);
  ```

  - 其它整型输出如 Ada.Short_Integer_Text_IO 也都类似，真正的需要实现的只是 Ada.Text_IO.Integer_IO。其它的浮点型输出、模数输出也都建立在各自的类属程序包上。


##### 类属参数

- 类属参数有 3 类：类型参数(type parameter)，值参数(value parameter)，子程序参数(subprogram parameter)

###### 类型参数

- 类属类型吸引人的地方大家都有所体会了，但有些朋友可能在上面的例子中就想到假如 Swap 的参数是数组或其它什么来着会怎样---不是说类属类型可以由其它类型替换吗？但毫无疑问，仅凭上面这么简单的实现，就想接受所有的数据类型是不可能的。为了防止实例化时出现不合适的数据类型，我们可以指定类型参数的类别；当然编译器也会自动找出错误，不允许我们进行非法操作。

- 下面是类型参数的一些分类，各自有不同的限制条件：

  ```
  type T is private -- 限制最少，先前例子所采用的；
  type T is limited private -- 比前者略多一点限制；
  type T is (<>) -- T 一定要是离散类型；
  type T is range <> -- T 一定要是整型；
  type T is digits <> -- T 一定要为符点型；
  type T is delta <> -- T 一定要定点型；
  type T is array(index_type) of element_type --实际数组的成员类型一定要和形式数组的类型匹配；
  type T is access X -- T 指向类型 X，X 可以预先定义的类属参数；
  ```

###### 值参数

- 先前我们在类属部份都声明类型参数，供后面的程序使用，但是也可以直接声明某一变量：

  ```
  generic
  	type element is private;
  	size: positive := 200;
  package stack is
  	procedure push...
  	procedure pop...
  	function empty return boolean;
  end stack;
  package body stack is
  	size:integer;
  	theStack :array (1..size) of element;
  	...
  
  实例化新的程序包：
  package fred is new stack(element => integer, size => 50);
  或者
  package fred is new stack(integer,1000);
  或者
  package fred is new stack(integer);
  如果值参数没有默认值，实例化时一定要提供一个值。值参数也可以为字符串类型：
  ```

###### 子程序参数

- 我们也可以将一个子程序作为一个类属参数，见下：

  ```
  generic 
  	type element is limited private;
  	with function "="(e1,e2:element) return boolean;
  	with procedure assign(e1,e2:element);
  package stuff is...
  
  实例化一个程序包：
  package things is new stuff(person,text."=",text.assign);
  
  也可以有一个默认子程序：
  with procedure assign(e1,e2:element) is myAssign(e1,e2:person);   这个不是实例化，是一个类属，但是是默认和子程序
  或者
  with function "="(e1,e2:element ) return boolean is<>;  这个也是声明一个类属
  这样实例化时，如果"="函数没有函数提供，则会根据 element 的类型，自动选择一个"="函数，如 element是 Integer 类型，则会使用 Integer 的 "=" 函数。
  ```

  

#### 一些记录

##### and 和and then ，or 和 or else

- and在运算时两侧都会计算，不管第一天条件是否为FALSE，其他的一些语言例如c中&&在第一个条件为FALSE时第二个条件就不运算了。ada中用and then来进行类似的功能。or else也是类似，如果第一个为TRUE，第二个就不计算了。

##### renames

```
LOCAL_EVENT : FPL_LOCAL_EVENT_TYPES.EVENTS renames FPL_DISK.EVENT_LIST.TABLE(INDEX);
```

- 上面这种用法是让LOCAL_EVENT这个变量代替比较难写的FPL_DISK.EVENT_LIST.TABLE(INDEX)，FPL_DISK.EVENT_LIST.TABLE(INDEX)的类型就是FPL_LOCAL_EVENT_TYPES.EVENTS

##### 关于with

- with后面跟的不一定是一个程序包，也可以是一个procedure，这是经过在虚拟机上验证过的，我们可以在一个文件中写一个procedure，然后在主程序中with一下这个procedure，这样可以直接使用，不用use那个procedure。

##### 定义某个具体的CHARACTER

```
RESET_FIELD_STRING : constant STRING(1 .. 1) := ( 1 => CHARACTER'VAL(163));

ADA中CHARACTER是一个枚举类型，所以可以使用VAL属性来取某一个值。

ANY_ARG : constant CHARACTER := ASCII.NUL   对于一些前面的控制字符，已经定义好了我们可以直接使用，后面的一些没有定义，只能使用VAL来取。
NUL : constant Character := Character'Val (0);

CRCRLF : constant STRING := ASCII.CR & ASCII.CR & ASCII.LF
```

#### ADA与C的接口

```
function SET_EXTERNAL_CONF
    (FDEXM_RECEIVING_CHECKING_PERIOD : in SYSTEM.ADDRESS;
     HB_TRANSMISSION_PERIOD          : in SYSTEM.ADDRESS)

     return INTEGER_32;

  pragma INTERFACE (C, SET_EXTERNAL_CONF);
  pragma INTERFACE_NAME (SET_EXTERNAL_CONF, "COM_DPR_SetExternalConf");
```

- 如果在ADA中想用一个函数，但是函数是用c写的，我们就按上面这种方法，只需要声明一个ADA函数，然后在写上pragma这两行就可以，不需要写ADA函数的实现，相当于调用ADA函数时，直接用的C函数。如果c里面的变量类型为指针，则ada声明时需要用SYSTEM.ADDRESS

- 那个C的函数我们是需要自己写的。

- 另外如果变量类型为指针，我们不能直接使用其他文件中定义的全局变量，必须将那个变量在本文件中重新定义一份。

  ```
    C_ERROR_CODE := SET_EXTERNAL_CONF
         (FDEXM_RECEIVING_CHECKING_PERIOD => FDEXM_RECEIVING_CHECKING_PERIOD'ADDRESS,
          HB_TRANSMISSION_PERIOD          => HB_TRANSMISSION_PERIOD'ADDRESS
          );
  ```

  - 对于示例中的接口函数，不能直接使用dpr_common中定义的全局变量，必须在本文件中定义一个，然后'ADDRESS
  
  - 应该是我们只能用INTEGER_32类型的变量，dpr_common中的变量一般是subtype的，所以我们不能直接这样用，我们需要在本文件中定义一个INTEGER_32的变量，然后将dpr_common中的那个值赋值过来，这样就可以用了。如果dpr_common中的类型本来就是INTEGER_32就不用这样了，可以直接用ADDRESS取地址。
  - 上面好像也不对，用的时候测试着用吧，先直接取地址，不行再本地在定义一个INTEGER_32类型的值在赋值过来。
