//1. База убеждений
maxDelay(500). // максимальная величина паузы между 
                  //порождением  2х клиентов.
maxAgentCounter(10). // максимальное количество 
                             //порождаемых клиентов.
agentCounter(0). // счетчик созданных клиентов.
completeCounter(0). // счетчик клиентов, завершивших свою 
                                  //работу.
sellers([seller1, seller2, seller3]). //список продавцов
!start. // начальная цель, инициализирующая работу генератора.

// 2. Планы по достижению целей
@g1
+!start: agentCounter(AC) & maxAgentCounter(MAC) &      
AC<MAC <-
	-+agentCounter(AC+1);
	?maxDelay(MD);
	?agentCounter(C);
	.wait(math.round(math.random(MD)));
	.concat("customer(",C,")",Name);  
	.create_agent(Name, "customer.asl"); 
	V=math.round(math.random(3))+1;   
	.send(Name, tell, orderValue(V));
	!!start.
/*
Если еще не создано заданное количество клиентов, то данный план рекурсивно
порождает клиентов и определяет им параметр «желаемое количество порций»
(orderValue), выдерживая случайную паузу. Строка 15 определяет условия активации
плана. План настроен на перехват события возникновения цели !start, после чего
проверяются контекстные ограничения. В них сначала происходит конкретизация переменных
АС и МАС посредством считывания из базы убеждений указанных предикатов, потом их
сравнение. В строке 16 увеличивается счетчик созданных клиентов. В строках 17 и 18
происходит считывание из базы убеждений значений максимально возможной паузы и
текущего значения счетчика клиентов. В строке 19 выдерживается случайная пауза,
величина которой вычисляется через обращение к функциям генерации случайных чисел
и округления, определенных в модуле math. В строке 20 из отдельных фрагментов
путем конкатенации собирается имя для порождаемого клиента. Это имя помещается
в переменную Name. В строке 21 происходит непосредственное создание нового клиента
с заданным именем, который работает по заданной программе, хранящейся в указанном
файле. В строке 8 происходит вычисление очередной случайной величины, которая
далее рассматривается как объем заказа клиента. В строке 23 генератор сообщает
только что созданному клиенту убеждение, в котором указан объем заказа. Строка
24 рекурсивно вызывает этот же самый план, причем в базе намерений создается для
него новый стек (т.к. используется оператор «!!»).
 */
	
@g2 +!start <-true.
/*
План «заглушка», который срабатывает, когда перестают выполняться контекстные
ограничения предыдущего плана.
 */


@g3[atomic]
+!finishMe[source(Agent)] <- 
	?completeCounter(C);
	-+completeCounter(C+1);
	.kill_agent(Agent).
/*
План завершает работу программного агента (клиента) по его запросу. Строка 54 задает
плану метку «g3» и приписывает к нему аннотацию «atomic», говорящую о том, что
выполнение данного плана не должно прерываться обработкой других намерений. Строка 55
* определяет условие активации плана. Здесь это событие возникновение цели
«!finishMe», которая поступает от агента «Agent», о чем и говориться в аннотации «source».
В строках 56 и 57 ведется подсчет количества завершивших работу клиентов. В строке 58
вызывается функция завершения работы агента.
 */


@g4[atomic]
+completeCounter(C): maxAgentCounter(X)& X==C <-
	.print("SIMULATION COMPLETE");
	?sellers(S);
	for (.member(Y,S)) 
		{ .send(Y, askOne, salesProceeds(Z),   salesProceeds(Z));
			.print("The  sales proceeds of ",Y," is ",Z)
		}.
/*
План срабатывает в конце процесса работы МАС. Он обрабатывает событие изменения
счетчика завершенных агентов  и выполняется, когда количество завершенных агентов
становится равно количеству созданных. В строке 73 из базы убеждений считывается
список продавцов. Строка 74 определяет заголовок цикла. Цикл выполняется, пока функция
«.member» возвращает true. Эта функция, применяемая в цикле подобным образом,
последовательно перебирает элементы списка и помещает их в переменную Y. Она возвращает
true до тех пор, пока список не кончится. Строки 75 и 76 описывают тело цикла. В строке 75
генератор запрашивает у продавца Y содержание убеждения «salesProceeds(Z)» и ожидает
ответа. После получения ответа в строке 76 выводится информация о выручке данного продавца.
 */

@g5
+!who_is_last<-true.
/* План «заглушка», обеспечивающий нейтральную реакцию генератора при получении цели
«who_is_last», поступающей всем агентам от покупателя. Иначе говоря, при возникновении
данной цели она считается автоматически достигнутой без выполнения каких-либо действий.
*/