#### 数组array

- 数组是一种复合数据类型(composite type)，包含多个同一种类型的数据元素。数组元素的名称用指定的 下标表示，这些下标是离散数。数组的值则是一个由这些元素的值构成的合成值(composite value)。Ada 下 的数组和其它语言很相似，只是多了一些“宽松”的规定，如无约束数组、动态数组，更加方便了用户。字 符串类型 String，Wide_String 等则是数组元素为字符型的数组类型

##### 简单数组simple array

```
type array_name is array (index specification) of type;
```

- 字段说明

  - array_name是该数组类型的名称
  - index specification指明该数组类型的元素下标
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

  - 这样 Path_Name 的长度就自动成为6。但如果

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